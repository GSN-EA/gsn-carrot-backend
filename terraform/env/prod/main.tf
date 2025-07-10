module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "gsn-carrot-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/gsn-carrot-cluster" = "shared"
    "Environment"                              = "prod"
  }
}

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
  cluster_endpoint_public_access_cidrs = ["119.196.71.73/32"]

  eks_managed_node_groups = {
    default = {
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
