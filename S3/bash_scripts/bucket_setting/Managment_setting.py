import boto3
import logging
import sys
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# AWS Region
REGION = "eu-west-2"

# Initialize AWS S3 client
s3 = boto3.client("s3", region_name=REGION)

def bucket_exists(bucket_name):
    """Check if an S3 bucket exists."""
    try:
        s3.head_bucket(Bucket=bucket_name)
        return True
    except ClientError as e:
        logging.error(f"❌ Bucket '{bucket_name}' does not exist or access denied.")
        return False

def enable_versioning(bucket_name):
    """Enable versioning on an S3 bucket (required for replication)."""
    try:
        s3.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={"Status": "Enabled"}
        )
        logging.info(f"✅ Enabled versioning on bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable versioning: {e}")

# ================= Lifecycle Configuration =================
def apply_lifecycle_policy(bucket_name):
    """Apply a lifecycle policy to optimize storage costs."""
    lifecycle_policy = {
        "Rules": [
            {
                "ID": "TransitionToGlacier",
                "Filter": {"Prefix": ""},  # Applies to all objects
                "Status": "Enabled",
                "Transitions": [
                    {"Days": 30, "StorageClass": "STANDARD_IA"},
                    {"Days": 90, "StorageClass": "GLACIER"}
                ],
                "Expiration": {"Days": 365}  # Deletes objects after 1 year
            }
        ]
    }
    
    try:
        s3.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration={"Rules": lifecycle_policy["Rules"]}
        )
        logging.info(f"🔄 Applied Lifecycle Policy to bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to apply lifecycle policy: {e}")

# ================= Replication Rules =================
def apply_replication_rules(bucket_name, destination_bucket):
    """Apply replication rules to replicate data to another bucket."""
    enable_versioning(bucket_name)
    enable_versioning(destination_bucket)
    
    replication_config = {
        "Role": "arn:aws:iam::YOUR_ACCOUNT_ID:role/s3-replication-role",  # Replace with your IAM Role
        "Rules": [
            {
                "ID": "ReplicationRule",
                "Status": "Enabled",
                "Priority": 1,
                "DeleteMarkerReplication": {"Status": "Disabled"},
                "Filter": {},
                "Destination": {
                    "Bucket": f"arn:aws:s3:::{destination_bucket}",
                    "StorageClass": "STANDARD"
                }
            }
        ]
    }
    
    try:
        s3.put_bucket_replication_configuration(
            Bucket=bucket_name,
            ReplicationConfiguration=replication_config
        )
        logging.info(f"🔄 Applied Replication Rule: '{bucket_name}' → '{destination_bucket}'")
    except ClientError as e:
        logging.error(f"❌ Failed to apply replication rule: {e}")

# ================= Inventory Configuration =================
def apply_inventory_configuration(bucket_name):
    """Apply inventory configuration to track stored objects."""
    inventory_config = {
        "Id": "InventoryConfig",
        "IsEnabled": True,
        "IncludedObjectVersions": "All",
        "Schedule": {"Frequency": "Daily"},
        "Destination": {
            "S3BucketDestination": {
                "Bucket": f"arn:aws:s3:::{bucket_name}",
                "Format": "CSV"
            }
        }
    }
    
    try:
        s3.put_bucket_inventory_configuration(
            Bucket=bucket_name,
            Id="InventoryConfig",
            InventoryConfiguration=inventory_config
        )
        logging.info(f"📊 Applied Inventory Configuration for bucket '{bucket_name}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to apply inventory configuration: {e}")

# ================= Main Function =================
def main():
    """Main function to configure S3 Management Settings."""
    bucket_name = input("Enter the S3 bucket name to configure settings: ").strip()
    
    if not bucket_exists(bucket_name):
        sys.exit(1)
    
    if input("Do you want to apply Lifecycle Configuration? (y/N): ").strip().lower() == "y":
        apply_lifecycle_policy(bucket_name)
    
    if input("Do you want to apply Replication Rules? (y/N): ").strip().lower() == "y":
        destination_bucket = input("Enter the destination bucket for replication: ").strip()
        if not bucket_exists(destination_bucket):
            logging.error("❌ The destination bucket does not exist or is inaccessible.")
            sys.exit(1)
        apply_replication_rules(bucket_name, destination_bucket)
    
    if input("Do you want to apply Inventory Configuration? (y/N): ").strip().lower() == "y":
        apply_inventory_configuration(bucket_name)
    
    logging.info("✅ S3 Management Configuration completed.")

if __name__ == "__main__":
    main()
