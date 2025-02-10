output "lifecycle_configuration_status" {
  description = "Lifecycle Configuration Status"
  value       = aws_s3_bucket_lifecycle_configuration.s3_lifecycle.rule[*].status
}
