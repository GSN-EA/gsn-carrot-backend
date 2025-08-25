# 📦 Product-API 구현 계획 (Living Docs)

> **Living Document**: 이 문서는 구현 진행에 따라 지속적으로 업데이트됩니다.
> 
> **Last Updated**: 2025-08-25  
> **Status**: 🔄 Planning Phase

---

## 📖 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [API 명세](#api-명세)
3. [데이터베이스 설계](#데이터베이스-설계)
4. [환경 설정](#환경-설정)
5. [JWT 인증 및 보안](#jwt-인증-및-보안)
6. [기술 스택](#기술-스택)
7. [구현 우선순위](#구현-우선순위)
8. [K8s 배포 구성](#k8s-배포-구성)
9. [체크리스트](#체크리스트)

---

## 🎯 프로젝트 개요

당근마켓 클론 프로젝트의 상품 관련 API 서비스입니다.
- **기존 user-api와 동일한 RDS 및 JWT 시크릿 공유**
- **RESTful API 설계**
- **Spring Boot + JPA + MySQL 기반**
- **JWT 기반 인증으로 권한 관리**

---

## 📋 API 명세

### 🔓 공개 API (인증 불필요)

#### 1. 상품 목록 조회
```
GET /api/v1/product
Query Parameters:
- search: string (선택) - 제목 검색
- page: int (기본값: 0) - 페이지 번호
- size: int (기본값: 10) - 페이지 크기  
- sort: string (기본값: createdAt,desc) - 정렬 (createdAt,desc | price,asc | title,asc)

Response: 200 OK
{
  "content": [
    {
      "productId": 123,
      "title": "아이폰 15 Pro",
      "price": 1000000,
      "imageUrl": "https://s3.amazonaws.com/.../product-123.jpg",
      "onSale": true,
      "createdAt": "2024-01-01T10:00:00"
    }
  ],
  "pageable": {
    "page": 0,
    "size": 10,
    "totalElements": 50,
    "totalPages": 5
  }
}
```

#### 2. 상품 상세 조회
```
GET /api/v1/product/{productId}

Response: 200 OK
{
  "productId": 123,
  "seller": {
    "email": "seller@example.com",
    "nickname": "판매자닉네임"
  },
  "title": "아이폰 15 Pro",
  "price": 1000000,
  "imageUrl": "https://s3.amazonaws.com/.../product-123.jpg",
  "description": "상품 상세 설명...",
  "onSale": true,
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-02T15:30:00"
}

Response: 404 Not Found
{
  "message": "상품을 찾을 수 없습니다.",
  "timestamp": "2024-01-01T10:00:00"
}
```

### 🔒 인증 필요 API

#### 3. 상품 등록
```
POST /api/v1/product
Header: Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data

Request Body (Form Data):
- title: string (필수) - "아이폰 15 Pro"
- price: integer (필수) - 1000000
- description: string (필수) - "상품 설명..."
- image: file (필수) - 이미지 파일

파일 제한사항:
- 개수: 1개 (필수)
- 크기: 최대 5MB
- 형식: JPG, JPEG, PNG, WEBP만 허용

Response: 201 Created
{
  "message": "상품 등록 성공",
  "productId": 123,
  "imageUrl": "https://s3.amazonaws.com/.../product-123.jpg"
}

Response: 400 Bad Request
{
  "message": "이미지 파일이 필요합니다.",
  "timestamp": "2024-01-01T10:00:00"
}

Response: 413 Payload Too Large
{
  "message": "파일 크기가 너무 큽니다. (최대 5MB)",
  "timestamp": "2024-01-01T10:00:00"
}
```

#### 4. 상품 수정
```
PUT /api/v1/product/{productId}
Header: Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data

Request Body (Form Data):
- title: string (선택) - "아이폰 15 Pro (수정)"
- price: integer (선택) - 950000
- description: string (선택) - "수정된 설명..."
- image: file (선택) - 새 이미지 파일 (업로드 시 기존 이미지 교체)

Response: 200 OK
{
  "message": "상품 수정 성공",
  "imageUrl": "https://s3.amazonaws.com/.../product-123-updated.jpg"
}

Response: 403 Forbidden
{
  "message": "본인의 상품만 수정할 수 있습니다."
}
```

#### 5. 상품 삭제
```
DELETE /api/v1/product/{productId}
Header: Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "message": "상품 삭제 성공"
}

Response: 403 Forbidden
{
  "message": "본인의 상품만 삭제할 수 있습니다."
}
```

#### 6. 판매 완료 처리
```
POST /api/v1/product/{productId}/sold
Header: Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "message": "판매 완료 처리 성공"
}
```

#### 7. 내 상품 목록 조회
```
GET /api/v1/product/my
Header: Authorization: Bearer {jwt_token}
Query Parameters:
- page, size, sort (상품 목록 조회와 동일)

Response: 200 OK
{
  "content": [상품 목록],
  "pageable": {...}
}
```

---

## 🗄️ 데이터베이스 설계

### Products 테이블

```sql
CREATE TABLE products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '상품 고유 ID',
    user_id BIGINT NOT NULL COMMENT '등록 사용자 ID', 
    title VARCHAR(255) NOT NULL COMMENT '상품 제목',
    price INT NOT NULL COMMENT '가격 (원 단위)',
    image_url VARCHAR(500) NOT NULL COMMENT 'S3 이미지 URL',
    description TEXT COMMENT '상품 설명',
    on_sale BOOLEAN DEFAULT TRUE COMMENT '판매중 여부',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '등록 일시',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_on_sale (on_sale),
    INDEX idx_created_at (created_at),
    FULLTEXT INDEX idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Entity 설계

```java
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private Long id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(nullable = false, length = 255)
    private String title;
    
    @Column(nullable = false)
    private Integer price;
    
    @Column(name = "image_url", nullable = false, length = 500)
    private String imageUrl;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "on_sale")
    private Boolean onSale = true;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp 
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
```

---

## ⚙️ 환경 설정

### application.properties

```properties
spring.application.name=product-api

# Database Configuration (환경변수로 주입)
spring.datasource.url=jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:carrot}?useSSL=true&allowPublicKeyRetrieval=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:password}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.open-in-view=false

# SQL 초기화 설정
spring.sql.init.mode=always
spring.sql.init.continue-on-error=true

# Swagger UI 설정  
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.swagger-ui.operationsSorter=method
springdoc.swagger-ui.tagsSorter=alpha

# Actuator Configuration
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=when_authorized
management.health.db.enabled=true

# JWT Configuration
jwt.secret=${JWT_SECRET}

# S3 Configuration  
aws.s3.bucket=${S3_BUCKET_NAME}
aws.s3.region=${AWS_REGION:ap-northeast-2}

# File Upload Configuration
spring.servlet.multipart.enabled=true
spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=5MB

# Pagination Default
spring.data.web.pageable.default-page-size=10
spring.data.web.pageable.max-page-size=100
```

### build.gradle 의존성

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    
    // JWT
    implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-impl:0.11.5'
    implementation 'io.jsonwebtoken:jjwt-jackson:0.11.5'
    
    // Security
    implementation 'org.springframework.security:spring-security-crypto:6.2.1'
    
    // Documentation
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0'
    
    // AWS S3
    implementation 'software.amazon.awssdk:s3:2.20.162'
    
    // Database
    runtimeOnly 'com.mysql:mysql-connector-j'
    runtimeOnly 'com.h2database:h2' // 테스트용
    
    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    // Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}
```

---

## 🔐 JWT 인증 및 보안

### 인증 구조
- **user-api와 동일한 JWT_SECRET 공유**
- **JWTUtil, JwtAuthInterceptor 클래스 재사용**
- **토큰에서 userId 추출하여 권한 검증**

### 권한 매트릭스

| API | 인증 필요 | 권한 검증 |
|-----|----------|----------|
| GET /product | ❌ | - |
| GET /product/{id} | ❌ | - |
| POST /product | ✅ | JWT 유효성 |
| PUT /product/{id} | ✅ | 상품 소유자 |
| DELETE /product/{id} | ✅ | 상품 소유자 |
| POST /product/{id}/sold | ✅ | 상품 소유자 |
| GET /product/my | ✅ | JWT 유효성 |

### 보안 고려사항
- **입력값 검증**: @Valid, @NotBlank, @Min, @Max
- **파일 업로드 검증**: 파일 타입, 크기 제한
- **SQL 인젝션 방지**: JPA Query Methods 사용
- **XSS 방지**: 응답 데이터 이스케이핑
- **권한 검증**: 본인 상품만 수정/삭제 가능

---

## 🛠️ 기술 스택

| 분야 | 기술 |
|------|------|
| **Framework** | Spring Boot 3.2.0 |
| **Language** | Java 17 |
| **Database** | MySQL 8.0 (RDS) |
| **ORM** | Spring Data JPA |
| **Authentication** | JWT (jsonwebtoken 0.11.5) |
| **Documentation** | Swagger UI (SpringDoc) |
| **Build Tool** | Gradle |
| **Deployment** | Kubernetes |
| **Container** | Docker |

---

## 📝 구현 우선순위

### Phase 1: 기본 인프라 (1일)
- [ ] 프로젝트 설정 및 의존성 추가
- [ ] application.properties 설정
- [ ] JWT 관련 클래스 복사 (user-api에서)
- [ ] Product Entity 및 Repository 구현
- [ ] schema.sql 작성

### Phase 2: 핵심 API (1일)
- [ ] ProductController 구현
- [ ] ProductService 구현 (기본 CRUD)
- [ ] DTO 클래스 구현
- [ ] 예외 처리 (GlobalExceptionHandler)

### Phase 3: 고급 기능 (0.5일)  
- [ ] 검색 기능 (제목 기반)
- [ ] 페이징 및 정렬
- [ ] JWT 인증 적용
- [ ] 권한 검증 로직

### Phase 4: 테스트 및 문서화 (0.5일)
- [ ] 단위 테스트 작성
- [ ] Swagger 문서화
- [ ] README.md 작성

### Phase 5: 배포 (0.5일)
- [ ] Dockerfile 작성
- [ ] K8s 배포 파일 작성
- [ ] 배포 및 검증

**총 예상 소요시간**: 3-4일

---

## ☸️ K8s 배포 구성

### 시크릿 사용 전략
- **DB 시크릿**: 기존 `user-api-db-secret` 재사용
- **JWT 시크릿**: 기존 `jwt-secret` 재사용

### Deployment 환경변수
```yaml
env:
  - name: DB_HOST
    valueFrom:
      secretKeyRef:
        name: user-api-db-secret
        key: DB_HOST
  - name: DB_PORT  
    valueFrom:
      secretKeyRef:
        name: user-api-db-secret
        key: DB_PORT
  - name: DB_NAME
    valueFrom:
      secretKeyRef:
        name: user-api-db-secret
        key: DB_NAME
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: user-api-db-secret
        key: DB_USERNAME
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: user-api-db-secret
        key: DB_PASSWORD
  - name: JWT_SECRET
    valueFrom:
      secretKeyRef:
        name: jwt-secret
        key: JWT_SECRET
  - name: S3_BUCKET_NAME
    valueFrom:
      secretKeyRef:
        name: s3-secret
        key: S3_BUCKET_NAME
  - name: AWS_REGION
    value: "ap-northeast-2"
```

---

## ✅ 체크리스트

### 🔧 개발 환경 설정
- [ ] build.gradle 의존성 추가 (AWS SDK 포함)
- [ ] application.properties 설정 (S3, 파일업로드 설정 포함)
- [ ] schema.sql 작성
- [ ] user-api JWT 클래스 복사

### 📦 모델 및 리포지토리
- [ ] Product Entity 구현
- [ ] ProductRepository 인터페이스
- [ ] 기본 쿼리 메서드 정의

### 🌐 API 구현  
- [ ] ProductController 클래스 (MultipartFile 처리 포함)
- [ ] ProductService 클래스
- [ ] S3Service 클래스 (이미지 업로드/삭제)
- [ ] Request/Response DTO 클래스
- [ ] 파일 업로드 검증 로직 (타입, 크기)

### 🔐 보안 및 인증
- [ ] JWTUtil 클래스 복사
- [ ] JwtAuthInterceptor 클래스 복사  
- [ ] WebConfig 설정
- [ ] 권한 검증 로직 구현

### 🧪 테스트
- [ ] ProductService 단위 테스트
- [ ] S3Service 단위 테스트
- [ ] ProductController 통합 테스트 (파일 업로드 포함)
- [ ] API 엔드포인트 테스트

### 📚 문서화
- [ ] Swagger 어노테이션 추가
- [ ] API 문서 확인
- [ ] README.md 작성

### 🚀 배포
- [ ] Dockerfile 작성
- [ ] K8s Deployment YAML (S3 환경변수 포함)
- [ ] K8s Service YAML  
- [ ] K8s Ingress YAML
- [ ] S3 버킷 및 시크릿 설정 확인
- [ ] 배포 후 동작 확인

---

## 📝 진행 상황

### ✅ 완료된 작업
- PLAN.md 문서 작성 (단일 이미지 업로드 방식)
- API 명세 정의 (multipart/form-data 방식)
- DB 스키마 설계 (단순화된 products 테이블)
- 환경 설정 및 의존성 정의 (S3, AWS SDK 포함)

### 🔄 진행 중인 작업  
- 없음

### ⏳ 대기 중인 작업
- 전체 구현

---

> **Note**: 이 문서는 구현 진행에 따라 지속적으로 업데이트됩니다.
> 각 단계 완료 시마다 체크리스트를 업데이트하고, 필요시 계획을 조정합니다.