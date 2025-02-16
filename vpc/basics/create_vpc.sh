#!/usr/bin/env bash

# Function to validate CIDR format
validate_cidr() {
    local CIDR=$1
    if [[ ! "$CIDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]{1,2})$ ]]; then
        echo "❌ ERROR: Invalid CIDR format! Example: 10.0.0.0/16"
        return 1
    fi
    return 0
}

# Function to validate AWS Region
validate_region() {
    local REGION=$1
    VALID_REGIONS=("us-east-1" "us-west-2" "eu-west-2" "ap-southeast-1" "ap-northeast-1")
    if [[ ! " ${VALID_REGIONS[@]} " =~ " ${REGION} " ]]; then
        echo "❌ ERROR: Invalid AWS region! Example: eu-west-2"
        return 1
    fi
    return 0
}

# Ask user for AWS Region
while true; do
    read -p "Enter AWS Region (e.g., eu-west-2): " AWS_REGION
    validate_region "$AWS_REGION" && break
done

# Ask user for VPC CIDR Block
while true; do
    read -p "Enter VPC CIDR Block (e.g., 10.0.0.0/16): " VPC_CIDR
    validate_cidr "$VPC_CIDR" && break
done

# Ask user for VPC Tag Name
read -p "Enter VPC Tag Name (e.g., MyCustomVPC): " VPC_TAG

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $AWS_REGION --query "Vpc.VpcId" --output text)

if [ -z "$VPC_ID" ]; then
    echo "❌ ERROR: Failed to create VPC."
    exit 1
fi
echo "✅ VPC Created Successfully: $VPC_ID"

# Add a Custom Tag (User-Provided Name)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value="$VPC_TAG" --region $AWS_REGION
echo "🏷️  Added tag: Name=$VPC_TAG"

# Enable DNS Support & Hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}" --region $AWS_REGION
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}" --region $AWS_REGION
echo "🛠️  Enabled DNS Support & Hostnames"

# Ask user if they want to create an Internet Gateway
read -p "Do you want to attach an Internet Gateway to this VPC? (yes/no): " ATTACH_IGW
if [[ "$ATTACH_IGW" == "yes" ]]; then
    IGW_ID=$(aws ec2 create-internet-gateway --region $AWS_REGION --query "InternetGateway.InternetGatewayId" --output text)
    aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $AWS_REGION
    aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value="${VPC_TAG}-IGW" --region $AWS_REGION
    echo "🌐 Internet Gateway Created & Attached: $IGW_ID"
fi

# Ask user how many subnets they want to create
read -p "How many subnets do you want to create? " SUBNET_COUNT

# Create multiple subnets
declare -a SUBNET_IDS=()
declare -a PUBLIC_SUBNET_IDS=()

for (( i=1; i<=SUBNET_COUNT; i++ ))
do
    echo "🔹 Configuring Subnet #$i"

    # Ask user for Subnet CIDR Block (until valid)
    while true; do
        read -p "Enter Subnet #$i CIDR Block (must be inside $VPC_CIDR, e.g., 10.0.1.0/24): " SUBNET_CIDR
        validate_cidr "$SUBNET_CIDR" && break
    done

    # Ask for Availability Zone
    read -p "Enter Availability Zone for Subnet #$i (e.g., eu-west-2a): " SUBNET_AZ

    # Ask for Subnet Tag Name
    read -p "Enter Subnet #$i Tag Name (e.g., PublicSubnet1): " SUBNET_TAG

    # Ask if the subnet is public or private
    read -p "Should Subnet #$i be Public? (yes/no): " SUBNET_TYPE

    # Create Subnet
    SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --availability-zone $SUBNET_AZ --region $AWS_REGION --query "Subnet.SubnetId" --output text)

    if [ -z "$SUBNET_ID" ]; then
        echo "❌ ERROR: Failed to create Subnet #$i."
        exit 1
    fi
    echo "✅ Subnet #$i Created Successfully: $SUBNET_ID"

    # Add a Custom Tag to the Subnet
    aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value="$SUBNET_TAG" --region $AWS_REGION
    echo "🏷️  Added tag: Name=$SUBNET_TAG"

    # If public subnet, enable auto-assign public IP
    if [[ "$SUBNET_TYPE" == "yes" ]]; then
        aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch
        echo "🌍 Subnet #$i is Public and will auto-assign public IPs."
        PUBLIC_SUBNET_IDS+=("$SUBNET_ID")
    else
        echo "🔒 Subnet #$i is Private."
    fi

    # Store the subnet ID
    SUBNET_IDS+=("$SUBNET_ID")
done

# If public subnets exist, create and associate a Route Table
if [[ "$ATTACH_IGW" == "yes" && ${#PUBLIC_SUBNET_IDS[@]} -gt 0 ]]; then
    RTB_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $AWS_REGION --query "RouteTable.RouteTableId" --output text)
    aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block "0.0.0.0/0" --gateway-id $IGW_ID --region $AWS_REGION
    aws ec2 create-tags --resources $RTB_ID --tags Key=Name,Value="${VPC_TAG}-Public-RTB" --region $AWS_REGION

    for SUBNET_ID in "${PUBLIC_SUBNET_IDS[@]}"; do
        aws ec2 associate-route-table --route-table-id $RTB_ID --subnet-id $SUBNET_ID --region $AWS_REGION
    done

    echo "📡 Public Route Table Created & Associated: $RTB_ID"
fi

echo "✅ AWS VPC & Network Setup Complete!"
