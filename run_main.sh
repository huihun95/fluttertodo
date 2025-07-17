#!/bin/bash

# Flutter TODO 메인 앱 실행 스크립트

# Flutter 프로젝트 디렉토리로 이동
cd "$(dirname "$0")"

# 메인 TODO 앱 실행
flutter run -d macos --release
