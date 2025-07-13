# Import existing Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = "gsn-cloud.org"

  tags = {
    Name        = "gsn-cloud.org"
    Environment = "prod"
    Terraform   = "true"
  }
}

# ACM Certificate for gsn-cloud.org
resource "aws_acm_certificate" "main" {
  domain_name               = "gsn-cloud.org"
  subject_alternative_names = ["*.gsn-cloud.org"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "gsn-cloud.org"
    Environment = "prod"
    Terraform   = "true"
  }
}

# Certificate validation will be done manually or in a separate step
# Uncomment and apply these resources after the certificate is created

# locals {
#   domain_validation_options = tolist(aws_acm_certificate.main.domain_validation_options)
# }

# resource "aws_route53_record" "cert_validation" {
#   count = length(local.domain_validation_options)
  
#   allow_overwrite = true
#   name            = local.domain_validation_options[count.index].resource_record_name
#   records         = [local.domain_validation_options[count.index].resource_record_value]
#   ttl             = 60
#   type            = local.domain_validation_options[count.index].resource_record_type
#   zone_id         = aws_route53_zone.main.zone_id
# }

# resource "aws_acm_certificate_validation" "main" {
#   certificate_arn         = aws_acm_certificate.main.arn
#   validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
  
#   timeouts {
#     create = "5m"
#   }
# }