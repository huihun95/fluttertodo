import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/TeamModel.dart';
import '../models/UserModel.dart';

// 팀 목록 Provider
final teamsProvider = StateNotifierProvider<TeamsNotifier, List<TeamModel>>((ref) {
  return TeamsNotifier();
});

// 팀 멤버 목록 Provider
final teamMembersProvider = StateNotifierProvider.family<TeamMembersNotifier, List<UserModel>, String>((ref, teamId) {
  return TeamMembersNotifier(teamId);  
});

// 팀 컨트롤러 Provider
final teamControllerProvider = StateNotifierProvider<TeamControllerNotifier, AsyncValue<void>>((ref) {
  return TeamControllerNotifier(ref);
});

// 태스크 컨트롤러 Provider
final taskControllerProvider = StateNotifierProvider<TaskControllerNotifier, AsyncValue<void>>((ref) {
  return TaskControllerNotifier(ref);
});

// 팀 목록 관리
class TeamsNotifier extends StateNotifier<List<TeamModel>> {
  TeamsNotifier() : super([]) {
    _loadTeams();
  }

  void _loadTeams() {
    // TODO: 실제 API 호출로 팀 목록 로드
    // 임시 데이터
    state = [
      TeamModel(
        id: '1',
        name: '개발팀',
        description: '프론트엔드 및 백엔드 개발',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        memberCount: 5,
      ),
      TeamModel(
        id: '2',
        name: '디자인팀',
        description: 'UI/UX 디자인',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        memberCount: 3,
      ),
    ];
  }

  void addTeam(TeamModel team) {
    state = [...state, team];
  }

  void updateTeam(TeamModel updatedTeam) {
    state = state.map((team) => team.id == updatedTeam.id ? updatedTeam : team).toList();
  }

  void removeTeam(String teamId) {
    state = state.where((team) => team.id != teamId).toList();
  }

  void refresh() {
    _loadTeams();
  }
}

// 팀 멤버 목록 관리
class TeamMembersNotifier extends StateNotifier<List<UserModel>> {
  final String teamId;

  TeamMembersNotifier(this.teamId) : super([]) {
    _loadTeamMembers();
  }

  void _loadTeamMembers() {
    // TODO: 실제 API 호출로 팀 멤버 목록 로드
    // 임시 데이터
    if (teamId == '1') {
      state = [
        UserModel(
          id: '1',
          name: '김개발',
          email: 'kim.dev@company.com',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        UserModel(
          id: '2',
          name: '이백엔드',
          email: 'lee.backend@company.com',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        UserModel(
          id: '3',
          name: '박프론트',
          email: 'park.frontend@company.com',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ];
    } else if (teamId == '2') {
      state = [
        UserModel(
          id: '4',
          name: '최디자인',
          email: 'choi.design@company.com',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        UserModel(
          id: '5',
          name: '정UX',
          email: 'jung.ux@company.com',
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ];
    } else {
      state = [];
    }
  }

  void addMember(UserModel member) {
    state = [...state, member];
  }

  void removeMember(String userId) {
    state = state.where((member) => member.id != userId).toList();
  }

  void refresh() {
    _loadTeamMembers();
  }
}

// 팀 관련 액션 컨트롤러
class TeamControllerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TeamControllerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createTeam(String name, String? description) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션
      
      final newTeam = TeamModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
        memberCount: 1, // 생성자만 포함
      );
      
      ref.read(teamsProvider.notifier).addTeam(newTeam);
      state = const AsyncValue.data(null);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTeamMember(String teamId, String userId) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 성공적으로 추가되면 팀 멤버 목록 새로고침
      ref.read(teamMembersProvider(teamId).notifier).refresh();
      state = const AsyncValue.data(null);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeTeamMember(String teamId, String userId) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(milliseconds: 500));
      
      ref.read(teamMembersProvider(teamId).notifier).removeMember(userId);
      state = const AsyncValue.data(null);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// 태스크 할당 컨트롤러
class TaskControllerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TaskControllerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> assignTask({
    required String title,
    required String content,
    required String assigneeId,
    required String teamId,
    required DateTime deadline,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: 실제 태스크 할당 API 호출
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 성공하면 태스크 목록 새로고침
      // ref.read(taskProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}