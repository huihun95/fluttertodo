import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/TeamModel.dart';
import '../models/UserModel.dart';
import '../controllers/team_controller.dart';
import '../services/websocket_service.dart';

class TeamManagementView extends ConsumerStatefulWidget {
  const TeamManagementView({super.key});

  @override
  ConsumerState<TeamManagementView> createState() => _TeamManagementViewState();
}

class _TeamManagementViewState extends ConsumerState<TeamManagementView> {
  TeamModel? _selectedTeam;
  bool _showCreateTeamForm = false;

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    final teamMembers = _selectedTeam != null 
        ? ref.watch(teamMembersProvider(_selectedTeam!.id))
        : <UserModel>[];

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
                  _selectedTeam == null ? '팀 선택' : '${_selectedTeam!.name} 팀원',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (_selectedTeam != null) ...[
                      // 뒤로가기 버튼
                      GestureDetector(
                        onTap: () => setState(() => _selectedTeam = null),
                        child: Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 새로고침 또는 팀 생성 버튼
                    GestureDetector(
                      onTap: () {
                        if (_selectedTeam == null) {
                          setState(() => _showCreateTeamForm = !_showCreateTeamForm);
                        } else {
                          ref.refresh(teamMembersProvider(_selectedTeam!.id));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _showCreateTeamForm ? Colors.green.shade50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _selectedTeam == null 
                              ? (_showCreateTeamForm ? Icons.close : Icons.group_add)
                              : Icons.refresh,
                          size: 16,
                          color: _selectedTeam == null
                              ? (_showCreateTeamForm ? Colors.green.shade600 : Colors.grey.shade600)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 팀 생성 폼 (토글)
          if (_showCreateTeamForm && _selectedTeam == null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: const CreateTeamForm(),
            ),

          // 메인 컨텐츠
          Expanded(
            child: _selectedTeam == null 
                ? _buildTeamList(teams)
                : _buildTeamMembersList(teamMembers),
          ),
        ],
      ),
    );
  }

  // 팀 목록 뷰
  Widget _buildTeamList(List<TeamModel> teams) {
    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              '참여중인 팀이 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: teams.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final team = teams[index];
        return TeamListItem(
          team: team,
          onTap: () => setState(() => _selectedTeam = team),
        );
      },
    );
  }

  // 팀원 목록 뷰  
  Widget _buildTeamMembersList(List<UserModel> members) {
    return Column(
      children: [
        // 태스크 할당 버튼
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: () => _showTaskAssignDialog(),
            icon: const Icon(Icons.assignment_add, size: 16),
            label: const Text('태스크 할당하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        // 팀원 목록
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '팀원이 없습니다',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: members.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return TeamMemberItem(
                      member: member,
                      onAssignTask: () => _showTaskAssignDialog(assignTo: member),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showTaskAssignDialog({UserModel? assignTo}) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => TaskAssignDialog(
        team: _selectedTeam!,
        assignTo: assignTo,
      ),
    );
  }
}

// 팀 목록 아이템
class TeamListItem extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;

  const TeamListItem({
    super.key,
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // 팀 아이콘
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.groups,
                size: 14,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 10),
            
            // 팀 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (team.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      team.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // 멤버 수
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${team.memberCount ?? 0}명',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
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

// 팀원 아이템
class TeamMemberItem extends StatelessWidget {
  final UserModel member;
  final VoidCallback onAssignTask;

  const TeamMemberItem({
    super.key,
    required this.member,
    required this.onAssignTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 아바타
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (member.email != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    member.email!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // 할당 버튼
          GestureDetector(
            onTap: onAssignTask,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.assignment_add,
                size: 14,
                color: Colors.blue.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 팀 생성 폼
class CreateTeamForm extends ConsumerStatefulWidget {
  const CreateTeamForm({super.key});

  @override
  ConsumerState<CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends ConsumerState<CreateTeamForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 팀명 입력
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '팀명 입력',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 6),
        
        // 설명 입력
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: '팀 설명 (선택사항)',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        
        // 생성 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('팀 생성', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  void _createTeam() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팀명을 입력해주세요')),
      );
      return;
    }

    // TODO: 실제 팀 생성 API 호출
    ref.read(teamControllerProvider.notifier).createTeam(
      _nameController.text.trim(),
      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    _nameController.clear();
    _descriptionController.clear();
  }
}

// 태스크 할당 다이얼로그
class TaskAssignDialog extends ConsumerStatefulWidget {
  final TeamModel team;
  final UserModel? assignTo;

  const TaskAssignDialog({
    super.key,
    required this.team,
    this.assignTo,
  });

  @override
  ConsumerState<TaskAssignDialog> createState() => _TaskAssignDialogState();
}

class _TaskAssignDialogState extends ConsumerState<TaskAssignDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  UserModel? _selectedAssignee;

  @override
  void initState() {
    super.initState();
    _selectedAssignee = widget.assignTo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamMembers = ref.watch(teamMembersProvider(widget.team.id));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 350,
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
                  '태스크 할당',
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
            const SizedBox(height: 16),
            
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '태스크 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            // 내용 입력
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '태스크 내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            
            // 담당자 선택
            DropdownButtonFormField<UserModel>(
              value: _selectedAssignee,
              decoration: const InputDecoration(
                labelText: '담당자',
                border: OutlineInputBorder(),
              ),
              items: teamMembers.map((member) {
                return DropdownMenuItem<UserModel>(
                  value: member,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAssignee = value),
            ),
            const SizedBox(height: 12),
            
            // 마감일 선택
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '마감일',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_deadline.year}/${_deadline.month}/${_deadline.day} ${_deadline.hour.toString().padLeft(2, '0')}:${_deadline.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _assignTask,
                    child: const Text('할당하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline),
      );
      
      if (time != null) {
        setState(() {
          _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _assignTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('태스크 제목을 입력해주세요')),
      );
      return;
    }

    if (_selectedAssignee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('담당자를 선택해주세요')),
      );
      return;
    }

    // 태스크 할당 API 호출
    ref.read(taskControllerProvider.notifier).assignTask(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      assigneeId: _selectedAssignee!.id,
      teamId: widget.team.id,
      deadline: _deadline,
    );

    // WebSocket을 통해 실시간 태스크 할당 알림 전송
    final webSocketService = ref.read(webSocketServiceProvider);
    webSocketService.sendTaskAssignment(
      DateTime.now().millisecondsSinceEpoch.toString(), // 임시 태스크 ID
      _selectedAssignee!.id,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedAssignee!.name}님에게 태스크를 할당했습니다')),
    );
  }
}