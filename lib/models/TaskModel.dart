class TaskModel {
  final String id;
  final String requester;
  final DateTime deadline;
  final String content;
  final String priority;
  final String status;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.requester,
    required this.deadline,
    required this.content,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester': requester,
      'deadline': deadline.toIso8601String(),
      'content': content,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      requester: json['requester'],
      deadline: DateTime.parse(json['deadline']),
      content: json['content'],
      priority: json['priority'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  TaskModel copyWith({
    String? id,
    String? requester,
    DateTime? deadline,
    String? content,
    String? priority,
    String? status,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      requester: requester ?? this.requester,
      deadline: deadline ?? this.deadline,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}