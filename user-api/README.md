# 📘 user-api - 유저 서비스 API

Spring Boot 기반으로 제작된 유저 관련 API입니다.
회원가입, 로그인, 본인 정보 조회 기능을 제공합니다.

---

## 📦 프로젝트 구조

```
user-api/
├── src/
│   ├── main/
│   │   ├── java/com/gsn/carrot/user_api/
│   │   │   ├── controller/   // API 엔드포인트
│   │   │   ├── domain/       // Entity 정의
│   │   │   ├── dto/          // 요청/응답 DTO
│   │   │   ├── exception/    // 예외 처리
│   │   │   ├── repository/   // JPA 인터페이스
│   │   │   ├── service/      // 비즈니스 로직
│   │   │   └── util/         // JWT 유틸 등
│   ├── test/                 // 단위 테스트
├── application.properties    // DB 설정 등
├── Dockerfile                // 컨테이너 빌드용
├── build.gradle              // 의존성 관리
└── README.md
```

---

## 🛠️ 주요 기능

- 회원가입 `POST /api/v1/users`
- 로그인 `POST /api/v1/auth`
- 내 정보 조회 `GET /api/v1/users/me`

---

## 🔐 로그인 처리 방식

### 📋 전체 흐름

1. **로그인 요청** → `POST /api/v1/auth/login`
2. **사용자 검증** → 이메일/비밀번호 확인
3. **JWT 토큰 발급** → 성공 시 토큰 반환
4. **토큰 기반 인증** → 보호된 API 접근

### 🔍 상세 처리 과정

#### 1. 로그인 API (`AuthController:24`)
```java
@PostMapping("/login")
public ResponseEntity<String> login(@RequestBody LoginRequest request)
```
- **엔드포인트**: `POST /api/v1/auth/login`
- **요청 데이터**: `LoginRequest` (email, password)
- **응답**: JWT 토큰 문자열

#### 2. 인증 서비스 (`AuthService:24`)
```java
public String login(LoginRequest request)
```
**처리 단계**:
1. **사용자 조회** (`AuthService:26`): 이메일로 DB에서 사용자 검색
   - 존재하지 않으면 `CustomException` (404 NOT_FOUND) 발생
2. **비밀번호 검증** (`AuthService:34`): BCrypt로 암호화된 비밀번호 비교
   - 불일치 시 `CustomException` (401 UNAUTHORIZED) 발생
3. **JWT 토큰 생성** (`AuthService:39`): 유저 ID로 토큰 발급

#### 3. JWT 토큰 처리 (`JWTUtil`)

**토큰 생성** (`JWTUtil:36`):
- **알고리즘**: HS256 (HMAC with SHA-256)
- **유효시간**: 1시간 (3600초)
- **페이로드**: 사용자 ID (subject)
- **서명키**: 환경변수 `JWT_SECRET`에서 주입

**토큰 검증** (`JWTUtil:46`):
- Bearer 토큰에서 JWT 추출
- 서명 검증 및 만료시간 확인
- 유효한 경우 사용자 ID 반환, 실패 시 null 반환

#### 4. 인증 인터셉터 (`JwtAuthInterceptor`)

**보호된 엔드포인트 접근 시**:
1. **헤더 확인** (`JwtAuthInterceptor:21`): `Authorization: Bearer <토큰>` 형식 검증
2. **토큰 추출** (`JwtAuthInterceptor:29`): Bearer 제거 후 토큰만 추출
3. **토큰 검증** (`JwtAuthInterceptor:30`): JWTUtil로 유효성 확인
4. **사용자 정보 설정** (`JwtAuthInterceptor:39`): 유효한 경우 request에 userId 저장

**인터셉터 적용 범위** (`WebConfig:16`):
- **적용**: `/api/v1/users/me` (내 정보 조회)
- **제외**: `/api/v1/auth/login` (로그인 엔드포인트)

### 🔑 보안 특징

- **비밀번호 암호화**: BCrypt 해시 알고리즘 사용
- **JWT 서명**: HMAC-SHA256으로 토큰 무결성 보장
- **환경변수 관리**: JWT 비밀키를 환경변수로 분리 관리
- **토큰 만료**: 1시간 후 자동 만료로 보안 강화

### 📝 사용 예시

**로그인 요청**:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

**인증이 필요한 API 호출**:
```bash
curl -X GET http://localhost:8080/api/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

---

## 🧪 로컬 실행 방법

```bash
# 빌드 및 실행
./gradlew build
java -jar build/libs/user-api-0.0.1-SNAPSHOT.jar
```

또는 IDE(Cursor)에서 `UserApiApplication` 실행

---

## ✅ 테스트

```bash
./gradlew test
```
