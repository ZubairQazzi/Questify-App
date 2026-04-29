import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../backend/models/quest.dart';
import '../theme/questify_theme.dart';
import 'deadline_meter.dart';

class QuestCard extends StatelessWidget {
  const QuestCard({required this.quest, required this.onTap, super.key});

  final Quest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = switch (quest.difficulty) {
      QuestDifficulty.easy => QuestifyTheme.emerald,
      QuestDifficulty.medium => QuestifyTheme.gold,
      QuestDifficulty.hard => QuestifyTheme.coral,
    };
    final completedSteps = quest.steps.where((step) => step.isCompleted).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(26),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _TopTag(
                            label: quest.subject.toUpperCase(),
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          _TopTag(
                            label: quest.questType.label.toUpperCase(),
                            color: QuestifyTheme.violetGlow,
                          ),
                          if (quest.status == QuestStatus.overdue) ...<Widget>[
                            const SizedBox(width: 8),
                            const _TopTag(
                              label: 'MISSED',
                              color: QuestifyTheme.coral,
                            ),
                          ],
                          if (quest.bossBattleMode) ...<Widget>[
                            const SizedBox(width: 8),
                            const _TopTag(
                              label: 'BOSS',
                              color: QuestifyTheme.gold,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '+${quest.xpReward} XP',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent, width: 2),
                              color: quest.isCompleted
                                  ? accent.withValues(alpha: 0.16)
                                  : Colors.transparent,
                            ),
                            child: quest.isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: accent,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  quest.title,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quest.hasSteps
                                      ? '$completedSteps/${quest.steps.length} missions complete'
                                      : '${quest.estimatedMinutes} minute focus session',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DeadlineMeter(deadline: quest.deadline),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat(
                                'EEE, d MMM - h:mm a',
                              ).format(quest.deadline),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            '+${quest.coinReward} coins',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: QuestifyTheme.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTag extends StatelessWidget {
  const _TopTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
