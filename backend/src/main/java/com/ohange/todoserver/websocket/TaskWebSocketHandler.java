package com.ohange.todoserver.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.net.URI;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class TaskWebSocketHandler extends TextWebSocketHandler {

    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // 사용자별 세션 저장 (userId -> WebSocketSession)
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    // 팀별 세션 그룹 관리 (teamId -> Set<WebSocketSession>)
    private final Map<String, Set<WebSocketSession>> teamSessions = new ConcurrentHashMap<>();
    
    // 세션별 사용자 정보 저장 (sessionId -> UserInfo)
    private final Map<String, UserInfo> sessionUserInfo = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String userId = getUserIdFromSession(session);
        String teamId = getTeamIdFromSession(session);
        
        if (userId == null || teamId == null) {
            session.close(CloseStatus.BAD_DATA.withReason("userId와 teamId 파라미터가 필요합니다."));
            return;
        }

        // 사용자별 세션 저장
        userSessions.put(userId, session);
        
        // 팀별 세션 그룹에 추가
        teamSessions.computeIfAbsent(teamId, k -> ConcurrentHashMap.newKeySet()).add(session);
        
        // 세션 정보 저장
        sessionUserInfo.put(session.getId(), new UserInfo(userId, teamId));
        
        System.out.println("WebSocket 연결 성공 - User: " + userId + ", Team: " + teamId + ", Session: " + session.getId());
        
        // 연결 성공 메시지 전송
        sendToSession(session, new WebSocketMessage("CONNECTION_SUCCESS", 
                Map.of("message", "실시간 알림 연결이 성공했습니다.", "userId", userId, "teamId", teamId)));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        UserInfo userInfo = sessionUserInfo.remove(session.getId());
        
        if (userInfo != null) {
            // 사용자별 세션에서 제거
            userSessions.remove(userInfo.getUserId(), session);
            
            // 팀별 세션 그룹에서 제거
            Set<WebSocketSession> teamSessionSet = teamSessions.get(userInfo.getTeamId());
            if (teamSessionSet != null) {
                teamSessionSet.remove(session);
                if (teamSessionSet.isEmpty()) {
                    teamSessions.remove(userInfo.getTeamId());
                }
            }
            
            System.out.println("WebSocket 연결 종료 - User: " + userInfo.getUserId() + 
                             ", Team: " + userInfo.getTeamId() + ", Session: " + session.getId());
        }
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // 클라이언트로부터의 메시지 처리 (필요시 구현)
        System.out.println("클라이언트 메시지 수신: " + message.getPayload());
        
        // Ping-Pong 메시지 처리
        if ("ping".equals(message.getPayload())) {
            sendToSession(session, new WebSocketMessage("PONG", Map.of("timestamp", System.currentTimeMillis())));
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        System.err.println("WebSocket 전송 에러 - Session: " + session.getId() + ", Error: " + exception.getMessage());
        session.close(CloseStatus.SERVER_ERROR);
    }

    // 특정 사용자에게 메시지 전송
    public void sendToUser(String userId, WebSocketMessage message) {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            sendToSession(session, message);
        } else {
            System.out.println("사용자 " + userId + "의 활성 세션을 찾을 수 없습니다.");
        }
    }

    // 팀 전체에게 브로드캐스트
    public void broadcastToTeam(String teamId, WebSocketMessage message) {
        Set<WebSocketSession> sessions = teamSessions.get(teamId);
        if (sessions != null) {
            sessions.removeIf(session -> !session.isOpen()); // 비활성 세션 제거
            
            for (WebSocketSession session : sessions) {
                sendToSession(session, message);
            }
            
            System.out.println("팀 " + teamId + "에 메시지 브로드캐스트: " + sessions.size() + "개 세션");
        } else {
            System.out.println("팀 " + teamId + "의 활성 세션을 찾을 수 없습니다.");
        }
    }

    // 세션에 메시지 전송 (내부 메서드)
    private void sendToSession(WebSocketSession session, WebSocketMessage message) {
        try {
            if (session.isOpen()) {
                String jsonMessage = objectMapper.writeValueAsString(message);
                session.sendMessage(new TextMessage(jsonMessage));
            }
        } catch (IOException e) {
            System.err.println("메시지 전송 실패 - Session: " + session.getId() + ", Error: " + e.getMessage());
        }
    }

    // URL에서 userId 파라미터 추출
    private String getUserIdFromSession(WebSocketSession session) {
        try {
            URI uri = session.getUri();
            if (uri != null) {
                String query = uri.getQuery();
                if (query != null) {
                    for (String param : query.split("&")) {
                        String[] pair = param.split("=");
                        if (pair.length == 2 && "userId".equals(pair[0])) {
                            return pair[1];
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("userId 파라미터 추출 실패: " + e.getMessage());
        }
        return null;
    }

    // URL에서 teamId 파라미터 추출
    private String getTeamIdFromSession(WebSocketSession session) {
        try {
            URI uri = session.getUri();
            if (uri != null) {
                String query = uri.getQuery();
                if (query != null) {
                    for (String param : query.split("&")) {
                        String[] pair = param.split("=");
                        if (pair.length == 2 && "teamId".equals(pair[0])) {
                            return pair[1];
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("teamId 파라미터 추출 실패: " + e.getMessage());
        }
        return null;
    }

    // 현재 연결된 사용자 수 조회
    public int getConnectedUserCount() {
        return userSessions.size();
    }

    // 현재 활성 팀 수 조회
    public int getActiveTeamCount() {
        return teamSessions.size();
    }

    // 특정 사용자가 온라인인지 확인
    public boolean isUserOnline(String userId) {
        WebSocketSession session = userSessions.get(userId);
        return session != null && session.isOpen();
    }

    // 사용자 정보 내부 클래스
    private static class UserInfo {
        private final String userId;
        private final String teamId;

        public UserInfo(String userId, String teamId) {
            this.userId = userId;
            this.teamId = teamId;
        }

        public String getUserId() { return userId; }
        public String getTeamId() { return teamId; }
    }
}