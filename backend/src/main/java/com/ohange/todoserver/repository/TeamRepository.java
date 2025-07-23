package com.ohange.todoserver.repository;

import com.ohange.todoserver.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TeamRepository extends JpaRepository<Team, UUID> {
    
    // 팀명으로 검색
    Optional<Team> findByName(String name);
    
    // 사용자가 속한 팀들 조회
    @Query("SELECT DISTINCT t FROM Team t JOIN t.memberships m WHERE m.user.id = :userId")
    List<Team> findTeamsByUserId(@Param("userId") UUID userId);
    
    // 팀명에 특정 키워드가 포함된 팀들 검색
    List<Team> findByNameContainingIgnoreCase(String keyword);
}