#!/usr/bin/env bash

# Ask user for VPC ID
read -p "Enter the VPC ID you want to delete: " VPC_ID

# Check if VPC ID is entered
if [ -z "$VPC_ID" ]; then
    echo "❌ ERROR: No VPC ID provided. Exiting."
    exit 1
fi

echo "🔍 Checking VPC resources before deletion..."

# Delete Subnets
echo "🛑 Deleting Subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
if [ -n "$SUBNET_IDS" ]; then
    echo "Deleting subnets: $SUBNET_IDS"
    echo "$SUBNET_IDS" | xargs -I {} aws ec2 delete-subnet --subnet-id {}
else
    echo "✅ No subnets found."
fi

# Detach and Delete Internet Gateway
echo "🛑 Detaching & Deleting Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text)
if [ -n "$IGW_ID" ]; then
    echo "Detaching and deleting IGW: $IGW_ID"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
else
    echo "✅ No Internet Gateway found."
fi

# Delete Route Tables (Except Main)
echo "🛑 Deleting Route Tables..."
RTB_IDS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?Associations[?Main!=true]].RouteTableId" --output text)
if [ -n "$RTB_IDS" ]; then
    echo "Deleting route tables: $RTB_IDS"
    echo "$RTB_IDS" | xargs -I {} aws ec2 delete-route-table --route-table-id {}
else
    echo "✅ No additional route tables found."
fi

# Delete Security Groups (Except Default)
echo "🛑 Deleting Security Groups..."
SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
if [ -n "$SG_IDS" ]; then
    echo "Deleting security groups: $SG_IDS"
    echo "$SG_IDS" | xargs -I {} aws ec2 delete-security-group --group-id {}
else
    echo "✅ No custom security groups found."
fi

# Terminate EC2 Instances (If Any)
echo "🛑 Terminating EC2 Instances..."
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_IDS" ]; then
    echo "Terminating EC2 instances: $INSTANCE_IDS"
    echo "$INSTANCE_IDS" | xargs -I {} aws ec2 terminate-instances --instance-ids {}
else
    echo "✅ No EC2 instances found."
fi

# Finally, Delete the VPC
echo "🛑 Deleting VPC: $VPC_ID..."
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "✅ VPC $VPC_ID Deleted Successfully!"
