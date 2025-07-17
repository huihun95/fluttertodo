import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HotkeyService {
  static final HotkeyService _instance = HotkeyService._internal();
  factory HotkeyService() => _instance;
  HotkeyService._internal();
  
  final StreamController<bool> _showSpotlightController = StreamController<bool>.broadcast();
  Stream<bool> get showSpotlightStream => _showSpotlightController.stream;
  
  bool _isInitialized = false;
  bool _isSpotlightVisible = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // hotkey_manager 초기화
      await hotKeyManager.unregisterAll();
      
      // Command + , 전역 단축키 등록
      HotKey hotKey = HotKey(
        KeyCode.comma,
        modifiers: [KeyModifier.meta], // Command 키 (macOS)
        scope: HotKeyScope.system, // 시스템 전역에서 동작
      );
      
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) {
          if (!_isSpotlightVisible) {
            showSpotlight();
          }
        },
      );
      
      _isInitialized = true;
      print('✅ 전역 단축키 등록 완료: Command + ,');
    } catch (e) {
      print('❌ 전역 단축키 등록 실패: $e');
      print('💡 해결방법: 시스템 환경설정 > 보안 및 개인정보보호 > 접근성에서 앱 권한 허용');
    }
  }
  
  void showSpotlight() {
    _isSpotlightVisible = true;
    _showSpotlightController.add(true);
  }
  
  void hideSpotlight() {
    _isSpotlightVisible = false;
    _showSpotlightController.add(false);
  }
  
  void dispose() {
    _showSpotlightController.close();
    hotKeyManager.unregisterAll();
    _isInitialized = false;
  }
}

// Provider
final hotkeyServiceProvider = Provider<HotkeyService>((ref) {
  return HotkeyService();
});
