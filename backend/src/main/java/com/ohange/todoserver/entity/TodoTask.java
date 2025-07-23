package com.ohange.todoserver.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "todo_tasks")
public class TodoTask {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    // 할당한 사람 (요청자)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id")
    private User requester;

    // 할당받은 사람 (담당자)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignee_id")
    private User assignee;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TodoTaskStatus status = TodoTaskStatus.PENDING;

    private LocalDateTime deadline;

    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // 팀 정보 추가
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;

    // 완료 관련 필드들
    @Column(columnDefinition = "TEXT")
    private String completionNote;

    private LocalDateTime completedAt;

    // 태스크 관련 알림들
    @OneToMany(mappedBy = "task", fetch = FetchType.LAZY)
    private List<Notification> notifications;

    // 태스크 히스토리
    @OneToMany(mappedBy = "task", fetch = FetchType.LAZY)
    private List<TaskHistory> history;

    // 기본 생성자
    public TodoTask() {}

    // 생성자
    public TodoTask(String title, String content, User requester, User assignee, Team team, LocalDateTime deadline) {
        this.title = title;
        this.content = content;
        this.requester = requester;
        this.assignee = assignee;
        this.team = team;
        this.deadline = deadline;
    }

    // TodoTaskStatus enum
    public enum TodoTaskStatus {
        PENDING,     // 대기중
        IN_PROGRESS, // 진행중
        COMPLETED,   // 완료
        CANCELLED    // 취소
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public User getRequester() {
        return requester;
    }

    public void setRequester(User requester) {
        this.requester = requester;
    }

    public User getAssignee() {
        return assignee;
    }

    public void setAssignee(User assignee) {
        this.assignee = assignee;
    }

    public TodoTaskStatus getStatus() {
        return status;
    }

    public void setStatus(TodoTaskStatus status) {
        this.status = status;
    }

    public LocalDateTime getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDateTime deadline) {
        this.deadline = deadline;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }

    public List<TaskHistory> getHistory() {
        return history;
    }

    public void setHistory(List<TaskHistory> history) {
        this.history = history;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public String getCompletionNote() {
        return completionNote;
    }

    public void setCompletionNote(String completionNote) {
        this.completionNote = completionNote;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
}