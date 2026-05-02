import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int priority; // 0 = low, 1 = medium, 2 = high

  @HiveField(7)
  String categoryId;

  @HiveField(8)
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
    required this.categoryId,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
    String? categoryId,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
