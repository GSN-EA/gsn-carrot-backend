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

  # 퍼블릭 서브넷에 태그를 추가하여 loadbalancer controller가 로드밸런서를 생성할 수 있도록 한다.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

}
