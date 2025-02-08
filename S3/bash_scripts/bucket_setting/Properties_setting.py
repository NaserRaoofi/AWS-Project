import boto3
import sys
import logging
import json
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# AWS Region
REGION = "eu-west-2"

# Initialize AWS Client
s3 = boto3.client("s3", region_name=REGION)

def bucket_exists(bucket_name):
    """Check if an S3 bucket exists."""
    try:
        s3.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        error_code = e.response["Error"].get("Code")
        if error_code == "404":
            logging.error(f"❌ Bucket '{bucket_name}' does not exist.")
        else:
            logging.error(f"❌ AWS Error: {e}")
        return False

def enable_versioning(bucket_name):
    """Enables versioning on the bucket."""
    try:
        s3.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={"Status": "Enabled"}
        )
        logging.info(f"✅ Enabled versioning on bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable versioning: {e}")


def enable_encryption(bucket_name):
    """Enables AES-256 server-side encryption on the bucket."""
    encryption_config = {
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }
    try:
        s3.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration=encryption_config
        )
        logging.info(f"🔒 Enabled AES-256 encryption on bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable encryption: {e}")


def enable_logging(bucket_name, target_bucket, target_prefix="logs/"):
    """Enables access logging for the bucket."""
    try:
        s3.put_bucket_logging(
            Bucket=bucket_name,
            BucketLoggingStatus={
                "LoggingEnabled": {
                    "TargetBucket": target_bucket,
                    "TargetPrefix": target_prefix
                }
            }
        )
        logging.info(f"📝 Enabled logging for bucket '{bucket_name}' to '{target_bucket}/{target_prefix}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable logging: {e}")


def enable_transfer_acceleration(bucket_name):
    """Enables Transfer Acceleration for faster data transfers."""
    try:
        s3.put_bucket_accelerate_configuration(
            Bucket=bucket_name,
            AccelerateConfiguration={"Status": "Enabled"}
        )
        logging.info(f"⚡ Enabled transfer acceleration on bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable transfer acceleration: {e}")


def enable_requester_pays(bucket_name):
    """Enables requester pays, meaning the requester is charged for access."""
    try:
        s3.put_bucket_request_payment(
            Bucket=bucket_name,
            RequestPaymentConfiguration={"Payer": "Requester"}
        )
        logging.info(f"💰 Enabled requester pays on bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable requester pays: {e}")


def main():
    """Main function to configure necessary bucket settings."""
    bucket_name = input("Enter the S3 bucket name to configure: ").strip()
    
    if not bucket_exists(bucket_name):
        sys.exit(1)
    
    if input("Enable versioning? (y/N): ").strip().lower() == "y":
        enable_versioning(bucket_name)
    
    if input("Enable encryption? (y/N): ").strip().lower() == "y":
        enable_encryption(bucket_name)
    
    if input("Enable transfer acceleration? (y/N): ").strip().lower() == "y":
        enable_transfer_acceleration(bucket_name)
    
    if input("Enable requester pays? (y/N): ").strip().lower() == "y":
        enable_requester_pays(bucket_name)
    
    enable_logging_choice = input("Enable access logging? (y/N): ").strip().lower()
    if enable_logging_choice == "y":
        log_bucket = input("Enter the target bucket for logging: ").strip()
        enable_logging(bucket_name, log_bucket)

    logging.info("✅ Selected bucket settings have been applied.")

if __name__ == "__main__":
    main()
