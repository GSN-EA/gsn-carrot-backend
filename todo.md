# EKS 배포 작업 명세 및 TODO

## 🎯 **주요 목표**
Spring Boot user-api 애플리케이션을 EKS에 배포하고 `https://api.gsn-cloud.org`로 접속 가능하게 만들기

## ✅ **완료된 작업**
1. **인프라 구성**
   - EKS 클러스터, RDS MySQL, VPC 구성 완료
   - AWS Secrets Manager에 DB 크리덴셜 저장
   - AWS Load Balancer Controller, Secrets Store CSI Driver 설치 완료

2. **Kubernetes 리소스 배포**
   - Namespace, Deployment, Service, Ingress 생성 완료
   - SecretProviderClass 생성 (AWS Secrets Manager 연동)
   - ServiceAccount + IAM 역할 연동 완료

3. **SSL 및 도메인 설정**
   - ACM 인증서 생성 (`gsn-cloud.org`, `*.gsn-cloud.org`)
   - Route53 호스팅 존 import 완료
   - DNS 검증 레코드 추가 완료

## 🚨 **현재 문제 상황**
**Pod가 ContainerCreating 상태에서 멈춤** - AWS Secrets Manager 시크릿 마운트 실패

**오류 내용:** `Failed to fetch secret from all regions: gsn-carrot-db-credentials`

**원인:** SecretProviderClass에서 시크릿 이름을 `gsn-carrot-db-credentials`로 참조했지만, 실제 ARN은 `arn:aws:secretsmanager:ap-northeast-2:891377077611:secret:gsn-carrot-db-credentials-n03Ehx`

**해결 시도:** SecretProviderClass에서 전체 ARN 사용하도록 수정했으나 아직 Pod 상태 미확인

## 📋 **다음 세션 TODO (우선순위순)**

### 🔥 **HIGH 우선순위**
1. **Pod 상태 확인 및 시크릿 마운트 문제 해결**
   - `kubectl get pods -n gsn-carrot` 상태 확인
   - 필요시 Pod 로그 확인: `kubectl logs -n gsn-carrot <pod-name>`
   - SecretProviderClass 문제 해결

2. **ALB 생성 확인 및 Ingress 상태 검증**
   - `kubectl get ingress -n gsn-carrot` 확인
   - ALB 생성 여부: `aws elbv2 describe-load-balancers`

3. **Route53에 ALB A 레코드 추가**
   - ALB DNS name 확인 후 Route53에 `api.gsn-cloud.org` A 레코드 추가

4. **SSL 인증서 검증 완료 확인**
   - `aws acm describe-certificate --certificate-arn <cert-arn>`

5. **애플리케이션 접속 테스트**
   - `https://api.gsn-cloud.org/actuator/health` 접속 테스트

### 🔶 **MEDIUM 우선순위**
6. **HPA 리소스 생성**
7. **PDB 리소스 생성**

### 🔷 **LOW 우선순위**  
8. **Ingress annotation 경고 수정** (`ingressClassName` 사용)

## 📁 **주요 파일 위치**
- **Kubernetes 매니페스트:** `/Users/kimminseok/GitHub/gsn-carrot-backend/user-api/k8s/`
- **Terraform 설정:** `/Users/kimminseok/GitHub/gsn-carrot-backend/terraform/env/prod/`
- **도메인:** `api.gsn-cloud.org`
- **네임스페이스:** `gsn-carrot`

## 🔍 **디버깅 명령어**
```bash
# Pod 상태 확인
kubectl get pods -n gsn-carrot
kubectl describe pod -n gsn-carrot <pod-name>

# Ingress 상태 확인  
kubectl get ingress -n gsn-carrot
kubectl describe ingress -n gsn-carrot user-api-ingress

# ALB 확인
aws elbv2 describe-load-balancers

# 시크릿 확인
aws secretsmanager get-secret-value --secret-id gsn-carrot-db-credentials --query SecretString --output text
```

## 💡 **참고사항**
- 시크릿 실제 내용: `{"dbname":"carrot","host":"gsn-carrot-mysql.cv26ii48whsl.ap-northeast-2.rds.amazonaws.com:3306","password":"hello_gsn_11","port":3306,"username":"admin"}`
- ACM 인증서 ARN: `arn:aws:acm:ap-northeast-2:891377077611:certificate/45d09a19-99e3-4858-84ec-56c17204fd6b`
- Route53 Zone ID: `Z047165113HO3P7R71WBQ`