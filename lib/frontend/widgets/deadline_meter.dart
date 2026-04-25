import 'package:flutter/material.dart';

import '../../backend/services/gamification_service.dart';
import '../theme/questify_theme.dart';

class DeadlineMeter extends StatelessWidget {
  const DeadlineMeter({required this.deadline, super.key});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final status = GamificationService.deadlineStatus(deadline);
    final now = DateTime.now();
    final totalHours = deadline.difference(now).inHours;
    final ratio = switch (status) {
      'Safe' => 0.28,
      'Approaching' => 0.64,
      'Critical' => 0.9,
      _ => 1.0,
    };
    final accent = switch (status) {
      'Safe' => QuestifyTheme.emerald,
      'Approaching' => QuestifyTheme.gold,
      'Critical' => const Color(0xFFFF9B54),
      _ => QuestifyTheme.coral,
    };
    final message = totalHours < 0
        ? 'Deadline passed'
        : totalHours < 24
        ? '$totalHours h left'
        : '${(totalHours / 24).ceil()} days left';

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('DEADLINE DANGER', style: theme.textTheme.labelMedium),
            const Spacer(),
            Text(
              status.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: ratio,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
