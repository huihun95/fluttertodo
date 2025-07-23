package com.ohange.todoserver.repository;

import com.ohange.todoserver.entity.TeamMembership;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TeamMembershipRepository extends JpaRepository<TeamMembership, UUID> {
    
    // 특정 팀의 멤버십 조회
    List<TeamMembership> findByTeamId(UUID teamId);
    
    // 특정 사용자가 속한 팀 멤버십 조회
    List<TeamMembership> findByUserId(UUID userId);
    
    // 특정 팀에서 특정 사용자의 멤버십 조회
    Optional<TeamMembership> findByTeamIdAndUserId(UUID teamId, UUID userId);
    
    // 특정 팀의 관리자들 조회
    @Query("SELECT tm FROM TeamMembership tm WHERE tm.team.id = :teamId AND tm.role = 'ADMIN'")
    List<TeamMembership> findTeamAdmins(@Param("teamId") UUID teamId);
    
    // 사용자가 특정 팀의 멤버인지 확인
    boolean existsByTeamIdAndUserId(UUID teamId, UUID userId);
    
    // 사용자가 특정 팀의 관리자인지 확인
    @Query("SELECT COUNT(tm) > 0 FROM TeamMembership tm WHERE tm.team.id = :teamId AND tm.user.id = :userId AND tm.role = 'ADMIN'")
    boolean isUserTeamAdmin(@Param("teamId") UUID teamId, @Param("userId") UUID userId);
}