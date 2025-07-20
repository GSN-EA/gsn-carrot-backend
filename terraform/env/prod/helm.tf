# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ServiceAccount for AWS Load Balancer Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }
  }
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "AWSLoadBalancerControllerIAMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
      }
    ]
  })

  tags = {
    Name        = "AWSLoadBalancerControllerIAMRole"
    Environment = "prod"
    Terraform   = "true"
  }
}

# Github에서 공식 정책 JSON 파일을 가져온다.
data "http" "aws_load_balancer_controller_policy_doc" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/docs/install/iam_policy.json"
}

# 읽어온 내용으로 IAM 정책을 생성
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller (Managed by Terraform)"
  policy      = data.http.aws_load_balancer_controller_policy_doc.response_body
}

# 생성될 정책을 역할(Role)에 연결
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}

# Install AWS Load Balancer Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
      }
      region = "ap-northeast-2"
    })
  ]

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}
