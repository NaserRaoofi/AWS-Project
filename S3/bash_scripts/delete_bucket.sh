#!/usr/bin/env bash

# Prompt the user to enter a bucket name
read -p "Enter the S3 bucket name to delete: " BUCKET_NAME

# Check if the user entered a name
if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided."
    exit 1
fi

echo "Checking if bucket '$BUCKET_NAME' exists..."

# Check if the bucket exists
EXISTING_BUCKET=$(aws s3api list-buckets --query "Buckets[?Name=='$BUCKET_NAME']" --output text)

if [ -z "$EXISTING_BUCKET" ]; then
    echo "❌ Bucket '$BUCKET_NAME' does not exist. Please enter a valid bucket name."
    exit 1
fi

# Ask for confirmation before deleting the bucket
read -p "⚠️ Are you sure you want to delete bucket '$BUCKET_NAME'? This action cannot be undone! (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Bucket deletion canceled."
    exit 0
fi

echo "🚀 Deleting bucket '$BUCKET_NAME'..."

# Empty the bucket before deletion (required for non-empty buckets)
aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json 2>/dev/null)" 2>/dev/null
aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' --output json 2>/dev/null)" 2>/dev/null

# Now delete the empty bucket
aws s3api delete-bucket --bucket "$BUCKET_NAME"

# Check if the bucket was deleted successfully
if [ $? -eq 0 ]; then
    echo "✅ Bucket '$BUCKET_NAME' deleted successfully."
else
    echo "❌ Failed to delete bucket '$BUCKET_NAME'. Make sure it's empty and you have the correct permissions."
    exit 1
fi
