# 대상 그룹: 8080 + /health로 건강 체크
resource "aws_lb_target_group" "blog" {
  name     = "tf-blog-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# 시작 템플릿: 기본 AL2023 + 사용자 데이터
resource "aws_launch_template" "blog" {
  name          = "tf-blog-lt"
  image_id      = nonsensitive(data.aws_ssm_parameter.al2023.value)
  instance_type = "t3.micro"
  key_name      = "PeaceKeeper-key"
  user_data     = base64encode(file("${path.module}/userdata.sh"))

  iam_instance_profile {
    name = data.aws_iam_instance_profile.blog.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "tf-blog-web" }
  }
}
