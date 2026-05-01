import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/main.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/providers/theme_provider.dart';
import 'package:task_manager/services/hive_service.dart';

class FakeHiveService implements HiveService {
  @override
  late Box<Task> _box;

  @override
  Future<void> init() async {}

  @override
  Future<List<Task>> getAllTasks() async => [];

  @override
  Future<List<Task>> getTasksByCategory(String categoryId) async => [];

  @override
  Future<List<Task>> getCompletedTasks() async => [];

  @override
  Future<List<Task>> getPendingTasks() async => [];

  @override
  Future<List<Task>> getTodayTasks() async => [];

  @override
  Future<List<Task>> getUpcomingTasks() async => [];

  @override
  Future<void> addTask(Task task) async {}

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<void> toggleTaskCompletion(String id) async {}

  @override
  Future<void> deleteAllCompleted() async {}

  @override
  Future<void> generateSampleData() async {}
}

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider(FakeHiveService())),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
