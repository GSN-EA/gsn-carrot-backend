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

## 🔐 인증 방식

JWT 기반 인증 사용
로그인 시 발급된 토큰을 `Authorization: Bearer <토큰>` 형태로 요청 헤더에 포함해야 합니다.

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
