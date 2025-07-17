#!/bin/bash

# Flutter TODO Spotlight 실행 스크립트
# 이 스크립트는 Command + , 키 조합으로 실행되어 Spotlight 스타일의 TODO 추가 창을 엽니다.

# Flutter 프로젝트 디렉토리로 이동
cd "$(dirname "$0")"

# Spotlight 모드로 Flutter 앱 실행
flutter run -d macos --dart-entrypoint-args="spotlight" -t lib/spotlight_main.dart --release
