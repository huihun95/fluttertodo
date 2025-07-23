package com.ohange.todoserver.service;

import com.ohange.todoserver.entity.*;
import com.ohange.todoserver.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class TodoTaskService {

    @Autowired
    private TodoTaskRepository todoTaskRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private TeamMembershipRepository teamMembershipRepository;

    @Autowired
    private TaskHistoryRepository taskHistoryRepository;

    @Autowired
    private RealtimeNotificationService notificationService;

    // 태스크 생성 및 할당
    public TodoTask createAndAssignTask(String title, String content, UUID requesterId, 
                                      UUID assigneeId, UUID teamId, LocalDateTime deadline) {
        
        // 권한 검증: 요청자가 해당 팀의 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(teamId, requesterId)) {
            throw new IllegalArgumentException("팀 멤버만 태스크를 생성할 수 있습니다.");
        }

        // 할당받을 사용자도 팀 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(teamId, assigneeId)) {
            throw new IllegalArgumentException("팀 멤버에게만 태스크를 할당할 수 있습니다.");
        }

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new IllegalArgumentException("팀을 찾을 수 없습니다."));
        
        User requester = getUserById(requesterId);
        User assignee = getUserById(assigneeId);

        // 태스크 생성
        TodoTask task = new TodoTask(title, content, requester, assignee, team, deadline);
        task.setStatus(TodoTask.TodoTaskStatus.PENDING);
        
        TodoTask savedTask = todoTaskRepository.save(task);

        // 히스토리 기록
        TaskHistory history = new TaskHistory(savedTask, requester, TaskHistory.ActionType.CREATED, 
                                            null, "PENDING", "태스크가 생성되었습니다.");
        taskHistoryRepository.save(history);

        // 할당 히스토리
        TaskHistory assignHistory = new TaskHistory(savedTask, requester, TaskHistory.ActionType.ASSIGNED, 
                                                  null, assignee.getName(), "태스크가 할당되었습니다.");
        taskHistoryRepository.save(assignHistory);

        // 실시간 알림 발송
        notificationService.notifyTaskAssigned(savedTask);

        return savedTask;
    }

    // 태스크 완료
    public TodoTask completeTask(UUID taskId, UUID userId, String completionNote) {
        TodoTask task = todoTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("태스크를 찾을 수 없습니다."));

        // 권한 체크: 할당된 사용자만 완료 가능
        if (!task.getAssignee().getId().equals(userId)) {
            throw new IllegalArgumentException("태스크를 완료할 권한이 없습니다.");
        }

        // 이미 완료된 태스크인지 확인
        if (task.getStatus() == TodoTask.TodoTaskStatus.COMPLETED) {
            throw new IllegalArgumentException("이미 완료된 태스크입니다.");
        }

        // 태스크 완료 처리
        TodoTask.TodoTaskStatus oldStatus = task.getStatus();
        task.setStatus(TodoTask.TodoTaskStatus.COMPLETED);
        task.setCompletedAt(LocalDateTime.now());
        task.setCompletionNote(completionNote);

        TodoTask savedTask = todoTaskRepository.save(task);

        // 히스토리 기록
        TaskHistory history = new TaskHistory(savedTask, task.getAssignee(), TaskHistory.ActionType.COMPLETED,
                                            oldStatus.name(), "COMPLETED", completionNote);
        taskHistoryRepository.save(history);

        // 실시간 완료 알림 발송
        notificationService.notifyTaskCompleted(savedTask);

        return savedTask;
    }

    // 태스크 상태 변경
    public TodoTask updateTaskStatus(UUID taskId, UUID userId, TodoTask.TodoTaskStatus newStatus) {
        TodoTask task = todoTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("태스크를 찾을 수 없습니다."));

        // 권한 체크: 할당된 사용자나 요청자만 상태 변경 가능
        if (!task.getAssignee().getId().equals(userId) && !task.getRequester().getId().equals(userId)) {
            throw new IllegalArgumentException("태스크 상태를 변경할 권한이 없습니다.");
        }

        TodoTask.TodoTaskStatus oldStatus = task.getStatus();
        task.setStatus(newStatus);
        
        TodoTask savedTask = todoTaskRepository.save(task);

        // 히스토리 기록
        User user = getUserById(userId);
        TaskHistory history = new TaskHistory(savedTask, user, TaskHistory.ActionType.STATUS_CHANGED,
                                            oldStatus.name(), newStatus.name(), "태스크 상태가 변경되었습니다.");
        taskHistoryRepository.save(history);

        // 상태 변경 알림
        notificationService.notifyTaskStatusChanged(savedTask, oldStatus, newStatus, user);

        return savedTask;
    }

    // 태스크 재할당
    public TodoTask reassignTask(UUID taskId, UUID newAssigneeId, UUID requesterId) {
        TodoTask task = todoTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("태스크를 찾을 수 없습니다."));

        // 권한 체크: 원래 요청자나 팀 관리자만 재할당 가능
        boolean isOriginalRequester = task.getRequester().getId().equals(requesterId);
        boolean isTeamAdmin = teamMembershipRepository.isUserTeamAdmin(task.getTeam().getId(), requesterId);
        
        if (!isOriginalRequester && !isTeamAdmin) {
            throw new IllegalArgumentException("태스크를 재할당할 권한이 없습니다.");
        }

        // 새 담당자가 팀 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(task.getTeam().getId(), newAssigneeId)) {
            throw new IllegalArgumentException("팀 멤버에게만 태스크를 할당할 수 있습니다.");
        }

        User oldAssignee = task.getAssignee();
        User newAssignee = getUserById(newAssigneeId);
        task.setAssignee(newAssignee);

        TodoTask savedTask = todoTaskRepository.save(task);

        // 히스토리 기록
        User requester = getUserById(requesterId);
        TaskHistory history = new TaskHistory(savedTask, requester, TaskHistory.ActionType.ASSIGNED,
                                            oldAssignee.getName(), newAssignee.getName(), "태스크가 재할당되었습니다.");
        taskHistoryRepository.save(history);

        // 새 담당자에게 알림
        notificationService.notifyTaskAssigned(savedTask);

        return savedTask;
    }

    // 팀의 모든 태스크 조회
    @Transactional(readOnly = true)
    public List<TodoTask> getTeamTasks(UUID teamId, UUID userId) {
        // 사용자가 해당 팀의 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(teamId, userId)) {
            throw new IllegalArgumentException("팀 멤버만 팀의 태스크를 조회할 수 있습니다.");
        }

        return todoTaskRepository.findByTeamIdOrderByCreatedAtDesc(teamId);
    }

    // 사용자의 태스크들 조회 (할당받은 것 + 요청한 것)
    @Transactional(readOnly = true)
    public UserTasksResponse getUserTasks(UUID userId) {
        List<TodoTask> assignedTasks = todoTaskRepository.findByAssigneeIdOrderByCreatedAtDesc(userId);
        List<TodoTask> requestedTasks = todoTaskRepository.findByRequesterIdOrderByCreatedAtDesc(userId);
        
        return new UserTasksResponse(assignedTasks, requestedTasks);
    }

    // 사용자의 완료되지 않은 태스크들 조회
    @Transactional(readOnly = true)
    public List<TodoTask> getPendingTasksByUser(UUID userId) {
        return todoTaskRepository.findPendingTasksByAssignee(userId);
    }

    // 마감일이 임박한 태스크들 조회
    @Transactional(readOnly = true)
    public List<TodoTask> getUpcomingDeadlineTasks(UUID teamId) {
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        return todoTaskRepository.findUpcomingDeadlineTasks(teamId, tomorrow);
    }

    // Helper 메서드
    private User getUserById(UUID userId) {
        // UserRepository를 통해 사용자 조회 (추후 구현)
        // 임시로 User 객체 생성
        User user = new User();
        user.setId(userId);
        return user;
    }

    // 응답 DTO 클래스
    public static class UserTasksResponse {
        private final List<TodoTask> assigned;
        private final List<TodoTask> requested;

        public UserTasksResponse(List<TodoTask> assigned, List<TodoTask> requested) {
            this.assigned = assigned;
            this.requested = requested;
        }

        public List<TodoTask> getAssigned() { return assigned; }
        public List<TodoTask> getRequested() { return requested; }
    }
}