import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final int priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<int, ({String label, Color color})> priorityMap = {
      0: (label: 'Низкий', color: const Color(0xFF10B981)),
      1: (label: 'Средний', color: const Color(0xFFF59E0B)),
      2: (label: 'Высокий', color: const Color(0xFFEF4444)),
    };

    final data = priorityMap[priority] ?? priorityMap[1]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: data.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
