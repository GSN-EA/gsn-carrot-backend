terraform {
  backend "s3" {
    bucket         = "carrot-terraform-backend"
    key            = "prd/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "gsn-carrot-terraform-lock"
    encrypt        = true
  }
}
