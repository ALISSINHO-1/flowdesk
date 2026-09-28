import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_storage.dart';

class TaskController extends ChangeNotifier {
  static int _idSequence = 0;

  TaskController(this._storage);

  final TaskStorage _storage;
  final List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isDarkMode = false;
  String _query = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  DueDateFilter _dueDateFilter = DueDateFilter.all;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String get query => _query;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  DueDateFilter get dueDateFilter => _dueDateFilter;

  List<Task> get filteredTasks {
    final normalizedQuery = _query.trim().toLowerCase();
    return _tasks.where((task) {
      final matchesQuery = normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          task.description.toLowerCase().contains(normalizedQuery);
      final matchesStatus = _statusFilter == null || task.status == _statusFilter;
      final matchesPriority =
          _priorityFilter == null || task.priority == _priorityFilter;
      final matchesDueDate = switch (_dueDateFilter) {
        DueDateFilter.all => true,
        DueDateFilter.overdue => task.isOverdue(),
        DueDateFilter.withDate => task.dueDate != null,
        DueDateFilter.withoutDate => task.dueDate == null,
      };
      return matchesQuery && matchesStatus && matchesPriority && matchesDueDate;
    }).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate != null) return 1;
        if (a.dueDate != null && b.dueDate == null) return -1;
        return (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt);
      });
  }

  int countFor(TaskStatus status) =>
      _tasks.where((task) => task.status == status).length;
  int get overdueCount => _tasks.where((task) => task.isOverdue()).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks
        ..clear()
        ..addAll(await _storage.loadTasks());
      _isDarkMode = await _storage.loadDarkMode();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    _tasks.add(Task(
      id: '${now.microsecondsSinceEpoch}-${_idSequence++}',
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    ));
    await _persistAndNotify();
  }

  Future<void> updateTask(
    Task task, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime? dueDate,
  }) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index < 0) return;
    _tasks[index] = task.copyWith(
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      dueDate: dueDate,
      clearDueDate: dueDate == null,
      updatedAt: DateTime.now(),
    );
    await _persistAndNotify();
  }

  Future<void> setStatus(Task task, TaskStatus status) async {
    await updateTask(
      task,
      title: task.title,
      description: task.description,
      status: status,
      priority: task.priority,
      dueDate: task.dueDate,
    );
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((item) => item.id == task.id);
    await _persistAndNotify();
  }

  void setSearch(String value) {
    _query = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? value) {
    _priorityFilter = value;
    notifyListeners();
  }

  void setDueDateFilter(DueDateFilter value) {
    _dueDateFilter = value;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storage.saveDarkMode(_isDarkMode);
  }

  Future<void> _persistAndNotify() async {
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }
}
