package com.gsn.carrot.user_api.service;

import com.gsn.carrot.user_api.domain.User;
import com.gsn.carrot.user_api.dto.UserRequest;
import com.gsn.carrot.user_api.dto.UserResponse;
import com.gsn.carrot.user_api.exception.CustomException;
import com.gsn.carrot.user_api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserResponse createUser(UserRequest request) {
        // 이메일 중복 확인
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("이미 존재하는 이메일입니다.");
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .nickname(request.getNickname())
                .build();

        User saved = userRepository.save(user);
        return new UserResponse(saved.getId(), saved.getEmail(), saved.getNickname());
    }

    public UserResponse getUserById(Long userId) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isEmpty()) {
            throw new CustomException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
        }

        User foundUser = user.get();
        return new UserResponse(foundUser.getId(), foundUser.getEmail(), foundUser.getNickname());
    }
}
