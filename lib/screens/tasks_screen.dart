import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мои задачи',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(provider),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(context, provider),
                  const SizedBox(height: 12),
                  _buildFilterChips(context, provider),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(context, provider),
                ],
              ),
            ),
          ),
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.tasks.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                title: 'Нет задач',
                subtitle: provider.searchQuery.isNotEmpty
                    ? 'По запросу "${provider.searchQuery}" ничего не найдено'
                    : 'Добавьте свою первую задачу с помощью кнопки ниже',
              ),
            )
          else
            SliverList.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return TaskCard(
                  task: task,
                  onToggle: () => provider.toggleCompletion(task.id),
                  onDelete: () => _confirmDelete(context, task),
                  onEdit: () => _openEditTask(context, task),
                );
              },
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  String _getSubtitle(TaskProvider provider) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'ru').format(now);
    if (provider.pendingCount > 0) {
      return '$dateStr · ${provider.pendingCount} ${provider.pendingCount == 1 ? 'активная задача' : provider.pendingCount < 5 ? 'активные задачи' : 'активных задач'}';
    }
    return dateStr;
  }

  Widget _buildSearchField(BuildContext context, TaskProvider provider) {
    return TextField(
      onChanged: provider.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Поиск задач...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: provider.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => provider.setSearchQuery(''),
              )
            : null,
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, TaskProvider provider) {
    final filters = [
      (TaskFilter.all, 'Все'),
      (TaskFilter.today, 'Сегодня'),
      (TaskFilter.upcoming, 'Предстоящие'),
      (TaskFilter.completed, 'Выполненные'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = filters[index];
          final isSelected = provider.filter == filter;
          final theme = Theme.of(context);

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => provider.setFilter(filter),
            selectedColor: theme.colorScheme.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: isSelected
                  ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.4))
                  : BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, TaskProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TaskCategory.predefined.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = provider.selectedCategoryId == null;
            final theme = Theme.of(context);
            return ChoiceChip(
              label: const Text('Все категории'),
              selected: isSelected,
              onSelected: (_) => provider.clearCategoryFilter(),
              selectedColor: theme.colorScheme.primary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }
          final category = TaskCategory.predefined[index - 1];
          return CategoryChip(
            categoryId: category.id,
            isSelected: provider.selectedCategoryId == category.id,
            onTap: () => provider.setCategoryFilter(category.id),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('Задача "${task.title}" будет удалена безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _openEditTask(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: AddTaskScreen(
            scrollController: scrollController,
            taskToEdit: task,
          ),
        ),
      ),
    );
  }
}
