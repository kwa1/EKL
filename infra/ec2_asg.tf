# ec2_asg.tf

resource "aws_launch_configuration" "ec2_launch_config" {
  name          = "ec2-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0" # Example AMI, update with a valid one
  instance_type = var.ec2_instance_type

  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.ec2_launch_config.id

  target_group_arns = [aws_lb_target_group.alb_target_group_https.arn]
}

# Attach the EC2 instances to the target group for HTTPS
resource "aws_lb_target_group_attachment" "asg_attachment_https" {
  target_group_arn = aws_lb_target_group.alb_target_group_https.arn
  target_id        = aws_autoscaling_group.asg.instances[0].id
  port             = 443
}
