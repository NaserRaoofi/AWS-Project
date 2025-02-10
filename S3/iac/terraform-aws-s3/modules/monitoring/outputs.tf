output "cloudwatch_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.s3_high_request_count.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.s3_alerts.arn
}

