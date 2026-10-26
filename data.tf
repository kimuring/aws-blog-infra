# 기존 VPC
data "aws_vpc" "main" {
  id = "vpc-03d80beffc022dcce"
}

# 퍼블릭 서브넷 2개 (이름에 public이 들어간 것)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# 기존 RDS
data "aws_db_instance" "main" {
  db_instance_identifier = "database-1"
}

# 기존 IAM 역할 (서버 신분증)
data "aws_iam_instance_profile" "blog" {
  name = "blog-ec2-role"
}

# 최신 Amazon Linux 2023 AMI
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
