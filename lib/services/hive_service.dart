import 'dart:math';
import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveService {
  static const String _boxName = 'tasks';
  late Box<Task> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  Future<List<Task>> getAllTasks() async {
    return _box.values.toList();
  }

  Future<List<Task>> getTasksByCategory(String categoryId) async {
    return _box.values.where((t) => t.categoryId == categoryId).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    return _box.values.where((t) => t.isCompleted).toList();
  }

  Future<List<Task>> getPendingTasks() async {
    return _box.values.where((t) => !t.isCompleted).toList();
  }

  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _box.values.where((t) {
      if (t.dueDate == null) return false;
      final date = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return date.isAtSameMomentAs(today);
    }).toList();
  }

  Future<List<Task>> getUpcomingTasks() async {
    final now = DateTime.now();
    return _box.values.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now) && !t.isCompleted;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
      await task.save();
    }
  }

  Future<void> deleteAllCompleted() async {
    final completed = _box.values.where((t) => t.isCompleted).toList();
    for (final task in completed) {
      await task.delete();
    }
  }

  Future<void> generateSampleData() async {
    if (_box.isNotEmpty) return;

    final categories = ['work', 'personal', 'study', 'health', 'shopping'];
    final titles = [
      'Подготовить презентацию',
      'Купить продукты',
      'Сделать зарядку',
      'Выучить 20 слов',
      'Позвонить клиенту',
      'Оплатить коммунальные услуги',
      'Забрать посылку',
      'Прочитать главу книги',
      'Записаться к врачу',
      'Обновить резюме',
    ];

    final random = Random();
    final now = DateTime.now();

    for (int i = 0; i < 15; i++) {
      final dueDate = DateTime(
        now.year,
        now.month,
        now.day + random.nextInt(14) - 3,
        random.nextInt(24),
      );
      final task = Task(
        id: 'task_$i',
        title: titles[random.nextInt(titles.length)],
        description: 'Описание задачи номер ${i + 1}. Добавьте здесь свои заметки.',
        createdAt: now.subtract(Duration(days: random.nextInt(7))),
        dueDate: dueDate,
        isCompleted: random.nextBool() && random.nextBool(),
        priority: random.nextInt(3),
        categoryId: categories[random.nextInt(categories.length)],
      );
      if (task.isCompleted) {
        task.completedAt = now.subtract(Duration(days: random.nextInt(5)));
      }
      await _box.put(task.id, task);
    }
  }
}
