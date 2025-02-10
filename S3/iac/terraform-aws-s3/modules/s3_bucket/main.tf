resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name  # Uses a variable for flexibility
  force_destroy = true  # Allows Terraform to delete the bucket (for testing)
}
