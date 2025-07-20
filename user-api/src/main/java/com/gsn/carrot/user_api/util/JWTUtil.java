// JWTUtil.java

package com.gsn.carrot.user_api.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JWTUtil {

    @Value("${jwt.secret}") // application.yml 또는 환경 변수에서 값을 주입받습니다.
    private String secret;

    private Key key;

    // 의존성 주입이 완료된 후, secret 값을 사용하여 Key 객체를 초기화합니다.
    @PostConstruct
    public void init() {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    // 토큰 유효시간: 1시간
    private static final long EXPIRATION_TIME = 1000 * 60 * 60;

    // JWT 발급
    public String generateToken(Long userId) {
        return Jwts.builder()
                .setSubject(String.valueOf(userId))
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key, SignatureAlgorithm.HS256) // 서명 알고리즘 명시
                .compact();
    }

    // JWT 검증 및 userId 추출
    public Long validateAndExtractUserId(String token) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            return Long.parseLong(claims.getSubject());
        } catch (JwtException e) {
            // 유효하지 않은 토큰
            return null;
        }
    }
}
