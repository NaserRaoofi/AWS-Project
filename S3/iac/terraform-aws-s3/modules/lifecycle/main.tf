resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = var.bucket_name  

  rule {
    id     = "move-to-glacier"
    status = "Enabled"

    filter {
      prefix = "archive/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"  
    }

    transition {
      days          = 60
      storage_class = "ONEZONE_IA"  # Move to One Zone-IA after 60 days
    }

    transition {
      days          = 90
      storage_class = "GLACIER"  
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"  
    }

    expiration {
      days = 400  # Automatically delete objects after 400 days
    }
  }

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90  # Delete noncurrent versions after 90 days
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }

  rule {
    id     = "delete-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7  
    }
  }
}
