import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'websocket_service.dart';

// 알림 타입
enum NotificationType {
  taskAssigned('태스크 할당됨', Icons.assignment, Colors.blue),
  taskCompleted('태스크 완료됨', Icons.check_circle, Colors.green),
  taskUpdated('태스크 업데이트됨', Icons.edit, Colors.orange),
  taskDeleted('태스크 삭제됨', Icons.delete, Colors.red),
  teamMemberAdded('팀원 추가됨', Icons.person_add, Colors.blue),
  teamMemberRemoved('팀원 제거됨', Icons.person_remove, Colors.red),
  userOnline('사용자 온라인', Icons.circle, Colors.green),
  userOffline('사용자 오프라인', Icons.circle_outlined, Colors.grey);

  const NotificationType(this.title, this.icon, this.color);
  final String title;
  final IconData icon;
  final Color color;

  static NotificationType fromMessageType(MessageType messageType) {
    switch (messageType) {
      case MessageType.taskAssigned:
        return NotificationType.taskAssigned;
      case MessageType.taskCompleted:
        return NotificationType.taskCompleted;
      case MessageType.taskUpdated:
        return NotificationType.taskUpdated;
      case MessageType.taskDeleted:
        return NotificationType.taskDeleted;
      case MessageType.teamMemberAdded:
        return NotificationType.teamMemberAdded;
      case MessageType.teamMemberRemoved:
        return NotificationType.teamMemberRemoved;
      case MessageType.userOnlineStatus:
        return NotificationType.userOnline;
    }
  }
}

// 알림 모델
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}

// 알림 서비스
class NotificationService extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final List<AppNotification> _notifications = [];
  bool _isInitialized = false;

  NotificationService(this._webSocketService) {
    _initialize();
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  void _initialize() {
    if (_isInitialized) return;
    
    // WebSocket 메시지 리스너 등록
    _webSocketService.addWebSocketListener(MessageType.taskAssigned, _onTaskAssigned);
    _webSocketService.addWebSocketListener(MessageType.taskCompleted, _onTaskCompleted);
    _webSocketService.addWebSocketListener(MessageType.taskUpdated, _onTaskUpdated);
    _webSocketService.addWebSocketListener(MessageType.taskDeleted, _onTaskDeleted);
    _webSocketService.addWebSocketListener(MessageType.teamMemberAdded, _onTeamMemberAdded);
    _webSocketService.addWebSocketListener(MessageType.teamMemberRemoved, _onTeamMemberRemoved);
    _webSocketService.addWebSocketListener(MessageType.userOnlineStatus, _onUserOnlineStatus);
    
    _isInitialized = true;
    log('알림 서비스 초기화 완료');
  }

  // 태스크 할당 알림
  void _onTaskAssigned(WebSocketMessage message) {
    final taskData = message.data;
    final assignerName = taskData['assignerName'] ?? '알 수 없는 사용자';
    final taskTitle = taskData['title'] ?? '새 태스크';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.taskAssigned,
      title: '새 태스크가 할당되었습니다',
      message: '$assignerName님이 "$taskTitle" 태스크를 할당했습니다',
      timestamp: message.timestamp,
      data: taskData,
    ));
  }

  // 태스크 완료 알림
  void _onTaskCompleted(WebSocketMessage message) {
    final taskData = message.data;
    final completedBy = taskData['completedBy'] ?? '알 수 없는 사용자';
    final taskTitle = taskData['title'] ?? '태스크';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.taskCompleted,
      title: '태스크가 완료되었습니다',
      message: '$completedBy님이 "$taskTitle" 태스크를 완료했습니다',
      timestamp: message.timestamp,
      data: taskData,
    ));
  }

  // 태스크 업데이트 알림
  void _onTaskUpdated(WebSocketMessage message) {
    final taskData = message.data;
    final updatedBy = taskData['updatedBy'] ?? '알 수 없는 사용자';
    final taskTitle = taskData['title'] ?? '태스크';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.taskUpdated,
      title: '태스크가 업데이트되었습니다',
      message: '$updatedBy님이 "$taskTitle" 태스크를 업데이트했습니다',
      timestamp: message.timestamp,
      data: taskData,
    ));
  }

  // 태스크 삭제 알림
  void _onTaskDeleted(WebSocketMessage message) {
    final taskData = message.data;
    final deletedBy = taskData['deletedBy'] ?? '알 수 없는 사용자';
    final taskTitle = taskData['title'] ?? '태스크';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.taskDeleted,
      title: '태스크가 삭제되었습니다',
      message: '$deletedBy님이 "$taskTitle" 태스크를 삭제했습니다',
      timestamp: message.timestamp,
      data: taskData,
    ));
  }

  // 팀원 추가 알림
  void _onTeamMemberAdded(WebSocketMessage message) {
    final memberData = message.data;
    final memberName = memberData['memberName'] ?? '새 팀원';
    final teamName = memberData['teamName'] ?? '팀';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.teamMemberAdded,
      title: '새 팀원이 추가되었습니다',
      message: '$memberName님이 $teamName에 합류했습니다',
      timestamp: message.timestamp,
      data: memberData,
    ));
  }

  // 팀원 제거 알림
  void _onTeamMemberRemoved(WebSocketMessage message) {
    final memberData = message.data;
    final memberName = memberData['memberName'] ?? '팀원';
    final teamName = memberData['teamName'] ?? '팀';
    
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.teamMemberRemoved,
      title: '팀원이 제거되었습니다',
      message: '$memberName님이 $teamName에서 제거되었습니다',
      timestamp: message.timestamp,
      data: memberData,
    ));
  }

  // 사용자 온라인 상태 알림
  void _onUserOnlineStatus(WebSocketMessage message) {
    final statusData = message.data;
    final userName = statusData['userName'] ?? '사용자';
    final isOnline = statusData['isOnline'] ?? false;
    
    // 온라인 상태 변경은 너무 빈번하므로 중요한 경우만 알림
    if (statusData['showNotification'] == true) {
      _addNotification(AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: isOnline ? NotificationType.userOnline : NotificationType.userOffline,
        title: isOnline ? '사용자가 온라인입니다' : '사용자가 오프라인입니다',
        message: '$userName님이 ${isOnline ? '온라인' : '오프라인'} 상태가 되었습니다',
        timestamp: message.timestamp,
        data: statusData,
      ));
    }
  }

  // 알림 추가
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification); // 최신 알림을 맨 위에
    
    // 최대 50개의 알림만 보관
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    
    notifyListeners();
    log('새 알림 추가: ${notification.title}');
  }

  // 수동 알림 추가 (UI에서 직접 호출)
  void addManualNotification({
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    _addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  // 알림 읽음 처리
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // 모든 알림 읽음 처리
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  // 알림 삭제
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // 모든 알림 삭제
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // 읽은 알림만 삭제
  void clearReadNotifications() {
    _notifications.removeWhere((n) => n.isRead);
    notifyListeners();
  }

  @override
  void dispose() {
    // WebSocket 리스너 제거
    if (_isInitialized) {
      _webSocketService.removeWebSocketListener(MessageType.taskAssigned, _onTaskAssigned);
      _webSocketService.removeWebSocketListener(MessageType.taskCompleted, _onTaskCompleted);
      _webSocketService.removeWebSocketListener(MessageType.taskUpdated, _onTaskUpdated);
      _webSocketService.removeWebSocketListener(MessageType.taskDeleted, _onTaskDeleted);
      _webSocketService.removeWebSocketListener(MessageType.teamMemberAdded, _onTeamMemberAdded);
      _webSocketService.removeWebSocketListener(MessageType.teamMemberRemoved, _onTeamMemberRemoved);
      _webSocketService.removeWebSocketListener(MessageType.userOnlineStatus, _onUserOnlineStatus);
    }
    super.dispose();
  }
}

// Riverpod Providers
final notificationServiceProvider = ChangeNotifierProvider<NotificationService>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return NotificationService(webSocketService);
});

// 알림 목록 Provider
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(notificationServiceProvider).notifications;
});

// 읽지 않은 알림 목록 Provider
final unreadNotificationsProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(notificationServiceProvider).unreadNotifications;
});

// 읽지 않은 알림 개수 Provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationServiceProvider).unreadCount;
});