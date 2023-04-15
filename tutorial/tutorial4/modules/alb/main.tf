resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket = var.alb_log_bucket
    enabled = true
  }

  security_groups = {

  }
}

module security_groups {
  source = "../security_groups"
}