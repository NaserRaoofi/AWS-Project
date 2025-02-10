resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  force_destroy = true  
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "s3_kms_key" {
  description         = "KMS Key for S3 Bucket Encryption"
  enable_key_rotation = true
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/${var.bucket_name}-encryption"
  target_key_id = aws_kms_key.s3_kms_key.id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_kms" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
    }
  }
}
