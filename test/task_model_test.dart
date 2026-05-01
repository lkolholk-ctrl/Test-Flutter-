import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';

void main() {
  group('Task Model', () {
    test('should create a task with default values', () {
      final task = Task(
        id: 'test_1',
        title: 'Test Task',
        createdAt: DateTime.now(),
        categoryId: 'work',
      );

      expect(task.id, 'test_1');
      expect(task.title, 'Test Task');
      expect(task.description, '');
      expect(task.isCompleted, false);
      expect(task.priority, 1);
      expect(task.categoryId, 'work');
      expect(task.dueDate, isNull);
      expect(task.completedAt, isNull);
    });

    test('should create a task with custom values', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));

      final task = Task(
        id: 'test_2',
        title: 'High Priority Task',
        description: 'This is important',
        createdAt: now,
        dueDate: dueDate,
        isCompleted: true,
        priority: 2,
        categoryId: 'personal',
        completedAt: now,
      );

      expect(task.title, 'High Priority Task');
      expect(task.description, 'This is important');
      expect(task.isCompleted, true);
      expect(task.priority, 2);
      expect(task.dueDate, dueDate);
      expect(task.completedAt, now);
    });

    test('copyWith should update specified fields only', () {
      final task = Task(
        id: 'test_3',
        title: 'Original',
        createdAt: DateTime.now(),
        categoryId: 'work',
      );

      final updated = task.copyWith(title: 'Updated', priority: 2);

      expect(updated.id, 'test_3');
      expect(updated.title, 'Updated');
      expect(updated.priority, 2);
      expect(updated.categoryId, 'work');
      expect(updated.isCompleted, false);
    });
  });
}
