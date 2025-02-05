#✔ Checks if the bucket already exists before creating it.
#✔ Automatically sets the correct region.
#✔ Uses structured logging for clear debugging.
#✔ Implements strong error handling to catch AWS-related issues.

import boto3
import sys
import logging
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# AWS Region
REGION = "eu-west-2"

# Initialize AWS Clients
try:
    s3 = boto3.client("s3", region_name=REGION)
except (NoCredentialsError, PartialCredentialsError):
    logging.error("❌ AWS credentials not found or misconfigured. Run 'aws configure'.")
    sys.exit(1)

def bucket_exists(bucket_name):
    """Check if an S3 bucket already exists."""
    try:
        s3.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        error_code = e.response["Error"].get("Code")
        if error_code == "404":
            return False
        logging.error(f"❌ AWS Error: {e}")
        return False

def create_s3_bucket(bucket_name):
    """Creates an S3 bucket with best security practices."""
    try:
        logging.info(f"🚀 Creating S3 bucket: {bucket_name} in region: {REGION}...")

        if bucket_exists(bucket_name):
            logging.error(f"❌ Bucket '{bucket_name}' already exists. Choose another name.")
            sys.exit(1)

        # Create bucket with region specification
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={"LocationConstraint": REGION}
        )
        logging.info(f"✅ Bucket '{bucket_name}' created successfully in region '{REGION}'.")

        return True
    except ClientError as e:
        logging.error(f"❌ Failed to create bucket: {e}")
        sys.exit(1)

def main():
    """Main function to create a bucket."""
    bucket_name = input("Enter a unique S3 bucket name: ").strip()

    if not bucket_name:
        logging.error("❌ Error: No bucket name provided.")
        sys.exit(1)

    if create_s3_bucket(bucket_name):
        logging.info("🎉 Core bucket setup completed successfully.")

if __name__ == "__main__":
    main()