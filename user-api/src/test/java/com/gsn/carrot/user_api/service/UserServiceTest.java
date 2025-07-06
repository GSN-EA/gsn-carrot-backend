package com.gsn.carrot.user_api.service;

import com.gsn.carrot.user_api.domain.User;
import com.gsn.carrot.user_api.dto.UserRequest;
import com.gsn.carrot.user_api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserServiceTest {

    private UserRepository userRepository;
    private BCryptPasswordEncoder passwordEncoder;
    private UserService userService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordEncoder = new BCryptPasswordEncoder();
        userService = new UserService(userRepository, passwordEncoder);
    }

    @Test
    void createUser_성공() {
        // given
        UserRequest request = new UserRequest("test@example.com", "1234", "tester");
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        // when
        var result = userService.createUser(request);

        // then
        assertEquals("test@example.com", result.getEmail());
        assertEquals("tester", result.getNickname());
    }

    @Test
    void createUser_중복이메일_예외발생() {
        // given
        UserRequest request = new UserRequest("test@example.com", "1234", "tester");
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(mock(User.class)));

        // when & then
        assertThrows(RuntimeException.class, () -> userService.createUser(request));
    }
}
