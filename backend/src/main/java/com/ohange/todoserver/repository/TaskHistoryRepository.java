package com.ohange.todoserver.repository;

import com.ohange.todoserver.entity.TaskHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TaskHistoryRepository extends JpaRepository<TaskHistory, UUID> {
    
    // 특정 태스크의 히스토리 조회 (시간순)
    List<TaskHistory> findByTaskIdOrderByCreatedAtAsc(UUID taskId);
    
    // 특정 사용자가 수행한 액션들 조회
    List<TaskHistory> findByUserIdOrderByCreatedAtDesc(UUID userId);
    
    // 특정 태스크의 특정 액션 타입 히스토리 조회
    @Query("SELECT th FROM TaskHistory th WHERE th.task.id = :taskId AND th.action = :action ORDER BY th.createdAt DESC")
    List<TaskHistory> findByTaskIdAndAction(@Param("taskId") UUID taskId, @Param("action") TaskHistory.ActionType action);
    
    // 특정 팀의 모든 태스크 히스토리 조회
    @Query("SELECT th FROM TaskHistory th WHERE th.task.team.id = :teamId ORDER BY th.createdAt DESC")
    List<TaskHistory> findByTeamId(@Param("teamId") UUID teamId);
}