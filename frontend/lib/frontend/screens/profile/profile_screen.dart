import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/user_settings.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/questify_top_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onOpenProgressMap,
    required this.onOpenHistory,
    required this.onSignOut,
    super.key,
  });

  final VoidCallback onOpenProgressMap;
  final VoidCallback onOpenHistory;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final user = controller.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final avatarLetter = user.name.trim().isEmpty
        ? '?'
        : user.name.trim()[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 128),
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
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: QuestifyTheme.violet.withValues(
                      alpha: 0.18,
                    ),
                    child: Text(
                      avatarLetter,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: QuestifyTheme.violetGlow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.name, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: QuestifyTheme.emerald.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: QuestifyTheme.emerald.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'SYNCED',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: QuestifyTheme.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProfileStat(
                      label: 'Level',
                      value: '${user.level}',
                      accent: QuestifyTheme.violetGlow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStat(
                      label: 'Streak',
                      value: '${user.streak}',
                      accent: QuestifyTheme.coral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStat(
                      label: 'Badges',
                      value: '${controller.unlockedRewards.length}',
                      accent: QuestifyTheme.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsPanel(
          title: 'SETTINGS',
          children: <Widget>[
            ListTile(
              leading: Icon(
                controller.settings.themePreference == ThemePreference.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between dark and light themes'),
              trailing: Switch(
                value:
                    controller.settings.themePreference == ThemePreference.dark,
                onChanged: (value) {
                  controller.setThemePreference(
                    value ? ThemePreference.dark : ThemePreference.light,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.notifications_active_rounded),
              title: const Text('Notifications'),
              subtitle: Text(
                'Daily reminder at ${controller.settings.reminderLabel}',
              ),
              trailing: Switch(
                value: controller.settings.notificationsEnabled,
                onChanged: (value) {
                  controller.updateSettings(
                    controller.settings.copyWith(notificationsEnabled: value),
                  );
                },
              ),
              onTap: () => _pickReminderTime(context, controller),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.flag_circle_rounded),
              title: const Text('Daily goal'),
              subtitle: Text(
                '${controller.settings.dailyGoalQuests} completed quests per day',
              ),
              onTap: () => _pickDailyGoal(context, controller),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.timer_rounded),
              title: const Text('Focus session length'),
              subtitle: Text(
                '${controller.settings.focusDurationMinutes} minutes per session',
              ),
              onTap: () => _pickFocusDuration(context, controller),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsPanel(
          title: 'ACCOUNT',
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.map_rounded),
              title: const Text('Progress Map'),
              subtitle: const Text(
                'See your level trail and reward milestones',
              ),
              onTap: onOpenProgressMap,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Quest History'),
              subtitle: const Text('Review finished quests and reflections'),
              onTap: onOpenHistory,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              subtitle: const Text('Sign out from Firebase'),
              onTap: onSignOut,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    QuestifyController controller,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.settings.reminderHour,
        minute: controller.settings.reminderMinute,
      ),
    );
    if (selected == null) {
      return;
    }
    await controller.updateSettings(
      controller.settings.copyWith(
        reminderHour: selected.hour,
        reminderMinute: selected.minute,
      ),
    );
  }

  Future<void> _pickDailyGoal(
    BuildContext context,
    QuestifyController controller,
  ) async {
    double draftValue = controller.settings.dailyGoalQuests.toDouble();
    final selected = await showQuestifyTopDialog<double>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily quest goal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Slider(
                  min: 1,
                  max: 8,
                  divisions: 7,
                  value: draftValue,
                  label: draftValue.round().toString(),
                  onChanged: (value) => setState(() => draftValue = value),
                ),
                Text('${draftValue.round()} quests per day'),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(draftValue),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (selected == null) {
      return;
    }
    await controller.updateSettings(
      controller.settings.copyWith(dailyGoalQuests: selected.round()),
    );
  }

  Future<void> _pickFocusDuration(
    BuildContext context,
    QuestifyController controller,
  ) async {
    double draftValue = controller.settings.focusDurationMinutes.toDouble();
    final selected = await showQuestifyTopDialog<double>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Focus timer length',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Slider(
                  min: 15,
                  max: 60,
                  divisions: 9,
                  value: draftValue,
                  label: '${draftValue.round()} min',
                  onChanged: (value) => setState(() => draftValue = value),
                ),
                Text('${draftValue.round()} minutes'),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(draftValue),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (selected == null) {
      return;
    }

    await controller.updateSettings(
      controller.settings.copyWith(focusDurationMinutes: selected.round()),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}
