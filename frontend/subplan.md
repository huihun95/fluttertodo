# 범용 인증 코어 모듈 개발 계획

## 🎯 프로젝트 비전

### 핵심 목표
**"어떤 서비스든, 한 줄의 코드 변경 없이 다양한 인증 방식을 사용할 수 있는 범용 인증 시스템"**

- A 서비스(TODO 앱)와 B 서비스(E-commerce)가 **동일한 코드**로 **다른 인증 방식** 사용
- **DB 인증 → OAuth 전환** 시에도 **비즈니스 로직은 그대로**
- **JAR 파일 하나**만 추가하면 바로 사용 가능한 플러그인 시스템

### 설계 철학
1. **완전한 독립성**: 특정 DB, Framework에 종속되지 않음
2. **최소한의 계약**: 꼭 필요한 인터페이스만 정의
3. **설정 기반 조립**: 코드 변경 없이 YAML 설정만으로 전환
4. **플러그인 아키텍처**: 새로운 인증 방식을 쉽게 추가 가능

## 🏗️ 아키텍처 설계

### 전체 구조도
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   A 서비스      │  │   B 서비스      │  │   C 서비스      │
│   (TODO App)    │  │ (E-commerce)    │  │ (CRM System)    │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ @Autowired      │  │ @Autowired      │  │ @Autowired      │
│ AuthService     │  │ AuthService     │  │ AuthService     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
    ╔══════════════════════════════════════════════════════════╗
    ║              AUTH CORE MODULE (auth-core.jar)            ║
    ╠══════════════════════════════════════════════════════════╣
    ║  🎯 Core Interfaces                                      ║
    ║    • IAuthProvider                                       ║
    ║    • ITokenValidator                                     ║
    ║    • IUserResolver                                       ║
    ║                                                          ║
    ║  📦 Standard Models                                      ║
    ║    • AuthResult                                          ║
    ║    • Credential                                          ║
    ║    • AuthUser                                            ║
    ║                                                          ║
    ║  🔧 Plugin System                                        ║
    ║    • ComponentRegistry                                   ║
    ║    • AutoConfiguration                                   ║
    ╚══════════════════════════════════════════════════════════╝
                               │
       ┌───────────────────────┼───────────────────────┐
       │                       │                       │
   ┌───▼────┐             ┌───▼────┐             ┌───▼────┐
   │Database│             │ OAuth  │             │  LDAP  │
   │Provider│             │Provider│             │Provider│
   └────────┘             └────────┘             └────────┘
```

### 3-Layer 아키텍처

#### **1. Core Layer (핵심 계층)**
```
src/main/java/com/authcore/
├── interfaces/              # 표준 인터페이스
│   ├── IAuthProvider.java   # 인증 제공자 인터페이스
│   ├── ITokenValidator.java # 토큰 검증 인터페이스
│   ├── IUserResolver.java   # 사용자 정보 조회 인터페이스
│   └── IPermissionChecker.java # 권한 확인 인터페이스
├── models/                  # 표준 데이터 모델
│   ├── AuthResult.java      # 인증 결과
│   ├── Credential.java      # 인증 정보
│   ├── AuthUser.java        # 표준 사용자
│   └── Permission.java      # 권한 정보
├── exceptions/              # 표준 예외
│   ├── AuthException.java
│   ├── TokenExpiredException.java
│   └── UnauthorizedException.java
└── services/                # 핵심 서비스
    ├── AuthService.java     # 메인 인증 서비스
    └── ComponentRegistry.java # 플러그인 레지스트리
```

#### **2. Plugin Layer (플러그인 계층)**
```
src/main/java/com/authcore/plugins/
├── database/                # DB 인증 플러그인
│   ├── DatabaseAuthProvider.java
│   ├── JpaUserRepository.java
│   └── DatabaseConfiguration.java
├── oauth/                   # OAuth 플러그인
│   ├── GoogleOAuthProvider.java
│   ├── KakaoOAuthProvider.java
│   ├── OAuthConfiguration.java
│   └── OAuthTokenValidator.java
├── ldap/                    # LDAP 플러그인
│   ├── LdapAuthProvider.java
│   ├── LdapUserResolver.java
│   └── LdapConfiguration.java
└── custom/                  # 커스텀 플러그인 템플릿
    ├── CustomAuthProvider.java
    └── CustomConfiguration.java
```

#### **3. Configuration Layer (설정 계층)**
```
src/main/resources/
├── META-INF/
│   └── spring.factories    # Auto Configuration
├── application-auth.yml    # 기본 설정 템플릿
└── auth-plugins.yml        # 플러그인 정의
```

## 🔧 핵심 인터페이스 설계

### **IAuthProvider (인증 제공자)**
```java
/**
 * 모든 인증 방식의 표준 인터페이스
 * DB, OAuth, LDAP 등 어떤 방식이든 이 인터페이스를 구현
 */
@FunctionalInterface
public interface IAuthProvider {
    /**
     * 사용자 인증 수행
     * @param credential 인증 정보 (이메일+비밀번호, OAuth 토큰 등)
     * @return 인증 결과 (성공/실패, 사용자 정보, 토큰 등)
     */
    AuthResult authenticate(Credential credential);
    
    /**
     * 제공자 고유 식별자
     * @return "database", "google-oauth", "ldap" 등
     */
    default String getProviderId() {
        return this.getClass().getSimpleName().toLowerCase()
            .replace("authprovider", "").replace("provider", "");
    }
    
    /**
     * 지원하는 인증 타입들
     * @return PASSWORD, OAUTH_TOKEN, LDAP 등
     */
    default Set<CredentialType> getSupportedTypes() {
        return Set.of(CredentialType.PASSWORD);
    }
}
```

### **ITokenValidator (토큰 검증자)**
```java
/**
 * 토큰 검증 표준 인터페이스
 * JWT, Opaque Token, Session 등 모든 토큰 방식 지원
 */
public interface ITokenValidator {
    /**
     * 토큰 유효성 검증
     * @param token 검증할 토큰
     * @return 검증 결과 (사용자 정보, 권한 포함)
     */
    AuthResult validateToken(String token);
    
    /**
     * 토큰 무효화 (로그아웃)
     * @param token 무효화할 토큰
     */
    void invalidateToken(String token);
    
    /**
     * 토큰 갱신
     * @param refreshToken 갱신 토큰
     * @return 새로운 액세스 토큰
     */
    AuthResult refreshToken(String refreshToken);
}
```

### **표준 데이터 모델**

#### **AuthResult (인증 결과)**
```java
/**
 * 모든 인증 결과의 표준 형식
 * 어떤 인증 방식이든 동일한 형식으로 결과 반환
 */
@Data
@Builder
public class AuthResult {
    private boolean success;              // 인증 성공 여부
    private String userId;                // 사용자 고유 식별자
    private String accessToken;           // 액세스 토큰
    private String refreshToken;          // 갱신 토큰
    private Set<String> permissions;      // 권한 목록
    private Map<String, Object> metadata; // 확장 정보
    private String errorMessage;          // 실패 시 에러 메시지
    private AuthErrorCode errorCode;      // 에러 코드
    private LocalDateTime expiresAt;      // 토큰 만료 시간
    
    // 편의 메서드들
    public boolean isValid() { return success && accessToken != null; }
    public boolean hasPermission(String permission) { 
        return permissions != null && permissions.contains(permission); 
    }
    public boolean isExpired() { 
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt); 
    }
}
```

#### **Credential (인증 정보)**
```java
/**
 * 모든 인증 정보의 표준 형식
 * 이메일+비밀번호, OAuth 토큰, LDAP 등 모든 방식 지원
 */
@Data
@Builder
public class Credential {
    private CredentialType type;          // PASSWORD, OAUTH_TOKEN, LDAP 등
    private String identifier;            // 이메일, 사용자명 등
    private String secret;                // 비밀번호, 토큰 등
    private Map<String, Object> extras;   // 추가 정보 (provider, scope 등)
    
    // 팩토리 메서드들
    public static Credential password(String identifier, String password) {
        return Credential.builder()
            .type(CredentialType.PASSWORD)
            .identifier(identifier)
            .secret(password)
            .build();
    }
    
    public static Credential oauthToken(String token, String provider) {
        return Credential.builder()
            .type(CredentialType.OAUTH_TOKEN)
            .secret(token)
            .extras(Map.of("provider", provider))
            .build();
    }
}

public enum CredentialType {
    PASSWORD,      // 이메일/사용자명 + 비밀번호
    OAUTH_TOKEN,   // OAuth 액세스 토큰
    LDAP,          // LDAP 인증
    API_KEY,       // API 키
    CUSTOM         // 커스텀 인증
}
```

## 🔌 플러그인 시스템 설계

### **ComponentRegistry (컴포넌트 레지스트리)**
```java
/**
 * 모든 인증 플러그인을 관리하는 레지스트리
 * 런타임에 설정 기반으로 적절한 구현체 선택
 */
@Component
public class ComponentRegistry {
    private final Map<String, IAuthProvider> authProviders = new HashMap<>();
    private final Map<String, ITokenValidator> tokenValidators = new HashMap<>();
    
    /**
     * Spring Boot 시작 시 모든 플러그인 자동 등록
     */
    @EventListener(ApplicationReadyEvent.class)
    public void registerPlugins() {
        // 모든 IAuthProvider 구현체 스캔
        applicationContext.getBeansOfType(IAuthProvider.class)
            .forEach((name, provider) -> {
                authProviders.put(provider.getProviderId(), provider);
                log.info("Registered auth provider: {}", provider.getProviderId());
            });
            
        // 모든 ITokenValidator 구현체 스캔  
        applicationContext.getBeansOfType(ITokenValidator.class)
            .forEach((name, validator) -> {
                tokenValidators.put(name, validator);
                log.info("Registered token validator: {}", name);
            });
    }
    
    /**
     * 설정에서 지정한 인증 제공자 반환
     */
    public IAuthProvider getAuthProvider(String providerId) {
        IAuthProvider provider = authProviders.get(providerId);
        if (provider == null) {
            throw new IllegalStateException("Auth provider not found: " + providerId);
        }
        return provider;
    }
    
    public ITokenValidator getTokenValidator(String validatorId) {
        return tokenValidators.get(validatorId);
    }
}
```

### **AuthService (메인 인증 서비스)**
```java
/**
 * 모든 서비스에서 사용하는 통합 인증 서비스
 * 내부적으로는 설정된 플러그인들을 조합해서 동작
 */
@Service
public class AuthService {
    private final ComponentRegistry registry;
    private final AuthConfiguration config;
    
    /**
     * 로그인 - 어떤 인증 방식이든 동일한 API
     */
    public AuthResult login(String identifier, String credential) {
        // 1. 설정에서 지정한 인증 제공자 선택
        IAuthProvider provider = registry.getAuthProvider(config.getProvider());
        
        // 2. Credential 객체 생성
        Credential cred = Credential.password(identifier, credential);
        
        // 3. 인증 수행
        return provider.authenticate(cred);
    }
    
    /**
     * 토큰 검증 - 어떤 토큰 방식이든 동일한 API
     */
    public AuthResult validateToken(String token) {
        ITokenValidator validator = registry.getTokenValidator(config.getTokenValidator());
        return validator.validateToken(token);
    }
    
    /**
     * 권한 확인 - 표준화된 권한 체계
     */
    public boolean hasPermission(String token, String permission) {
        AuthResult result = validateToken(token);
        return result.isValid() && result.hasPermission(permission);
    }
    
    /**
     * 로그아웃 - 토큰 무효화
     */
    public void logout(String token) {
        ITokenValidator validator = registry.getTokenValidator(config.getTokenValidator());
        validator.invalidateToken(token);
    }
}
```

## 📱 구현체 템플릿

### **DatabaseAuthProvider (DB 인증)**
```java
/**
 * 데이터베이스 기반 인증 구현체
 * 이메일/비밀번호로 DB에서 사용자 조회 및 검증
 */
@Component
@ConditionalOnProperty(name = "auth.provider", havingValue = "database")
public class DatabaseAuthProvider implements IAuthProvider {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenGenerator tokenGenerator;
    
    @Override
    public AuthResult authenticate(Credential credential) {
        // 1. 사용자 조회
        Optional<User> userOpt = userRepository.findByEmail(credential.getIdentifier());
        if (userOpt.isEmpty()) {
            return AuthResult.builder()
                .success(false)
                .errorCode(AuthErrorCode.USER_NOT_FOUND)
                .errorMessage("사용자를 찾을 수 없습니다")
                .build();
        }
        
        User user = userOpt.get();
        
        // 2. 비밀번호 검증
        if (!passwordEncoder.matches(credential.getSecret(), user.getPasswordHash())) {
            return AuthResult.builder()
                .success(false)
                .errorCode(AuthErrorCode.INVALID_CREDENTIAL)
                .errorMessage("비밀번호가 일치하지 않습니다")
                .build();
        }
        
        // 3. 토큰 생성
        String accessToken = tokenGenerator.generateAccessToken(user.getId(), user.getPermissions());
        String refreshToken = tokenGenerator.generateRefreshToken(user.getId());
        
        // 4. 성공 결과 반환
        return AuthResult.builder()
            .success(true)
            .userId(user.getId())
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .permissions(user.getPermissions())
            .expiresAt(LocalDateTime.now().plusHours(1))
            .metadata(Map.of("email", user.getEmail(), "name", user.getName()))
            .build();
    }
}
```

### **GoogleOAuthProvider (OAuth 인증)**
```java
/**
 * Google OAuth 기반 인증 구현체
 * Google에서 발급한 토큰으로 사용자 정보 조회 및 검증
 */
@Component
@ConditionalOnProperty(name = "auth.provider", havingValue = "google-oauth")
public class GoogleOAuthProvider implements IAuthProvider {
    
    private final GoogleTokenVerifier verifier;
    private final JwtTokenGenerator tokenGenerator;
    private final UserService userService;
    
    @Override
    public AuthResult authenticate(Credential credential) {
        try {
            // 1. Google 토큰 검증
            GoogleIdToken idToken = verifier.verify(credential.getSecret());
            if (idToken == null) {
                return AuthResult.builder()
                    .success(false)
                    .errorCode(AuthErrorCode.INVALID_TOKEN)
                    .errorMessage("유효하지 않은 Google 토큰입니다")
                    .build();
            }
            
            // 2. Google에서 사용자 정보 추출
            GoogleIdToken.Payload payload = idToken.getPayload();
            String googleId = payload.getSubject();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            
            // 3. 로컬 사용자 생성 또는 조회
            User user = userService.findOrCreateByGoogleId(googleId, email, name);
            
            // 4. 우리 시스템의 토큰 생성
            String accessToken = tokenGenerator.generateAccessToken(user.getId(), user.getPermissions());
            String refreshToken = tokenGenerator.generateRefreshToken(user.getId());
            
            return AuthResult.builder()
                .success(true)
                .userId(user.getId())
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .permissions(user.getPermissions())
                .expiresAt(LocalDateTime.now().plusHours(1))
                .metadata(Map.of(
                    "email", email,
                    "name", name,
                    "provider", "google",
                    "googleId", googleId
                ))
                .build();
                
        } catch (Exception e) {
            return AuthResult.builder()
                .success(false)
                .errorCode(AuthErrorCode.OAUTH_ERROR)
                .errorMessage("Google OAuth 인증 중 오류가 발생했습니다")
                .build();
        }
    }
    
    @Override
    public Set<CredentialType> getSupportedTypes() {
        return Set.of(CredentialType.OAUTH_TOKEN);
    }
}
```

## ⚙️ 설정 시스템

### **application.yml 설정 예시**

#### **A 서비스 (TODO) - DB 인증**
```yaml
# A 서비스: 이메일/비밀번호 DB 인증
auth:
  provider: database              # DB 인증 사용
  token-validator: jwt           # JWT 토큰 검증
  
  database:
    user-table: users
    email-column: email
    password-column: password_hash
    
  jwt:
    secret: ${JWT_SECRET:your-secret-key}
    access-expiry: 3600          # 1시간
    refresh-expiry: 86400        # 24시간
    
  permissions:
    default: ["task.read", "task.create"]
    admin: ["task.*", "user.*"]

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/todoapp
    username: ${DB_USER:todo_user}
    password: ${DB_PASSWORD:todo_pass}
```

#### **B 서비스 (E-commerce) - Google OAuth**
```yaml
# B 서비스: Google OAuth 인증
auth:
  provider: google-oauth         # Google OAuth 사용
  token-validator: jwt           # JWT 토큰 검증
  
  google:
    client-id: ${GOOGLE_CLIENT_ID}
    client-secret: ${GOOGLE_CLIENT_SECRET}
    redirect-uri: https://mystore.com/auth/callback
    
  jwt:
    secret: ${JWT_SECRET}
    access-expiry: 7200          # 2시간
    
  permissions:
    default: ["order.read", "product.read"]
    customer: ["order.*"]
    admin: ["*"]

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ecommerce
    username: ${DB_USER:shop_user}
    password: ${DB_PASSWORD:shop_pass}
```

#### **C 서비스 (기업용) - LDAP 인증**
```yaml
# C 서비스: 기업 LDAP 인증
auth:
  provider: ldap                 # LDAP 인증 사용
  token-validator: redis         # Redis 세션 기반 토큰
  
  ldap:
    url: ldap://company.com:389
    base-dn: dc=company,dc=com
    user-dn-pattern: uid={0},ou=people
    
  redis:
    host: redis.company.com
    port: 6379
    timeout: 3600                # 1시간
    
  permissions:
    default: ["profile.read"]
    employee: ["document.read", "calendar.*"]
    manager: ["document.*", "report.read"]
    admin: ["*"]
```

## 🚀 실제 사용 시나리오

### **시나리오 1: A 서비스 (TODO 앱) 개발**

#### **1. 의존성 추가**
```xml
<!-- pom.xml -->
<dependency>
    <groupId>com.yourcompany</groupId>
    <artifactId>auth-core</artifactId>
    <version>1.0.0</version>
</dependency>
```

#### **2. 컨트롤러 구현**
```java
@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    
    @Autowired
    private AuthService authService;  // 코어 모듈에서 제공
    
    @Autowired 
    private TaskService taskService;
    
    /**
     * 태스크 목록 조회 - 인증된 사용자만 접근 가능
     */
    @GetMapping
    public ResponseEntity<List<Task>> getTasks(
            @RequestHeader("Authorization") String authHeader) {
        
        // 1. Bearer 토큰 추출
        String token = extractToken(authHeader);
        
        // 2. 토큰 검증 (어떤 인증 방식이든 동일한 코드)
        AuthResult authResult = authService.validateToken(token);
        if (!authResult.isValid()) {
            return ResponseEntity.status(401).build();
        }
        
        // 3. 권한 확인
        if (!authResult.hasPermission("task.read")) {
            return ResponseEntity.status(403).build();
        }
        
        // 4. 비즈니스 로직 수행
        List<Task> tasks = taskService.getTasksByUser(authResult.getUserId());
        return ResponseEntity.ok(tasks);
    }
    
    /**
     * 태스크 생성 - 생성 권한 필요
     */
    @PostMapping
    public ResponseEntity<Task> createTask(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody CreateTaskRequest request) {
        
        String token = extractToken(authHeader);
        AuthResult authResult = authService.validateToken(token);
        
        if (!authResult.isValid()) {
            return ResponseEntity.status(401).build();
        }
        
        if (!authResult.hasPermission("task.create")) {
            return ResponseEntity.status(403).build();
        }
        
        Task task = taskService.createTask(authResult.getUserId(), request);
        return ResponseEntity.ok(task);
    }
    
    /**
     * 로그인 API
     */
    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        // 어떤 인증 방식이든 동일한 코드
        AuthResult result = authService.login(request.getEmail(), request.getPassword());
        
        if (!result.isValid()) {
            return ResponseEntity.status(401)
                .body(LoginResponse.error(result.getErrorMessage()));
        }
        
        return ResponseEntity.ok(LoginResponse.success(
            result.getAccessToken(),
            result.getRefreshToken(),
            result.getMetadata()
        ));
    }
    
    private String extractToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid authorization header");
    }
}
```

#### **3. 설정 파일**
```yaml
# application.yml
auth:
  provider: database
  token-validator: jwt
  jwt:
    secret: todo-app-secret-key-2024
    access-expiry: 3600

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/todoapp
```

### **시나리오 2: B 서비스 (E-commerce) 개발**

#### **1. 같은 의존성, 다른 설정**
```java
// 컨트롤러 코드는 A 서비스와 거의 동일
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    @Autowired
    private AuthService authService;  // 동일한 인터페이스
    
    @GetMapping
    public ResponseEntity<List<Order>> getOrders(
            @RequestHeader("Authorization") String authHeader) {
        
        String token = extractToken(authHeader);
        
        // 동일한 검증 코드
        AuthResult authResult = authService.validateToken(token);
        if (!authResult.isValid()) {
            return ResponseEntity.status(401).build();
        }
        
        // 권한만 다름
        if (!authResult.hasPermission("order.read")) {
            return ResponseEntity.status(403).build();
        }
        
        List<Order> orders = orderService.getOrdersByUser(authResult.getUserId());
        return ResponseEntity.ok(orders);
    }
}
```

#### **2. 다른 설정 (Google OAuth)**
```yaml
# application.yml - 설정만 다름
auth:
  provider: google-oauth          # 인증 방식만 변경
  token-validator: jwt
  google:
    client-id: your-google-client-id
    client-secret: your-google-client-secret
```

### **시나리오 3: A 서비스의 인증 방식 전환**

#### **DB 인증 → Google OAuth 전환**
```yaml
# 기존 (DB 인증)
auth:
  provider: database
  
# 변경 후 (Google OAuth)  
auth:
  provider: google-oauth
  google:
    client-id: ${GOOGLE_CLIENT_ID}
    client-secret: ${GOOGLE_CLIENT_SECRET}
```

**👆 설정 변경만으로 인증 방식 완전 전환!**
- **Java 코드는 한 줄도 변경하지 않음**
- **기존 토큰들은 자동으로 무효화**
- **새로운 사용자들은 Google 로그인 사용**

## 🔧 확장 가이드

### **새로운 인증 방식 추가하기**

#### **1. 카카오 OAuth 구현체 추가**
```java
@Component
@ConditionalOnProperty(name = "auth.provider", havingValue = "kakao-oauth")
public class KakaoOAuthProvider implements IAuthProvider {
    
    @Override
    public AuthResult authenticate(Credential credential) {
        // 카카오 API 호출하여 토큰 검증
        // 사용자 정보 조회
        // AuthResult 반환
    }
    
    @Override
    public String getProviderId() {
        return "kakao-oauth";
    }
}
```

#### **2. 설정 클래스 추가**
```java
@Configuration
@ConditionalOnProperty(name = "auth.provider", havingValue = "kakao-oauth")
public class KakaoOAuthConfiguration {
    
    @Bean
    @ConfigurationProperties("auth.kakao")
    public KakaoOAuthProperties kakaoProperties() {
        return new KakaoOAuthProperties();
    }
}
```

#### **3. 설정 파일에서 사용**
```yaml
auth:
  provider: kakao-oauth
  kakao:
    app-key: your-kakao-app-key
    redirect-uri: https://yourapp.com/auth/kakao/callback
```

### **커스텀 토큰 검증자 추가**

#### **Redis 세션 기반 토큰**
```java
@Component("redis-session")
@ConditionalOnProperty(name = "auth.token-validator", havingValue = "redis-session")
public class RedisSessionValidator implements ITokenValidator {
    
    private final RedisTemplate<String, Object> redisTemplate;
    
    @Override
    public AuthResult validateToken(String token) {
        // Redis에서 세션 조회
        Object sessionData = redisTemplate.opsForValue().get("session:" + token);
        if (sessionData == null) {
            return AuthResult.builder()
                .success(false)
                .errorCode(AuthErrorCode.TOKEN_EXPIRED)
                .build();
        }
        
        // 세션 데이터를 AuthResult로 변환
        return convertToAuthResult(sessionData);
    }
}
```

## 📅 개발 로드맵

### **Phase 1: 코어 시스템 구축 (4주)**
- [ ] 핵심 인터페이스 정의 (IAuthProvider, ITokenValidator 등)
- [ ] 표준 모델 구현 (AuthResult, Credential 등)
- [ ] ComponentRegistry 및 AutoConfiguration 시스템
- [ ] 기본 예외 처리 및 로깅 시스템
- [ ] 단위 테스트 작성 (커버리지 90% 이상)

### **Phase 2: 기본 구현체 개발 (3주)**
- [ ] DatabaseAuthProvider 구현
- [ ] JwtTokenValidator 구현  
- [ ] 기본 설정 시스템 (application.yml 지원)
- [ ] Spring Boot Starter 패키징
- [ ] 통합 테스트 작성

### **Phase 3: OAuth 통합 (3주)**
- [ ] Google OAuth Provider 구현
- [ ] 카카오/네이버 OAuth Provider 구현
- [ ] OAuth 토큰 처리 및 사용자 매핑 로직
- [ ] OAuth 플로우 테스트 자동화

### **Phase 4: 고급 기능 (4주)**
- [ ] LDAP 인증 지원
- [ ] Redis 세션 관리
- [ ] 2FA (이중 인증) 지원
- [ ] 권한 관리 시스템 고도화
- [ ] 성능 최적화 및 캐싱

### **Phase 5: 생태계 확장 (4주)**
- [ ] Spring Security 연동
- [ ] 모니터링 및 메트릭스 지원
- [ ] Admin 대시보드 (선택사항)
- [ ] 문서화 및 예제 프로젝트
- [ ] Maven Central 배포

## 💡 성공 기준

### **기술적 목표**
- [ ] **Zero Code Change**: 설정 변경만으로 인증 방식 전환
- [ ] **Plugin Architecture**: 새로운 인증 방식을 30분 내로 추가 가능
- [ ] **Performance**: 기존 Spring Security 대비 10% 이상 성능 향상
- [ ] **Test Coverage**: 90% 이상 코드 커버리지
- [ ] **Documentation**: 모든 API 및 설정 100% 문서화

### **사용성 목표**
- [ ] **5분 설정**: 새 프로젝트에 5분 내로 인증 시스템 추가
- [ ] **표준 API**: RESTful API 표준 준수
- [ ] **Error Handling**: 명확한 에러 메시지 및 상태 코드
- [ ] **Backward Compatibility**: 기존 Spring Security 프로젝트와 호환

### **비즈니스 목표**
- [ ] **Multi-Service**: 5개 이상의 서로 다른 서비스에서 검증
- [ ] **Production Ready**: 실제 운영 환경에서 안정적 동작
- [ ] **Community**: GitHub Stars 100+ 및 기여자 5명 이상
- [ ] **Adoption**: 3개 이상의 외부 회사에서 사용

---

## 🎯 간단한 JWT 기반 인증 시스템 구현 계획

### 사용자 요구사항 분석
- **복잡한 플러그인 시스템 불필요**: ComponentRegistry 같은 복잡한 구조 대신 단순한 Strategy Pattern
- **JWT 중심 통합**: 모든 인증 방식(DB, Google OAuth 등)이 최종적으로 동일한 JWT 토큰 발급
- **핵심 목표**: "다양한 로그인 방식 → 통일된 JWT 시스템"

### 📐 간소화된 아키텍처 설계

#### **1. 단순한 Strategy Pattern 구조**
```
┌─────────────────┐
│   AuthService   │  ← 통합 인증 서비스 (단일 진입점)
├─────────────────┤
│ • login()       │
│ • validateJWT() │
│ • refreshJWT()  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ AuthStrategy    │  ← 인증 방식 선택자
│ Interface       │
├─────────────────┤
│ authenticate()  │
└─────────────────┘
         │
    ┌────┼────┐
    ▼    ▼    ▼
┌─────┐┌─────┐┌─────┐
│ DB  ││OAuth││LDAP │  ← 각각의 인증 구현체
│Auth ││Auth ││Auth │
└─────┘└─────┘└─────┘
         │
         ▼
┌─────────────────┐
│   JwtService    │  ← JWT 토큰 생성/검증 (공통)
├─────────────────┤
│ • generateJWT() │
│ • validateJWT() │
│ • refreshJWT()  │
└─────────────────┘
```

#### **2. 핵심 컴포넌트 구조**
```
src/main/java/com/authcore/
├── service/
│   ├── AuthService.java        # 메인 인증 서비스
│   ├── JwtService.java         # JWT 토큰 관리
│   └── UserService.java        # 사용자 정보 관리
├── strategy/
│   ├── AuthStrategy.java       # 인증 전략 인터페이스
│   ├── DatabaseAuthStrategy.java  # DB 인증
│   ├── GoogleOAuthStrategy.java    # Google OAuth
│   └── AuthStrategyFactory.java    # 전략 선택기
├── model/
│   ├── AuthRequest.java        # 인증 요청
│   ├── AuthResponse.java       # 인증 응답
│   └── JwtPayload.java         # JWT 페이로드
└── config/
    ├── AuthConfig.java         # 인증 설정
    └── SecurityConfig.java     # Spring Security 연동
```

### 🔧 JWT 중심 설계

#### **1. JwtService - 핵심 JWT 관리**
```java
@Service
public class JwtService {
    
    @Value("${auth.jwt.secret}")
    private String jwtSecret;
    
    @Value("${auth.jwt.expiration}")
    private Long jwtExpiration;
    
    /**
     * 모든 인증 방식이 최종적으로 호출하는 JWT 생성 메서드
     */
    public String generateAccessToken(String userId, Set<String> roles) {
        return Jwts.builder()
            .setSubject(userId)
            .claim("roles", roles)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
            .signWith(SignatureAlgorithm.HS256, jwtSecret)
            .compact();
    }
    
    public String generateRefreshToken(String userId) {
        return Jwts.builder()
            .setSubject(userId)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration * 7)) // 7배 긴 만료시간
            .signWith(SignatureAlgorithm.HS256, jwtSecret)
            .compact();
    }
    
    /**
     * 모든 API 요청에서 사용하는 JWT 검증
     */
    public AuthResponse validateToken(String token) {
        try {
            Claims claims = Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token)
                .getBody();
                
            return AuthResponse.success(
                claims.getSubject(),
                (List<String>) claims.get("roles")
            );
        } catch (ExpiredJwtException e) {
            return AuthResponse.expired();
        } catch (Exception e) {
            return AuthResponse.invalid();
        }
    }
}
```

#### **2. AuthService - 통합 인증 진입점**
```java
@Service
public class AuthService {
    
    private final JwtService jwtService;
    private final AuthStrategyFactory strategyFactory;
    private final UserService userService;
    
    /**
     * 로그인 - 어떤 방식이든 최종적으로 JWT 발급
     */
    public AuthResponse login(AuthRequest request) {
        // 1. 설정에 따라 적절한 인증 전략 선택
        AuthStrategy strategy = strategyFactory.getStrategy(request.getAuthType());
        
        // 2. 해당 전략으로 인증 수행
        AuthResult authResult = strategy.authenticate(request);
        if (!authResult.isSuccess()) {
            return AuthResponse.failure(authResult.getErrorMessage());
        }
        
        // 3. 성공하면 우리 시스템의 JWT 발급 (핵심!)
        User user = userService.findOrCreate(authResult.getUserInfo());
        String accessToken = jwtService.generateAccessToken(user.getId(), user.getRoles());
        String refreshToken = jwtService.generateRefreshToken(user.getId());
        
        return AuthResponse.success(accessToken, refreshToken, user);
    }
    
    /**
     * 토큰 검증 - 모든 API에서 공통 사용
     */
    public AuthResponse validateToken(String token) {
        return jwtService.validateToken(token);
    }
    
    /**
     * 토큰 갱신
     */
    public AuthResponse refreshToken(String refreshToken) {
        AuthResponse validation = jwtService.validateToken(refreshToken);
        if (!validation.isValid()) {
            return AuthResponse.invalid();
        }
        
        String newAccessToken = jwtService.generateAccessToken(
            validation.getUserId(), 
            validation.getRoles()
        );
        
        return AuthResponse.success(newAccessToken, refreshToken, null);
    }
}
```

### 🏗️ 구현 우선순위 (Phase별 개발)

#### **Phase 1: JWT 기반 DB 인증 (1주)**
```java
// 1단계: 가장 기본적인 이메일/비밀번호 + JWT
@Component
public class DatabaseAuthStrategy implements AuthStrategy {
    
    @Override
    public AuthResult authenticate(AuthRequest request) {
        // DB에서 사용자 조회
        User user = userRepository.findByEmail(request.getEmail());
        if (user == null) {
            return AuthResult.failure("사용자를 찾을 수 없습니다");
        }
        
        // 비밀번호 검증
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            return AuthResult.failure("비밀번호가 일치하지 않습니다");
        }
        
        // 성공 시 사용자 정보 반환 (JWT는 AuthService에서 생성)
        return AuthResult.success(
            UserInfo.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .roles(user.getRoles())
                .build()
        );
    }
}
```

#### **Phase 2: Google OAuth 추가 (1주)**
```java
// 2단계: Google OAuth 추가
@Component  
public class GoogleOAuthStrategy implements AuthStrategy {
    
    private final GoogleTokenVerifier googleVerifier;
    
    @Override
    public AuthResult authenticate(AuthRequest request) {
        try {
            // Google 토큰 검증
            GoogleIdToken idToken = googleVerifier.verify(request.getOauthToken());
            if (idToken == null) {
                return AuthResult.failure("유효하지 않은 Google 토큰입니다");
            }
            
            // Google에서 사용자 정보 추출
            GoogleIdToken.Payload payload = idToken.getPayload();
            String googleId = payload.getSubject();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            
            // 성공 시 사용자 정보 반환 (JWT는 AuthService에서 생성)
            return AuthResult.success(
                UserInfo.builder()
                    .externalId(googleId)
                    .provider("google")
                    .email(email)
                    .name(name)
                    .roles(Set.of("USER")) // 기본 권한
                    .build()
            );
        } catch (Exception e) {
            return AuthResult.failure("Google OAuth 인증 중 오류 발생");
        }
    }
}
```

#### **Phase 3: 다른 OAuth 제공자 확장 (1주)**
```java
// 3단계: 카카오, 네이버 등 추가
@Component
public class KakaoOAuthStrategy implements AuthStrategy {
    // 카카오 API 연동 로직
    // 최종적으로는 동일한 UserInfo 반환
}
```

### ⚙️ 설정 예시 (간단한 YAML 변경)

#### **DB 인증 사용 시**
```yaml
# application-db.yml
auth:
  strategy: database          # 인증 방식 선택
  jwt:
    secret: your-secret-key
    expiration: 3600000      # 1시간
    refresh-expiration: 86400000  # 24시간

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/myapp
    username: dbuser
    password: dbpass
```

#### **Google OAuth 사용 시**
```yaml
# application-oauth.yml  
auth:
  strategy: google-oauth      # 인증 방식만 변경!
  jwt:
    secret: your-secret-key   # JWT 설정은 동일
    expiration: 3600000
    refresh-expiration: 86400000
  google:
    client-id: ${GOOGLE_CLIENT_ID}
    client-secret: ${GOOGLE_CLIENT_SECRET}
```

#### **프로필별 전환**
```bash
# DB 인증으로 실행
java -jar app.jar --spring.profiles.active=db

# Google OAuth로 실행  
java -jar app.jar --spring.profiles.active=oauth
```

### 💻 실제 코드 예시

#### **1. 컨트롤러 구현**
```java
@RestController
@RequestMapping("/api")
public class AuthController {
    
    private final AuthService authService;
    
    /**
     * 통합 로그인 API - 어떤 인증 방식이든 동일한 엔드포인트
     */
    @PostMapping("/auth/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        AuthResponse response = authService.login(request);
        return response.isValid() 
            ? ResponseEntity.ok(response)
            : ResponseEntity.status(401).body(response);
    }
    
    /**
     * 토큰 검증 API
     */
    @PostMapping("/auth/validate")  
    public ResponseEntity<AuthResponse> validate(@RequestHeader("Authorization") String token) {
        String jwt = extractToken(token);
        AuthResponse response = authService.validateToken(jwt);
        return ResponseEntity.ok(response);
    }
    
    /**
     * 토큰 갱신 API
     */
    @PostMapping("/auth/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody RefreshRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return response.isValid()
            ? ResponseEntity.ok(response) 
            : ResponseEntity.status(401).body(response);
    }
    
    private String extractToken(String authHeader) {
        return authHeader.startsWith("Bearer ") 
            ? authHeader.substring(7) 
            : authHeader;
    }
}

/**
 * 비즈니스 API - JWT 검증 공통 적용
 */
@RestController  
@RequestMapping("/api/todos")
public class TodoController {
    
    private final AuthService authService;
    private final TodoService todoService;
    
    @GetMapping
    public ResponseEntity<List<Todo>> getTodos(@RequestHeader("Authorization") String token) {
        // 1. JWT 검증 (어떤 인증 방식으로 발급된 토큰이든 동일하게 처리)
        AuthResponse auth = authService.validateToken(extractToken(token));
        if (!auth.isValid()) {
            return ResponseEntity.status(401).build();
        }
        
        // 2. 비즈니스 로직 수행
        List<Todo> todos = todoService.getTodosByUser(auth.getUserId());
        return ResponseEntity.ok(todos);
    }
}
```

#### **2. 요청/응답 모델**
```java
// 통합 인증 요청
@Data
public class AuthRequest {
    private AuthType authType;        // DATABASE, GOOGLE_OAUTH, KAKAO_OAUTH 등
    
    // DB 인증용
    private String email;
    private String password;
    
    // OAuth 인증용  
    private String oauthToken;
    private String provider;          // "google", "kakao" 등
    
    // 정적 팩토리 메서드
    public static AuthRequest database(String email, String password) {
        return AuthRequest.builder()
            .authType(AuthType.DATABASE)
            .email(email)
            .password(password)
            .build();
    }
    
    public static AuthRequest googleOAuth(String token) {
        return AuthRequest.builder()
            .authType(AuthType.GOOGLE_OAUTH)
            .oauthToken(token)
            .provider("google")
            .build();
    }
}

// 통합 인증 응답 (모든 인증 방식이 동일한 형식)
@Data
@Builder  
public class AuthResponse {
    private boolean valid;
    private String userId;
    private String accessToken;       // 우리 시스템의 JWT
    private String refreshToken;      // 우리 시스템의 Refresh JWT
    private Set<String> roles;
    private String errorMessage;
    
    public static AuthResponse success(String accessToken, String refreshToken, User user) {
        return AuthResponse.builder()
            .valid(true)
            .userId(user.getId())
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .roles(user.getRoles())
            .build();
    }
    
    public static AuthResponse failure(String errorMessage) {
        return AuthResponse.builder()
            .valid(false)
            .errorMessage(errorMessage)
            .build();
    }
}
```

### 🧪 테스트 계획

#### **1. 통합 테스트**
```java
@SpringBootTest
@TestMethodOrder(OrderAnnotation.class)
class AuthIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    private String accessToken;
    
    /**
     * DB 인증 → JWT 발급 → API 호출 전체 플로우 테스트
     */
    @Test
    @Order(1)
    void testDatabaseAuthFlow() {
        // 1. DB 로그인
        AuthRequest loginRequest = AuthRequest.database("test@example.com", "password");
        ResponseEntity<AuthResponse> response = restTemplate.postForEntity(
            "/api/auth/login", loginRequest, AuthResponse.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        AuthResponse authResponse = response.getBody();
        assertThat(authResponse.isValid()).isTrue();
        assertThat(authResponse.getAccessToken()).isNotBlank();
        
        this.accessToken = authResponse.getAccessToken();
        
        // 2. JWT로 보호된 API 호출
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        
        ResponseEntity<List> todosResponse = restTemplate.exchange(
            "/api/todos", HttpMethod.GET, entity, List.class);
            
        assertThat(todosResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
    
    /**
     * Google OAuth → JWT 발급 → API 호출 전체 플로우 테스트  
     */
    @Test
    @Order(2)
    void testGoogleOAuthFlow() {
        // Mock Google 토큰으로 테스트
        AuthRequest oauthRequest = AuthRequest.googleOAuth("mock-google-token");
        ResponseEntity<AuthResponse> response = restTemplate.postForEntity(
            "/api/auth/login", oauthRequest, AuthResponse.class);
        
        // 동일한 JWT 발급 확인
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        AuthResponse authResponse = response.getBody();
        assertThat(authResponse.isValid()).isTrue();
        assertThat(authResponse.getAccessToken()).isNotBlank();
        
        // 동일한 API 호출 가능 확인
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(authResponse.getAccessToken());
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        
        ResponseEntity<List> todosResponse = restTemplate.exchange(
            "/api/todos", HttpMethod.GET, entity, List.class);
            
        assertThat(todosResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
    
    /**
     * 인증 방식 변경 시 기존 토큰 무효화 테스트
     */
    @Test  
    @Order(3)
    void testAuthStrategySwitch() {
        // 설정 변경 후 기존 토큰이 여전히 유효한지 확인
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        
        ResponseEntity<AuthResponse> validation = restTemplate.exchange(
            "/api/auth/validate", HttpMethod.POST, entity, AuthResponse.class);
            
        // JWT 자체는 여전히 유효해야 함 (설정 변경과 무관)
        assertThat(validation.getBody().isValid()).isTrue();
    }
}
```

#### **2. 성능 테스트**
```java
@Test
void testJwtPerformance() {
    StopWatch stopWatch = new StopWatch();
    
    // 1000번의 JWT 생성 시간 측정
    stopWatch.start("JWT Generation");
    for (int i = 0; i < 1000; i++) {
        String token = jwtService.generateAccessToken("user" + i, Set.of("USER"));
        assertThat(token).isNotBlank();
    }
    stopWatch.stop();
    
    // 1000번의 JWT 검증 시간 측정  
    List<String> tokens = generateTestTokens(1000);
    stopWatch.start("JWT Validation");
    for (String token : tokens) {
        AuthResponse response = jwtService.validateToken(token);
        assertThat(response.isValid()).isTrue();
    }
    stopWatch.stop();
    
    System.out.println(stopWatch.prettyPrint());
    
    // 성능 기준: 1000번 처리가 1초 이내
    assertThat(stopWatch.getTotalTimeMillis()).isLessThan(1000);
}
```

### 🚀 실제 배포 및 운영

#### **1. Docker 설정**
```dockerfile
# Dockerfile
FROM openjdk:21-jre-slim

COPY target/auth-service.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"  
    environment:
      - SPRING_PROFILES_ACTIVE=${AUTH_PROFILE:-db}
      - AUTH_JWT_SECRET=${JWT_SECRET}
      - GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
      - GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
    depends_on:
      - postgres
      
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=authdb
      - POSTGRES_USER=authuser
      - POSTGRES_PASSWORD=authpass
    ports:
      - "5432:5432"
```

#### **2. 배포 스크립트**
```bash
#!/bin/bash
# deploy.sh

# 인증 방식 선택
AUTH_TYPE=${1:-database}

echo "Deploying with ${AUTH_TYPE} authentication..."

# 환경별 설정 적용
case $AUTH_TYPE in
    "database")
        export SPRING_PROFILES_ACTIVE=db
        ;;
    "google")  
        export SPRING_PROFILES_ACTIVE=oauth
        export GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
        export GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
        ;;
    *)
        echo "Unknown auth type: $AUTH_TYPE"
        exit 1
        ;;
esac

# 빌드 및 배포
./mvnw clean package -DskipTests
docker-compose up --build -d

echo "Deployed successfully with ${AUTH_TYPE} auth!"
```

### 💡 핵심 장점 정리

1. **단순성**: 복잡한 ComponentRegistry 없이 간단한 Strategy Pattern
2. **JWT 중심**: 모든 인증 방식이 동일한 JWT로 통합
3. **설정 기반**: 코드 변경 없이 YAML 설정만으로 인증 방식 전환
4. **확장성**: 새로운 OAuth 제공자 추가가 쉬움
5. **테스트 용이성**: 각 컴포넌트가 독립적으로 테스트 가능
6. **실용성**: 실제 운영에서 바로 사용 가능한 구조

---

**📝 문서 정보**
- **작성일**: 2025-07-22
- **버전**: 1.1 (JWT 중심 간소화 계획 추가)
- **상태**: 상세 구현 계획 완료
- **담당자**: 개발팀