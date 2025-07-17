import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../view_component/task_card.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final allTasks = tasks.where((task) => task.status != 'completed').toList();

    // 우선순위별로 정렬
    allTasks.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a.priority] ?? 0;
      final bPriority = priorityOrder[b.priority] ?? 0;
      if (aPriority != bPriority) {
        return bPriority.compareTo(aPriority); // 높은 우선순위부터
      }
      return a.deadline.compareTo(b.deadline); // 마감일 순
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 태스크'),
        backgroundColor: Colors.green.shade50,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // 상태 표시 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행중인 모든 태스크',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    _buildStatusChip('전체', allTasks.length, Colors.green.shade100, Colors.green.shade700),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      '마감임박', 
                      _getUrgentTasksCount(allTasks), 
                      Colors.red.shade100, 
                      Colors.red.shade700
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 태스크 리스트
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: allTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '등록된 태스크가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '오늘 할 일 탭에서 새 태스크를 추가해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // 새로고침 기능
                        ref.invalidate(taskProvider);
                      },
                      child: ListView.builder(
                        itemCount: allTasks.length,
                        itemBuilder: (context, index) {
                          final task = allTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(task: task),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label $count개',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  int _getUrgentTasksCount(List tasks) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return tasks.where((task) {
      return task.deadline.isBefore(tomorrow);
    }).length;
  }
}
