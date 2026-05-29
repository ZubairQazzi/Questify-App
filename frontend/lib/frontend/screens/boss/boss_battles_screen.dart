import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/boss_battle.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/boss_health_bar.dart';
import '../../widgets/questify_feedback.dart';

class BossBattlesScreen extends StatelessWidget {
  const BossBattlesScreen({required this.onOpenBattle, super.key});

  final ValueChanged<String> onOpenBattle;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final defeatedBattles = controller.bossBattles
        .where((battle) => battle.status == BossBattleStatus.defeated)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 128),
      children: <Widget>[
        Text('BOSS BATTLES', style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          'Big deadlines become bosses with visible health bars and mission-based progress.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: QuestifyTheme.coral.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: QuestifyTheme.coral.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: QuestifyTheme.coral.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.sports_martial_arts_rounded,
                  color: QuestifyTheme.coral,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Deadline bosses', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Each completed mission damages the boss and moves the quest closer to victory.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _SummaryChip(
              label: 'Active',
              value: '${controller.activeBossBattles.length}',
              accent: QuestifyTheme.gold,
            ),
            _SummaryChip(
              label: 'Missed',
              value: '${controller.missedBossBattles.length}',
              accent: QuestifyTheme.coral,
            ),
            _SummaryChip(
              label: 'Defeated',
              value: '${defeatedBattles.length}',
              accent: QuestifyTheme.emerald,
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (controller.bossBattles.isEmpty)
          _EmptyBossPanel(theme: theme, scheme: scheme)
        else
          ...controller.bossBattles.map(
            (battle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => onOpenBattle(battle.id),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.88,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              battle.title,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          _StatusPill(status: battle.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      BossHealthBar(
                        healthPercent: battle.healthPercent,
                        completedMissions: battle.completedMissions,
                        totalMissions: battle.totalMissions,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              battle.status == BossBattleStatus.defeated
                                  ? 'All missions cleared. Boss defeated.'
                                  : battle.status == BossBattleStatus.overdue
                                  ? 'Deadline passed. This boss battle is marked missed.'
                                  : '${battle.completedMissions}/${battle.totalMissions} missions cleared',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM').format(battle.deadline),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class BossBattleDetailScreen extends StatelessWidget {
  const BossBattleDetailScreen({required this.bossBattleId, super.key});

  final String bossBattleId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final battle = controller.bossBattles
        .where((item) => item.id == bossBattleId)
        .firstOrNull;

    if (battle == null) {
      return const Scaffold(
        body: Center(child: Text('Boss battle not found.')),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(battle.title)),
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
                  Text('BOSS STATUS', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Text(
                    battle.status == BossBattleStatus.defeated
                        ? 'Boss defeated'
                        : battle.status == BossBattleStatus.overdue
                        ? 'Boss battle missed'
                        : 'The boss still has work left',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  BossHealthBar(
                    healthPercent: battle.healthPercent,
                    completedMissions: battle.completedMissions,
                    totalMissions: battle.totalMissions,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    battle.status == BossBattleStatus.defeated
                        ? 'All ${battle.totalMissions} missions are complete.'
                        : battle.status == BossBattleStatus.overdue
                        ? 'The deadline passed before every mission was cleared.'
                        : '${battle.completedMissions}/${battle.totalMissions} missions cleared so far.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deadline: ${DateFormat('EEE, d MMM - h:mm a').format(battle.deadline)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...battle.missions.map(
              (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: battle.status == BossBattleStatus.defeated
                          || battle.status == BossBattleStatus.overdue
                      ? null
                      : () async {
                          final message = await controller.toggleBossMission(
                            bossBattleId: battle.id,
                            missionId: mission.id,
                            completed: !mission.isCompleted,
                          );
                          if (!context.mounted || message == null) {
                            return;
                          }
                          showQuestifyFeedback(
                            context,
                            message,
                            tone: message.contains('missed')
                                ? QuestifyFeedbackTone.warning
                                : QuestifyFeedbackTone.success,
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: mission.isCompleted
                          ? QuestifyTheme.emerald.withValues(alpha: 0.12)
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.82,
                            ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: mission.isCompleted
                            ? QuestifyTheme.emerald.withValues(alpha: 0.4)
                            : scheme.outline,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: mission.isCompleted,
                          onChanged: battle.status == BossBattleStatus.defeated
                                  || battle.status == BossBattleStatus.overdue
                              ? null
                              : (_) async {
                                  final message = await controller
                                      .toggleBossMission(
                                        bossBattleId: battle.id,
                                        missionId: mission.id,
                                        completed: !mission.isCompleted,
                                      );
                                  if (!context.mounted || message == null) {
                                    return;
                                  }
                                  showQuestifyFeedback(
                                    context,
                                    message,
                                    tone: message.contains('missed')
                                        ? QuestifyFeedbackTone.warning
                                        : QuestifyFeedbackTone.success,
                                  );
                                },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mission.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: mission.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BossBattleStatus status;

  @override
  Widget build(BuildContext context) {
    final accent = switch (status) {
      BossBattleStatus.active => QuestifyTheme.gold,
      BossBattleStatus.defeated => QuestifyTheme.emerald,
      BossBattleStatus.overdue => QuestifyTheme.coral,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: accent),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBossPanel extends StatelessWidget {
  const _EmptyBossPanel({required this.theme, required this.scheme});

  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('No boss fights yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Turn on boss battle mode when creating a large project quest and the battle will appear here.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
