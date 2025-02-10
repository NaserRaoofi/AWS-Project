variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for S3 encryption"
  type        = string
}
