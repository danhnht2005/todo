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

    final tasks = (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
      .toList();
    return _attachCreators(tasks);
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

    // Shared custom lists can contain tasks created by different members.
    // For smart lists, keep the filter scoped to the signed-in user.
    if (listId == null) {
      query = query.eq('user_id', _userId);
    }

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

    final tasks = (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
      .toList();
    return _attachCreators(tasks);
  }

  /// Lấy chi tiết 1 task theo id
  Future<TaskModel> getTaskById(String id) async {
    final response = await _client
        .from('tasks')
        .select('*, steps(*)')
        .eq('id', id)
        .single();

    final task = TaskModel.fromJson(response);
    final tasks = await _attachCreators([task]);
    return tasks.isNotEmpty ? tasks.first : task;
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

    final tasks = (response as List)
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
      .toList();
    return _attachCreators(tasks);
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

  Future<List<TaskModel>> _attachCreators(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return tasks;

    final creatorIds = tasks.map((task) => task.userId).toSet().toList();
    if (creatorIds.isEmpty) return tasks;

    try {
      final response = await _client
          .from('profiles')
          .select('id, full_name, email')
          .inFilter('id', creatorIds);

      final profileById = <String, Map<String, dynamic>>{};
      for (final item in response as List) {
        final profile = item as Map<String, dynamic>;
        profileById[profile['id'] as String] = profile;
      }

      return tasks
          .map((task) {
            final profile = profileById[task.userId];
            if (profile == null) return task;
            return task.copyWith(
              createdByName: profile['full_name'] as String?,
              createdByEmail: profile['email'] as String?,
            );
          })
          .toList(growable: false);
    } on PostgrestException {
      return tasks;
    }
  }
}
