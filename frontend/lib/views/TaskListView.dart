import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../models/TaskModel.dart';
import '../view_component/task_creation_bar.dart';
import '../services/websocket_service.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final pendingTasks = tasks.where((task) => task.status != '완료').toList();
    
    // 최신순으로 정렬
    pendingTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          // 헤더 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 태스크 (${pendingTasks.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    // 새로고침 버튼
                    GestureDetector(
                      onTap: () {
                        // TODO: 서버에서 태스크 새로고침
                        ref.refresh(taskProvider);
                      },
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 태스크 추가 버튼
                    GestureDetector(
                      onTap: () => setState(() => _showCreateForm = !_showCreateForm),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _showCreateForm ? Colors.blue.shade50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _showCreateForm ? Icons.close : Icons.add,
                          size: 16,
                          color: _showCreateForm ? Colors.blue.shade600 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 태스크 생성 폼 (토글)
          if (_showCreateForm)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: const TaskCreationBar(isCompact: true),
            ),
          
          // 태스크 목록
          Expanded(
            child: pendingTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '할당된 태스크가 없습니다',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: pendingTasks.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final task = pendingTasks[index];
                      return CompactTaskItem(
                        task: task,
                        onTap: () => _showTaskDetail(task),
                        onComplete: () => _completeTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetail(TaskModel task) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => TaskDetailDialog(task: task),
    );
  }

  void _completeTask(TaskModel task) {
    // 로컬 상태 업데이트
    ref.read(taskProvider.notifier).updateTaskStatus(task.id, '완료');
    
    // WebSocket을 통해 실시간 상태 업데이트 전송
    final webSocketService = ref.read(webSocketServiceProvider);
    webSocketService.sendTaskStatusUpdate(task.id, '완료');
  }

}

// 컴팩트 태스크 아이템
class CompactTaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const CompactTaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.deadline.isBefore(DateTime.now());
    final isUrgent = task.deadline.difference(DateTime.now()).inHours < 24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 완료 체크박스
            GestureDetector(
              onTap: onComplete,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOverdue ? Colors.red.shade400 : Colors.blue.shade400,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            
            // 태스크 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 및 상태
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '지연',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '긴급',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  
                  // 요청자 및 마감일
                  Row(
                    children: [
                      Text(
                        '${task.requester} →',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.deadline.month}/${task.deadline.day} ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isOverdue ? Colors.red.shade600 : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 더보기 아이콘
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// 태스크 상세 다이얼로그
class TaskDetailDialog extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '태스크 상세',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 제목
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // 메타 정보
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('요청자', task.requester ?? '알 수 없음'),
                ),
                Expanded(
                  child: _buildInfoItem('담당자', task.assignee),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('마감일', 
                    '${task.deadline.month}/${task.deadline.day} ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')}'),
                ),
                Expanded(
                  child: _buildInfoItem('상태', task.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(taskProvider.notifier).updateTaskStatus(task.id, '완료');
                      Navigator.pop(context);
                    },
                    child: const Text('완료하기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
