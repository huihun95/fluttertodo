package com.ohange.todoserver.repository;

import com.ohange.todoserver.entity.TodoTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TodoTaskRepository extends JpaRepository<TodoTask, UUID> {
    
    // 특정 팀의 모든 태스크 조회
    List<TodoTask> findByTeamIdOrderByCreatedAtDesc(UUID teamId);
    
    // 특정 사용자가 할당받은 태스크들 조회
    List<TodoTask> findByAssigneeIdOrderByCreatedAtDesc(UUID assigneeId);
    
    // 특정 사용자가 요청한 태스크들 조회
    List<TodoTask> findByRequesterIdOrderByCreatedAtDesc(UUID requesterId);
    
    // 특정 상태의 태스크들 조회
    List<TodoTask> findByStatusOrderByCreatedAtDesc(TodoTask.TodoTaskStatus status);
    
    // 특정 팀에서 특정 상태의 태스크들 조회
    List<TodoTask> findByTeamIdAndStatusOrderByCreatedAtDesc(UUID teamId, TodoTask.TodoTaskStatus status);
    
    // 특정 사용자가 할당받은 완료되지 않은 태스크들 조회
    @Query("SELECT t FROM TodoTask t WHERE t.assignee.id = :assigneeId AND t.status != 'COMPLETED' ORDER BY t.deadline ASC")
    List<TodoTask> findPendingTasksByAssignee(@Param("assigneeId") UUID assigneeId);
    
    // 마감일이 임박한 태스크들 조회 (팀별)
    @Query("SELECT t FROM TodoTask t WHERE t.team.id = :teamId AND t.status != 'COMPLETED' AND t.deadline <= CURRENT_DATE + 1 ORDER BY t.deadline ASC")
    List<TodoTask> findUpcomingDeadlineTasks(@Param("teamId") UUID teamId);
}