output "vpc_id"         { value = data.aws_vpc.main.id }
output "public_subnets" { value = data.aws_subnets.public.ids }
output "rds_endpoint"   { value = data.aws_db_instance.main.address }
output "rds_sg"         { value = data.aws_db_instance.main.vpc_security_groups }
output "al2023_ami"     { value = nonsensitive(data.aws_ssm_parameter.al2023.value) }
