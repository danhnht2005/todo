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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskListModel> get lists => _lists;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

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

  Future<void> createTaskList({
    required String title,
    String iconName = 'list',
    String colorHex = '#2564CF',
  }) async {
    try {
      await _repository.createList(
        title: title,
        iconName: iconName,
        colorHex: colorHex,
      );
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể tạo danh sách: ${e.toString()}');
    }
  }

  Future<void> updateTaskList({
    required String listId,
    String? title,
    String? iconName,
    String? colorHex,
  }) async {
    try {
      await _repository.updateList(
        listId: listId,
        title: title,
        iconName: iconName,
        colorHex: colorHex,
      );
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể cập nhật: ${e.toString()}');
    }
  }

  Future<void> deleteTaskList(String listId) async {
    try {
      await _repository.deleteList(listId);
      await loadTaskLists();
    } catch (e) {
      _setError('Không thể xóa: ${e.toString()}');
    }
  }
}
