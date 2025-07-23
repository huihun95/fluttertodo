import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_component/navigation_bar.dart';
import '../view_component/notification_widget.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';
import 'TaskListView.dart';
import 'TeamManagementView.dart';

class FloatingTaskView extends ConsumerStatefulWidget {
  const FloatingTaskView({super.key});

  @override
  ConsumerState<FloatingTaskView> createState() => _FloatingTaskViewState();
}

class _FloatingTaskViewState extends ConsumerState<FloatingTaskView> {
  OverlayEntry? _notificationOverlay;

  @override
  void initState() {
    super.initState();
    
    // WebSocket 연결 (임시 사용자 ID로 연결)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
      _setupNotificationListener();
    });
  }

  void _initializeWebSocket() {
    final webSocketService = ref.read(webSocketServiceProvider);
    // TODO: 실제 사용자 ID와 팀 ID로 교체
    webSocketService.connect(
      userId: 'user_001', // 임시 사용자 ID
      teamId: '1', // 기본 팀 ID
    );
  }

  void _setupNotificationListener() {
    final notificationService = ref.read(notificationServiceProvider);
    
    // TODO: 실제 알림 수신 시 인앱 팝업 표시
    // 이 부분은 추후 실제 알림 수신 시 구현
  }

  void _showNotificationPopup(AppNotification notification) {
    // 기존 팝업이 있으면 제거
    _notificationOverlay?.remove();
    
    _notificationOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: InAppNotificationPopup(
          notification: notification,
          onDismiss: () {
            _notificationOverlay?.remove();
            _notificationOverlay = null;
          },
          onTap: () {
            // 알림 클릭 시 읽음 처리
            ref.read(notificationServiceProvider).markAsRead(notification.id);
            _notificationOverlay?.remove();
            _notificationOverlay = null;
          },
        ),
      ),
    );
    
    Overlay.of(context).insert(_notificationOverlay!);
  }

  @override
  void dispose() {
    _notificationOverlay?.remove();
    // WebSocket 연결 해제
    ref.read(webSocketServiceProvider).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);
    final webSocketState = ref.watch(webSocketStateProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 연결 상태 표시 (선택사항)
            if (webSocketState != WebSocketState.connected)
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConnectionColor(webSocketState).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: _getConnectionColor(webSocketState), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getConnectionColor(webSocketState),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getConnectionText(webSocketState),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getConnectionColor(webSocketState),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            // 네비게이션 바 (알림 배지 포함)
            Stack(
              clipBehavior: Clip.none,
              children: [
                const TodoNavigationBar(),
                
                // 알림 배지 (우측 상단)
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            // 선택된 탭에 따른 컨텐츠
            if (activeTab == NavigationTab.tasks)
              const TaskListView()
            else if (activeTab == NavigationTab.team)
              const TeamManagementView(),
          ],
        ),
      ),
    );
  }

  Color _getConnectionColor(WebSocketState state) {
    switch (state) {
      case WebSocketState.connected:
        return Colors.green;
      case WebSocketState.connecting:
      case WebSocketState.reconnecting:
        return Colors.orange;
      case WebSocketState.disconnected:
      case WebSocketState.error:
        return Colors.red;
    }
  }

  String _getConnectionText(WebSocketState state) {
    switch (state) {
      case WebSocketState.connected:
        return '연결됨';
      case WebSocketState.connecting:
        return '연결 중...';
      case WebSocketState.reconnecting:
        return '재연결 중...';
      case WebSocketState.disconnected:
        return '연결 안됨';
      case WebSocketState.error:
        return '연결 오류';
    }
  }
}
