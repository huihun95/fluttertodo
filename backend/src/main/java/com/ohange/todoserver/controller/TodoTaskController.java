package com.ohange.todoserver.controller;

import com.ohange.todoserver.entity.TodoTask;
import com.ohange.todoserver.service.TodoTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tasks")
@CrossOrigin(origins = "*") // 개발용, 운영 시 제한 필요
public class TodoTaskController {

    @Autowired
    private TodoTaskService todoTaskService;

    // 태스크 생성 및 할당
    @PostMapping
    public ResponseEntity<TaskResponse> createTask(@RequestBody CreateTaskRequest request) {
        try {
            TodoTask task = todoTaskService.createAndAssignTask(
                    request.getTitle(),
                    request.getContent(),
                    request.getRequesterId(),
                    request.getAssigneeId(),
                    request.getTeamId(),
                    request.getDeadline()
            );
            
            return ResponseEntity.ok(new TaskResponse(task, "태스크가 성공적으로 생성되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TaskResponse(null, e.getMessage()));
        }
    }

    // 태스크 완료
    @PutMapping("/{taskId}/complete")
    public ResponseEntity<TaskResponse> completeTask(
            @PathVariable UUID taskId,
            @RequestBody CompleteTaskRequest request) {
        try {
            TodoTask task = todoTaskService.completeTask(taskId, request.getUserId(), request.getCompletionNote());
            return ResponseEntity.ok(new TaskResponse(task, "태스크가 완료되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TaskResponse(null, e.getMessage()));
        }
    }

    // 태스크 상태 변경
    @PutMapping("/{taskId}/status")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @PathVariable UUID taskId,
            @RequestBody UpdateStatusRequest request) {
        try {
            TodoTask task = todoTaskService.updateTaskStatus(taskId, request.getUserId(), request.getStatus());
            return ResponseEntity.ok(new TaskResponse(task, "태스크 상태가 변경되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TaskResponse(null, e.getMessage()));
        }
    }

    // 태스크 재할당
    @PutMapping("/{taskId}/assign")
    public ResponseEntity<TaskResponse> reassignTask(
            @PathVariable UUID taskId,
            @RequestBody ReassignTaskRequest request) {
        try {
            TodoTask task = todoTaskService.reassignTask(taskId, request.getNewAssigneeId(), request.getRequesterId());
            return ResponseEntity.ok(new TaskResponse(task, "태스크가 재할당되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TaskResponse(null, e.getMessage()));
        }
    }

    // 팀의 모든 태스크 조회
    @GetMapping("/team/{teamId}")
    public ResponseEntity<List<TodoTask>> getTeamTasks(
            @PathVariable UUID teamId,
            @RequestParam UUID userId) {
        try {
            List<TodoTask> tasks = todoTaskService.getTeamTasks(teamId, userId);
            return ResponseEntity.ok(tasks);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 사용자의 태스크들 조회
    @GetMapping("/my")
    public ResponseEntity<TodoTaskService.UserTasksResponse> getUserTasks(@RequestParam UUID userId) {
        TodoTaskService.UserTasksResponse response = todoTaskService.getUserTasks(userId);
        return ResponseEntity.ok(response);
    }

    // 사용자의 완료되지 않은 태스크들 조회
    @GetMapping("/my/pending")
    public ResponseEntity<List<TodoTask>> getPendingTasks(@RequestParam UUID userId) {
        List<TodoTask> tasks = todoTaskService.getPendingTasksByUser(userId);
        return ResponseEntity.ok(tasks);
    }

    // 마감일이 임박한 태스크들 조회
    @GetMapping("/team/{teamId}/upcoming")
    public ResponseEntity<List<TodoTask>> getUpcomingDeadlineTasks(@PathVariable UUID teamId) {
        List<TodoTask> tasks = todoTaskService.getUpcomingDeadlineTasks(teamId);
        return ResponseEntity.ok(tasks);
    }

    // 특정 태스크 조회
    @GetMapping("/{taskId}")
    public ResponseEntity<TodoTask> getTask(@PathVariable UUID taskId) {
        // todoTaskRepository.findById()로 직접 조회하거나 서비스에 메서드 추가
        return ResponseEntity.ok(null); // 추후 구현
    }

    // DTO 클래스들
    public static class CreateTaskRequest {
        private String title;
        private String content;
        private UUID requesterId;
        private UUID assigneeId;
        private UUID teamId;
        private LocalDateTime deadline;

        // Getters and Setters
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
        public UUID getRequesterId() { return requesterId; }
        public void setRequesterId(UUID requesterId) { this.requesterId = requesterId; }
        public UUID getAssigneeId() { return assigneeId; }
        public void setAssigneeId(UUID assigneeId) { this.assigneeId = assigneeId; }
        public UUID getTeamId() { return teamId; }
        public void setTeamId(UUID teamId) { this.teamId = teamId; }
        public LocalDateTime getDeadline() { return deadline; }
        public void setDeadline(LocalDateTime deadline) { this.deadline = deadline; }
    }

    public static class CompleteTaskRequest {
        private UUID userId;
        private String completionNote;

        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }
        public String getCompletionNote() { return completionNote; }
        public void setCompletionNote(String completionNote) { this.completionNote = completionNote; }
    }

    public static class UpdateStatusRequest {
        private UUID userId;
        private TodoTask.TodoTaskStatus status;

        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }
        public TodoTask.TodoTaskStatus getStatus() { return status; }
        public void setStatus(TodoTask.TodoTaskStatus status) { this.status = status; }
    }

    public static class ReassignTaskRequest {
        private UUID newAssigneeId;
        private UUID requesterId;

        public UUID getNewAssigneeId() { return newAssigneeId; }
        public void setNewAssigneeId(UUID newAssigneeId) { this.newAssigneeId = newAssigneeId; }
        public UUID getRequesterId() { return requesterId; }
        public void setRequesterId(UUID requesterId) { this.requesterId = requesterId; }
    }

    public static class TaskResponse {
        private TodoTask task;
        private String message;

        public TaskResponse(TodoTask task, String message) {
            this.task = task;
            this.message = message;
        }

        public TodoTask getTask() { return task; }
        public String getMessage() { return message; }
    }
}