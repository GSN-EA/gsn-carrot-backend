# ECR Repository for user-api
resource "aws_ecr_repository" "user_api" {
  name                 = "gsn-carrot/user-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Service     = "user-api"
    Terraform   = "true"
  }
}