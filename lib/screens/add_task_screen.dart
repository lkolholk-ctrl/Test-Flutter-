import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.scrollController, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'work';
  int _selectedPriority = 1;
  DateTime? _dueDate;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedCategory = task.categoryId;
      _selectedPriority = task.priority;
      _dueDate = task.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(24, 20, 24, max(24, bottom + 24)),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isEditing ? 'Редактировать задачу' : 'Новая задача',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Название',
            hintText: 'Введите название задачи',
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Описание',
            hintText: 'Добавьте детали (необязательно)',
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        Text(
          'Категория',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TaskCategory.predefined.map((cat) {
            final isSelected = _selectedCategory == cat.id;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 16, color: isSelected ? cat.color : null),
                  const SizedBox(width: 6),
                  Text(cat.name),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat.id),
              selectedColor: cat.color.withOpacity(0.15),
              checkmarkColor: cat.color,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Приоритет',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPriorityButton(0, 'Низкий', const Color(0xFF10B981)),
            const SizedBox(width: 12),
            _buildPriorityButton(1, 'Средний', const Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            _buildPriorityButton(2, 'Высокий', const Color(0xFFEF4444)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Дедлайн',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickDateTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _dueDate != null
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? DateFormat('d MMMM yyyy, HH:mm', 'ru').format(_dueDate!)
                        : 'Не выбран',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _dueDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                if (_dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _dueDate = null),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveTask,
            icon: Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Сохранить изменения' : 'Создать задачу'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(int priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = priority),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ru', 'RU'),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Введите название задачи');
      return;
    }

    final provider = context.read<TaskProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _dueDate,
      );
      provider.updateTask(updated);
    } else {
      final task = Task(
        id: 'task_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}',
        title: title,
        description: _descriptionController.text.trim(),
        createdAt: now,
        dueDate: _dueDate,
        priority: _selectedPriority,
        categoryId: _selectedCategory,
      );
      provider.addTask(task);
    }

    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
