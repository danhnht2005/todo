import 'package:flutter/material.dart';
import '../models/task_list_model.dart';
import '../services/task_list_service.dart';

class TaskListProvider extends ChangeNotifier {
  final TaskListService _repository;

  TaskListProvider({required TaskListService repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<TaskListModel> _lists = [];
  TaskListModel? _selectedTaskList;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskListModel> get lists => _lists;
  TaskListModel? get selectedTaskList => _selectedTaskList;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Load task list detail by id
  Future<void> loadTaskListDetail(String listId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _selectedTaskList = await _repository.getListById(listId);
    } catch (e) {
      _errorMessage = 'Không thể tải chi tiết danh sách: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load all list
  Future<void> loadTaskLists() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _lists = await _repository.getLists();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create list
  Future<void> createTaskList({required String title}) async {
    try {
      await _repository.createList(title: title);
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể tạo danh sách: ${e.toString()}');
    }
  }

  // Update list
  Future<void> updateTaskList({required String listId, String? title}) async {
    try {
      await _repository.updateList(listId: listId, title: title);
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể cập nhật: ${e.toString()}');
    }
  }

  // Delete list
  Future<void> deleteTaskList(String listId) async {
    try {
      await _repository.deleteList(listId);
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể xóa: ${e.toString()}');
    }
  }
}
