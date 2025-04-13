# Security Group for App Tier
resource "aws_security_group" "app" {
  name_prefix = "app-tier-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.web_sg_id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.db_sg_id]
  }

  tags = merge(var.project_tags, {
    Name = "app-tier-sg"
  })
}

# Launch Template for App Tier
resource "aws_launch_template" "app" {
  name_prefix   = "app-tier"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-11-amazon-corretto
              EOF
  )

  tags = merge(var.project_tags, {
    Name = "app-tier-template"
  })
}

# Internal Load Balancer
resource "aws_lb" "app" {
  name               = "app-tier-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app.id]
  subnets            = var.private_subnet_ids

  tags = merge(var.project_tags, {
    Name = "app-tier-alb"
  })
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name     = "app-tier-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 30
    timeout           = 5
    path              = "/health"
    port              = "traffic-port"
    protocol          = "HTTP"
    matcher           = "200"
  }

  tags = merge(var.project_tags, {
    Name = "app-tier-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.app.arn]
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-tier-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.project_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
