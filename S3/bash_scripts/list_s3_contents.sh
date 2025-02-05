#!/usr/bin/env bash

# List all S3 buckets
echo "📂 Available S3 Buckets:"
aws s3api list-buckets --query "Buckets[].Name" --output text

# Prompt user for the S3 bucket name
read -p "Enter the S3 bucket name to list contents: " BUCKET_NAME

# Check if the bucket name is provided
if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided."
    exit 1
fi

echo "🔍 Checking if bucket '$BUCKET_NAME' exists..."
EXISTING_BUCKET=$(aws s3api head-bucket --bucket "$BUCKET_NAME" 2>&1)

if [[ $? -ne 0 ]]; then
    echo "❌ Error: Bucket '$BUCKET_NAME' does not exist or you don't have permission to access it."
    exit 1
fi

# List directories (folders) correctly
echo "📁 Listing directories in 's3://$BUCKET_NAME/'..."
aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --delimiter "/" --query "CommonPrefixes[].Prefix" --output text

# List actual files (excluding folders)
echo "📄 Listing objects (files) in 's3://$BUCKET_NAME/'..."
aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --query "Contents[].Key" --output text

echo "✅ Done!"
