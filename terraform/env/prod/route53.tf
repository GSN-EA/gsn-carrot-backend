##############################
# Route53 Hosted Zone 구역
##############################
# 기존 Route53 Hosted Zone 가져오기
resource "aws_route53_zone" "main" {
  name = "gsn-cloud.org"

  tags = {
    Name        = "gsn-cloud.org"
    Environment = "prod"
    Terraform   = "true"
  }
}

##############################
# ACM 인증서 구역
##############################
# gsn-cloud.org용 ACM 인증서
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

##############################
# ALB 정보 조회 구역
##############################
# user-api Ingress로 생성된 ALB 정보를 조회하는 data 소스입니다.
# ALB는 Helm으로 배포된 aws-load-balancer-controller에 의해 생성되므로 depends_on을 통해 의존성을 명시합니다.
data "aws_lb" "user_api_alb" {
  tags = {
    "ingress.k8s.aws/stack"    = "gsn-carrot/user-api-ingress" # Ingress 리소스의 stack 태그
    "ingress.k8s.aws/resource" = "LoadBalancer"                # ALB 리소스임을 명시하는 태그
  }

  depends_on = [
    helm_release.aws_load_balancer_controller # ALB가 생성된 후에만 조회하도록 의존성 설정
  ]
}

##############################
# ALB용 Route53 레코드 구역
##############################
# user-api ALB의 DNS 정보를 사용하여 api.gsn-cloud.org에 대한 A(Alias) 레코드를 생성합니다.
resource "aws_route53_record" "api_dns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.user_api_alb.dns_name
    zone_id                = data.aws_lb.user_api_alb.zone_id
    evaluate_target_health = true
  }
}

##############################
# 프론트엔드 Route53 레코드 구역
##############################
# 프로덕션 프론트엔드 CNAME 레코드
resource "aws_route53_record" "frontend_prod" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "shop.${aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = ["d2ghzjuypu9nyc.cloudfront.net"]
}

resource "aws_route53_record" "frontend_prod_subdomain_acm_validation" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_1a2e3150b1f5cfb4a2c48dfe17c060d9.shop.${aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = ["_6b2f235aee95a41b459458ab3c68500e.xlfgrmvvlj.acm-validations.aws."]
}


# Chat API CNAME 레코드
resource "aws_route53_record" "chat_api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "chat.${aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = 300
  records = ["m529bw2gn1.execute-api.ap-northeast-2.amazonaws.com"]
}


##############################
# ACM 인증서 검증 구역
##############################
# ACM이 요청하는 DNS 검증 레코드를 Route 53에 자동으로 생성
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# 위에서 생성한 DNS 레코드를 통해 AWS가 인증서 검증을 완료할 때까지 대기
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
