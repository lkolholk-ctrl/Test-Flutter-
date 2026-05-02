import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryChip extends StatelessWidget {
  final String categoryId;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoryId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = TaskCategory.getById(categoryId);
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: isSelected ? category.color : theme.colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(category.name),
        ],
      ),
      selected: isSelected,
      selectedColor: category.color.withOpacity(0.15),
      backgroundColor: theme.chipTheme.backgroundColor,
      labelStyle: TextStyle(
        color: isSelected ? category.color : theme.colorScheme.onSurface.withOpacity(0.8),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: category.color,
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: isSelected
            ? BorderSide(color: category.color.withOpacity(0.4), width: 1.5)
            : BorderSide.none,
      ),
    );
  }
}
