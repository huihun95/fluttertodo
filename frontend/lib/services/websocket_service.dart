import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// WebSocket 연결 상태
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

// WebSocket 메시지 타입
enum MessageType {
  taskAssigned('TASK_ASSIGNED'),
  taskCompleted('TASK_COMPLETED'),
  taskUpdated('TASK_UPDATED'),
  taskDeleted('TASK_DELETED'),
  teamMemberAdded('TEAM_MEMBER_ADDED'),
  teamMemberRemoved('TEAM_MEMBER_REMOVED'),
  userOnlineStatus('USER_ONLINE_STATUS');

  const MessageType(this.value);
  final String value;

  static MessageType? fromString(String value) {
    for (MessageType type in MessageType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

// WebSocket 메시지 모델
class WebSocketMessage {
  final MessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;
  final String? teamId;

  WebSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
    this.userId,
    this.teamId,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: MessageType.fromString(json['type']) ?? MessageType.taskUpdated,
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'teamId': teamId,
    };
  }
}

// WebSocket 서비스
class WebSocketService extends ChangeNotifier {
  static const String _baseUrl = 'ws://127.0.0.1:8080/ws/tasks';
  static const int _reconnectDelay = 3000; // 3초
  static const int _maxReconnectAttempts = 5;

  WebSocketChannel? _channel;
  WebSocketState _state = WebSocketState.disconnected;
  String? _currentUserId;
  String? _currentTeamId;
  int _reconnectAttempts = 0;
  
  final List<WebSocketMessage> _messageHistory = [];
  final Map<MessageType, List<Function(WebSocketMessage)>> _listeners = {};

  // Getters
  WebSocketState get state => _state;
  String? get currentUserId => _currentUserId;
  String? get currentTeamId => _currentTeamId;
  List<WebSocketMessage> get messageHistory => List.unmodifiable(_messageHistory);
  bool get isConnected => _state == WebSocketState.connected;

  // WebSocket 연결
  Future<void> connect({
    required String userId,
    String? teamId,
  }) async {
    if (_state == WebSocketState.connecting || _state == WebSocketState.connected) {
      return;
    }

    _currentUserId = userId;
    _currentTeamId = teamId;
    
    await _connectToWebSocket();
  }

  Future<void> _connectToWebSocket() async {
    try {
      _setState(WebSocketState.connecting);
      
      // WebSocket URL 구성
      String url = _baseUrl;
      List<String> params = [];
      
      if (_currentUserId != null) {
        params.add('userId=$_currentUserId');
      }
      if (_currentTeamId != null) {
        params.add('teamId=$_currentTeamId');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      log('WebSocket 연결 시도: $url');
      
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
        protocols: ['websocket'], // 프로토콜 명시
      );
      
      // 연결 타임아웃 설정 (5초)
      await Future.any([
        _channel!.ready,
        Future.delayed(const Duration(seconds: 5), () => throw 'Connection timeout'),
      ]);
      
      // WebSocket 스트림 리스닝
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: false, // 에러 발생 시에도 스트림 유지
      );

      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;
      
      log('WebSocket 연결 성공');
      
      // 연결 확인 메시지 전송
      _sendMessage({
        'type': 'CONNECTION_ESTABLISHED',
        'userId': _currentUserId,
        'teamId': _currentTeamId,
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      log('WebSocket 연결 실패: $e');
      _setState(WebSocketState.error);
      _scheduleReconnect();
    }
  }

  // 메시지 수신 처리
  void _onMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final wsMessage = WebSocketMessage.fromJson(data);
      
      log('WebSocket 메시지 수신: ${wsMessage.type.value}');
      
      // 메시지 히스토리에 추가
      _messageHistory.add(wsMessage);
      if (_messageHistory.length > 100) {
        _messageHistory.removeAt(0); // 최대 100개 메시지만 보관
      }
      
      // 리스너들에게 알림
      _notifyListeners(wsMessage);
      
    } catch (e) {
      log('메시지 파싱 오류: $e');
    }
  }

  // 오류 처리
  void _onError(error) {
    log('WebSocket 오류: $error');
    _setState(WebSocketState.error);
    _scheduleReconnect();
  }

  // 연결 종료 처리
  void _onDisconnected() {
    log('WebSocket 연결 종료');
    _setState(WebSocketState.disconnected);
    _channel = null;
    _scheduleReconnect();
  }

  // 재연결 스케줄링
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      log('최대 재연결 시도 횟수 초과');
      _setState(WebSocketState.error);
      return;
    }

    _reconnectAttempts++;
    _setState(WebSocketState.reconnecting);
    
    log('재연결 시도 $_reconnectAttempts/$_maxReconnectAttempts');
    
    Future.delayed(Duration(milliseconds: _reconnectDelay), () {
      if (_state == WebSocketState.reconnecting) {
        _connectToWebSocket();
      }
    });
  }

  // 메시지 전송
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _state == WebSocketState.connected) {
      try {
        _channel!.sink.add(jsonEncode(message));
        log('메시지 전송: ${message['type']}');
      } catch (e) {
        log('메시지 전송 실패: $e');
      }
    } else {
      log('WebSocket이 연결되지 않음 - 메시지 전송 실패');
    }
  }

  // 태스크 관련 메시지 전송
  void sendTaskStatusUpdate(String taskId, String status) {
    _sendMessage({
      'type': 'TASK_STATUS_UPDATE',
      'data': {
        'taskId': taskId,
        'status': status,
      },
      'userId': _currentUserId,
      'teamId': _currentTeamId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendTaskAssignment(String taskId, String assigneeId) {
    _sendMessage({
      'type': 'TASK_ASSIGNMENT',
      'data': {
        'taskId': taskId,
        'assigneeId': assigneeId,
      },
      'userId': _currentUserId,
      'teamId': _currentTeamId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // WebSocket 이벤트 리스너 등록
  void addWebSocketListener(MessageType type, Function(WebSocketMessage) callback) {
    if (!_listeners.containsKey(type)) {
      _listeners[type] = [];
    }
    _listeners[type]!.add(callback);
  }

  // WebSocket 이벤트 리스너 제거
  void removeWebSocketListener(MessageType type, Function(WebSocketMessage) callback) {
    _listeners[type]?.remove(callback);
  }

  // 리스너들에게 알림
  void _notifyListeners(WebSocketMessage message) {
    final listeners = _listeners[message.type];
    if (listeners != null) {
      for (final callback in listeners) {
        try {
          callback(message);
        } catch (e) {
          log('리스너 콜백 실행 오류: $e');
        }
      }
    }
  }

  // 팀 변경
  Future<void> switchTeam(String? teamId) async {
    if (_currentTeamId != teamId) {
      _currentTeamId = teamId;
      if (_state == WebSocketState.connected) {
        // 연결을 다시 설정
        await disconnect();
        await connect(userId: _currentUserId!, teamId: teamId);
      }
    }
  }

  // 연결 종료
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _setState(WebSocketState.disconnected);
    _currentUserId = null;
    _currentTeamId = null;
    _reconnectAttempts = 0;
    _messageHistory.clear();
    _listeners.clear();
    
    log('WebSocket 연결 종료');
  }

  // 상태 변경
  void _setState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

// Riverpod Providers
final webSocketServiceProvider = ChangeNotifierProvider<WebSocketService>((ref) {
  return WebSocketService();
});

// WebSocket 상태 Provider
final webSocketStateProvider = Provider<WebSocketState>((ref) {
  return ref.watch(webSocketServiceProvider).state;
});

// WebSocket 연결 상태 Provider
final webSocketConnectedProvider = Provider<bool>((ref) {
  return ref.watch(webSocketServiceProvider).isConnected;
});

// WebSocket 메시지 히스토리 Provider
final webSocketMessagesProvider = Provider<List<WebSocketMessage>>((ref) {
  return ref.watch(webSocketServiceProvider).messageHistory;
});