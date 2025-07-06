package com.gsn.carrot.user_api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "사용자 회원가입 요청")
public class UserRequest {
    @Schema(description = "사용자 이메일", example = "user@example.com")
    private String email;

    @Schema(description = "사용자 비밀번호", example = "password123")
    private String password;

    @Schema(description = "사용자 닉네임", example = "홍길동")
    private String nickname;
}
