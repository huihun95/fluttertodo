package com.ohange.todoserver.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**").permitAll()
                .anyRequest().authenticated()
            );
        
        // TODO: 프로덕션 환경에서는 다음 보안 설정 필요
        // 1. JWT 기반 인증 구현
        //    - JWT 토큰 발급/검증 로직 추가
        //    - JwtAuthenticationFilter 구현
        // 2. CORS 설정 추가
        //    - Flutter 앱의 도메인 허용
        //    - 허용할 HTTP 메서드 지정 (GET, POST, PUT, DELETE)
        //    - 허용할 헤더 설정
        // 3. CSRF 보호 재활성화 검토
        //    - 모바일 앱 전용이면 비활성화 유지
        //    - 웹 클라이언트 지원 시 CSRF 토큰 구현
        // 4. API 엔드포인트별 세밀한 권한 설정
        //    - 공개 API (회원가입, 로그인)
        //    - 인증 필요 API (TODO CRUD)
        //    - 관리자 전용 API
        
        return http.build();
    }
}