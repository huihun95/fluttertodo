package com.ohange.todoserver.config;

import com.ohange.todoserver.websocket.TaskWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private TaskWebSocketHandler taskWebSocketHandler;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // Flutter 앱용 순수 WebSocket 엔드포인트
        registry.addHandler(taskWebSocketHandler, "/ws/tasks")
                .setAllowedOrigins("*"); // 개발용, 운영시 제한 필요
        
        // 웹 브라우저용 SockJS 엔드포인트 (필요시)
        registry.addHandler(taskWebSocketHandler, "/ws/tasks-sockjs")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}