# VPC 관련 출력값들
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  value       = module.vpc.vpc_cidr_block
}

# 서브넷 관련 출력값들
output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.vpc.public_subnets
}

output "private_subnet_arns" {
  description = "프라이빗 서브넷 ARN 목록"
  value       = module.vpc.private_subnet_arns
}

output "public_subnet_arns" {
  description = "퍼블릭 서브넷 ARN 목록"
  value       = module.vpc.public_subnet_arns
}

# NAT Gateway 관련 출력값들 (수정됨)
output "nat_gateway_ids" {
  description = "NAT Gateway ID 목록"
  value       = module.vpc.natgw_ids
}

output "nat_public_ips" {
  description = "NAT Gateway의 퍼블릭 IP 목록"
  value       = module.vpc.nat_public_ips
}

# 라우팅 테이블 관련 출력값들
output "private_route_table_ids" {
  description = "프라이빗 라우팅 테이블 ID 목록"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "퍼블릭 라우팅 테이블 ID 목록"
  value       = module.vpc.public_route_table_ids
}

# 기타 유용한 출력값들
output "azs" {
  description = "사용된 가용영역 목록"
  value       = module.vpc.azs
}

output "name" {
  description = "VPC 이름"
  value       = module.vpc.name
}

# EKS 관련 출력값들
output "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 API 서버 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS 클러스터 버전"
  value       = module.eks.cluster_version
}

output "eks_managed_node_groups" {
  description = "EKS 관리형 노드 그룹"
  value       = module.eks.eks_managed_node_groups
}

output "oidc_provider_arn" {
  description = "EKS 클러스터에 연결된 OIDC Provider의 ARN"
  value       = module.eks.oidc_provider_arn
}

# ECR 관련 출력값들
output "ecr_repository_url" {
  description = "ECR repository URL for user-api"
  value       = aws_ecr_repository.user_api.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name for user-api"
  value       = aws_ecr_repository.user_api.name
}

# RDS 관련 출력값들
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

# Secrets Manager 관련 출력값들
output "secrets_manager_secret_name" {
  description = "Secrets Manager secret name for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

# KMS 관련 출력값들
output "kms_key_id" {
  description = "KMS key ID for RDS encryption"
  value       = aws_kms_key.rds.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for RDS encryption"
  value       = aws_kms_key.rds.arn
}

# Route53 관련 출력값들
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_zone_name" {
  description = "Route53 hosted zone name"
  value       = aws_route53_zone.main.name
}

# ACM 관련 출력값들
output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain" {
  description = "ACM certificate domain"
  value       = aws_acm_certificate.main.domain_name
}
