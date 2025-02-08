
#🔍 What This Script Does
#✅ Monitors Object Access Patterns – Tracks how often objects in the bucket are accessed.
#✅ Generates Analytics Reports – Exports CSV data to the destination bucket for analysis.
#✅ Helps Identify Storage Optimization Opportunities – Suggests which objects can be moved to cheaper storage classes (like Glacier, Intelligent-Tiering, etc.).

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

def enable_storage_class_analysis(bucket_name, destination_bucket, config_id="AnalysisConfig", prefix=None):
    """Enable Storage Class Analysis on the given S3 bucket with a valid destination bucket."""
    analysis_config = {
        "Id": config_id,
        "StorageClassAnalysis": {
            "DataExport": {
                "OutputSchemaVersion": "V_1",
                "Destination": {
                    "S3BucketDestination": {
                        "Format": "CSV",
                        "Bucket": f"arn:aws:s3:::{destination_bucket}",  # Destination bucket must be different
                        "Prefix": f"storage-analysis/{config_id}/"
                    }
                }
            }
        }
    }
    
    if prefix:
        analysis_config["Prefix"] = prefix
    
    try:
        s3.put_bucket_analytics_configuration(
            Bucket=bucket_name,
            Id=config_id,
            AnalyticsConfiguration=analysis_config
        )
        logging.info(f"📊 Enabled Storage Class Analysis for bucket '{bucket_name}', exporting to '{destination_bucket}'.")
    except ClientError as e:
        logging.error(f"❌ Failed to enable Storage Class Analysis: {e}")


def main():
    """Main function to configure Storage Class Analysis."""
    bucket_name = input("Enter the S3 bucket name: ").strip()
    
    if not bucket_exists(bucket_name):
        sys.exit(1)
    
    enable_analysis = input("Do you want to enable Storage Class Analysis on this bucket? (y/N): ").strip().lower()
    if enable_analysis == "y":
        destination_bucket = input("Enter the destination bucket for analytics data: ").strip()
        if not bucket_exists(destination_bucket):
            logging.error("❌ The destination bucket does not exist or is inaccessible.")
            sys.exit(1)
        prefix = input("Enter a prefix to analyze (or press Enter for full bucket analysis): ").strip()
        prefix = prefix if prefix else None
        enable_storage_class_analysis(bucket_name, destination_bucket, prefix=prefix)
    
    logging.info("✅ Storage Class Analysis configuration completed.")

if __name__ == "__main__":
    main()
