output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.route53_handler.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.ec2_state_changes.arn
}

output "cloudwatch_event_rule" {
  description = "The name of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.ec2_state_change.name
}
