import 'step_model.dart';

/// TaskModel
class TaskModel {
  final String id;
  final String title;
  final String? note;
  final bool isCompleted;
  final bool isImportant;
  final bool isMyDay;
  final String? listId;
  final List<StepModel> steps;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.note,
    this.isCompleted = false,
    this.isImportant = false,
    this.isMyDay = false,
    this.listId,
    this.steps = const [],
    this.dueDate,
    this.reminderAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int get completedStepCount => steps.where((s) => s.isCompleted).length;
  int get totalStepCount => steps.length;
  double get stepProgress =>
      totalStepCount == 0 ? 0.0 : completedStepCount / totalStepCount;

  TaskModel copyWith({
    String? id,
    String? title,
    String? note,
    bool? isCompleted,
    bool? isImportant,
    bool? isMyDay,
    String? listId,
    List<StepModel>? steps,
    DateTime? dueDate,
    DateTime? reminderAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      isMyDay: isMyDay ?? this.isMyDay,
      listId: listId ?? this.listId,
      steps: steps ?? this.steps,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static TaskModel fromJson(Map<String, dynamic> json) {
    List<StepModel> steps = [];
    if (json['steps'] != null && json['steps'] is List) {
      steps = (json['steps'] as List)
          .map((s) => StepModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      note: json['note'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      isImportant: json['is_important'] as bool? ?? false,
      isMyDay: json['is_my_day'] as bool? ?? false,
      listId: json['list_id'] as String?,
      steps: steps,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String title,
    String? note,
    bool isImportant = false,
    bool isMyDay = false,
    String? listId,
    String? dueDate,
  }) {
    return {
      'user_id': userId,
      'title': title,
      if (note != null) 'note': note,
      'is_important': isImportant,
      'is_my_day': isMyDay,
      'list_id': listId,
      'due_date': dueDate,
    };
  }

  static Map<String, dynamic> toUpdateJson({
    String? title,
    String? note,
    bool? isCompleted,
    bool? isImportant,
    bool? isMyDay,
    String? listId,
    String? dueDate,
    String? reminderAt,
    String? completedAt,
    bool clearDueDate = false,
    bool clearListId = false,
    bool clearNote = false,
  }) {
    final map = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) map['title'] = title;
    if (note != null) map['note'] = note;
    if (clearNote) map['note'] = null;
    if (isCompleted != null) {
      map['is_completed'] = isCompleted;
      map['completed_at'] = isCompleted
          ? DateTime.now().toIso8601String()
          : null;
    }
    if (isImportant != null) map['is_important'] = isImportant;
    if (isMyDay != null) map['is_my_day'] = isMyDay;
    if (listId != null) map['list_id'] = listId;
    if (clearListId) map['list_id'] = null;
    if (dueDate != null) map['due_date'] = dueDate;
    if (clearDueDate) map['due_date'] = null;
    if (reminderAt != null) map['reminder_at'] = reminderAt;
    if (completedAt != null) map['completed_at'] = completedAt;
    return map;
  }
}
