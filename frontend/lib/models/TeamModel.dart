class TeamModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int? memberCount;

  TeamModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.memberCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
    };
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      memberCount: json['memberCount'],
    );
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? memberCount,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}