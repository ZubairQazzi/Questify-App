import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/boss_battle.dart';
import '../../../backend/models/reward_badge.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/questify_top_dialog.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({required this.onOpenProgressMap, super.key});

  final VoidCallback onOpenProgressMap;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = controller.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 128),
      children: <Widget>[
        Text('REWARDS', style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          'Spend coins, unlock badges, and keep the motivation loop visible.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
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
              Text('REWARD VAULT', style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              Text('Your reward economy', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _CounterCard(
                      icon: Icons.paid_rounded,
                      label: 'Coins',
                      value: '${user.coins}',
                      accent: QuestifyTheme.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CounterCard(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Unlocked',
                      value: '${controller.unlockedRewards.length}',
                      accent: QuestifyTheme.emerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpenProgressMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('OPEN PROGRESS MAP'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: QuestifyTheme.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: QuestifyTheme.gold.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LEGEND CHEST',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: QuestifyTheme.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The more quests you finish, the more badges and coins you stack.',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Badges unlock automatically when your streaks, focus sessions, and mission clears hit their milestones.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('BADGES', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (controller.rewards.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline),
            ),
            child: const Text('Complete quests to unlock your first badge.'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1200
                  ? 5
                  : width >= 900
                  ? 4
                  : width >= 640
                  ? 3
                  : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.rewards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.08,
                ),
                itemBuilder: (context, index) {
                  final badge = controller.rewards[index];
                  final insight = _insightForBadge(controller, badge);
                  return _BadgeCard(
                    badge: badge,
                    insight: insight,
                    onTap: () => _showBadgeDetails(
                      context,
                      badge: badge,
                      insight: insight,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  _BadgeInsight _insightForBadge(
    QuestifyController controller,
    RewardBadge badge,
  ) {
    final user = controller.user!;
    final latestQuest = controller.completedQuests.isEmpty
        ? null
        : controller.completedQuests.first;
    final defeatedBosses = controller.bossBattles
        .where((battle) => battle.status == BossBattleStatus.defeated)
        .map((battle) => battle.title)
        .toList();

    return switch (badge.id) {
      'first_quest' => _BadgeInsight(
        explanation:
            'This badge celebrates the first quest you successfully finished on time.',
        recordLabel: 'Completed quests',
        recordValue: '${controller.completedQuestCount}',
        howToUnlock: 'Finish at least one quest before its deadline.',
        detail: latestQuest == null
            ? 'No completed quest has been recorded yet.'
            : 'Latest win: ${latestQuest.title}',
      ),
      'streak_3' => _BadgeInsight(
        explanation:
            'This badge tracks consistency and rewards you for showing up on consecutive days.',
        recordLabel: 'Current streak',
        recordValue: '${user.streak} day(s)',
        howToUnlock: 'Keep a 3-day completion streak alive.',
        detail:
            'Your streak only grows when you complete quests on consecutive days.',
      ),
      'boss_slayer' => _BadgeInsight(
        explanation:
            'This badge is tied to large deadline quests that use boss battle mode.',
        recordLabel: 'Bosses defeated',
        recordValue: '${controller.defeatedBossesCount}',
        howToUnlock:
            'Defeat at least one boss battle by clearing every mission in time.',
        detail: defeatedBosses.isEmpty
            ? 'No boss battle has been defeated yet.'
            : 'Defeated bosses: ${defeatedBosses.join(', ')}',
      ),
      'focus_knight' => _BadgeInsight(
        explanation:
            'Focus sessions represent uninterrupted study sprints that build deep work habits.',
        recordLabel: 'Focus sessions',
        recordValue: '${controller.totalFocusSessionsCount}',
        howToUnlock: 'Finish 3 focus sessions.',
        detail:
            'Each completed timer adds to this total and helps unlock the badge.',
      ),
      'coin_collector' => _BadgeInsight(
        explanation:
            'Coins are your reward currency for finishing quests and defeating boss battles.',
        recordLabel: 'Current coins',
        recordValue: '${user.coins}',
        howToUnlock: 'Reach 100 coins in your account.',
        detail:
            'Complete more quests and boss battles to increase your coin balance.',
      ),
      'scholar_rank' => _BadgeInsight(
        explanation:
            'This badge marks strong long-term progress across quests, XP, and level growth.',
        recordLabel: 'Current level',
        recordValue: 'Level ${user.level}',
        howToUnlock: 'Reach level 5 by earning XP from completed quests.',
        detail:
            'Your current XP is ${user.xp}, and every completed quest pushes the rank higher.',
      ),
      _ => const _BadgeInsight(
        explanation: 'This badge tracks a special Questify milestone.',
        recordLabel: 'Progress',
        recordValue: 'Unavailable',
        howToUnlock: 'Keep using the app to unlock more rewards.',
        detail: 'More details will appear here once the reward is active.',
      ),
    };
  }

  Future<void> _showBadgeDetails(
    BuildContext context, {
    required RewardBadge badge,
    required _BadgeInsight insight,
  }) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = Color(int.parse(badge.accentHex));
    await showQuestifyTopDialog<void>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _BadgeCard.iconForKey(badge.iconKey),
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          badge.title,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.unlocked ? 'Unlocked badge' : 'Locked badge',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: badge.unlocked
                                ? QuestifyTheme.emerald
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('What it means', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(insight.explanation, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text('Current record', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      insight.recordLabel.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.recordValue,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(insight.detail, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.unlocked ? 'How you earned it' : 'How to unlock it',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(insight.howToUnlock, style: theme.textTheme.bodyMedium),
              if (badge.unlockedAt != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  'Unlocked on ${DateFormat('d MMM yyyy, h:mm a').format(badge.unlockedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.insight,
    required this.onTap,
  });

  final RewardBadge badge;
  final _BadgeInsight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(int.parse(badge.accentHex));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: badge.unlocked
                ? accent.withValues(alpha: 0.5)
                : scheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: badge.unlocked ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconForKey(badge.iconKey),
                size: 22,
                color: badge.unlocked ? accent : scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              badge.title,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${insight.recordLabel}: ${insight.recordValue}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? accent.withValues(alpha: 0.14)
                    : scheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: badge.unlocked
                      ? accent.withValues(alpha: 0.35)
                      : scheme.outline,
                ),
              ),
              child: Text(
                badge.unlocked ? 'UNLOCKED' : 'LOCKED',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: badge.unlocked ? accent : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData iconForKey(String key) {
    return switch (key) {
      'flag' => Icons.flag_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      'sports_martial_arts' => Icons.sports_martial_arts_rounded,
      'timer' => Icons.timer_rounded,
      'paid' => Icons.paid_rounded,
      'school' => Icons.school_rounded,
      _ => Icons.workspace_premium_rounded,
    };
  }
}

class _BadgeInsight {
  const _BadgeInsight({
    required this.explanation,
    required this.recordLabel,
    required this.recordValue,
    required this.howToUnlock,
    required this.detail,
  });

  final String explanation;
  final String recordLabel;
  final String recordValue;
  final String howToUnlock;
  final String detail;
}
