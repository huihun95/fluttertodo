package com.ohange.todoserver.websocket;

import java.util.Map;

public class WebSocketMessage {
    private String type;
    private Map<String, Object> data;
    private long timestamp;

    // 기본 생성자
    public WebSocketMessage() {
        this.timestamp = System.currentTimeMillis();
    }

    // 생성자
    public WebSocketMessage(String type, Map<String, Object> data) {
        this.type = type;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }

    // 정적 팩토리 메서드들
    public static WebSocketMessage taskAssigned(Map<String, Object> taskData) {
        return new WebSocketMessage("TASK_ASSIGNED", taskData);
    }

    public static WebSocketMessage taskCompleted(Map<String, Object> taskData) {
        return new WebSocketMessage("TASK_COMPLETED", taskData);
    }

    public static WebSocketMessage taskStatusChanged(Map<String, Object> taskData) {
        return new WebSocketMessage("TASK_STATUS_CHANGED", taskData);
    }

    public static WebSocketMessage teamTaskUpdate(Map<String, Object> taskData) {
        return new WebSocketMessage("TEAM_TASK_UPDATE", taskData);
    }

    public static WebSocketMessage notification(Map<String, Object> notificationData) {
        return new WebSocketMessage("NOTIFICATION", notificationData);
    }

    public static WebSocketMessage error(String errorMessage) {
        return new WebSocketMessage("ERROR", Map.of("message", errorMessage));
    }

    // Getters and Setters
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public void setData(Map<String, Object> data) {
        this.data = data;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "WebSocketMessage{" +
                "type='" + type + '\'' +
                ", data=" + data +
                ", timestamp=" + timestamp +
                '}';
    }
}