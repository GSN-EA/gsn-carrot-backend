package com.gsn.carrot.user_api.service;

import com.gsn.carrot.user_api.domain.User;
import com.gsn.carrot.user_api.dto.LoginRequest;
import com.gsn.carrot.user_api.repository.UserRepository;
import com.gsn.carrot.user_api.util.JWTUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import com.gsn.carrot.user_api.exception.CustomException;
import org.springframework.http.HttpStatus;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JWTUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder(); // 비밀번호 비교용

    public String login(LoginRequest request) {
        // 1. 이메일로 유저 조회
        Optional<User> optionalUser = userRepository.findByEmail(request.getEmail());
        if (optionalUser.isEmpty()) {
            throw new CustomException("존재하지 않는 사용자입니다.", HttpStatus.NOT_FOUND);
        }

        User user = optionalUser.get();

        // 2. 비밀번호 비교
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new CustomException("비밀번호가 일치하지 않습니다.", HttpStatus.UNAUTHORIZED);
        }

        // 3. JWT 토큰 생성 후 반환
        return jwtUtil.generateToken(user.getId());
    }
}
