#Block Public Access → Restricts unauthorized public access.
#Bucket Policy (Secure Transport) → Enforces secure HTTPS-only access.
#Object Ownership → Ensures bucket owner control.
#ACL (Access Control List) → Sets bucket ACL to private.
#CORS (Cross-Origin Resource Sharing) → Configures access from other domains.

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

def block_public_access(bucket_name):
    """Blocks all public access to the bucket."""
    try:
        s3.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                "BlockPublicAcls": True,
                "IgnorePublicAcls": True,
                "BlockPublicPolicy": True,
                "RestrictPublicBuckets": True
            }
        )
        logging.info(f"🚫 Blocked public access for bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to block public access: {e}")

def set_bucket_policy(bucket_name):
    """Applies a sample security-focused bucket policy."""
    policy = {
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                f"arn:aws:s3:::{bucket_name}",
                f"arn:aws:s3:::{bucket_name}/*"
            ],
            "Condition": {
                "Bool": {"aws:SecureTransport": "false"}
            }
        }]
    }
    try:
        s3.put_bucket_policy(Bucket=bucket_name, Policy=json.dumps(policy))
        logging.info(f"🔒 Applied bucket policy to '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to apply bucket policy: {e}")

def set_object_ownership(bucket_name):
    """Sets Object Ownership to Bucket Owner Enforced."""
    try:
        s3.put_bucket_ownership_controls(
            Bucket=bucket_name,
            OwnershipControls={
                "Rules": [{"ObjectOwnership": "BucketOwnerEnforced"}]
            }
        )
        logging.info(f"👤 Set object ownership to 'BucketOwnerEnforced' for '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to set object ownership: {e}")

def set_acl(bucket_name):
    """Sets ACL to private."""
    try:
        s3.put_bucket_acl(Bucket=bucket_name, ACL="private")
        logging.info(f"🔒 Set ACL to private for bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to set ACL: {e}")

def configure_cors(bucket_name):
    """Configures CORS for cross-origin access."""
    cors_configuration = {
        "CORSRules": [{
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET"],
            "AllowedOrigins": ["*"]
        }]
    }
    try:
        s3.put_bucket_cors(Bucket=bucket_name, CORSConfiguration=cors_configuration)
        logging.info(f"🌍 Configured CORS for bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to configure CORS: {e}")

def main():
    """Main function to configure bucket permissions settings."""
    bucket_name = input("Enter the S3 bucket name to configure permissions: ").strip()
    
    if not bucket_exists(bucket_name):
        sys.exit(1)
    
    if input("Block public access? (y/N): ").strip().lower() == "y":
        block_public_access(bucket_name)
    
    if input("Set a bucket policy for secure transport? (y/N): ").strip().lower() == "y":
        set_bucket_policy(bucket_name)
    
    if input("Set object ownership to Bucket Owner Enforced? (y/N): ").strip().lower() == "y":
        set_object_ownership(bucket_name)
    
    if input("Set ACL to private? (y/N): ").strip().lower() == "y":
        set_acl(bucket_name)
    
    if input("Configure CORS for cross-origin access? (y/N): ").strip().lower() == "y":
        configure_cors(bucket_name)

    logging.info("✅ Selected bucket permission settings have been applied.")

if __name__ == "__main__":
    main()
