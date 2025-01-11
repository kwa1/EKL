# variables.tf

variable "vpc_id" {
  description = "VPC ID where the resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "record_name" {
  description = "Domain name for the ALB"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t3.micro"
}
