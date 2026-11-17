import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/models/quiz_result.dart';

class ScoreHistoryTile extends StatelessWidget {
  const ScoreHistoryTile({super.key, required this.result, this.onDelete});

  final QuizResult result;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM d, h:mm a',
    ).format(result.completedAt);
    final theme = QuizCategory.byId(result.themeId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF122033),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFC75F),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${theme.title} • ${result.badge}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate • ${result.correctAnswers}/${result.totalQuestions} correct',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            '${result.score}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
