# Terraform AWS S3 Project

## Overview
This Terraform project automates the creation and management of AWS S3 buckets.

## Structure
- `main.tf` → Defines the AWS provider.
- `variables.tf` → Stores global input variables.
- `outputs.tf` → Outputs bucket details.
- `backend.tf` → Configures Terraform remote state storage.
- `providers.tf` → Manages provider settings.
- `terraform.tfvars` → Stores default variable values.

## Usage
1. **Initialize Terraform**
   ```sh
   terraform init
