import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/step_model.dart';
import '../models/task_model.dart';

/// TaskService — CRUD tasks
class TaskService {
  final SupabaseClient _client;

  TaskService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// Lấy tất cả tasks của user (kèm steps)
  Future<List<TaskModel>> getTasks() async {
    final response = await _client
        .from('tasks')
        .select('*, steps(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Lấy tasks theo filter
  Future<List<TaskModel>> getTasksFiltered({
    bool? isMyDay,
    bool? isImportant,
    bool? hasDueDate,
    String? listId,
    bool noList = false,
  }) async {
    var query = _client.from('tasks').select('*, steps(*)');

    query = query.eq('user_id', _userId);

    if (isMyDay == true) {
      query = query.eq('is_my_day', true);
    }
    if (isImportant == true) {
      query = query.eq('is_important', true);
    }
    if (hasDueDate == true) {
      query = query.not('due_date', 'is', null);
    }
    if (listId != null) {
      query = query.eq('list_id', listId);
    }
    if (noList) {
      query = query.isFilter('list_id', null);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Lấy chi tiết 1 task theo id
  Future<TaskModel> getTaskById(String id) async {
    final response = await _client
        .from('tasks')
        .select('*, steps(*)')
        .eq('id', id)
        .eq('user_id', _userId)
        .single();

    return TaskModel.fromJson(response);
  }

  /// Tạo task mới
  Future<TaskModel> createTask({
    required String title,
    bool isMyDay = false,
    bool isImportant = false,
    String? listId,
    String? dueDate,
    String? reminderAt,
  }) async {
    final response = await _client
        .from('tasks')
        .insert(
          TaskModel.toInsertJson(
            userId: _userId,
            title: title,
            isMyDay: isMyDay,
            isImportant: isImportant,
            listId: listId,
            dueDate: dueDate,
            reminderAt: reminderAt,
          ),
        )
        .select('*, steps(*)')
        .single();

    return TaskModel.fromJson(response);
  }

  /// Cập nhật task
  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? note,
    bool? isCompleted,
    bool? isImportant,
    bool? isMyDay,
    String? listId,
    String? dueDate,
    String? reminderAt,
    bool clearDueDate = false,
    bool clearListId = false,
    bool clearNote = false,
    bool clearReminderAt = false,
  }) async {
    final response = await _client
        .from('tasks')
        .update(
          TaskModel.toUpdateJson(
            title: title,
            note: note,
            isCompleted: isCompleted,
            isImportant: isImportant,
            isMyDay: isMyDay,
            listId: listId,
            dueDate: dueDate,
            reminderAt: reminderAt,
            clearDueDate: clearDueDate,
            clearListId: clearListId,
            clearNote: clearNote,
            clearReminderAt: clearReminderAt,
          ),
        )
        .eq('id', taskId)
        .select('*, steps(*)')
        .single();

    return TaskModel.fromJson(response);
  }

  /// Xóa task
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  /// Tìm kiếm task theo tiêu đề
  Future<List<TaskModel>> searchTasks(String query) async {
    final response = await _client
        .from('tasks')
        .select('*, steps(*)')
        .eq('user_id', _userId)
        .ilike('title', '%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ═══════════════════════════════════════════
  // STEPS
  // ═══════════════════════════════════════════

  /// Thêm step vào task
  Future<void> addStep({
    required String taskId,
    required String title,
    int sortOrder = 0,
  }) async {
    await _client
        .from('steps')
        .insert(
          StepModel.toInsertJson(
            taskId: taskId,
            title: title,
            sortOrder: sortOrder,
          ),
        );
  }

  /// Toggle step hoàn thành
  Future<void> toggleStep({
    required String stepId,
    required bool isCompleted,
  }) async {
    await _client
        .from('steps')
        .update({'is_completed': isCompleted})
        .eq('id', stepId);
  }

  /// Xóa step
  Future<void> deleteStep(String stepId) async {
    await _client.from('steps').delete().eq('id', stepId);
  }
}
