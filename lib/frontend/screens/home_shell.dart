import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/questify_controller.dart';
import '../theme/questify_theme.dart';
import '../widgets/questify_backdrop.dart';
import '../widgets/questify_feedback.dart';
import 'boss/boss_battles_screen.dart';
import 'dashboard/add_quest_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/quest_detail_screen.dart';
import 'profile/history_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/progress_map_screen.dart';
import 'rewards/rewards_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<QuestifyController>().refreshTimeSensitiveState(
        persistIfChanged: true,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<QuestifyController>().refreshTimeSensitiveState(
        persistIfChanged: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();

    if (controller.user == null) {
      return Scaffold(
        body: QuestifyBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 18),
                      Text(
                        'Syncing your dashboard',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Questify is reconnecting your Firebase session and loading your progress.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final pages = <Widget>[
      DashboardScreen(
        onOpenQuest: _openQuest,
        onOpenHistory: _openHistory,
        onOpenProgressMap: _openProgressMap,
        onCreateQuest: _openAddQuest,
      ),
      BossBattlesScreen(onOpenBattle: _openBossBattle),
      RewardsScreen(onOpenProgressMap: _openProgressMap),
      ProfileScreen(
        onOpenProgressMap: _openProgressMap,
        onOpenHistory: _openHistory,
        onSignOut: () async {
          await controller.signOut();
        },
      ),
    ];
    return Scaffold(
      extendBody: true,
      body: QuestifyBackdrop(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: IndexedStack(
                  index: _currentIndex,
                  children: pages,
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                child: _QuestifyNavBar(
                  currentIndex: _currentIndex,
                  onSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _openAddQuest() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const AddQuestScreen(),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    showQuestifyFeedback(
      context,
      'Quest saved successfully.',
      tone: QuestifyFeedbackTone.success,
    );
  }

  Future<void> _openQuest(String questId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QuestDetailScreen(questId: questId),
      ),
    );
  }

  Future<void> _openBossBattle(String bossBattleId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BossBattleDetailScreen(bossBattleId: bossBattleId),
      ),
    );
  }

  Future<void> _openProgressMap() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ProgressMapScreen(),
      ),
    );
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }
}

class _QuestifyNavBar extends StatelessWidget {
  const _QuestifyNavBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outline,
          width: 1.2,
        ),
      ),
      child: Row(
        children: <Widget>[
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onSelected(0),
          ),
          _NavItem(
            icon: Icons.sports_martial_arts_rounded,
            label: 'Boss',
            selected: currentIndex == 1,
            onTap: () => onSelected(1),
          ),
          _NavItem(
            icon: Icons.workspace_premium_rounded,
            label: 'Rewards',
            selected: currentIndex == 2,
            onTap: () => onSelected(2),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: currentIndex == 3,
            onTap: () => onSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? QuestifyTheme.violet.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? QuestifyTheme.violetGlow : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: selected
                    ? QuestifyTheme.violetGlow
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? QuestifyTheme.violetGlow
                        : scheme.onSurfaceVariant,
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
