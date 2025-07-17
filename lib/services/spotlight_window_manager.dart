import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpotlightWindowManager {
  static final SpotlightWindowManager _instance = SpotlightWindowManager._internal();
  factory SpotlightWindowManager() => _instance;
  SpotlightWindowManager._internal();
  
  bool _isSpotlightMode = false;
  Size? _originalSize;
  Offset? _originalPosition;
  bool? _originalAlwaysOnTop;
  bool? _originalSkipTaskbar;
  
  Future<void> showSpotlightWindow() async {
    if (_isSpotlightMode) return;
    
    try {
      // 현재 창 상태 저장
      _originalSize = await windowManager.getSize();
      _originalPosition = await windowManager.getPosition();
      _originalAlwaysOnTop = await windowManager.isAlwaysOnTop();
      _originalSkipTaskbar = await windowManager.isSkipTaskbar();
      
      // Spotlight 모드로 창 변경
      await windowManager.setSize(const Size(600, 450));
      await windowManager.center();
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSkipTaskbar(false); // 독에서 보이도록
      await windowManager.show();
      await windowManager.focus();
      
      _isSpotlightMode = true;
    } catch (e) {
      print('❌ Spotlight 창 표시 실패: $e');
    }
  }
  
  Future<void> hideSpotlightWindow() async {
    if (!_isSpotlightMode) return;
    
    try {
      // 원래 창 상태로 복원
      if (_originalSize != null) {
        await windowManager.setSize(_originalSize!);
      }
      if (_originalPosition != null) {
        await windowManager.setPosition(_originalPosition!);
      }
      if (_originalAlwaysOnTop != null) {
        await windowManager.setAlwaysOnTop(_originalAlwaysOnTop!);
      }
      if (_originalSkipTaskbar != null) {
        await windowManager.setSkipTaskbar(_originalSkipTaskbar!);
      }
      
      _isSpotlightMode = false;
      
      // 원래 상태 초기화
      _originalSize = null;
      _originalPosition = null;
      _originalAlwaysOnTop = null;
      _originalSkipTaskbar = null;
    } catch (e) {
      print('❌ 원래 창 복원 실패: $e');
    }
  }
  
  bool get isSpotlightMode => _isSpotlightMode;
}

// Provider
final spotlightWindowManagerProvider = Provider<SpotlightWindowManager>((ref) {
  return SpotlightWindowManager();
});
