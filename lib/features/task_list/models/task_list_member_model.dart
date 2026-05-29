class TaskListMemberModel {
  final String id;
  final String listId;
  final String userId;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;

  const TaskListMemberModel({
    required this.id,
    required this.listId,
    required this.userId,
    this.fullName,
    this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  static TaskListMemberModel fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return TaskListMemberModel(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      userId: json['user_id'] as String,
      fullName: profile?['full_name'] as String?,
      email: profile?['email'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
