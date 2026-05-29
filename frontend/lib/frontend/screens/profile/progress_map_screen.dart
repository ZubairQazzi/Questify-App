import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';

class ProgressMapScreen extends StatelessWidget {
  const ProgressMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final currentLevel = controller.user?.level ?? 1;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Map')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 12,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final level = index + 1;
          final reached = level <= currentLevel;
          final current = level == currentLevel;
          final accent = current
              ? QuestifyTheme.violetGlow
              : reached
              ? QuestifyTheme.emerald
              : scheme.onSurfaceVariant;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
              border: Border.all(
                color: current ? QuestifyTheme.violetGlow : scheme.outline,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.16),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Level $level', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(_titleForLevel(level)),
                    ],
                  ),
                ),
                if (current)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: QuestifyTheme.violet.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'CURRENT',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: QuestifyTheme.violetGlow,
                      ),
                    ),
                  )
                else if (reached)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: QuestifyTheme.emerald,
                  )
                else
                  Icon(
                    Icons.lock_outline_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _titleForLevel(int level) {
    if (level >= 10) {
      return 'Legend Architect';
    }
    if (level >= 8) {
      return 'Productivity Paladin';
    }
    if (level >= 6) {
      return 'Deadline Defender';
    }
    if (level >= 4) {
      return 'Scholar Captain';
    }
    if (level >= 2) {
      return 'Quest Cadet';
    }
    return 'Fresh Adventurer';
  }
}
