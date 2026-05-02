import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  static const List<TaskCategory> predefined = [
    TaskCategory(
      id: 'work',
      name: 'Работа',
      color: Color(0xFF6366F1),
      icon: Icons.work_outline,
    ),
    TaskCategory(
      id: 'personal',
      name: 'Личное',
      color: Color(0xFF10B981),
      icon: Icons.person_outline,
    ),
    TaskCategory(
      id: 'study',
      name: 'Учеба',
      color: Color(0xFFF59E0B),
      icon: Icons.school_outlined,
    ),
    TaskCategory(
      id: 'health',
      name: 'Здоровье',
      color: Color(0xFFEF4444),
      icon: Icons.favorite_outline,
    ),
    TaskCategory(
      id: 'shopping',
      name: 'Покупки',
      color: Color(0xFF8B5CF6),
      icon: Icons.shopping_bag_outlined,
    ),
    TaskCategory(
      id: 'other',
      name: 'Другое',
      color: Color(0xFF6B7280),
      icon: Icons.folder_outlined,
    ),
  ];

  static TaskCategory getById(String id) {
    return predefined.firstWhere(
      (c) => c.id == id,
      orElse: () => predefined.last,
    );
  }
}
