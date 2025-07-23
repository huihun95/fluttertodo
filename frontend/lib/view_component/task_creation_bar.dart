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
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedRequester;
  String _selectedAssignee = '내가 담당';
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.isCompact ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          // 태스크 옵션들 (컴팩트 모드에서는 숨김)
          if (!widget.isCompact) ...[
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    '요청자: ${_selectedRequester ?? '선택 안함'}',
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
                    '담당자: $_selectedAssignee',
                    () => _showAssigneeDialog(),
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
                child: Column(
                  children: [
                    if (!widget.isCompact)
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '제목...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 1,
                        onSubmitted: (_) => _createTask(),
                      ),
                    if (!widget.isCompact) const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: widget.isCompact ? '태스크 추가...' : '내용...',
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
                  ],
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
          children: ['선택 안함', '나', 'PM', '팀리더', '고객']
              .map((requester) => ListTile(
                    title: Text(requester),
                    onTap: () {
                      setState(() {
                        _selectedRequester = requester == '선택 안함' ? null : requester;
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

  void _showAssigneeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('담당자 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['내가 담당', '팀원A', '팀원B', '외부업체']
              .map((assignee) => ListTile(
                    title: Text(assignee),
                    onTap: () {
                      setState(() {
                        _selectedAssignee = assignee;
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
    final title = widget.isCompact ? _contentController.text.trim() : _titleController.text.trim();
    final content = widget.isCompact ? '' : _contentController.text.trim();
    
    if (title.isEmpty) return;

    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      requester: _selectedRequester,
      assignee: _selectedAssignee,
      deadline: _selectedDeadline,
      status: '진행중',
      createdAt: DateTime.now(),
    );

    ref.read(taskProvider.notifier).addTask(task);
    _titleController.clear();
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
