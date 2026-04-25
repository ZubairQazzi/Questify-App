import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/boss_health_bar.dart';
import '../../widgets/quest_card.dart';
import '../../widgets/stat_pill.dart';
import '../../widgets/xp_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.onOpenQuest,
    required this.onOpenHistory,
    required this.onOpenProgressMap,
    super.key,
  });

  final ValueChanged<String> onOpenQuest;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenProgressMap;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final user = controller.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final urgentQuest = controller.urgentQuest;
    final bossBattle = controller.activeBossBattles.firstOrNull;
    final avatarLetter = user.name.trim().isEmpty
        ? '?'
        : user.name.trim()[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 128),
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundColor: QuestifyTheme.violet.withValues(alpha: 0.18),
              child: Text(
                avatarLetter,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: QuestifyTheme.violetGlow,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'QUESTIFY',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: QuestifyTheme.violetGlow,
                    ),
                  ),
                  Text('Command Center', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outline),
              ),
              child: Text(
                'LV ${user.level}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: QuestifyTheme.gold,
                ),
              ),
            ),
          ],
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
              Text(
                'WELCOME BACK, ${user.name.split(' ').first.toUpperCase()}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: QuestifyTheme.lilac,
                ),
              ),
              const SizedBox(height: 6),
              Text(controller.rankTitle, style: theme.textTheme.displaySmall),
              const SizedBox(height: 10),
              Text(
                'Keep the streak alive, clear your missions, and turn deadlines into visible wins.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniCard(
                      value: '${user.streak}',
                      label: 'Streak days',
                      accent: QuestifyTheme.coral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      value: '${user.coins}',
                      label: 'Coins saved',
                      accent: QuestifyTheme.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        XpBar(
          level: user.level,
          progress: controller.levelProgress,
          xp: user.xp,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            StatPill(
              icon: Icons.check_circle_outline_rounded,
              label: 'Done today',
              value:
                  '${controller.completedTodayCount}/${controller.settings.dailyGoalQuests}',
              color: QuestifyTheme.emerald,
            ),
            StatPill(
              icon: Icons.map_rounded,
              label: 'Progress map',
              value: 'Open',
              color: QuestifyTheme.violetGlow,
            ),
            StatPill(
              icon: Icons.history_rounded,
              label: 'History',
              value: 'Review',
              color: QuestifyTheme.cyan,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: _ShortcutTile(
                icon: Icons.map_rounded,
                title: 'Progress Map',
                subtitle: 'See your level path',
                onTap: onOpenProgressMap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShortcutTile(
                icon: Icons.history_rounded,
                title: 'Quest History',
                subtitle: 'Review completed wins',
                onTap: onOpenHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Text('TODAY\'S QUESTS', style: theme.textTheme.titleLarge),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outline),
              ),
              child: Text(
                '${controller.activeQuests.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: QuestifyTheme.violetGlow,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (controller.activeQuests.isEmpty)
          _EmptyPanel(
            title: 'No quests on the board',
            body:
                'Create your first quest and Questify will start turning deadlines into missions.',
          )
        else
          ...controller.activeQuests
              .take(6)
              .map(
                (quest) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuestCard(
                    quest: quest,
                    onTap: () => onOpenQuest(quest.id),
                  ),
                ),
              ),
        if (urgentQuest != null) ...<Widget>[
          const SizedBox(height: 10),
          _WarningCard(
            title: 'HIGH PRIORITY',
            body: urgentQuest.title,
            caption: 'Nearest deadline on the board',
            accent: QuestifyTheme.coral,
            onTap: () => onOpenQuest(urgentQuest.id),
          ),
        ],
        if (bossBattle != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: QuestifyTheme.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: QuestifyTheme.gold.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'BOSS FIGHT INCOMING',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: QuestifyTheme.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(bossBattle.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                BossHealthBar(healthPercent: bossBattle.healthPercent),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => onOpenQuest(bossBattle.linkedQuestId),
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('OPEN BATTLE QUEST'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: QuestifyTheme.violet.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: QuestifyTheme.violetGlow),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.title,
    required this.body,
    required this.caption,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String body;
  final String caption;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: accent),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(caption, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
