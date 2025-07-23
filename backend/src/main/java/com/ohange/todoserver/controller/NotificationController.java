package com.ohange.todoserver.controller;

import com.ohange.todoserver.entity.Notification;
import com.ohange.todoserver.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*") // 개발용, 운영 시 제한 필요
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    // 사용자의 모든 알림 조회
    @GetMapping("/my")
    public ResponseEntity<List<Notification>> getMyNotifications(@RequestParam UUID userId) {
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return ResponseEntity.ok(notifications);
    }

    // 사용자의 알림 페이징 조회
    @GetMapping("/my/paged")
    public ResponseEntity<Page<Notification>> getMyNotificationsPaged(
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return ResponseEntity.ok(notifications);
    }

    // 읽지 않은 알림 조회
    @GetMapping("/my/unread")
    public ResponseEntity<List<Notification>> getUnreadNotifications(@RequestParam UUID userId) {
        List<Notification> notifications = notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
        return ResponseEntity.ok(notifications);
    }

    // 읽지 않은 알림 개수 조회
    @GetMapping("/my/unread/count")
    public ResponseEntity<NotificationCountResponse> getUnreadNotificationCount(@RequestParam UUID userId) {
        long count = notificationRepository.countByUserIdAndIsReadFalse(userId);
        return ResponseEntity.ok(new NotificationCountResponse(count));
    }

    // 특정 알림을 읽음으로 표시
    @PutMapping("/{notificationId}/read")
    public ResponseEntity<String> markAsRead(@PathVariable UUID notificationId) {
        int updated = notificationRepository.markAsRead(notificationId);
        if (updated > 0) {
            return ResponseEntity.ok("알림이 읽음으로 표시되었습니다.");
        } else {
            return ResponseEntity.badRequest().body("알림을 찾을 수 없습니다.");
        }
    }

    // 사용자의 모든 알림을 읽음으로 표시
    @PutMapping("/my/read-all")
    public ResponseEntity<String> markAllAsRead(@RequestParam UUID userId) {
        int updated = notificationRepository.markAllAsReadByUserId(userId);
        return ResponseEntity.ok(updated + "개의 알림이 읽음으로 표시되었습니다.");
    }

    // 특정 태스크와 관련된 알림들 조회
    @GetMapping("/task/{taskId}")
    public ResponseEntity<List<Notification>> getTaskNotifications(@PathVariable UUID taskId) {
        List<Notification> notifications = notificationRepository.findByTaskIdOrderByCreatedAtDesc(taskId);
        return ResponseEntity.ok(notifications);
    }

    // 알림 삭제
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<String> deleteNotification(@PathVariable UUID notificationId) {
        if (notificationRepository.existsById(notificationId)) {
            notificationRepository.deleteById(notificationId);
            return ResponseEntity.ok("알림이 삭제되었습니다.");
        } else {
            return ResponseEntity.badRequest().body("알림을 찾을 수 없습니다.");
        }
    }

    // DTO 클래스
    public static class NotificationCountResponse {
        private final long count;

        public NotificationCountResponse(long count) {
            this.count = count;
        }

        public long getCount() { return count; }
    }
}