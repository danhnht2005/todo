import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_list_model.dart';

/// TaskListService — CRUD custom lists qua Supabase
class TaskListService {
  final SupabaseClient _client;

  TaskListService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// Lấy tất cả custom lists
  Future<List<TaskListModel>> getLists() async {
    final listsResponse = await _client
        .from('task_lists')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: true);

    return (listsResponse as List).map((json) {
      return TaskListModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  /// Lấy chi tiết 1 list theo id
  Future<TaskListModel> getListById(String id) async {
    final response = await _client
        .from('task_lists')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();

    return TaskListModel.fromJson(response);
  }

  /// Tạo list mới
  Future<TaskListModel> createList({required String title}) async {
    final response = await _client
        .from('task_lists')
        .insert(TaskListModel.toInsertJson(userId: _userId, title: title))
        .select()
        .single();

    return TaskListModel.fromJson(response);
  }

  /// Cập nhật list
  Future<TaskListModel> updateList({
    required String listId,
    String? title,
  }) async {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;

    final response = await _client
        .from('task_lists')
        .update(map)
        .eq('id', listId)
        .select()
        .single();

    return TaskListModel.fromJson(response);
  }

  /// Xóa list
  Future<void> deleteList(String listId) async {
    await _client.from('task_lists').delete().eq('id', listId);
  }
}
