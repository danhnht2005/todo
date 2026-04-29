class TaskListModel {
  final String id;
  final String title;
  final int taskCount;
  final DateTime createdAt;

  const TaskListModel({
    required this.id,
    required this.title,
    this.taskCount = 0,
    required this.createdAt,
  });

  TaskListModel copyWith({
    String? id,
    String? title,
    int? taskCount,
    DateTime? createdAt,
  }) {
    return TaskListModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static TaskListModel fromJson(
    Map<String, dynamic> json, {
    int taskCount = 0,
  }) {
    return TaskListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      taskCount: taskCount,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String title,
  }) {
    return {'user_id': userId, 'title': title};
  }
}
