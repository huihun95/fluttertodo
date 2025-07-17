import 'package:flutter/material.dart';
import 'dart:io';

class AccessibilityPermissionDialog extends StatelessWidget {
  const AccessibilityPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(Icons.security, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          const Text('접근성 권한 필요'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '전역 단축키 (Command + ,)를 사용하려면 접근성 권한이 필요합니다.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '설정 방법:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. 시스템 환경설정 열기\n'
                  '2. 보안 및 개인정보보호 선택\n'
                  '3. 접근성 탭으로 이동\n'
                  '4. TODO 앱에 체크 표시',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '권한을 허용하지 않아도 앱은 정상 작동합니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () {
            _openSystemPreferences();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('설정 열기'),
        ),
      ],
    );
  }
  
  void _openSystemPreferences() {
    // macOS 시스템 환경설정의 접근성 페이지 열기
    Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
    ]);
  }
}
