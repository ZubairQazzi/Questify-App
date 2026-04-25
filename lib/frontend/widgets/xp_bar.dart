import 'package:flutter/material.dart';

import '../theme/questify_theme.dart';

class XpBar extends StatelessWidget {
  const XpBar({
    required this.level,
    required this.progress,
    required this.xp,
    super.key,
  });

  final int level;
  final double progress;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'XP STATUS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: QuestifyTheme.lilac,
                ),
              ),
              const Spacer(),
              Text(
                '$xp XP',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('LEVEL $level', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: QuestifyTheme.obsidian.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 14,
                value: progress.clamp(0, 1),
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  QuestifyTheme.violetGlow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
