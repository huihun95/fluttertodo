package com.ohange.todoserver.repository;

import com.ohange.todoserver.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    
    // 특정 사용자의 알림들 조회 (최신순)
    List<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId);
    
    // 특정 사용자의 알림들 페이징 조회
    Page<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    
    // 특정 사용자의 읽지 않은 알림들 조회
    List<Notification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(UUID userId);
    
    // 특정 사용자의 읽지 않은 알림 개수
    long countByUserIdAndIsReadFalse(UUID userId);
    
    // 특정 태스크와 관련된 알림들 조회
    List<Notification> findByTaskIdOrderByCreatedAtDesc(UUID taskId);
    
    // 특정 사용자의 알림을 모두 읽음으로 표시
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.user.id = :userId AND n.isRead = false")
    int markAllAsReadByUserId(@Param("userId") UUID userId);
    
    // 특정 알림을 읽음으로 표시
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.id = :notificationId")
    int markAsRead(@Param("notificationId") UUID notificationId);
}