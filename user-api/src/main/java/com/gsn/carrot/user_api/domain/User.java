package com.gsn.carrot.user_api.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String nickname;

    private LocalDateTime createdAt;

    @PrePersist // INSERT 전 자동 실행됨 -> createdAt 값을 자동으로 넣어줌
    public void createdAt() {
        this.createdAt = LocalDateTime.now();
    }
}
