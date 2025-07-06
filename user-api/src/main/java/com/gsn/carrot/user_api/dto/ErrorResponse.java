package com.gsn.carrot.user_api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
@Schema(description = "에러 응답")
public class ErrorResponse {
    @Schema(description = "에러 타입", example = "Bad Request")
    private String error;

    @Schema(description = "에러 메시지", example = "이미 존재하는 이메일입니다.")
    private String message;
}
