output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}

output "kms_key_arn" {
  description = "KMS Key ARN used for bucket encryption"
  value       = aws_kms_key.s3_kms_key.arn
}
