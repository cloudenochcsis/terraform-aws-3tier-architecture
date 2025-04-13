# Security Group for Web Tier
resource "aws_security_group" "web" {
  name_prefix = "web-tier-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  tags = merge(var.project_tags, {
    Name = "web-tier-sg"
  })
}

# Launch Template for Web Tier
resource "aws_launch_template" "web" {
  name_prefix   = "web-tier"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  tags = merge(var.project_tags, {
    Name = "web-tier-template"
  })
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "web-tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = var.public_subnet_ids

  tags = merge(var.project_tags, {
    Name = "web-tier-alb"
  })
}

# ALB Target Group
resource "aws_lb_target_group" "web" {
  name     = "web-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 30
    timeout           = 5
    path              = "/"
    port              = "traffic-port"
    protocol          = "HTTP"
    matcher           = "200"
  }

  tags = merge(var.project_tags, {
    Name = "web-tier-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-tier-asg"
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
