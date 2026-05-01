import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_manager/models/task.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  group('Task Model', () {
    test('creates task with correct values', () {
      final task = Task(
        id: '1',
        title: 'Test',
        createdAt: DateTime(2024),
        categoryId: 'work',
      );
      expect(task.title, 'Test');
      expect(task.isCompleted, false);
    });
  });
}
