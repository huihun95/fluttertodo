package com.ohange.todoserver.controller;

import com.ohange.todoserver.entity.Team;
import com.ohange.todoserver.entity.TeamMembership;
import com.ohange.todoserver.service.TeamService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/teams")
@CrossOrigin(origins = "*") // 개발용, 운영 시 제한 필요
public class TeamController {

    @Autowired
    private TeamService teamService;

    // 팀 생성
    @PostMapping
    public ResponseEntity<TeamResponse> createTeam(@RequestBody CreateTeamRequest request) {
        try {
            Team team = teamService.createTeam(request.getName(), request.getDescription(), request.getCreatorId());
            return ResponseEntity.ok(new TeamResponse(team, "팀이 성공적으로 생성되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TeamResponse(null, e.getMessage()));
        }
    }

    // 팀에 멤버 추가
    @PostMapping("/{teamId}/members")
    public ResponseEntity<MemberResponse> addTeamMember(
            @PathVariable UUID teamId,
            @RequestBody AddMemberRequest request) {
        try {
            TeamMembership membership = teamService.addTeamMember(teamId, request.getUserId(), request.getRequesterId());
            return ResponseEntity.ok(new MemberResponse(membership, "멤버가 성공적으로 추가되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new MemberResponse(null, e.getMessage()));
        }
    }

    // 팀 멤버 제거
    @DeleteMapping("/{teamId}/members/{userId}")
    public ResponseEntity<String> removeTeamMember(
            @PathVariable UUID teamId,
            @PathVariable UUID userId,
            @RequestParam UUID requesterId) {
        try {
            teamService.removeTeamMember(teamId, userId, requesterId);
            return ResponseEntity.ok("멤버가 성공적으로 제거되었습니다.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 멤버 역할 변경
    @PutMapping("/{teamId}/members/{userId}/role")
    public ResponseEntity<MemberResponse> changeUserRole(
            @PathVariable UUID teamId,
            @PathVariable UUID userId,
            @RequestBody ChangeRoleRequest request) {
        try {
            TeamMembership membership = teamService.changeUserRole(teamId, userId, request.getRole(), request.getRequesterId());
            return ResponseEntity.ok(new MemberResponse(membership, "멤버 역할이 성공적으로 변경되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new MemberResponse(null, e.getMessage()));
        }
    }

    // 팀 정보 조회
    @GetMapping("/{teamId}")
    public ResponseEntity<Team> getTeam(
            @PathVariable UUID teamId,
            @RequestParam UUID userId) {
        try {
            Team team = teamService.getTeam(teamId, userId);
            return ResponseEntity.ok(team);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 팀 멤버 목록 조회
    @GetMapping("/{teamId}/members")
    public ResponseEntity<List<TeamService.TeamMemberInfo>> getTeamMembers(
            @PathVariable UUID teamId,
            @RequestParam UUID userId) {
        try {
            List<TeamService.TeamMemberInfo> members = teamService.getTeamMembers(teamId, userId);
            return ResponseEntity.ok(members);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    // 사용자가 속한 팀 목록 조회
    @GetMapping("/my")
    public ResponseEntity<List<Team>> getUserTeams(@RequestParam UUID userId) {
        List<Team> teams = teamService.getUserTeams(userId);
        return ResponseEntity.ok(teams);
    }

    // 팀 검색
    @GetMapping("/search")
    public ResponseEntity<List<Team>> searchTeams(@RequestParam String keyword) {
        List<Team> teams = teamService.searchTeams(keyword);
        return ResponseEntity.ok(teams);
    }

    // 팀 정보 수정
    @PutMapping("/{teamId}")
    public ResponseEntity<TeamResponse> updateTeam(
            @PathVariable UUID teamId,
            @RequestBody UpdateTeamRequest request) {
        try {
            Team team = teamService.updateTeam(teamId, request.getName(), request.getDescription(), request.getRequesterId());
            return ResponseEntity.ok(new TeamResponse(team, "팀 정보가 성공적으로 수정되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new TeamResponse(null, e.getMessage()));
        }
    }

    // 팀 삭제
    @DeleteMapping("/{teamId}")
    public ResponseEntity<String> deleteTeam(
            @PathVariable UUID teamId,
            @RequestParam UUID requesterId) {
        try {
            teamService.deleteTeam(teamId, requesterId);
            return ResponseEntity.ok("팀이 성공적으로 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // DTO 클래스들
    public static class CreateTeamRequest {
        private String name;
        private String description;
        private UUID creatorId;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public UUID getCreatorId() { return creatorId; }
        public void setCreatorId(UUID creatorId) { this.creatorId = creatorId; }
    }

    public static class AddMemberRequest {
        private UUID userId;
        private UUID requesterId;

        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }
        public UUID getRequesterId() { return requesterId; }
        public void setRequesterId(UUID requesterId) { this.requesterId = requesterId; }
    }

    public static class ChangeRoleRequest {
        private TeamMembership.Role role;
        private UUID requesterId;

        public TeamMembership.Role getRole() { return role; }
        public void setRole(TeamMembership.Role role) { this.role = role; }
        public UUID getRequesterId() { return requesterId; }
        public void setRequesterId(UUID requesterId) { this.requesterId = requesterId; }
    }

    public static class UpdateTeamRequest {
        private String name;
        private String description;
        private UUID requesterId;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public UUID getRequesterId() { return requesterId; }
        public void setRequesterId(UUID requesterId) { this.requesterId = requesterId; }
    }

    public static class TeamResponse {
        private Team team;
        private String message;

        public TeamResponse(Team team, String message) {
            this.team = team;
            this.message = message;
        }

        public Team getTeam() { return team; }
        public String getMessage() { return message; }
    }

    public static class MemberResponse {
        private TeamMembership membership;
        private String message;

        public MemberResponse(TeamMembership membership, String message) {
            this.membership = membership;
            this.message = message;
        }

        public TeamMembership getMembership() { return membership; }
        public String getMessage() { return message; }
    }
}