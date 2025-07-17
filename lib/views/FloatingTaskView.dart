import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../view_component/task_creation_bar.dart';

class FloatingTaskView extends ConsumerStatefulWidget {
  const FloatingTaskView({super.key});

  @override
  ConsumerState<FloatingTaskView> createState() => _FloatingTaskViewState();
}

class _FloatingTaskViewState extends ConsumerState<FloatingTaskView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    // 완료되지 않은 태스크만 가져와서 생성순으로 정렬 (가장 먼저 등록한 순서)
    final allTasks = tasks.where((task) => task.status != 'completed').toList();
    allTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // 기본적으로 최대 3개만 표시
    final displayTasks = allTasks.take(3).toList();

    return Material(
      color: Colors.transparent, // 완전 투명
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 순수 태스크 컨테이너들만
              if (displayTasks.isEmpty)
                Container(
                  width: 300,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95), // 약간 투명
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '태스크가 없습니다',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...displayTasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < displayTasks.length - 1 ? 8 : 0),
                    child: PureTaskCard(task: task),
                  );
                }),
              
              // 마우스 호버 시에만 태스크 추가 창 표시
              if (_isHovered)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: const TaskCreationBar(isCompact: true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 완전히 순수한 태스크 카드 (배경 없음)
class PureTaskCard extends ConsumerWidget {
  final dynamic task;

  const PureTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = _getPriorityColor(task.priority);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && task.status != 'completed';

    return GestureDetector(
      onTap: () => _showTaskMenu(context, ref, task),
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: isOverdue 
              ? Colors.red.shade50.withOpacity(0.95) 
              : Colors.white.withOpacity(0.95), // 약간 투명
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? Colors.red.shade300 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // 더 진한 그림자
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 요청자와 마감기한
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.requester,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${task.deadline.month}/${task.deadline.day} ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 태스크 내용
              Expanded(
                child: Text(
                  task.content,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _showTaskMenu(BuildContext context, WidgetRef ref, dynamic task) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('태스크 관리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('완료하기'),
              onTap: () {
                ref.read(taskProvider.notifier).completeTask(task.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제하기'),
              onTap: () {
                ref.read(taskProvider.notifier).deleteTask(task.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
