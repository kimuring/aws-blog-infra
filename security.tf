# ALB용: 인터넷에서 80 허용
resource "aws_security_group" "alb" {
  name        = "tf-alb-sg"
  description = "ALB - HTTP from internet"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 웹서버용: 8080은 ALB에서만, SSH는 내 IP만
resource "aws_security_group" "web" {
  name        = "tf-web-sg"
  description = "Web - 8080 from ALB only"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 기존 RDS 보안 그룹에 "tf-web-sg에서 오는 3306 허용" 한 줄 추가
resource "aws_vpc_security_group_ingress_rule" "rds_from_web" {
  security_group_id            = "sg-0a7b85b55185622a1"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "MySQL from tf-web-sg"
}
