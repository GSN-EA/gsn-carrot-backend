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
