# FlutterTodo 프로젝트 계획서

## 📱 프로젝트 개요
**이름**: FlutterTodo  
**타입**: macOS 데스크톱 태스크 관리 애플리케이션  
**기술 스택**: Flutter 3.8+, Riverpod, macOS 네이티브 기능  

## 🎯 프로젝트 목표
1. **개인 생산성 향상을 위한 빠른 태스크 관리**
2. **팀 협업을 위한 태스크 할당 및 공유 시스템 구축**
3. **macOS 환경에 최적화된 직관적인 사용자 경험 제공**

## 📋 현재 구현된 기능 (v1.0)

### 🔥 핵심 기능
- **전역 단축키**: Command + , (콤마)로 언제든지 Spotlight 모드 활성화
- **Spotlight 모드**: macOS Spotlight과 유사한 빠른 태스크 생성 인터페이스
- **플로팅 윈도우**: 항상 최상위 표시, 투명 배경으로 자연스러운 UI
- **로컬 데이터 저장**: SharedPreferences를 통한 오프라인 데이터 관리

### 📊 태스크 관리 기능
- **태스크 CRUD**: 생성, 수정, 삭제, 상태 변경
- **태스크 필터링**: 오늘 마감, 전체 태스크, 상태별 필터
- **마감일 알림**: 마감일 초과 시 시각적 강조 표시
- **담당자 시스템**: 요청자/담당자 구분

### 🎨 UI/UX 특징
- **반응형 UI**: 마우스 호버 시 인터랙션
- **애니메이션**: 스케일/투명도 효과
- **키보드 네비게이션**: ESC/Enter 키 지원
- **접근성**: macOS 접근성 권한 안내

### 🏗️ 아키텍처
- **상태 관리**: Riverpod Provider 패턴
- **서비스 계층**: GlobalHotkey, WindowManager 분리
- **컴포넌트 구조**: 재사용 가능한 View Component 설계
- **데이터 모델**: TaskModel with JSON serialization

## 🚀 향후 개발 계획 (v2.0)

### 🌐 서버 연동 기능
- **백엔드 API**: Spring Boot 기반 REST API 서버
- **실시간 동기화**: WebSocket을 통한 실시간 태스크 업데이트
- **클라우드 저장**: PostgreSQL 기반 중앙 데이터베이스
- **오프라인 모드**: 로컬 캐싱 + 온라인 동기화

### 👥 팀 협업 기능
- **사용자 관리**: 회원가입, 로그인, 프로필 관리
- **팀/프로젝트**: 여러 팀 참여, 프로젝트별 태스크 분류
- **태스크 할당**: 다른 팀원에게 태스크 할당/위임
- **알림 시스템**: 태스크 할당/변경 시 실시간 알림
- **댓글/피드백**: 태스크별 댓글 및 진행 상황 공유

### 📱 크로스 플랫폼 확장
- **모바일 앱**: iOS/Android 클라이언트 개발
- **웹 대시보드**: 관리자용 웹 인터페이스
- **Windows/Linux**: 다른 데스크톱 OS 지원

### 📈 고급 기능
- **태스크 템플릿**: 자주 사용하는 태스크 유형을 템플릿으로 저장
- **시간 추적**: 태스크별 작업 시간 측정
- **리포트/분석**: 생산성 분석, 완료 통계
- **태그 시스템**: 태스크 분류를 위한 태그 기능
- **우선순위**: High/Medium/Low 우선순위 설정
- **반복 태스크**: 주기적으로 반복되는 태스크 설정

## 🔧 기술적 개선사항

### 🏛️ 아키텍처 개선
- **Clean Architecture**: 도메인, 데이터, 프레젠테이션 계층 분리
- **Repository Pattern**: 데이터 소스 추상화
- **UseCase/Interactor**: 비즈니스 로직 분리
- **Dependency Injection**: 의존성 주입 패턴 적용

### 🛠️ 개발 도구
- **CI/CD**: GitHub Actions를 통한 자동 빌드/테스트
- **테스팅**: Unit/Widget/Integration 테스트 커버리지 확대
- **코드 품질**: Lint, 정적 분석, 코드 리뷰 자동화
- **문서화**: API 문서, 사용자 가이드 작성

### 🔐 보안 및 성능
- **인증/인가**: JWT 기반 토큰 인증
- **데이터 암호화**: 민감 정보 암호화 저장
- **성능 최적화**: 지연 로딩, 캐싱 전략
- **에러 핸들링**: 전역 에러 처리 및 로깅

## 📅 개발 로드맵

### Phase 1: 서버 기반 전환 (2개월)
- [ ] Spring Boot API 서버 구축
- [ ] 사용자 인증 시스템 구현
- [ ] Flutter 클라이언트 API 연동
- [ ] 기존 로컬 데이터 마이그레이션

### Phase 2: 팀 협업 기능 (2개월)
- [ ] 팀/프로젝트 관리 기능
- [ ] 태스크 할당 시스템
- [ ] 실시간 알림 기능
- [ ] 댓글/피드백 시스템

### Phase 3: 고도화 및 확장 (3개월)
- [ ] 모바일 앱 개발
- [ ] 고급 분석/리포트 기능
- [ ] 성능 최적화 및 버그 수정
- [ ] 사용자 피드백 반영

## 💡 추가 아이디어

### 🎨 UI/UX 개선
- **다크 모드**: 시스템 테마 연동
- **커스터마이징**: 색상 테마, 폰트 크기 설정
- **미니 모드**: 더욱 작은 플로팅 위젯
- **드래그 앤 드롭**: 태스크 우선순위 변경

### 🔗 통합 기능
- **캘린더 연동**: macOS Calendar 앱 연동
- **이메일 연동**: 이메일로 태스크 생성
- **Slack/Teams**: 협업 도구 연동
- **GitHub**: 이슈/PR 연동

### 🤖 스마트 기능
- **AI 추천**: 태스크 완료 시간 예측
- **자동 분류**: 태스크 내용 기반 자동 태그
- **음성 입력**: 음성으로 태스크 생성
- **스마트 알림**: 적절한 시점 알림

## 🗄️ 데이터베이스 구조 (PostgreSQL)

### **Users (사용자)**
```sql
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_active_at TIMESTAMP
);
```

### **Teams (팀)**
```sql
CREATE TABLE teams (
    team_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id BIGINT REFERENCES users(user_id),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Team_Members (팀 멤버)**
```sql
CREATE TABLE team_members (
    team_member_id BIGSERIAL PRIMARY KEY,
    team_id BIGINT REFERENCES teams(team_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER', -- OWNER, ADMIN, MEMBER
    joined_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(team_id, user_id)
);
```

### **Projects (프로젝트)**
```sql
CREATE TABLE projects (
    project_id BIGSERIAL PRIMARY KEY,
    team_id BIGINT REFERENCES teams(team_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    start_date DATE,
    end_date DATE,
    created_by BIGINT REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Tasks (태스크)**
```sql
CREATE TABLE tasks (
    task_id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(project_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'TODO', -- TODO, IN_PROGRESS, ON_HOLD, COMPLETED
    priority VARCHAR(20) DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, URGENT
    assignee_id BIGINT REFERENCES users(user_id),
    requester_id BIGINT REFERENCES users(user_id),
    due_date TIMESTAMP,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    completion_percentage INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);
```

### **Task_Tags (태스크 태그)**
```sql
CREATE TABLE tags (
    tag_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    color VARCHAR(7), -- HEX color code
    team_id BIGINT REFERENCES teams(team_id) ON DELETE CASCADE,
    UNIQUE(name, team_id)
);

CREATE TABLE task_tags (
    task_id BIGINT REFERENCES tasks(task_id) ON DELETE CASCADE,
    tag_id BIGINT REFERENCES tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY(task_id, tag_id)
);
```

### **Task_Comments (태스크 댓글)**
```sql
CREATE TABLE task_comments (
    comment_id BIGSERIAL PRIMARY KEY,
    task_id BIGINT REFERENCES tasks(task_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Task_Templates (태스크 템플릿)**
```sql
CREATE TABLE task_templates (
    template_id BIGSERIAL PRIMARY KEY,
    team_id BIGINT REFERENCES teams(team_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    title_template VARCHAR(200) NOT NULL,
    description_template TEXT,
    estimated_hours DECIMAL(5,2),
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    created_by BIGINT REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **Notifications (알림)**
```sql
CREATE TABLE notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- TASK_ASSIGNED, TASK_UPDATED, COMMENT_ADDED, etc.
    title VARCHAR(200) NOT NULL,
    message TEXT,
    reference_id BIGINT, -- task_id, project_id, etc.
    reference_type VARCHAR(20), -- TASK, PROJECT, etc.
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **Time_Tracking (시간 추적)**
```sql
CREATE TABLE time_entries (
    entry_id BIGSERIAL PRIMARY KEY,
    task_id BIGINT REFERENCES tasks(task_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_minutes INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 🌐 API 엔드포인트 설계

### **🔐 Authentication (인증)**
```
POST   /api/v1/auth/register          # 회원가입
POST   /api/v1/auth/login             # 로그인
POST   /api/v1/auth/logout            # 로그아웃
POST   /api/v1/auth/refresh           # 토큰 갱신
POST   /api/v1/auth/forgot-password   # 비밀번호 찾기
POST   /api/v1/auth/reset-password    # 비밀번호 재설정
```

### **👤 Users (사용자 관리)**
```
GET    /api/v1/users/me               # 내 프로필 조회
PUT    /api/v1/users/me               # 내 프로필 수정
GET    /api/v1/users/{userId}         # 사용자 상세 조회
GET    /api/v1/users/search           # 사용자 검색
PUT    /api/v1/users/me/password      # 비밀번호 변경
POST   /api/v1/users/me/avatar        # 프로필 이미지 업로드
```

### **👥 Teams (팀 관리)**
```
GET    /api/v1/teams                  # 내 팀 목록
POST   /api/v1/teams                  # 팀 생성
GET    /api/v1/teams/{teamId}         # 팀 상세 조회
PUT    /api/v1/teams/{teamId}         # 팀 정보 수정
DELETE /api/v1/teams/{teamId}         # 팀 삭제

GET    /api/v1/teams/{teamId}/members # 팀 멤버 목록
POST   /api/v1/teams/{teamId}/members # 팀 멤버 초대
DELETE /api/v1/teams/{teamId}/members/{userId} # 멤버 삭제
PUT    /api/v1/teams/{teamId}/members/{userId}/role # 역할 변경
```

### **📁 Projects (프로젝트 관리)**
```
GET    /api/v1/projects               # 프로젝트 목록
POST   /api/v1/projects               # 프로젝트 생성
GET    /api/v1/projects/{projectId}   # 프로젝트 상세
PUT    /api/v1/projects/{projectId}   # 프로젝트 수정
DELETE /api/v1/projects/{projectId}   # 프로젝트 삭제
GET    /api/v1/projects/{projectId}/stats # 프로젝트 통계
```

### **✅ Tasks (태스크 관리)**
```
GET    /api/v1/tasks                  # 태스크 목록 조회
POST   /api/v1/tasks                  # 태스크 생성
GET    /api/v1/tasks/{taskId}         # 태스크 상세 조회
PUT    /api/v1/tasks/{taskId}         # 태스크 수정
DELETE /api/v1/tasks/{taskId}         # 태스크 삭제
PUT    /api/v1/tasks/{taskId}/status  # 태스크 상태 변경
PUT    /api/v1/tasks/{taskId}/assign  # 태스크 할당

# 필터링 및 검색
GET    /api/v1/tasks?assignee={userId}      # 담당자별 태스크
GET    /api/v1/tasks?status={status}        # 상태별 태스크
GET    /api/v1/tasks?project={projectId}    # 프로젝트별 태스크
GET    /api/v1/tasks?due=today              # 오늘 마감 태스크
GET    /api/v1/tasks/search?q={keyword}     # 태스크 검색

# 대시보드
GET    /api/v1/tasks/dashboard/my           # 내 태스크 대시보드
GET    /api/v1/tasks/dashboard/team/{teamId} # 팀 태스크 대시보드
```

### **💬 Comments (댓글)**
```
GET    /api/v1/tasks/{taskId}/comments      # 태스크 댓글 목록
POST   /api/v1/tasks/{taskId}/comments      # 댓글 작성
PUT    /api/v1/comments/{commentId}         # 댓글 수정
DELETE /api/v1/comments/{commentId}         # 댓글 삭제
```

### **🏷️ Tags (태그 관리)**
```
GET    /api/v1/teams/{teamId}/tags          # 팀 태그 목록
POST   /api/v1/teams/{teamId}/tags          # 태그 생성
PUT    /api/v1/tags/{tagId}                 # 태그 수정
DELETE /api/v1/tags/{tagId}                 # 태그 삭제
```

### **📋 Templates (템플릿)**
```
GET    /api/v1/teams/{teamId}/templates     # 팀 템플릿 목록
POST   /api/v1/teams/{teamId}/templates     # 템플릿 생성
GET    /api/v1/templates/{templateId}       # 템플릿 상세
PUT    /api/v1/templates/{templateId}       # 템플릿 수정
DELETE /api/v1/templates/{templateId}       # 템플릿 삭제
POST   /api/v1/templates/{templateId}/use   # 템플릿으로 태스크 생성
```

### **🔔 Notifications (알림)**
```
GET    /api/v1/notifications               # 내 알림 목록
PUT    /api/v1/notifications/{notificationId}/read # 알림 읽음 처리
PUT    /api/v1/notifications/read-all      # 모든 알림 읽음 처리
DELETE /api/v1/notifications/{notificationId} # 알림 삭제
```

### **⏱️ Time Tracking (시간 추적)**
```
GET    /api/v1/tasks/{taskId}/time-entries # 태스크 시간 기록 목록
POST   /api/v1/tasks/{taskId}/time-entries/start # 시간 추적 시작
PUT    /api/v1/time-entries/{entryId}/stop # 시간 추적 종료
PUT    /api/v1/time-entries/{entryId}      # 시간 기록 수정
DELETE /api/v1/time-entries/{entryId}      # 시간 기록 삭제
GET    /api/v1/users/{userId}/time-report  # 사용자 시간 리포트
```

### **📊 Reports & Analytics (리포트)**
```
GET    /api/v1/reports/team/{teamId}/productivity   # 팀 생산성 리포트
GET    /api/v1/reports/user/{userId}/productivity   # 개인 생산성 리포트
GET    /api/v1/reports/project/{projectId}/status   # 프로젝트 현황 리포트
GET    /api/v1/reports/tasks/completion-trends      # 태스크 완료 추이
GET    /api/v1/reports/workload/{teamId}           # 팀 업무량 분석
```

### **🔄 WebSocket Events (실시간 통신)**
```
# 연결
WS     /ws/notifications                  # 알림 실시간 수신

# 이벤트 타입
task.created        # 태스크 생성
task.updated        # 태스크 수정  
task.assigned       # 태스크 할당
task.completed      # 태스크 완료
comment.added       # 댓글 추가
project.updated     # 프로젝트 업데이트
team.member.joined  # 팀 멤버 합류
```

### **📱 Mobile/Desktop Sync (동기화)**
```
GET    /api/v1/sync/tasks/{lastSyncTime}  # 변경된 태스크 동기화
POST   /api/v1/sync/tasks/batch          # 태스크 일괄 업데이트
GET    /api/v1/sync/offline-changes      # 오프라인 변경사항 조회
POST   /api/v1/sync/resolve-conflicts    # 충돌 해결
```

## 🔧 API Response 표준 형식

### **성공 응답**
```json
{
    "success": true,
    "data": {
        // 응답 데이터
    },
    "message": "성공적으로 처리되었습니다.",
    "timestamp": "2025-07-22T10:30:00Z"
}
```

### **에러 응답**
```json
{
    "success": false,
    "error": {
        "code": "TASK_NOT_FOUND",
        "message": "태스크를 찾을 수 없습니다.",
        "details": {
            "taskId": "12345"
        }
    },
    "timestamp": "2025-07-22T10:30:00Z"
}
```

### **페이지네이션 응답**
```json
{
    "success": true,
    "data": {
        "content": [
            // 데이터 배열
        ],
        "pagination": {
            "page": 1,
            "size": 20,
            "totalElements": 150,
            "totalPages": 8,
            "hasNext": true,
            "hasPrevious": false
        }
    }
}
```

## 📊 성공 지표
- **사용자 활성도**: 일일 활성 사용자 수
- **태스크 완료율**: 생성 대비 완료 비율
- **팀 참여도**: 팀 태스크 할당/완료 통계
- **성능 지표**: 앱 로딩 시간, 응답 속도
- **사용자 만족도**: 앱스토어 평점, 사용자 피드백

## 🏗️ 유연한 아키텍처 설계 가이드

### 📋 설계 철학
프로젝트의 **재사용성**, **확장성**, **유지보수성**을 높이기 위해 **핵심 기능**과 **확장 기능**을 분리하여 설계합니다. 서비스마다 달라질 수 있는 요소들은 쉽게 교체하거나 확장할 수 있도록 **인터페이스 기반 아키텍처**를 적용합니다.

### 🎯 핵심 원칙
1. **단일 책임 원칙**: 각 모듈은 하나의 책임만 가짐
2. **개방-폐쇄 원칙**: 확장에는 열려있고 변경에는 닫혀있음
3. **의존성 역전**: 구체적인 구현이 아닌 추상화에 의존
4. **인터페이스 분리**: 클라이언트가 사용하지 않는 인터페이스에 의존하지 않음

## 🏛️ 레이어드 아키텍처 설계

### **1. Core Layer (핵심 계층) - 재사용 가능**
```
core/
├── auth/                    # 인증 핵심 로직
│   ├── interfaces/          # 인터페이스 정의
│   │   ├── IAuthService     # 인증 서비스 인터페이스
│   │   ├── ITokenManager    # 토큰 관리 인터페이스
│   │   └── IUserRepository  # 사용자 저장소 인터페이스
│   ├── models/              # 핵심 데이터 모델
│   │   ├── AuthUser         # 최소 인증 사용자 모델
│   │   ├── AuthToken        # 토큰 모델
│   │   └── AuthResult       # 인증 결과 모델
│   └── usecases/            # 비즈니스 로직
│       ├── LoginUseCase     # 로그인 유스케이스
│       ├── RegisterUseCase  # 회원가입 유스케이스
│       └── TokenRefreshUseCase # 토큰 갱신 유스케이스
├── common/                  # 공통 유틸리티
│   ├── exceptions/          # 예외 정의
│   ├── validators/          # 검증 로직
│   └── constants/           # 상수 정의
└── security/                # 보안 관련
    ├── encryption/          # 암호화
    └── jwt/                 # JWT 처리
```

### **2. Application Layer (애플리케이션 계층) - 프로젝트별 커스터마이징**
```
application/
├── todo/                    # TODO 앱 특화 로직
│   ├── models/              # 확장된 모델
│   │   └── TodoUser         # TODO 특화 사용자 모델
│   ├── services/            # 애플리케이션 서비스
│   │   ├── UserService      # 사용자 관리 서비스
│   │   └── ProfileService   # 프로필 관리 서비스
│   └── configs/             # 애플리케이션 설정
│       └── TodoAuthConfig   # TODO 인증 설정
└── shared/                  # 공통 애플리케이션 로직
    ├── dto/                 # 데이터 전송 객체
    └── mappers/             # 모델 변환기
```

### **3. Infrastructure Layer (인프라 계층) - 구현체**
```
infrastructure/
├── persistence/             # 데이터 저장
│   ├── repositories/        # Repository 구현체
│   │   └── JpaUserRepository # JPA 사용자 저장소
│   └── entities/            # JPA 엔티티
│       └── UserEntity       # 사용자 엔티티
├── external/                # 외부 서비스
│   ├── email/               # 이메일 서비스
│   └── oauth/               # OAuth 연동
└── security/                # 보안 구현체
    ├── JwtTokenManager      # JWT 토큰 매니저 구현
    └── BCryptPasswordEncoder # 비밀번호 암호화
```

## 🔧 핵심 모델 설계

### **AuthUser (핵심 인증 모델) - 최소 필수 정보**
```java
// Core Layer
public class AuthUser {
    private String userId;        // 고유 식별자 (필수)
    private String identifier;    // 로그인 식별자 (이메일/사용자명)
    private String passwordHash;  // 암호화된 비밀번호 (필수)
    private AuthStatus status;    // 계정 상태 (필수)
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 핵심 인증 관련 메서드만 포함
    public boolean isActive() { return status == AuthStatus.ACTIVE; }
    public boolean canLogin() { return isActive() && passwordHash != null; }
}

public enum AuthStatus {
    ACTIVE, INACTIVE, SUSPENDED, PENDING_VERIFICATION
}
```

### **TodoUser (확장된 사용자 모델) - 프로젝트 특화**
```java
// Application Layer - TODO 프로젝트 특화
public class TodoUser extends AuthUser {
    private String displayName;     // 표시 이름
    private String profileImageUrl; // 프로필 이미지
    private String timezone;        // 시간대
    private UserPreferences preferences; // 사용자 설정
    private LocalDateTime lastActiveAt;
    
    // TODO 앱 특화 메서드
    public String getDisplayNameOrDefault() { /* ... */ }
    public boolean isOnline() { /* ... */ }
}

public class UserPreferences {
    private String language;
    private String theme;
    private NotificationSettings notifications;
    // 확장 가능한 설정들
}
```

## 🔌 인터페이스 기반 설계

### **IAuthService (핵심 인증 인터페이스)**
```java
// Core Layer - 재사용 가능한 인증 인터페이스
public interface IAuthService {
    // 핵심 인증 기능만 정의
    AuthResult login(String identifier, String password);
    AuthResult register(AuthUser user, String password);
    boolean validateToken(String token);
    AuthResult refreshToken(String refreshToken);
    void logout(String token);
}

public class AuthResult {
    private boolean success;
    private String accessToken;
    private String refreshToken;
    private AuthUser user;
    private String errorMessage;
    private AuthErrorCode errorCode;
}
```

### **ITodoUserService (확장된 사용자 서비스)**
```java
// Application Layer - TODO 특화
public interface ITodoUserService extends IAuthService {
    // 추가 기능들
    TodoUser updateProfile(String userId, ProfileUpdateRequest request);
    List<TodoUser> searchUsers(String query);
    void updateLastActive(String userId);
    UserPreferences getUserPreferences(String userId);
    void updatePreferences(String userId, UserPreferences preferences);
}
```

## 🛠️ 구현체 분리 전략

### **1. Repository Pattern**
```java
// Core Interface
public interface IUserRepository {
    Optional<AuthUser> findByIdentifier(String identifier);
    AuthUser save(AuthUser user);
    boolean existsByIdentifier(String identifier);
}

// Infrastructure Implementation
@Repository
public class JpaUserRepository implements IUserRepository {
    @Autowired
    private UserJpaRepository jpaRepository;
    
    @Override
    public Optional<AuthUser> findByIdentifier(String identifier) {
        return jpaRepository.findByEmail(identifier)
            .map(this::toAuthUser);
    }
    
    // Entity <-> Model 변환 로직
    private AuthUser toAuthUser(UserEntity entity) { /* ... */ }
}
```

### **2. Service Implementation**
```java
// Core Implementation
@Service
public class CoreAuthService implements IAuthService {
    private final IUserRepository userRepository;
    private final ITokenManager tokenManager;
    private final IPasswordEncoder passwordEncoder;
    
    // 핵심 인증 로직만 구현
    @Override
    public AuthResult login(String identifier, String password) {
        // 재사용 가능한 로그인 로직
    }
}

// Application Implementation
@Service
public class TodoUserService extends CoreAuthService implements ITodoUserService {
    private final ITodoUserRepository todoUserRepository;
    
    // TODO 특화 기능 구현
    @Override
    public TodoUser updateProfile(String userId, ProfileUpdateRequest request) {
        // TODO 앱 특화 로직
    }
}
```

## 🔄 설정 기반 확장성

### **AuthConfiguration (설정 클래스)**
```java
@Configuration
public class AuthConfiguration {
    
    @Bean
    @ConditionalOnProperty(name = "app.auth.provider", havingValue = "database")
    public IAuthService databaseAuthService(IUserRepository userRepository) {
        return new DatabaseAuthService(userRepository);
    }
    
    @Bean
    @ConditionalOnProperty(name = "app.auth.provider", havingValue = "oauth")
    public IAuthService oauthAuthService(OAuthClient oauthClient) {
        return new OAuthAuthService(oauthClient);
    }
    
    @Bean
    public ITokenManager tokenManager(@Value("${app.jwt.secret}") String secret) {
        return new JwtTokenManager(secret);
    }
}
```

### **application.yml (환경별 설정)**
```yaml
# 개발환경
app:
  auth:
    provider: database
    token:
      access-expiry: 3600
      refresh-expiry: 86400
  features:
    email-verification: false
    two-factor: false

---
# 운영환경
spring:
  profiles: production
app:
  auth:
    provider: oauth
    oauth:
      google:
        client-id: ${GOOGLE_CLIENT_ID}
        client-secret: ${GOOGLE_CLIENT_SECRET}
  features:
    email-verification: true
    two-factor: true
```

## 📱 Flutter 클라이언트 아키텍처

### **Core Models (재사용 가능)**
```dart
// core/models/auth_user.dart
class AuthUser {
  final String userId;
  final String identifier;
  final AuthStatus status;
  final DateTime createdAt;
  
  // 핵심 인증 관련 메서드만
  bool get isActive => status == AuthStatus.active;
  bool get canLogin => isActive;
}

// application/models/todo_user.dart
class TodoUser extends AuthUser {
  final String displayName;
  final String? profileImageUrl;
  final String timezone;
  final UserPreferences preferences;
  
  // TODO 앱 특화 메서드
  String get displayNameOrDefault => displayName.isNotEmpty ? displayName : identifier;
}
```

### **Repository Interfaces**
```dart
// core/interfaces/auth_repository.dart
abstract class IAuthRepository {
  Future<AuthResult> login(String identifier, String password);
  Future<AuthResult> register(AuthUser user, String password);
  Future<bool> validateToken(String token);
  Future<void> logout();
}

// application/interfaces/todo_user_repository.dart
abstract class ITodoUserRepository extends IAuthRepository {
  Future<TodoUser> updateProfile(ProfileUpdateRequest request);
  Future<List<TodoUser>> searchUsers(String query);
  Future<UserPreferences> getPreferences();
}
```

## 🚀 확장 시나리오 예시

### **시나리오 1: 새로운 프로젝트에서 재사용**
1. **Core Layer** 그대로 복사
2. **Application Layer**만 새 프로젝트용으로 생성
3. **Infrastructure Layer** 필요한 부분만 교체

### **시나리오 2: OAuth 로그인 추가**
1. `IOAuthService` 인터페이스 추가
2. `GoogleOAuthService`, `KakaoOAuthService` 구현체 생성
3. 설정 파일에서 provider 변경만으로 전환

### **시나리오 3: 다중 데이터베이스 지원**
1. `IUserRepository` 인터페이스는 그대로 유지
2. `MongoUserRepository`, `RedisUserRepository` 구현체 추가
3. 설정 기반으로 Repository 선택

## 💡 개발 가이드라인

### **1. 새 기능 추가 시**
- Core에 추가할지, Application에 추가할지 먼저 판단
- 다른 프로젝트에서도 쓸 수 있다면 → Core
- 현재 프로젝트에만 특화된다면 → Application

### **2. 모델 설계 시**
- AuthUser에는 인증에 **꼭 필요한** 정보만
- 추가 정보는 상속이나 컴포지션으로 확장
- 데이터베이스 스키마와 모델을 1:1 매핑하지 말고 필요에 따라 분리

### **3. 인터페이스 설계 시**
- 구현체에 종속적이지 않도록 추상적으로 정의
- 메서드는 비즈니스 의미 중심으로 명명
- 반환 타입도 인터페이스나 추상 클래스 사용 고려

### **4. 테스트 전략**
- Core Layer는 단위 테스트 100% 커버리지 목표
- Mock을 이용해 구현체에 독립적인 테스트
- Application Layer는 통합 테스트 중심

이런 구조로 개발하면 **Todo 앱 → 다른 앱으로 확장**하거나, **인증 방식 변경**, **데이터베이스 교체** 등이 매우 쉬워집니다.

## 🔧 상세 구현 계획

### 📱 **Flutter 클라이언트 구현 계획**

#### **Phase 1: 기본 구조 및 상태 관리 (1주)**
```dart
// lib/core/auth/ 구조
lib/
├── core/
│   ├── auth/
│   │   ├── models/
│   │   │   ├── auth_user.dart          # 기본 사용자 모델
│   │   │   ├── login_request.dart      # 로그인 요청 모델
│   │   │   └── auth_result.dart        # 인증 결과 모델
│   │   ├── providers/
│   │   │   ├── auth_provider.dart      # Riverpod 인증 상태 관리
│   │   │   └── token_provider.dart     # JWT 토큰 관리
│   │   ├── services/
│   │   │   ├── auth_service.dart       # 인증 서비스 (API 호출)
│   │   │   ├── token_storage.dart      # 토큰 로컬 저장
│   │   │   └── auth_interceptor.dart   # HTTP 인터셉터
│   │   └── repositories/
│   │       └── auth_repository.dart    # 인증 Repository 패턴
│   ├── network/
│   │   ├── dio_client.dart             # Dio HTTP 클라이언트 설정
│   │   └── api_endpoints.dart          # API 엔드포인트 상수
│   └── storage/
│       └── secure_storage.dart         # Flutter Secure Storage 래퍼
├── features/
│   ├── auth/
│   │   ├── login/
│   │   │   ├── login_screen.dart       # 로그인 화면
│   │   │   ├── login_controller.dart   # 로그인 로직
│   │   │   └── widgets/
│   │   │       ├── login_form.dart     # 로그인 폼
│   │   │       └── oauth_buttons.dart  # OAuth 버튼들
│   │   ├── register/
│   │   │   ├── register_screen.dart    # 회원가입 화면
│   │   │   └── register_controller.dart
│   │   └── profile/
│   │       ├── profile_screen.dart     # 프로필 화면
│   │       └── profile_controller.dart
│   └── tasks/                          # 기존 태스크 기능 유지
└── shared/
    ├── widgets/
    │   ├── loading_widget.dart         # 로딩 위젯
    │   └── error_widget.dart           # 에러 표시 위젯
    └── utils/
        ├── validators.dart             # 입력 검증 유틸
        └── constants.dart              # 상수 정의
```

#### **주요 구현 내용**
```dart
// 1. AuthUser 모델
class AuthUser {
  final String userId;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  
  // JWT에서 추출되는 정보들
  factory AuthUser.fromJwt(Map<String, dynamic> payload) {
    return AuthUser(
      userId: payload['sub'],
      email: payload['email'],
      displayName: payload['name'] ?? payload['email'],
      profileImageUrl: payload['picture'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(payload['iat'] * 1000),
    );
  }
}

// 2. AuthProvider (Riverpod)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState.initial());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.login(email, password);
      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: result.user,
          token: result.accessToken,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// 3. AuthService
class AuthService {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;
  
  Future<AuthResult> login(String email, String password) async {
    final response = await _dioClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    if (response.data['success']) {
      final token = response.data['data']['accessToken'];
      await _tokenStorage.saveToken(token);
      
      return AuthResult(
        success: true,
        accessToken: token,
        user: AuthUser.fromJwt(_parseJwt(token)),
      );
    }
    
    throw AuthException(response.data['error']['message']);
  }
  
  // Google OAuth 로그인
  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw AuthException('Google 로그인 취소');
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // 구글 토큰을 우리 서버로 전송하여 JWT 받기
    final response = await _dioClient.post('/auth/google', data: {
      'googleToken': googleAuth.accessToken,
    });
    
    // 응답 처리는 동일
    return _processAuthResponse(response);
  }
}
```

#### **Phase 2: UI 구현 및 네비게이션 (1주)**
```dart
// 로그인 화면 구현
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 및 타이틀
            Text('FlutterTodo', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 48),
            
            // 로그인 폼
            LoginForm(
              onSubmit: (email, password) {
                ref.read(authProvider.notifier).login(email, password);
              },
            ),
            
            SizedBox(height: 24),
            
            // OAuth 버튼들
            OAuthButtons(
              onGooglePressed: () {
                ref.read(authProvider.notifier).loginWithGoogle();
              },
              onApplePressed: () {
                // Apple 로그인 구현
              },
            ),
            
            // 로딩 상태 표시
            if (authState.isLoading) 
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
              
            // 에러 상태 표시
            if (authState.error != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  authState.error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

#### **Phase 3: 인증 상태 관리 및 네비게이션 (1주)**
```dart
// 메인 앱에서 인증 상태에 따른 네비게이션
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        redirect: (context, state) {
          final authState = ref.read(authProvider);
          final isLoginPage = state.location == '/login';
          
          if (!authState.isAuthenticated && !isLoginPage) {
            return '/login';
          }
          if (authState.isAuthenticated && isLoginPage) {
            return '/';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => TaskListView(),
          ),
        ],
      ),
    );
  }
}

// HTTP 인터셉터로 자동 토큰 첨부
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 토큰 만료 시 로그아웃 처리
      _tokenStorage.clearToken();
      // 로그인 페이지로 리다이렉트
    }
    handler.next(err);
  }
}
```

### 🌐 **Spring Boot API 서버 구현 계획**

#### **Phase 1: 기본 프로젝트 구조 및 설정 (1주)**
```java
// 프로젝트 구조
src/main/java/com/fluttertodo/
├── FlutterTodoApplication.java         # 메인 애플리케이션
├── config/                             # 설정 클래스들
│   ├── SecurityConfig.java             # Spring Security 설정
│   ├── JwtConfig.java                  # JWT 설정
│   ├── CorsConfig.java                 # CORS 설정
│   └── DatabaseConfig.java             # DB 설정
├── auth/                               # 인증 관련 (재사용 가능)
│   ├── controller/
│   │   └── AuthController.java         # 인증 API 컨트롤러
│   ├── service/
│   │   ├── AuthService.java            # 인증 서비스 (핵심)
│   │   ├── JwtTokenService.java        # JWT 토큰 관리
│   │   └── OAuthService.java           # OAuth 처리
│   ├── model/
│   │   ├── AuthUser.java               # 기본 사용자 모델
│   │   ├── LoginRequest.java           # 로그인 요청 DTO
│   │   ├── AuthResponse.java           # 인증 응답 DTO
│   │   └── JwtClaims.java              # JWT 클레임
│   ├── repository/
│   │   └── AuthUserRepository.java     # 사용자 Repository
│   └── exception/
│       ├── AuthException.java          # 인증 예외
│       └── TokenExpiredException.java  # 토큰 만료 예외
├── todo/                               # TODO 앱 특화 기능
│   ├── controller/
│   │   ├── TaskController.java         # 태스크 API
│   │   ├── TeamController.java         # 팀 API
│   │   └── ProjectController.java      # 프로젝트 API
│   ├── service/
│   │   ├── TaskService.java
│   │   ├── TeamService.java
│   │   └── ProjectService.java
│   ├── model/
│   │   ├── TodoUser.java               # TODO 특화 사용자 (AuthUser 확장)
│   │   ├── Task.java
│   │   ├── Team.java
│   │   └── Project.java
│   └── repository/
│       ├── TodoUserRepository.java
│       ├── TaskRepository.java
│       └── TeamRepository.java
└── common/                             # 공통 유틸리티
    ├── dto/
    │   ├── ApiResponse.java            # 표준 API 응답
    │   └── PagedResponse.java          # 페이징 응답
    ├── exception/
    │   └── GlobalExceptionHandler.java # 전역 예외 처리
    └── util/
        ├── DateTimeUtil.java
        └── ValidationUtil.java
```

#### **주요 구현 내용**
```java
// 1. AuthService - 핵심 인증 로직 (재사용 가능)
@Service
@Transactional
public class AuthService {
    private final AuthUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final OAuthService oAuthService;
    
    /**
     * 이메일/비밀번호 로그인 - 어떤 프로젝트든 동일
     */
    public AuthResponse login(LoginRequest request) {
        // 1. 사용자 조회
        AuthUser user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new AuthException("사용자를 찾을 수 없습니다"));
        
        // 2. 비밀번호 검증
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new AuthException("비밀번호가 일치하지 않습니다");
        }
        
        // 3. JWT 토큰 생성
        String accessToken = jwtTokenService.generateAccessToken(user);
        String refreshToken = jwtTokenService.generateRefreshToken(user);
        
        return AuthResponse.builder()
            .success(true)
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .user(user)
            .expiresAt(jwtTokenService.getExpirationTime())
            .build();
    }
    
    /**
     * Google OAuth 로그인 - 구글 토큰을 우리 JWT로 변환
     */
    public AuthResponse loginWithGoogle(String googleToken) {
        // 1. 구글 토큰 검증 및 사용자 정보 추출
        GoogleUserInfo googleUser = oAuthService.verifyGoogleToken(googleToken);
        
        // 2. 로컬 사용자 생성 또는 조회
        AuthUser user = userRepository.findByEmail(googleUser.getEmail())
            .orElseGet(() -> createUserFromGoogle(googleUser));
        
        // 3. 우리 시스템의 JWT 토큰 생성
        String accessToken = jwtTokenService.generateAccessToken(user);
        String refreshToken = jwtTokenService.generateRefreshToken(user);
        
        return AuthResponse.builder()
            .success(true)
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .user(user)
            .build();
    }
    
    /**
     * 토큰 검증 - 모든 보호된 API에서 사용
     */
    public AuthUser validateToken(String token) {
        if (!jwtTokenService.isValidToken(token)) {
            throw new TokenExpiredException("토큰이 만료되었습니다");
        }
        
        String userId = jwtTokenService.getUserIdFromToken(token);
        return userRepository.findById(userId)
            .orElseThrow(() -> new AuthException("사용자를 찾을 수 없습니다"));
    }
}

// 2. JwtTokenService - JWT 토큰 관리
@Service
public class JwtTokenService {
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration:3600}")
    private int jwtExpiration; // 1시간
    
    public String generateAccessToken(AuthUser user) {
        Date expiryDate = new Date(System.currentTimeMillis() + jwtExpiration * 1000);
        
        return Jwts.builder()
            .setSubject(user.getUserId())
            .claim("email", user.getEmail())
            .claim("name", user.getDisplayName())
            .claim("role", user.getRole())
            .setIssuedAt(new Date())
            .setExpirationDate(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }
    
    public boolean isValidToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
    
    public String getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody();
        return claims.getSubject();
    }
}

// 3. AuthController - 인증 API 엔드포인트
@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {
    private final AuthService authService;
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @PostMapping("/google")
    public ResponseEntity<ApiResponse<AuthResponse>> googleLogin(
            @RequestBody GoogleLoginRequest request) {
        
        AuthResponse response = authService.loginWithGoogle(request.getGoogleToken());
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @RequestBody RefreshTokenRequest request) {
        
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout(
            @RequestHeader("Authorization") String authHeader) {
        
        String token = extractToken(authHeader);
        authService.logout(token);
        return ResponseEntity.ok(ApiResponse.success("로그아웃되었습니다"));
    }
    
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<AuthUser>> getCurrentUser(
            @RequestHeader("Authorization") String authHeader) {
        
        String token = extractToken(authHeader);
        AuthUser user = authService.validateToken(token);
        return ResponseEntity.ok(ApiResponse.success(user));
    }
}
```

#### **Phase 2: JWT 보안 및 미들웨어 (1주)**
```java
// JWT 인증 필터
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtTokenService jwtTokenService;
    private final AuthService authService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                  HttpServletResponse response, 
                                  FilterChain filterChain) throws ServletException, IOException {
        
        String token = getTokenFromRequest(request);
        
        if (token != null && jwtTokenService.isValidToken(token)) {
            try {
                AuthUser user = authService.validateToken(token);
                
                // Spring Security 컨텍스트에 인증 정보 설정
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(authentication);
                
            } catch (Exception e) {
                logger.error("JWT 토큰 검증 실패: {}", e.getMessage());
            }
        }
        
        filterChain.doFilter(request, response);
    }
    
    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}

// Security 설정
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
            
        return http.build();
    }
}
```

#### **Phase 3: TODO 앱 비즈니스 로직 (2주)**
```java
// TaskController - 인증된 사용자의 태스크 관리
@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    private final TaskService taskService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<Task>>> getTasks(
            Authentication authentication) {
        
        AuthUser user = (AuthUser) authentication.getPrincipal();
        List<Task> tasks = taskService.getTasksByUser(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(tasks));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<Task>> createTask(
            @Valid @RequestBody CreateTaskRequest request,
            Authentication authentication) {
        
        AuthUser user = (AuthUser) authentication.getPrincipal();
        Task task = taskService.createTask(user.getUserId(), request);
        return ResponseEntity.ok(ApiResponse.success(task));
    }
    
    @PutMapping("/{taskId}")
    public ResponseEntity<ApiResponse<Task>> updateTask(
            @PathVariable String taskId,
            @Valid @RequestBody UpdateTaskRequest request,
            Authentication authentication) {
        
        AuthUser user = (AuthUser) authentication.getPrincipal();
        Task task = taskService.updateTask(taskId, request, user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(task));
    }
}
```

### 🔄 **통합 테스트 및 배포 계획 (1주)**

#### **API 테스트**
```java
@SpringBootTest
@AutoConfigureTestDatabase
@Testcontainers
class AuthControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:13");
    
    @Test
    void 로그인_성공_테스트() {
        // Given
        LoginRequest request = new LoginRequest("test@example.com", "password123");
        
        // When
        ResponseEntity<ApiResponse<AuthResponse>> response = 
            restTemplate.postForEntity("/api/auth/login", request, 
                new ParameterizedTypeReference<>() {});
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getData().getAccessToken()).isNotNull();
    }
    
    @Test
    void JWT_토큰으로_보호된_API_접근_테스트() {
        // Given
        String token = getValidJwtToken();
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        
        // When
        ResponseEntity<ApiResponse<List<Task>>> response = 
            restTemplate.exchange("/api/tasks", HttpMethod.GET, 
                new HttpEntity<>(headers), new ParameterizedTypeReference<>() {});
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

### 📋 **개발 우선순위 및 타임라인**

#### **Week 1-2: 백엔드 기본 구조**
- [ ] Spring Boot 프로젝트 설정
- [ ] 기본 인증 API 구현 (로그인, 회원가입)
- [ ] JWT 토큰 시스템 구현
- [ ] 기본 보안 설정

#### **Week 3-4: 프론트엔드 기본 구조**
- [ ] Flutter 프로젝트 인증 모듈 구현
- [ ] 로그인/회원가입 화면
- [ ] 상태 관리 (Riverpod) 설정
- [ ] API 연동 및 토큰 관리

#### **Week 5-6: OAuth 통합**
- [ ] Google OAuth 백엔드 구현
- [ ] Flutter Google Sign-In 연동
- [ ] Apple Sign-In 추가 (선택사항)

#### **Week 7-8: TODO 앱 기능 연동**
- [ ] 기존 로컬 태스크를 서버 연동으로 전환
- [ ] 실시간 동기화 구현
- [ ] 팀 기능 구현

이 계획으로 **단순하면서도 확장 가능한 JWT 기반 인증 시스템**을 구축할 수 있습니다!

---

**마지막 업데이트**: 2025-07-22  
**버전**: v1.0 (현재) → v2.0 (계획)  
**담당자**: 개발팀