import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/reward_badge.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';

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
                  return _BadgeCard(badge: badge);
                },
              );
            },
          ),
      ],
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
  const _BadgeCard({required this.badge});

  final RewardBadge badge;

  @override
  Widget build(BuildContext context) {
    final accent = Color(int.parse(badge.accentHex));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
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
              _iconForKey(badge.iconKey),
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
    );
  }

  IconData _iconForKey(String key) {
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
