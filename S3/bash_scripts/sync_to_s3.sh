#!/usr/bin/env bash

# Set your variables
BUCKET_NAME="demo-sirvan-v1"  # Your S3 bucket
LOCAL_DIR="/e/AWS Project/S3/files"  # Your correct local directory
S3_DIR="Home/users/"  # Your correct S3 directory

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI is not configured. Run 'aws configure' first."
    exit 1
fi

# Ensure the local directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "❌ Error: The directory '$LOCAL_DIR' does not exist."
    exit 1
fi

echo "🚀 Watching for changes in '$LOCAL_DIR'... (Press Ctrl+C to stop)"

# Function to sync files to S3
sync_files() {
    echo "🔄 Syncing '$LOCAL_DIR' to 's3://$BUCKET_NAME/$S3_DIR'..."
    aws s3 sync "$LOCAL_DIR" "s3://$BUCKET_NAME/$S3_DIR" --exact-timestamps
    if [ $? -eq 0 ]; then
        echo "✅ Sync completed successfully."
    else
        echo "❌ Sync failed."
    fi
}

# Initial sync
sync_files

# Watch for changes using inotifywait (Linux/macOS) or fswatch (alternative for macOS)
while true; do
    inotifywait -r -e modify,create,delete "$LOCAL_DIR" &>/dev/null
    sync_files
done
