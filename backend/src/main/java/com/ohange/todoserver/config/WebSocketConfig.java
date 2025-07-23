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
        registry.addHandler(taskWebSocketHandler, "/ws/tasks")
                .setAllowedOrigins("*") // 개발용, 운영시 제한 필요
                .withSockJS(); // SockJS 지원 (WebSocket을 지원하지 않는 브라우저용)
    }
}