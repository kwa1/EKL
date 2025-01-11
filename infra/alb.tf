# alb.tf

resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = var.record_name
  validation_method = "DNS"

  tags = {
    Name = "ELK-SSL-Certificate"
  }
}

resource "aws_lb" "application_lb" {
  name               = "elk-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
  enable_deletion_protection = false
}

# Target group for HTTPS (port 443)
resource "aws_lb_target_group" "alb_target_group_https" {
  name     = "elk-target-group-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
}

# HTTPS Listener for secure traffic (port 443)
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl_certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group_https.arn
    type             = "forward"
  }
}

# HTTP Listener for non-secure traffic (port 80) and forward to HTTPS
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }
}
