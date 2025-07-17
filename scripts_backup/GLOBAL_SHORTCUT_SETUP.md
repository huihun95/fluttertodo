# Flutter TODO - 전역 단축키 설정 가이드

## 🎯 목표
`Command + ,` 키 조합을 눌렀을 때 화면 어디서든 Spotlight 스타일의 TODO 추가 창이 나타나도록 설정합니다.

## 📦 빌드 및 설정

### 1. 앱 빌드
```bash
# 메인 TODO 앱 빌드
flutter build macos --release

# Spotlight 창 앱 빌드
flutter build macos --release -t lib/spotlight_main.dart
```

### 2. macOS Automator를 사용한 전역 단축키 설정

#### 2-1. Automator 앱 생성
1. **Spotlight 검색** → "Automator" 실행
2. **새로운 문서 생성** → "Quick Action" 선택
3. **"Workflow receives"** 설정:
   - "no input" 선택
   - "in any application" 선택

#### 2-2. Shell Script 액션 추가
1. 왼쪽 라이브러리에서 **"Run Shell Script"** 드래그
2. Shell 스크립트 내용:
```bash
#!/bin/bash
cd /Users/hh/Desktop/github/fluttertodo
flutter run -d macos -t lib/spotlight_main.dart --release &
```

#### 2-3. Quick Action 저장
- 파일명: "TODO Spotlight" 로 저장

#### 2-4. 시스템 환경설정에서 단축키 설정
1. **시스템 환경설정** → **키보드** → **단축키**
2. **서비스** 섹션에서 "TODO Spotlight" 찾기
3. **단축키 설정**: `Command + ,`

### 3. 대안: Spotlight용 실행파일 생성

더 빠른 실행을 위해 별도의 바이너리를 생성할 수도 있습니다:

```bash
# Spotlight 전용 실행파일 생성
flutter build macos --release -t lib/spotlight_main.dart -o build/spotlight_app
```

## 🚀 사용 방법

### 메인 TODO 앱 실행
```bash
./run_main.sh
```

### Spotlight 창 실행 (수동)
```bash
./run_spotlight.sh
```

### 전역 단축키 사용
1. 어느 앱에서든 `Command + ,` 키 조합 누르기
2. Spotlight 스타일의 TODO 추가 창이 화면 중앙에 나타남
3. 작업 입력 후 Enter 또는 "추가" 버튼 클릭
4. 창이 자동으로 닫힘

## 🎨 특징

### Spotlight 창 특징
- **투명한 배경**: 뒤의 화면이 희미하게 보임
- **중앙 정렬**: 항상 화면 중앙에 표시
- **자동 포커스**: 창이 열리면 즉시 입력 가능
- **빠른 종료**: Enter, Esc, 또는 외부 클릭으로 종료
- **전체 기능**: 우선순위, 마감시간, 요청자 설정 가능

### 키보드 단축키
- **Enter**: 작업 추가 및 창 닫기
- **Esc**: 창 닫기 (작업 추가 없이)
- **Tab**: 필드 간 이동

## 🔧 문제 해결

### 권한 문제
```bash
# 스크립트 실행 권한 부여
chmod +x run_main.sh
chmod +x run_spotlight.sh
```

### Flutter 경로 문제
스크립트에서 Flutter 경로를 절대 경로로 수정:
```bash
/usr/local/bin/flutter run -d macos -t lib/spotlight_main.dart --release
```

### 단축키 충돌
다른 앱에서 `Command + ,`를 사용하는 경우 다른 키 조합으로 변경:
- `Command + Shift + N`
- `Option + Space`
- `Control + Command + T`

## 📱 향후 개선 사항

1. **네이티브 macOS 앱 변환**: Swift로 네이티브 앱 생성
2. **더 빠른 실행**: 백그라운드에서 대기하는 서비스 형태
3. **시스템 통합**: macOS 알림 센터와 연동
4. **iCloud 동기화**: 여러 기기 간 작업 동기화

이제 `Command + ,` 키를 누르면 어디서든 빠르게 TODO를 추가할 수 있습니다! 🎉
