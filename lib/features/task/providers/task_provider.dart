import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  TaskProvider({required TaskService taskService}) : _taskService = taskService;

  bool _isLoading = false;
  String? _errorMessage;
  List<TaskModel> _tasks = [];
  TaskModel? _task;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskModel> get tasks => _tasks;
  TaskModel? get task => _task;

  // Lưu lại filter hiện tại để reload sau khi thao tác
  bool? _currentIsMyDay;
  bool? _currentIsImportant;
  bool? _currentHasDueDate;
  String? _currentListId;
  bool _currentNoList = false;
  bool _isLoadAll = false;
  String? _currentSearchQuery;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadTasks({
    bool? isMyDay,
    bool? isImportant,
    bool? hasDueDate,
    String? listId,
    bool noList = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    _currentIsMyDay = isMyDay;
    _currentIsImportant = isImportant;
    _currentHasDueDate = hasDueDate;
    _currentListId = listId;
    _currentNoList = noList;
    _isLoadAll = false;
    _currentSearchQuery = null;

    try {
      _tasks = await _taskService.getTasksFiltered(
        isMyDay: isMyDay,
        isImportant: isImportant,
        hasDueDate: hasDueDate,
        listId: listId,
        noList: noList,
      );
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load tất cả tasks
  Future<void> loadAllTasks() async {
    _setLoading(true);
    _errorMessage = null;

    _isLoadAll = true;
    _currentIsMyDay = null;
    _currentIsImportant = null;
    _currentHasDueDate = null;
    _currentListId = null;
    _currentSearchQuery = null;

    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load task theo id
  Future<void> loadTaskDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _task = await _taskService.getTaskById(id);
    } catch (e) {
      _errorMessage = 'Không thể tải chi tiết tác vụ: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _reload() async {
    try {
      if (_currentSearchQuery != null) {
        _tasks = await _taskService.searchTasks(_currentSearchQuery!);
      } else if (_isLoadAll) {
        _tasks = await _taskService.getTasks();
      } else {
        _tasks = await _taskService.getTasksFiltered(
          isMyDay: _currentIsMyDay,
          isImportant: _currentIsImportant,
          hasDueDate: _currentHasDueDate,
          listId: _currentListId,
          noList: _currentNoList,
        );
      }

      // Cập nhật lại _task nếu đang xem chi tiết
      if (_task != null) {
        try {
          _task = await _taskService.getTaskById(_task!.id);
        } catch (_) {
          _task = null; // Task có thể đã bị xóa
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Lỗi reload: ${e.toString()}');
    }
  }

  Future<void> addTask({
    required String title,
    bool isMyDay = false,
    bool isImportant = false,
    String? listId,
    String? dueDate,
    String? reminderAt,
  }) async {
    try {
      await _taskService.createTask(
        title: title,
        isMyDay: isMyDay,
        isImportant: isImportant,
        listId: listId,
        dueDate: dueDate,
        reminderAt: reminderAt,
      );
      await _reload();
    } catch (e) {
      _setError('Không thể thêm task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      await _reload();
    } catch (e) {
      _setError('Không thể xóa task: ${e.toString()}');
    }
  }

  Future<void> toggleComplete({
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      await _taskService.updateTask(taskId: taskId, isCompleted: isCompleted);
      await _reload();
    } catch (e) {
      _setError('Lỗi: ${e.toString()}');
    }
  }

  Future<void> toggleImportant({
    required String taskId,
    required bool isImportant,
  }) async {
    try {
      await _taskService.updateTask(taskId: taskId, isImportant: isImportant);
      await _reload();
    } catch (e) {
      _setError('Lỗi: ${e.toString()}');
    }
  }

  Future<void> toggleMyDay({
    required String taskId,
    required bool isMyDay,
  }) async {
    try {
      await _taskService.updateTask(taskId: taskId, isMyDay: isMyDay);
      await _reload();
    } catch (e) {
      _setError('Lỗi: ${e.toString()}');
    }
  }

  Future<void> updateTask({
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
    try {
      await _taskService.updateTask(
        taskId: taskId,
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
      );
      await _reload();
    } catch (e) {
      _setError('Không thể cập nhật: ${e.toString()}');
    }
  }

  Future<void> addStep({required String taskId, required String title}) async {
    try {
      await _taskService.addStep(taskId: taskId, title: title);
      await _reload();
    } catch (e) {
      _setError('Không thể thêm bước: ${e.toString()}');
    }
  }

  Future<void> toggleStep({
    required String stepId,
    required bool isCompleted,
  }) async {
    try {
      await _taskService.toggleStep(stepId: stepId, isCompleted: isCompleted);
      await _reload();
    } catch (e) {
      _setError('Lỗi: ${e.toString()}');
    }
  }

  Future<void> deleteStep(String stepId) async {
    try {
      await _taskService.deleteStep(stepId);
      await _reload();
    } catch (e) {
      _setError('Lỗi: ${e.toString()}');
    }
  }

  Future<void> searchTasks(String query) async {
    _setLoading(true);
    _isLoadAll = false;
    _currentIsMyDay = null;
    _currentIsImportant = null;
    _currentHasDueDate = null;
    _currentListId = null;
    _currentSearchQuery = query;
    try {
      _tasks = await _taskService.searchTasks(query);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi tìm kiếm: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
}
