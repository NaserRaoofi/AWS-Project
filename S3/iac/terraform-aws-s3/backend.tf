terraform {
  backend "s3" {
    bucket         = "demo-sirvan-v1"  # Use your existing S3 bucket
    key            = "terraform/state.tfstate"
    region         = "eu-west-2"  # Match the bucket's region
    encrypt        = true
  }
}
