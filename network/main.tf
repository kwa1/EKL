provider "aws" {
  region = "eu-west-1"
}

# Variables
variable "lambda_s3_bucket" {}
variable "lambda_s3_key" {}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "lambda-route53-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-route53-policy"
  description = "Policy for Lambda to interact with Route 53, EC2, and SNS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "arn:aws:route53:::hostedzone/Z1CJQNRurgk"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Receive",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "route53_handler" {
  function_name    = "route53-handler"
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_execution.arn
  source_code_hash = filebase64sha256("lambda.zip")

  # Upload Lambda zip file
  filename = "lambda.zip"
  environment {
    variables = {
      HOSTED_ZONE_ID = "Z1CJQNRurgk"
      RECORD_NAME    = "elasticsearch-prod.-cloud.com"
    }
  }
}

# SNS Topic
resource "aws_sns_topic" "ec2_state_changes" {
  name = "ec2-state-change-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.ec2_state_changes.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.route53_handler.arn
}

# Grant SNS Permission to Invoke Lambda
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ec2_state_changes.arn
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change-rule"
  description = "Trigger for EC2 instance state changes"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    detail = {
      "state" = ["running", "terminated"]
    },
    "detail-type" = ["EC2 Instance State-change Notification"]
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  arn       = aws_sns_topic.ec2_state_changes.arn
}

# Grant CloudWatch Permission to Publish to SNS
resource "aws_iam_role_policy_attachment" "cloudwatch_publish" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
provider "aws" {
  region = "eu-west-1"
}

# Variables
variable "lambda_s3_bucket" {}
variable "lambda_s3_key" {}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "lambda-route53-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-route53-policy"
  description = "Policy for Lambda to interact with Route 53, EC2, and SNS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "arn:aws:route53:::hostedzone/Z1CJQNRAHT4HHI"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Receive",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "route53_handler" {
  function_name    = "route53-handler"
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_execution.arn
  source_code_hash = filebase64sha256("lambda.zip")

  # Upload Lambda zip file
  filename = "lambda.zip"
  environment {
    variables = {
      HOSTED_ZONE_ID = "Z1CJQNRurgk"
      RECORD_NAME    = "elasticsearch-prod.-cloud.com"
    }
  }
}

# SNS Topic
resource "aws_sns_topic" "ec2_state_changes" {
  name = "ec2-state-change-topic"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.ec2_state_changes.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.route53_handler.arn
}

# Grant SNS Permission to Invoke Lambda
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ec2_state_changes.arn
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change-rule"
  description = "Trigger for EC2 instance state changes"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    detail = {
      "state" = ["running", "terminated"]
    },
    "detail-type" = ["EC2 Instance State-change Notification"]
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  arn       = aws_sns_topic.ec2_state_changes.arn
}

# Grant CloudWatch Permission to Publish to SNS
resource "aws_iam_role_policy_attachment" "cloudwatch_publish" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
