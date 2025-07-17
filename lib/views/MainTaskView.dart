import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../view_component/task_card.dart';
import '../view_component/task_creation_bar.dart';

class MainTaskView extends ConsumerWidget {
  const MainTaskView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final todayTasks = tasks.where((task) {
      final today = DateTime.now();
      return task.deadline.year == today.year &&
          task.deadline.month == today.month &&
          task.deadline.day == today.day &&
          task.status != 'completed';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 할 일'),
        backgroundColor: Colors.blue.shade50,
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
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '오늘 예정된 태스크',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: todayTasks.isEmpty ? Colors.grey.shade300 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todayTasks.length}개',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: todayTasks.isEmpty ? Colors.grey.shade600 : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 태스크 리스트
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: todayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.today_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '오늘 할 일이 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '아래에서 새로운 태스크를 추가해보세요',
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
                        itemCount: todayTasks.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(task: todayTasks[index]),
                          );
                        },
                      ),
                    ),
            ),
          ),
          // 태스크 생성 바
          const TaskCreationBar(),
        ],
      ),
    );
  }
}
