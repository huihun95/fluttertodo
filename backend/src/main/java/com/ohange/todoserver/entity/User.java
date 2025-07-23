package com.ohange.todoserver.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 100)
    private String name;

    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // 내가 할당한 태스크들
    @OneToMany(mappedBy = "requester", fetch = FetchType.LAZY)
    private List<TodoTask> requestedTasks;

    // 내가 할당받은 태스크들
    @OneToMany(mappedBy = "assignee", fetch = FetchType.LAZY)
    private List<TodoTask> assignedTasks;

    // 내 알림들
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Notification> notifications;

    // 기본 생성자
    public User() {}

    // 생성자
    public User(String email, String password, String name) {
        this.email = email;
        this.password = password;
        this.name = name;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public List<TodoTask> getRequestedTasks() {
        return requestedTasks;
    }

    public void setRequestedTasks(List<TodoTask> requestedTasks) {
        this.requestedTasks = requestedTasks;
    }

    public List<TodoTask> getAssignedTasks() {
        return assignedTasks;
    }

    public void setAssignedTasks(List<TodoTask> assignedTasks) {
        this.assignedTasks = assignedTasks;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<Notification> notifications) {
        this.notifications = notifications;
    }
}