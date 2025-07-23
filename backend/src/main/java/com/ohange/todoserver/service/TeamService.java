package com.ohange.todoserver.service;

import com.ohange.todoserver.entity.Team;
import com.ohange.todoserver.entity.TeamMembership;
import com.ohange.todoserver.entity.User;
import com.ohange.todoserver.repository.TeamRepository;
import com.ohange.todoserver.repository.TeamMembershipRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class TeamService {

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private TeamMembershipRepository teamMembershipRepository;

    // 팀 생성
    public Team createTeam(String name, String description, UUID creatorId) {
        // 팀명 중복 체크
        if (teamRepository.findByName(name).isPresent()) {
            throw new IllegalArgumentException("이미 존재하는 팀명입니다.");
        }

        Team team = new Team(name, description);
        Team savedTeam = teamRepository.save(team);

        // 생성자를 팀 관리자로 추가
        User creator = getUserById(creatorId);
        TeamMembership membership = new TeamMembership(savedTeam, creator, TeamMembership.Role.ADMIN);
        teamMembershipRepository.save(membership);

        return savedTeam;
    }

    // 팀에 멤버 추가
    public TeamMembership addTeamMember(UUID teamId, UUID userId, UUID requesterId) {
        // 요청자가 팀 관리자인지 확인
        if (!teamMembershipRepository.isUserTeamAdmin(teamId, requesterId)) {
            throw new IllegalArgumentException("팀 관리자만 멤버를 추가할 수 있습니다.");
        }

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new IllegalArgumentException("팀을 찾을 수 없습니다."));

        // 이미 멤버인지 확인
        if (teamMembershipRepository.existsByTeamIdAndUserId(teamId, userId)) {
            throw new IllegalArgumentException("이미 팀의 멤버입니다.");
        }

        User user = getUserById(userId);
        TeamMembership membership = new TeamMembership(team, user, TeamMembership.Role.MEMBER);
        
        return teamMembershipRepository.save(membership);
    }

    // 팀 멤버 제거
    public void removeTeamMember(UUID teamId, UUID userId, UUID requesterId) {
        // 요청자가 팀 관리자인지 확인 (본인 탈퇴는 허용)
        boolean isSelfLeaving = userId.equals(requesterId);
        boolean isAdmin = teamMembershipRepository.isUserTeamAdmin(teamId, requesterId);
        
        if (!isSelfLeaving && !isAdmin) {
            throw new IllegalArgumentException("팀 관리자만 다른 멤버를 제거할 수 있습니다.");
        }

        TeamMembership membership = teamMembershipRepository.findByTeamIdAndUserId(teamId, userId)
                .orElseThrow(() -> new IllegalArgumentException("팀 멤버를 찾을 수 없습니다."));

        // 마지막 관리자인 경우 제거 불가
        if (membership.getRole() == TeamMembership.Role.ADMIN) {
            List<TeamMembership> admins = teamMembershipRepository.findTeamAdmins(teamId);
            if (admins.size() == 1) {
                throw new IllegalArgumentException("마지막 관리자는 팀을 떠날 수 없습니다.");
            }
        }

        teamMembershipRepository.delete(membership);
    }

    // 멤버 역할 변경
    public TeamMembership changeUserRole(UUID teamId, UUID userId, TeamMembership.Role newRole, UUID requesterId) {
        // 요청자가 팀 관리자인지 확인
        if (!teamMembershipRepository.isUserTeamAdmin(teamId, requesterId)) {
            throw new IllegalArgumentException("팀 관리자만 멤버의 역할을 변경할 수 있습니다.");
        }

        TeamMembership membership = teamMembershipRepository.findByTeamIdAndUserId(teamId, userId)
                .orElseThrow(() -> new IllegalArgumentException("팀 멤버를 찾을 수 없습니다."));

        // 본인의 역할 변경 방지 (다른 관리자에 의해서만 가능)
        if (userId.equals(requesterId)) {
            throw new IllegalArgumentException("본인의 역할은 변경할 수 없습니다.");
        }

        // 마지막 관리자의 역할 변경 방지
        if (membership.getRole() == TeamMembership.Role.ADMIN && newRole != TeamMembership.Role.ADMIN) {
            List<TeamMembership> admins = teamMembershipRepository.findTeamAdmins(teamId);
            if (admins.size() == 1) {
                throw new IllegalArgumentException("마지막 관리자의 역할은 변경할 수 없습니다.");
            }
        }

        membership.setRole(newRole);
        return teamMembershipRepository.save(membership);
    }

    // 팀 정보 조회
    @Transactional(readOnly = true)
    public Team getTeam(UUID teamId, UUID userId) {
        // 사용자가 해당 팀의 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(teamId, userId)) {
            throw new IllegalArgumentException("팀 멤버만 팀 정보를 조회할 수 있습니다.");
        }

        return teamRepository.findById(teamId)
                .orElseThrow(() -> new IllegalArgumentException("팀을 찾을 수 없습니다."));
    }

    // 팀 멤버 목록 조회
    @Transactional(readOnly = true)
    public List<TeamMemberInfo> getTeamMembers(UUID teamId, UUID userId) {
        // 사용자가 해당 팀의 멤버인지 확인
        if (!teamMembershipRepository.existsByTeamIdAndUserId(teamId, userId)) {
            throw new IllegalArgumentException("팀 멤버만 멤버 목록을 조회할 수 있습니다.");
        }

        List<TeamMembership> memberships = teamMembershipRepository.findByTeamId(teamId);
        
        return memberships.stream()
                .map(membership -> new TeamMemberInfo(
                        membership.getUser().getId(),
                        membership.getUser().getName(),
                        membership.getUser().getEmail(),
                        membership.getRole(),
                        membership.getJoinedAt()
                ))
                .collect(Collectors.toList());
    }

    // 사용자가 속한 팀 목록 조회
    @Transactional(readOnly = true)
    public List<Team> getUserTeams(UUID userId) {
        return teamRepository.findTeamsByUserId(userId);
    }

    // 팀 검색
    @Transactional(readOnly = true)
    public List<Team> searchTeams(String keyword) {
        return teamRepository.findByNameContainingIgnoreCase(keyword);
    }

    // 팀 정보 수정
    public Team updateTeam(UUID teamId, String name, String description, UUID requesterId) {
        // 요청자가 팀 관리자인지 확인
        if (!teamMembershipRepository.isUserTeamAdmin(teamId, requesterId)) {
            throw new IllegalArgumentException("팀 관리자만 팀 정보를 수정할 수 있습니다.");
        }

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new IllegalArgumentException("팀을 찾을 수 없습니다."));

        // 팀명 중복 체크 (현재 팀 제외)
        teamRepository.findByName(name).ifPresent(existingTeam -> {
            if (!existingTeam.getId().equals(teamId)) {
                throw new IllegalArgumentException("이미 존재하는 팀명입니다.");
            }
        });

        team.setName(name);
        team.setDescription(description);
        
        return teamRepository.save(team);
    }

    // 팀 삭제
    public void deleteTeam(UUID teamId, UUID requesterId) {
        // 요청자가 팀 관리자인지 확인
        if (!teamMembershipRepository.isUserTeamAdmin(teamId, requesterId)) {
            throw new IllegalArgumentException("팀 관리자만 팀을 삭제할 수 있습니다.");
        }

        Team team = teamRepository.findById(teamId)
                .orElseThrow(() -> new IllegalArgumentException("팀을 찾을 수 없습니다."));

        // 팀에 진행 중인 태스크가 있는지 확인 (추후 구현)
        // if (hasActiveTasks(teamId)) {
        //     throw new IllegalArgumentException("진행 중인 태스크가 있는 팀은 삭제할 수 없습니다.");
        // }

        teamRepository.delete(team);
    }

    // Helper 메서드
    private User getUserById(UUID userId) {
        // UserRepository를 통해 사용자 조회 (추후 구현)
        // 임시로 User 객체 생성
        User user = new User();
        user.setId(userId);
        return user;
    }

    // 팀 멤버 정보 DTO
    public static class TeamMemberInfo {
        private final UUID userId;
        private final String name;
        private final String email;
        private final TeamMembership.Role role;
        private final java.time.LocalDateTime joinedAt;

        public TeamMemberInfo(UUID userId, String name, String email, 
                             TeamMembership.Role role, java.time.LocalDateTime joinedAt) {
            this.userId = userId;
            this.name = name;
            this.email = email;
            this.role = role;
            this.joinedAt = joinedAt;
        }

        // Getters
        public UUID getUserId() { return userId; }
        public String getName() { return name; }
        public String getEmail() { return email; }
        public TeamMembership.Role getRole() { return role; }
        public java.time.LocalDateTime getJoinedAt() { return joinedAt; }
    }
}