# main.tf

provider "aws" {
  region = "us-west-2"
}

module "alb" {
  source = "./alb"
}

module "ec2_asg" {
  source = "./ec2_asg"
}

module "lambda_integration" {
  source = "./lambda_integration"
}

output "alb_url" {
  value = aws_lb.application_lb.dns_name
}
