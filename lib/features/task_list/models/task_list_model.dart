class TaskListModel {
  final String id;
  final String userId;
  final String title;
  final int taskCount;
  final DateTime createdAt;
  final bool isOwner;
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerAvatarUrl;

  const TaskListModel({
    required this.id,
    required this.userId,
    required this.title,
    this.taskCount = 0,
    required this.createdAt,
    this.isOwner = true,
    this.ownerName,
    this.ownerEmail,
    this.ownerAvatarUrl,
  });

  TaskListModel copyWith({
    String? id,
    String? userId,
    String? title,
    int? taskCount,
    DateTime? createdAt,
    bool? isOwner,
    String? ownerName,
    String? ownerEmail,
    String? ownerAvatarUrl,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      createdAt: createdAt ?? this.createdAt,
      isOwner: isOwner ?? this.isOwner,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
    );
  }

  static TaskListModel fromJson(
    Map<String, dynamic> json, {
    int taskCount = 0,
    bool? isOwner,
    String? currentUserId,
  }) {
    final userId = json['user_id'] as String;
    final profile = json['profiles'] as Map<String, dynamic>?;
    return TaskListModel(
      id: json['id'] as String,
      userId: userId,
      title: json['title'] as String,
      taskCount: taskCount,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwner: isOwner ?? (currentUserId == null || userId == currentUserId),
      ownerName: profile?['full_name'] as String?,
      ownerEmail: profile?['email'] as String?,
      ownerAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String title,
  }) {
    return {'user_id': userId, 'title': title};
  }
}
