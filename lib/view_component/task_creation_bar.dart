import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/TaskModel.dart';
import '../controllers/task_controller.dart';

class TaskCreationBar extends ConsumerStatefulWidget {
  final bool isCompact;
  const TaskCreationBar({super.key, this.isCompact = false});

  @override
  ConsumerState<TaskCreationBar> createState() => _TaskCreationBarState();
}

class _TaskCreationBarState extends ConsumerState<TaskCreationBar> {
  final _contentController = TextEditingController();
  String _selectedRequester = 'Self';
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  String _selectedPriority = 'medium';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.isCompact ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // 약간 투명
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // 더 진한 그림자
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 태스크 옵션들 (컴팩트 모드에서는 숨김)
          if (!widget.isCompact) ...[
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    '요청자: $_selectedRequester',
                    () => _showRequesterDialog(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOptionButton(
                    '마감: ${DateFormat('MM/dd').format(_selectedDeadline)}',
                    () => _showDeadlineDialog(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOptionButton(
                    '우선순위: $_selectedPriority',
                    () => _showPriorityDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // 태스크 입력 및 생성
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: widget.isCompact ? '태스크 추가...' : '새 태스크를 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: widget.isCompact ? 6 : 8,
                    ),
                  ),
                  maxLines: widget.isCompact ? 1 : 2,
                  minLines: 1,
                  onSubmitted: (_) => _createTask(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showRequesterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('요청자 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Self', 'PM', 'Team Lead', 'Client']
              .map((requester) => ListTile(
                    title: Text(requester),
                    onTap: () {
                      setState(() {
                        _selectedRequester = requester;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showDeadlineDialog() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
      );
      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('우선순위 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['high', 'medium', 'low']
              .map((priority) => ListTile(
                    title: Text(priority.toUpperCase()),
                    onTap: () {
                      setState(() {
                        _selectedPriority = priority;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _createTask() {
    if (_contentController.text.trim().isEmpty) return;

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      requester: _selectedRequester,
      deadline: _selectedDeadline,
      content: _contentController.text.trim(),
      priority: _selectedPriority,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    ref.read(taskProvider.notifier).addTask(task);
    _contentController.clear();
    
    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('태스크가 추가되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
