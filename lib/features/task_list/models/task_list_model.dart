class TaskListModel {
  final String id;
  final String userId;
  final String title;
  final int taskCount;
  final DateTime createdAt;
  final bool isOwner;

  const TaskListModel({
    required this.id,
    required this.userId,
    required this.title,
    this.taskCount = 0,
    required this.createdAt,
    this.isOwner = true,
  });

  TaskListModel copyWith({
    String? id,
    String? userId,
    String? title,
    int? taskCount,
    DateTime? createdAt,
    bool? isOwner,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      createdAt: createdAt ?? this.createdAt,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  static TaskListModel fromJson(
    Map<String, dynamic> json, {
    int taskCount = 0,
    bool? isOwner,
    String? currentUserId,
  }) {
    final userId = json['user_id'] as String;
    return TaskListModel(
      id: json['id'] as String,
      userId: userId,
      title: json['title'] as String,
      taskCount: taskCount,
      createdAt: DateTime.parse(json['created_at'] as String),
      isOwner: isOwner ?? (currentUserId == null || userId == currentUserId),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String title,
  }) {
    return {'user_id': userId, 'title': title};
  }
}
