variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
}
