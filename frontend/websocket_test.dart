import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  print('WebSocket 연결 테스트 시작...');
  
  try {
    // WebSocket 연결 시도
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8080/ws/tasks?userId=test&teamId=1'),
      protocols: ['websocket'],
    );
    
    print('WebSocket 연결 중...');
    
    // 연결 대기
    await channel.ready;
    print('✅ WebSocket 연결 성공!');
    
    // 메시지 리스닝
    channel.stream.listen(
      (message) {
        print('📨 메시지 수신: $message');
      },
      onError: (error) {
        print('❌ 메시지 수신 오류: $error');
      },
      onDone: () {
        print('🔌 연결 종료됨');
      },
    );
    
    // 테스트 메시지 전송
    final testMessage = {
      'type': 'CONNECTION_ESTABLISHED',
      'userId': 'test',
      'teamId': '1',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    channel.sink.add(testMessage.toString());
    print('📤 테스트 메시지 전송: $testMessage');
    
    // 5초 후 연결 종료
    await Future.delayed(const Duration(seconds: 5));
    await channel.sink.close();
    print('🏁 테스트 완료');
    
  } catch (e) {
    print('❌ WebSocket 연결 실패: $e');
  }
}