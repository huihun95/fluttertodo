import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../models/TaskModel.dart';

class SpotlightTaskCreator extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const SpotlightTaskCreator({super.key, required this.onClose});

  @override
  ConsumerState<SpotlightTaskCreator> createState() => _SpotlightTaskCreatorState();
}

class _SpotlightTaskCreatorState extends ConsumerState<SpotlightTaskCreator>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // 포커스를 텍스트 필드에 자동으로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _createTask() {
    if (_contentController.text.trim().isEmpty) return;
    
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _contentController.text.trim(), // content를 title로도 사용
      content: _contentController.text.trim(),
      requester: null, // 퀵 생성이므로 요청자 없음
      assignee: '내가 담당', // 기본 담당자
      deadline: DateTime.now().add(const Duration(days: 1)), // 기본 1일 후
      status: '진행중',
      createdAt: DateTime.now(),
    );
    
    ref.read(taskProvider.notifier).addTask(task);
    _closeWithAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _closeWithAnimation();
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              _createTask();
            }
          }
        },
        child: GestureDetector(
          onTap: _closeWithAnimation,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: GestureDetector(
                onTap: () {}, // 내부 클릭 시 닫히지 않도록
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: _buildSpotlightWindow(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlightWindow() {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 텍스트 필드
          Expanded(
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              decoration: InputDecoration(
                hintText: '새 작업을 입력하세요...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted: (_) => _createTask(),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // + 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _createTask,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}