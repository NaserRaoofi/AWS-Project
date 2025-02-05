#!/usr/bin/env bash

# Prompt user for the S3 bucket name
read -p "Enter the S3 bucket name: " BUCKET_NAME

# Check if the bucket name is provided
if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided."
    exit 1
fi

# Prompt user for the S3 folder (prefix)
read -p "Enter the folder (prefix) where files should be uploaded (or leave empty for root): " FOLDER

# Remove trailing slashes to standardize folder structure
FOLDER=$(echo "$FOLDER" | sed 's:/*$::')

# Keep asking for a valid file or directory until the user provides one
while true; do
    read -p "Enter the full path of the file or directory to upload: " LOCAL_PATH

    # Check if the local file/directory exists
    if [ -e "$LOCAL_PATH" ]; then
        break  # Exit the loop if the path exists
    else
        echo "❌ Error: The file or directory '$LOCAL_PATH' does not exist. Please enter a valid path."
    fi
done

# Function to upload a single file
upload_file() {
    local FILE_PATH="$1"
    local FILE_NAME=$(basename "$FILE_PATH")

    if [ -n "$FOLDER" ]; then
        S3_KEY="$FOLDER/$FILE_NAME"
    else
        S3_KEY="$FILE_NAME"
    fi

    echo "🚀 Uploading '$FILE_NAME' to S3://$BUCKET_NAME/$S3_KEY ..."
    aws s3api put-object --bucket "$BUCKET_NAME" --key "$S3_KEY" --body "$FILE_PATH"

    if [ $? -eq 0 ]; then
        echo "✅ Uploaded '$FILE_NAME' successfully."
    else
        echo "❌ Failed to upload '$FILE_NAME'."
    fi
}

# Check if LOCAL_PATH is a directory or file
if [ -d "$LOCAL_PATH" ]; then
    echo "📂 Detected a directory. Uploading all files inside..."
    
    # Loop through each file in the directory
    for FILE in "$LOCAL_PATH"/*; do
        if [ -f "$FILE" ]; then
            upload_file "$FILE"
        fi
    done
else
    # Upload single file
    upload_file "$LOCAL_PATH"
fi

echo "✅ Upload process completed."
