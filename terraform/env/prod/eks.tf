module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "gsn-carrot-cluster"
  cluster_version = "1.29"

  subnet_ids  = module.vpc.private_subnets
  vpc_id      = module.vpc.vpc_id
  enable_irsa = true

  cluster_endpoint_public_access       = true # 퍼블릭 엔드포인트 허용
  cluster_endpoint_private_access      = true # 프라이빗 엔드포인트도 허용
  cluster_endpoint_public_access_cidrs = var.allowed_cidrs

  # EKS 접근 권한 설정
  access_entries = {
    tenaya-admin = {
      principal_arn = "arn:aws:iam::891377077611:user/tenaya-admin"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_worker" {
  name        = "gsn-carrot-eks-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "gsn-carrot-eks-worker-sg"
    Environment = "prod"
    Terraform   = "true"
  }
}