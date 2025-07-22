class TaskModel {
  final String id;
  final String title;
  final String content;
  final String? requester;
  final String assignee;
  final DateTime deadline;
  final String status;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.content,
    this.requester,
    required this.assignee,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'requester': requester,
      'assignee': assignee,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      requester: json['requester'],
      assignee: json['assignee'],
      deadline: DateTime.parse(json['deadline']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? content,
    String? requester,
    String? assignee,
    DateTime? deadline,
    String? status,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      requester: requester ?? this.requester,
      assignee: assignee ?? this.assignee,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}