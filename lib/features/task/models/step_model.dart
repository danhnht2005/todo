/// StepModel
class StepModel {
  final String id;
  final String title;
  final bool isCompleted;

  const StepModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  StepModel copyWith({String? id, String? title, bool? isCompleted}) {
    return StepModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static StepModel fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String taskId,
    required String title,
    int sortOrder = 0,
  }) {
    return {'task_id': taskId, 'title': title, 'sort_order': sortOrder};
  }
}
