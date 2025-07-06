package com.gsn.carrot.user_api.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JWTUtil {
    private final Key key = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    // 토큰 유효시간: 1시간
    private static final long EXPIRATION_TIME = 1000 * 60 * 60;

    // JWT 발급
    public String generateToken(Long userId) {
        return Jwts.builder()
            .setSubject(String.valueOf(userId))
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
            .signWith(key)
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
