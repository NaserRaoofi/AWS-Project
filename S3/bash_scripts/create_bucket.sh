#!/usr/bin/env bash

# Prompt the user to enter a bucket name
read -p "Enter a unique S3 bucket name: " BUCKET_NAME

# Check if the user entered a name
if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided."
    exit 1
fi

REGION="eu-west-2"

echo "Creating S3 bucket: $BUCKET_NAME in region: $REGION..."

# Check if the bucket already exists
EXISTING_BUCKET=$(aws s3api list-buckets --query "Buckets[?Name=='$BUCKET_NAME']" --output text)

if [ -n "$EXISTING_BUCKET" ]; then
    echo "❌ Bucket '$BUCKET_NAME' already exists. Please choose another name."
    exit 1
fi

# Create the S3 bucket with region specification
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

# Check if the bucket was created successfully
if [ $? -eq 0 ]; then
    echo "✅ Bucket '$BUCKET_NAME' created successfully in region '$REGION'."
else
    echo "❌ Failed to create bucket. Check AWS CLI permissions and region."
    exit 1
fi
