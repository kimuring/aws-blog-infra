# ALB (정문)
resource "aws_lb" "blog" {
  name               = "tf-blog-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids
}

# 리스너: 80으로 들어오면 대상 그룹(8080)으로 전달
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.blog.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog.arn
  }
}

# Auto Scaling 그룹
resource "aws_autoscaling_group" "blog" {
  name                      = "tf-blog-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  vpc_zone_identifier       = data.aws_subnets.public.ids
  target_group_arns         = [aws_lb_target_group.blog.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.blog.id
    version = aws_launch_template.blog.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # 대수는 CPU 정책에 맡기기 (Terraform이 되돌리지 않음)
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# CPU 50% 대상 추적
resource "aws_autoscaling_policy" "cpu" {
  name                   = "tf-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.blog.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

output "alb_url" {
  value = "http://${aws_lb.blog.dns_name}"
}
