package com.ohange.todoserver.service;

import com.ohange.todoserver.entity.Notification;
import com.ohange.todoserver.entity.TodoTask;
import com.ohange.todoserver.entity.User;
import com.ohange.todoserver.repository.NotificationRepository;
import com.ohange.todoserver.websocket.TaskWebSocketHandler;
import com.ohange.todoserver.websocket.WebSocketMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Service
public class RealtimeNotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private TaskWebSocketHandler webSocketHandler;

    // 태스크 할당 시 실시간 알림
    public void notifyTaskAssigned(TodoTask task) {
        // 1. DB에 알림 저장
        Notification notification = new Notification();
        notification.setUser(task.getAssignee());
        notification.setTask(task);
        notification.setType(Notification.NotificationType.TASK_ASSIGNED);
        notification.setTitle("새 태스크 할당");
        notification.setMessage(task.getRequester().getName() + "님이 새 태스크를 할당했습니다: " + task.getTitle());
        
        Map<String, Object> data = createTaskAssignedData(task);
        notification.setData(data);
        
        notificationRepository.save(notification);

        // 2. WebSocket으로 실시간 전송
        WebSocketMessage message = WebSocketMessage.taskAssigned(data);
        webSocketHandler.sendToUser(task.getAssignee().getId().toString(), message);
        
        System.out.println("태스크 할당 알림 발송: " + task.getAssignee().getName() + " -> " + task.getTitle());
    }

    // 태스크 완료 시 실시간 알림
    public void notifyTaskCompleted(TodoTask task) {
        // 1. DB에 알림 저장 (요청자에게)
        Notification notification = new Notification();
        notification.setUser(task.getRequester());
        notification.setTask(task);
        notification.setType(Notification.NotificationType.TASK_COMPLETED);
        notification.setTitle("태스크 완료됨");
        notification.setMessage(task.getAssignee().getName() + "님이 태스크를 완료했습니다: " + task.getTitle());
        
        Map<String, Object> data = createTaskCompletedData(task);
        notification.setData(data);
        
        notificationRepository.save(notification);

        // 2. WebSocket으로 요청자에게 실시간 전송
        WebSocketMessage message = WebSocketMessage.taskCompleted(data);
        webSocketHandler.sendToUser(task.getRequester().getId().toString(), message);

        // 3. 팀 전체에게도 상태 업데이트 브로드캐스트
        WebSocketMessage teamUpdate = WebSocketMessage.teamTaskUpdate(
                Map.of("action", "UPDATE", "task", createTaskDto(task)));
        webSocketHandler.broadcastToTeam(task.getTeam().getId().toString(), teamUpdate);
        
        System.out.println("태스크 완료 알림 발송: " + task.getRequester().getName() + " <- " + task.getTitle());
    }

    // 태스크 상태 변경 알림
    public void notifyTaskStatusChanged(TodoTask task, TodoTask.TodoTaskStatus oldStatus, 
                                      TodoTask.TodoTaskStatus newStatus, User changedBy) {
        // 상태 변경자가 아닌 관련자들에게 알림
        User targetUser = changedBy.getId().equals(task.getAssignee().getId()) ? 
                         task.getRequester() : task.getAssignee();

        Notification notification = new Notification();
        notification.setUser(targetUser);
        notification.setTask(task);
        notification.setType(Notification.NotificationType.TASK_STATUS_CHANGED);
        notification.setTitle("태스크 상태 변경");
        notification.setMessage(String.format("%s님이 태스크 상태를 %s에서 %s로 변경했습니다: %s", 
                               changedBy.getName(), getStatusKorean(oldStatus), getStatusKorean(newStatus), task.getTitle()));
        
        Map<String, Object> data = createTaskStatusChangedData(task, oldStatus, newStatus, changedBy);
        notification.setData(data);
        
        notificationRepository.save(notification);

        // WebSocket 실시간 전송
        WebSocketMessage message = WebSocketMessage.taskStatusChanged(data);
        webSocketHandler.sendToUser(targetUser.getId().toString(), message);
        
        // 팀 전체에게도 상태 업데이트 브로드캐스트
        WebSocketMessage teamUpdate = WebSocketMessage.teamTaskUpdate(
                Map.of("action", "UPDATE", "task", createTaskDto(task)));
        webSocketHandler.broadcastToTeam(task.getTeam().getId().toString(), teamUpdate);
        
        System.out.println("태스크 상태 변경 알림 발송: " + targetUser.getName() + " -> " + task.getTitle());
    }

    // 태스크 할당 데이터 생성
    private Map<String, Object> createTaskAssignedData(TodoTask task) {
        Map<String, Object> data = new HashMap<>();
        data.put("taskId", task.getId().toString());
        data.put("title", task.getTitle());
        data.put("content", task.getContent());
        data.put("requester", task.getRequester().getName());
        data.put("deadline", task.getDeadline() != null ? 
                task.getDeadline().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        data.put("teamId", task.getTeam().getId().toString());
        data.put("teamName", task.getTeam().getName());
        return data;
    }

    // 태스크 완료 데이터 생성
    private Map<String, Object> createTaskCompletedData(TodoTask task) {
        Map<String, Object> data = new HashMap<>();
        data.put("taskId", task.getId().toString());
        data.put("title", task.getTitle());
        data.put("assignee", task.getAssignee().getName());
        data.put("completedAt", task.getCompletedAt() != null ? 
                task.getCompletedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        data.put("completionNote", task.getCompletionNote());
        data.put("teamId", task.getTeam().getId().toString());
        data.put("teamName", task.getTeam().getName());
        return data;
    }

    // 태스크 상태 변경 데이터 생성
    private Map<String, Object> createTaskStatusChangedData(TodoTask task, TodoTask.TodoTaskStatus oldStatus, 
                                                           TodoTask.TodoTaskStatus newStatus, User changedBy) {
        Map<String, Object> data = new HashMap<>();
        data.put("taskId", task.getId().toString());
        data.put("title", task.getTitle());
        data.put("oldStatus", oldStatus.name());
        data.put("newStatus", newStatus.name());
        data.put("changedBy", changedBy.getName());
        data.put("teamId", task.getTeam().getId().toString());
        return data;
    }

    // 태스크 DTO 생성 (팀 브로드캐스트용)
    private Map<String, Object> createTaskDto(TodoTask task) {
        Map<String, Object> taskDto = new HashMap<>();
        taskDto.put("id", task.getId().toString());
        taskDto.put("title", task.getTitle());
        taskDto.put("content", task.getContent());
        taskDto.put("status", task.getStatus().name());
        taskDto.put("requester", Map.of("id", task.getRequester().getId().toString(), "name", task.getRequester().getName()));
        taskDto.put("assignee", Map.of("id", task.getAssignee().getId().toString(), "name", task.getAssignee().getName()));
        taskDto.put("deadline", task.getDeadline() != null ? 
                task.getDeadline().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        taskDto.put("createdAt", task.getCreatedAt() != null ? 
                task.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        taskDto.put("completedAt", task.getCompletedAt() != null ? 
                task.getCompletedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null);
        return taskDto;
    }

    // 상태를 한국어로 변환
    private String getStatusKorean(TodoTask.TodoTaskStatus status) {
        switch (status) {
            case PENDING: return "대기중";
            case IN_PROGRESS: return "진행중";
            case COMPLETED: return "완료";
            case CANCELLED: return "취소";
            default: return status.name();
        }
    }
}