import 'package:flutter/material.dart';
import '../models/task_list_member_model.dart';
import '../models/task_list_model.dart';
import '../services/task_list_service.dart';

class TaskListProvider extends ChangeNotifier {
  final TaskListService _repository;

  TaskListProvider({required TaskListService repository})
      : _repository = repository;

  bool _isLoading = false;
  bool _isSharing = false;
  String? _errorMessage;
  List<TaskListModel> _lists = [];
  List<TaskListMemberModel> _members = [];
  TaskListModel? _selectedTaskList;

  bool get isLoading => _isLoading;
  bool get isSharing => _isSharing;
  String? get errorMessage => _errorMessage;
  List<TaskListModel> get lists => _lists;
  List<TaskListMemberModel> get members => _members;
  TaskListModel? get selectedTaskList => _selectedTaskList;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSharing(bool value) {
    _isSharing = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadTaskListDetail(String listId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _selectedTaskList = await _repository.getListById(listId);
    } catch (e) {
      _errorMessage = 'Khong the tai chi tiet danh sach: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTaskLists() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _lists = await _repository.getLists();
    } catch (e) {
      _errorMessage = 'Khong the tai danh sach: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTaskList({required String title}) async {
    try {
      await _repository.createList(title: title);
      await loadTaskLists();
    } catch (e) {
      _setError('Khong the tao danh sach: ${e.toString()}');
    }
  }

  Future<void> updateTaskList({required String listId, String? title}) async {
    try {
      await _repository.updateList(listId: listId, title: title);
      await loadTaskLists();
    } catch (e) {
      _setError('Khong the cap nhat: ${e.toString()}');
    }
  }

  Future<void> deleteTaskList(String listId) async {
    try {
      await _repository.deleteList(listId);
      await loadTaskLists();
    } catch (e) {
      _setError('Khong the xoa: ${e.toString()}');
    }
  }

  Future<void> loadMembers(String listId) async {
    _setSharing(true);
    _errorMessage = null;
    try {
      _members = await _repository.getMembers(listId);
    } catch (e) {
      _setError('Khong the tai thanh vien: ${e.toString()}');
    } finally {
      _setSharing(false);
    }
  }

  Future<bool> inviteUser({
    required String listId,
    required String email,
  }) async {
    _setSharing(true);
    _errorMessage = null;
    try {
      await _repository.inviteUserByEmail(listId: listId, email: email);
      try {
        _members = await _repository.getMembers(listId);
      } catch (_) {
        _members = [];
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Khong the moi nguoi dung: ${e.toString()}');
      return false;
    } finally {
      _setSharing(false);
    }
  }

  Future<void> removeMember({
    required String listId,
    required String memberId,
  }) async {
    _setSharing(true);
    _errorMessage = null;
    try {
      await _repository.removeMember(listId: listId, memberId: memberId);
      _members = await _repository.getMembers(listId);
      notifyListeners();
    } catch (e) {
      _setError('Khong the xoa thanh vien: ${e.toString()}');
    } finally {
      _setSharing(false);
    }
  }
}
