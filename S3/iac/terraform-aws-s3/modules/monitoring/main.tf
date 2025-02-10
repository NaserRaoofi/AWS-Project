# Create a dedicated logging bucket for S3 logs
resource "aws_s3_bucket" "s3_logging" {
  bucket         = "${var.bucket_name}-logs"
  force_destroy = true  # Allows bucket deletion during testing
}

# Enable logging for the main S3 bucket
resource "aws_s3_bucket_logging" "s3_logging" {
  bucket        = var.bucket_name
  target_bucket = aws_s3_bucket.s3_logging.id
  target_prefix = "logs/"
}

# Apply a strict S3 bucket policy to allow only S3 logging service access
resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.s3_logging.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logging.s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.s3_logging.id}/*"
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.s3_logging.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3_logging.id}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

# CloudWatch Alarm for high S3 request count
resource "aws_cloudwatch_metric_alarm" "s3_high_request_count" {
  alarm_name          = "${var.bucket_name}-high-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Sum"
  threshold           = 10000  # Alert if more than 10,000 requests
  alarm_description   = "Triggers when S3 request count is too high"
  alarm_actions       = [aws_sns_topic.s3_alerts.arn]

  dimensions = {
    BucketName  = var.bucket_name
    StorageType = "AllStorageTypes"
  }
}

# SNS Topic for CloudWatch Alerts
resource "aws_sns_topic" "s3_alerts" {
  name = "${var.bucket_name}-alerts"
}

# Subscription for SNS (Sends alerts to an email)
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.s3_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
