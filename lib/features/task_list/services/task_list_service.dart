import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_list_member_model.dart';
import '../models/task_list_model.dart';

/// TaskListService - CRUD and sharing for custom lists via Supabase.
class TaskListService {
  final SupabaseClient _client;

  TaskListService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  /// Get custom lists owned by the current user and lists shared with them.
  Future<List<TaskListModel>> getLists() async {
    final ownedResponse = await _client
        .from('task_lists')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: true);

    final listsById = <String, TaskListModel>{};

    for (final json in ownedResponse as List) {
      final list = TaskListModel.fromJson(
        json as Map<String, dynamic>,
        currentUserId: _userId,
      );
      listsById[list.id] = list;
    }

    for (final list in await _getSharedLists()) {
      listsById[list.id] = list;
    }

    final lists = listsById.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return lists;
  }

  Future<List<TaskListModel>> _getSharedLists() async {
    try {
      final response = await _client.rpc('get_shared_task_lists');
      return (response as List)
          .map(
            (json) => TaskListModel.fromJson(
              json as Map<String, dynamic>,
              isOwner: false,
              currentUserId: _userId,
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();
      final isMissingRpc =
          e.code == 'PGRST202' ||
          message.contains('could not find the function');
      if (!isMissingRpc) rethrow;
    }

    final memberResponse = await _client
        .from('task_list_members')
        .select('list_id')
        .eq('user_id', _userId);

    final listIds = (memberResponse as List)
        .map((json) => (json as Map<String, dynamic>)['list_id'] as String)
        .toSet()
        .toList();

    if (listIds.isEmpty) return [];

    final sharedResponse = await _client
        .from('task_lists')
        .select()
        .inFilter('id', listIds)
        .neq('user_id', _userId)
        .order('created_at', ascending: true);

    return (sharedResponse as List)
        .map(
          (json) => TaskListModel.fromJson(
            json as Map<String, dynamic>,
            isOwner: false,
            currentUserId: _userId,
          ),
        )
        .toList();
  }

  /// Get detail of a list the current user can access.
  Future<TaskListModel> getListById(String id) async {
    final response = await _client
        .from('task_lists')
        .select()
        .eq('id', id)
        .single();

    return TaskListModel.fromJson(response, currentUserId: _userId);
  }

  /// Create a new list.
  Future<TaskListModel> createList({required String title}) async {
    final response = await _client
        .from('task_lists')
        .insert(TaskListModel.toInsertJson(userId: _userId, title: title))
        .select()
        .single();

    return TaskListModel.fromJson(response, currentUserId: _userId);
  }

  /// Update list.
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

    return TaskListModel.fromJson(response, currentUserId: _userId);
  }

  /// Delete list.
  Future<void> deleteList(String listId) async {
    await _client.from('task_lists').delete().eq('id', listId);
  }

  Future<List<TaskListMemberModel>> getMembers(String listId) async {
    await _ensureOwner(listId);

    final response = await _client
        .from('task_list_members')
        .select(
          'id, list_id, user_id, created_at, '
          'profiles(id, full_name, email, avatar_url)',
        )
        .eq('list_id', listId)
        .order('created_at', ascending: true);

    return (response as List)
        .map(
          (json) => TaskListMemberModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> inviteUserByEmail({
    required String listId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      await _client.rpc(
        'invite_task_list_member',
        params: {
          'p_list_id': listId,
          'p_email': normalizedEmail,
        },
      );
      return;
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('user_email_not_found')) {
        throw Exception('Khong tim thay tai khoan voi email nay');
      }
      if (message.contains('owner_cannot_invite_self')) {
        throw Exception('Ban da la chu so huu danh sach nay');
      }
      if (message.contains('only_list_owner_can_invite')) {
        throw Exception('Chi chu so huu moi co the chia se danh sach');
      }

      final isMissingRpc =
          e.code == 'PGRST202' ||
          message.contains('could not find the function');
      if (!isMissingRpc) rethrow;
    }

    await _ensureOwner(listId);

    final profile = await _client
        .from('profiles')
        .select('id, email')
        .ilike('email', normalizedEmail)
        .maybeSingle();

    if (profile == null) {
      throw Exception('Khong tim thay tai khoan voi email nay');
    }

    final invitedUserId = profile['id'] as String;
    if (invitedUserId == _userId) {
      throw Exception('Ban da la chu so huu danh sach nay');
    }

    final existing = await _client
        .from('task_list_members')
        .select('id')
        .eq('list_id', listId)
        .eq('user_id', invitedUserId)
        .maybeSingle();

    if (existing != null) return;

    await _client.from('task_list_members').insert({
      'list_id': listId,
      'user_id': invitedUserId,
    });
  }

  Future<void> removeMember({
    required String listId,
    required String memberId,
  }) async {
    await _ensureOwner(listId);

    await _client
        .from('task_list_members')
        .delete()
        .eq('id', memberId)
        .eq('list_id', listId);
  }

  Future<void> _ensureOwner(String listId) async {
    final list = await _client
        .from('task_lists')
        .select('user_id')
        .eq('id', listId)
        .single();

    if (list['user_id'] != _userId) {
      throw Exception('Chi chu so huu moi co the chia se danh sach');
    }
  }
}
