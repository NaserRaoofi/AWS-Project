AWS S3 Management Scripts

📌 Overview

This repository contains advanced AWS S3 automation scripts using boto3 and aws s3api to efficiently manage S3 buckets. These scripts handle lifecycle policies, replication, security, storage optimization, and automation.

🚀 Features

✅ Lifecycle Management – Moves old objects to cheaper storage like Glacier & deletes expired data.✅ Replication Rules – Automatically copies data between buckets for backup and disaster recovery.✅ Inventory Tracking – Monitors stored objects and generates CSV reports.✅ Storage Class Analysis – Identifies underused objects to optimize storage costs.✅ Security Enhancements – Blocks public access, enables encryption, and enforces secure transport.✅ File Upload & Directory Syncing – Automates data transfers to S3.✅ Bucket Management – Lists, creates, and deletes S3 buckets programmatically.

📂 Project Structure

AWS-S3-Management/
├── S3/
│   ├── bash_scripts/
│   ├── bucket_setting/
│   │   ├── Management_setting.py        # Configures lifecycle, replication, inventory tracking
│   │   ├── Metrics_setting.py           # Configures storage class analysis and bucket metrics
│   │   ├── Permissions_setting.py       # Manages bucket ACLs, policies, and public access blocking
│   │   ├── Properties_setting.py        # Configures bucket properties such as encryption, logging, etc.
│   ├── create_bucket.sh                # Creates a new S3 bucket
│   ├── create_s3_bucket.py             # Python version of S3 bucket creation
│   ├── delete_bucket.sh                # Deletes an S3 bucket after emptying it
│   ├── list_s3_contents.py             # Lists files and folders in an S3 bucket
│   ├── list_s3_contents.sh             # Bash script to list bucket contents
│   ├── sync_to_s3.sh                   # Syncs a local directory to an S3 bucket
│   ├── upload_files.sh                 # Uploads single/multiple files to S3
├── files/                               # Directory for storing test data
├── README.md                            # Project documentation

⚡ Installation

Make sure you have AWS CLI and boto3 installed before running the scripts.

pip install boto3
aws configure  # Set up AWS credentials

📜 Usage

1️⃣ Apply Lifecycle Policies

python S3/bucket_setting/Management_setting.py

2️⃣ Configure Storage Class Analysis & Metrics

python S3/bucket_setting/Metrics_setting.py

3️⃣ Configure Bucket Permissions & Security

python S3/bucket_setting/Permissions_setting.py

4️⃣ Configure Bucket Properties

python S3/bucket_setting/Properties_setting.py

5️⃣ Upload Files to S3

./S3/upload_files.sh

6️⃣ Sync a Local Directory to S3

./S3/sync_to_s3.sh

7️⃣ Delete an S3 Bucket

./S3/delete_bucket.sh

8️⃣ Create an S3 Bucket

python S3/create_s3_bucket.py

9️⃣ List Bucket Contents

python S3/list_s3_contents.py

🤝 Contributing

Feel free to submit issues and pull requests to improve these scripts! 🚀

📜 License

This project is open-source and available under the MIT License.

📌 GitHub: https://github.com/NaserRaoofi
📌 LinkedIn: www.linkedin.com/in/naser-raoofi
