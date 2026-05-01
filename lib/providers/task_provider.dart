import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../services/hive_service.dart';

enum TaskFilter { all, today, upcoming, completed }

class TaskProvider extends ChangeNotifier {
  final HiveService _hiveService;

  TaskProvider(this._hiveService);

  List<Task> _tasks = [];
  List<Task> get tasks => _filteredTasks;

  TaskFilter _filter = TaskFilter.all;
  TaskFilter get filter => _filter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    await _hiveService.init();
    await _hiveService.generateSampleData();
    await _loadTasks();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    List<Task> loaded;
    switch (_filter) {
      case TaskFilter.today:
        loaded = await _hiveService.getTodayTasks();
        break;
      case TaskFilter.upcoming:
        loaded = await _hiveService.getUpcomingTasks();
        break;
      case TaskFilter.completed:
        loaded = await _hiveService.getCompletedTasks();
        break;
      default:
        loaded = await _hiveService.getAllTasks();
    }

    if (_selectedCategoryId != null) {
      loaded = loaded.where((t) => t.categoryId == _selectedCategoryId).toList();
    }

    loaded.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    _tasks = loaded;
    notifyListeners();
  }

  List<Task> get _filteredTasks {
    if (_searchQuery.isEmpty) return _tasks;
    final query = _searchQuery.toLowerCase();
    return _tasks.where((t) {
      return t.title.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> addTask(Task task) async {
    await _hiveService.addTask(task);
    await _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _hiveService.updateTask(task);
    await _loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _hiveService.deleteTask(id);
    await _loadTasks();
  }

  Future<void> toggleCompletion(String id) async {
    await _hiveService.toggleTaskCompletion(id);
    await _loadTasks();
  }

  Future<void> clearCompleted() async {
    await _hiveService.deleteAllCompleted();
    await _loadTasks();
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    _loadTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    _loadTasks();
  }

  void clearCategoryFilter() {
    _selectedCategoryId = null;
    _loadTasks();
  }

  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final cat in TaskCategory.predefined) {
      final count = _tasks.where((t) => t.categoryId == cat.id).length;
      if (count > 0) stats[cat.id] = count;
    }
    return stats;
  }

  Map<String, int> getCompletionStats() {
    final all = _tasks;
    final completed = all.where((t) => t.isCompleted).length;
    final pending = all.length - completed;
    return {'completed': completed, 'pending': pending};
  }

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get highPriorityCount => _tasks.where((t) => t.priority == 2 && !t.isCompleted).length;
}
