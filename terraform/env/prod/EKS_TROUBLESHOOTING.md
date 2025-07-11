# EKS 클러스터 접속 문제 해결 가이드

## 문제 상황
kubectl 명령어로 EKS 클러스터에 접속하려고 할 때 다음과 같은 오류가 발생하는 경우

### 오류 유형 1: 네트워크 접근 권한 오류
```bash
dial tcp: lookup <cluster-endpoint>: no such host
# 또는
dial tcp <ip>:443: i/o timeout
```

### 오류 유형 2: 인증 권한 오류
```bash
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

## 해결 방법

### 1단계: 현재 IP 확인
```bash
curl -s https://checkip.amazonaws.com
```

### 2단계: EKS 클러스터 퍼블릭 접근 CIDR에 현재 IP 추가

#### Terraform 설정 파일 수정
`main.tf` 파일의 EKS 모듈 설정에서 `cluster_endpoint_public_access_cidrs`에 현재 IP 추가:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  # ... 기타 설정

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["기존IP/32", "새로운IP/32"]

  # ... 기타 설정
}
```

#### Terraform 적용
```bash
cd terraform/env/prod
terraform apply
```

### 3단계: EKS 접근 권한 추가

#### 현재 AWS 사용자 정보 확인
```bash
aws sts get-caller-identity
```

#### EKS 접근 엔트리 생성
```bash
aws eks create-access-entry \
  --cluster-name gsn-carrot-cluster \
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:user/<USERNAME> \
  --region ap-northeast-2
```

#### 클러스터 관리자 권한 부여
```bash
aws eks associate-access-policy \
  --cluster-name gsn-carrot-cluster \
  --principal-arn arn:aws:iam::<ACCOUNT_ID>:user/<USERNAME> \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster \
  --region ap-northeast-2
```

### 4단계: kubeconfig 업데이트 및 접속 테스트

#### kubeconfig 업데이트
```bash
aws eks update-kubeconfig --region ap-northeast-2 --name gsn-carrot-cluster
```

#### 접속 테스트
```bash
kubectl get nodes
kubectl cluster-info
```

## 참고사항

### 사용된 명령어 요약
```bash
# 1. 현재 IP 확인
curl -s https://checkip.amazonaws.com

# 2. AWS 사용자 정보 확인
aws sts get-caller-identity

# 3. EKS 클러스터 목록 확인
aws eks list-clusters --region ap-northeast-2

# 4. EKS 접근 권한 추가
aws eks create-access-entry --cluster-name gsn-carrot-cluster --principal-arn arn:aws:iam::891377077611:user/tenaya-admin --region ap-northeast-2

# 5. 관리자 권한 부여
aws eks associate-access-policy --cluster-name gsn-carrot-cluster --principal-arn arn:aws:iam::891377077611:user/tenaya-admin --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster --region ap-northeast-2

# 6. kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name gsn-carrot-cluster
```

### 주의사항
- IP 주소는 변경될 수 있으므로 정기적으로 확인 필요
- 보안을 위해 `0.0.0.0/0` 대신 특정 IP만 허용하는 것을 권장
- EKS 접근 권한은 클러스터 생성자가 아닌 경우 별도로 추가해야 함

### 해결 일시
- 2025-07-11 11:10 KST
- 해결한 사용자: tenaya-admin
- 클러스터: gsn-carrot-cluster
- 리전: ap-northeast-2