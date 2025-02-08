#✔ Multi-threading for Faster Execution: Runs directory & object listing in parallel.
#✔ Better Error Handling: Detects missing credentials, bucket permissions, and API failures.
#✔ Sorting & Formatting: Lists files sorted by last modified date and displays size in KB.
#✔ File Type Filtering: Allows optional filtering by file extension (e.g., .jpg, .csv).
#✔ Security Enhancements: Ensures access permissions before running.
#✔ User Confirmation: Warns user if the bucket name isn't found in AWS.

import boto3
import sys
import logging
from concurrent.futures import ThreadPoolExecutor
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Initialize S3 client
s3 = boto3.client("s3")

def list_s3_buckets():
    """Lists all available S3 buckets."""
    try:
        response = s3.list_buckets()
        buckets = [bucket["Name"] for bucket in response.get("Buckets", [])]
        if buckets:
            print("\n📂 Available S3 Buckets:")
            for bucket in buckets:
                print(f"- {bucket}")
            return buckets
        else:
            print("⚠ No buckets found in your AWS account.")
            sys.exit(1)
    except (NoCredentialsError, PartialCredentialsError) as e:
        logging.error("❌ AWS credentials not configured properly.")
        sys.exit(1)
    except Exception as e:
        logging.error(f"❌ Error fetching buckets: {e}")
        sys.exit(1)

def check_bucket_exists(bucket_name):
    """Checks if an S3 bucket exists."""
    try:
        s3.head_bucket(Bucket=bucket_name)
        print(f"🔍 Checking if bucket '{bucket_name}' exists... ✅")
        return True
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            print(f"❌ Error: Bucket '{bucket_name}' does not exist.")
        elif e.response["Error"]["Code"] == "403":
            print(f"❌ Error: Access denied to bucket '{bucket_name}'. Check permissions.")
        else:
            print(f"❌ Unexpected error: {e}")
        sys.exit(1)

def list_directories(bucket_name):
    """Lists directories (folders) in an S3 bucket."""
    print(f"\n📁 Listing directories in 's3://{bucket_name}/'...")
    try:
        response = s3.list_objects_v2(Bucket=bucket_name, Delimiter="/")
        folders = [prefix["Prefix"].rstrip("/") for prefix in response.get("CommonPrefixes", [])]  # Remove trailing slashes

        if folders:
            for folder in folders:
                print(f"- {folder}")
        else:
            print("⚠ No directories found.")
    except Exception as e:
        logging.error(f"❌ Error fetching directories: {e}")

def list_objects(bucket_name, file_extension=None):
    """Lists files in an S3 bucket, excluding folders."""
    print(f"\n📄 Listing objects (files) in 's3://{bucket_name}/'...")
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        files = response.get("Contents", [])

        if not files:
            print("⚠ No files found.")
            return

        sorted_files = sorted(files, key=lambda x: x["LastModified"], reverse=True)

        for obj in sorted_files:
            key = obj["Key"]

            # **EXCLUDE FOLDERS from the object list** (folders have `/` at the end)
            if key.endswith("/"):
                continue

            size = round(obj["Size"] / 1024, 2)  # Convert bytes to KB
            last_modified = obj["LastModified"].strftime("%Y-%m-%d %H:%M:%S")

            # Apply file extension filter
            if file_extension and not key.endswith(file_extension):
                continue  # Skip files that don't match the extension filter

            # **Remove "Home/" or "Home/users/" prefix from filenames**
            cleaned_key = key.replace("Home/users/", "").replace("Home/", "")

            print(f"- {cleaned_key} | {size} KB | Last Modified: {last_modified}")

    except Exception as e:
        logging.error(f"❌ Error fetching files: {e}")

def main():
    """Main function to execute the script."""
    buckets = list_s3_buckets()
    
    # Get user input for bucket name
    bucket_name = input("\nEnter the S3 bucket name to list contents: ").strip()
    
    if bucket_name not in buckets:
        print(f"⚠ Warning: The bucket '{bucket_name}' was not found in your AWS account.")
        confirm = input("Do you want to continue? (y/N): ").strip().lower()
        if confirm != "y":
            print("❌ Operation cancelled.")
            sys.exit(1)

    check_bucket_exists(bucket_name)

    # Ask if the user wants to filter by file type
    filter_extension = input("Enter a file extension to filter (or press Enter to list all files): ").strip()
    filter_extension = filter_extension if filter_extension else None

    # Run directory and object listing in parallel for efficiency
    with ThreadPoolExecutor() as executor:
        executor.submit(list_directories, bucket_name)  # This now correctly lists directories
        executor.submit(list_objects, bucket_name, filter_extension)

    print("\n✅ Done!")

if __name__ == "__main__":
    main()
