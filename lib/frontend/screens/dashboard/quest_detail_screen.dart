import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/quest.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/boss_health_bar.dart';
import '../../widgets/deadline_meter.dart';
import 'add_quest_screen.dart';

class QuestDetailScreen extends StatelessWidget {
  const QuestDetailScreen({required this.questId, super.key});

  final String questId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final quest = controller.quests
        .where((item) => item.id == questId)
        .firstOrNull;
    if (quest == null) {
      return const Scaffold(body: Center(child: Text('Quest not found.')));
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFocusActive = controller.activeFocusQuestId == quest.id;
    final linkedBattle = controller.bossBattles
        .where((battle) => battle.linkedQuestId == quest.id)
        .firstOrNull;
    final completedSteps = quest.steps.where((step) => step.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(quest.title),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => AddQuestScreen(existingQuest: quest),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () async {
              final deleted = await _confirmDelete(context, controller, quest);
              if (deleted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: scheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _DetailChip(
                        label: quest.subject.toUpperCase(),
                        accent: QuestifyTheme.violetGlow,
                      ),
                      _DetailChip(
                        label: quest.difficulty.label.toUpperCase(),
                        accent: _difficultyColor(quest.difficulty),
                      ),
                      _DetailChip(
                        label: quest.questType.label.toUpperCase(),
                        accent: QuestifyTheme.cyan,
                      ),
                      if (quest.bossBattleMode)
                        const _DetailChip(
                          label: 'BOSS MODE',
                          accent: QuestifyTheme.gold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(quest.title, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 10),
                  Text(
                    quest.note?.isNotEmpty == true
                        ? quest.note!
                        : 'A focused mission with visible rewards and a clear finish line.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _InfoStat(
                          label: 'Deadline',
                          value: DateFormat(
                            'EEE, d MMM',
                          ).format(quest.deadline),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoStat(
                          label: 'Focus',
                          value: '${quest.estimatedMinutes} min',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QuestifyTheme.coral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: QuestifyTheme.coral.withValues(alpha: 0.45),
                ),
              ),
              child: DeadlineMeter(deadline: quest.deadline),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _RewardCard(
                    label: 'XP reward',
                    value: '+${quest.xpReward}',
                    accent: QuestifyTheme.violetGlow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RewardCard(
                    label: 'Coins',
                    value: '+${quest.coinReward}',
                    accent: QuestifyTheme.gold,
                  ),
                ),
              ],
            ),
            if (linkedBattle != null) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'BOSS BATTLE LINKED',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(linkedBattle.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    BossHealthBar(healthPercent: linkedBattle.healthPercent),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: scheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('FOCUS TIMER', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Text(
                    isFocusActive
                        ? controller.formatFocusTime(
                            controller.focusRemainingSeconds,
                          )
                        : controller.formatFocusTime(
                            controller.settings.focusDurationMinutes * 60,
                          ),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: QuestifyTheme.violetGlow,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: quest.isCompleted
                              ? null
                              : () => controller.startFocusTimer(quest.id),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('START'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFocusActive
                              ? controller.pauseFocusTimer
                              : null,
                          icon: const Icon(Icons.pause_rounded),
                          label: const Text('PAUSE'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFocusActive
                              ? controller.resetFocusTimer
                              : null,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('RESET'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (quest.steps.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'MISSION STEPS',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '$completedSteps/${quest.steps.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: QuestifyTheme.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quest.isCompleted
                          ? 'All mission steps are complete.'
                          : 'Tap a mission row to mark it done.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...quest.steps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MissionTile(
                          title: step.title,
                          completed: step.isCompleted,
                          disabled: quest.isCompleted,
                          onTap: quest.isCompleted
                              ? null
                              : () async {
                                  final message = await controller
                                      .toggleQuestStep(
                                        questId: quest.id,
                                        stepId: step.id,
                                        completed: !step.isCompleted,
                                      );
                                  if (!context.mounted || message == null) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: quest.isCompleted
                  ? null
                  : () => _completeQuest(context, controller, quest),
              icon: const Icon(Icons.emoji_events_rounded),
              label: Text(
                quest.isCompleted
                    ? 'QUEST ALREADY COMPLETE'
                    : 'COMPLETE QUEST & CLAIM REWARDS',
              ),
            ),
            if (quest.reflection != null) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: scheme.outline),
                ),
                child: Text('Reflection: ${quest.reflection}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _completeQuest(
    BuildContext context,
    QuestifyController controller,
    Quest quest,
  ) async {
    final reflection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'How did the quest feel?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <String>['Easy', 'Okay', 'Difficult'].map((option) {
                    return ActionChip(
                      label: Text(option),
                      onPressed: () => Navigator.of(context).pop(option),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (reflection == null || !context.mounted) {
      return;
    }

    final message = await controller.completeQuest(
      questId: quest.id,
      reflection: reflection,
    );
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    QuestifyController controller,
    Quest quest,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete quest?'),
            content: Text('Remove "${quest.title}" from your quest board?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return false;
    }
    final message = await controller.deleteQuest(quest.id);
    if (context.mounted && message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return message == null;
  }

  Color _difficultyColor(QuestDifficulty difficulty) {
    return switch (difficulty) {
      QuestDifficulty.easy => QuestifyTheme.emerald,
      QuestDifficulty.medium => QuestifyTheme.gold,
      QuestDifficulty.hard => QuestifyTheme.coral,
    };
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: accent),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.title,
    required this.completed,
    required this.disabled,
    this.onTap,
  });

  final String title;
  final bool completed;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: completed
              ? QuestifyTheme.emerald.withValues(alpha: 0.12)
              : scheme.surface.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: completed
                ? QuestifyTheme.emerald.withValues(alpha: 0.35)
                : scheme.outline,
          ),
        ),
        child: Row(
          children: <Widget>[
            Checkbox(
              value: completed,
              onChanged: disabled ? null : (_) => onTap?.call(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: completed
                  ? QuestifyTheme.emerald
                  : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
