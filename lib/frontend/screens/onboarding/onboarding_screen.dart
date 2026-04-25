import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/questify_backdrop.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  static const _items = <_OnboardingItem>[
    _OnboardingItem(
      icon: Icons.task_alt_rounded,
      accent: QuestifyTheme.violetGlow,
      title: 'Turn tasks into quests',
      description:
          'Create study missions with deadlines, rewards, and focus time in a single flow.',
      bullets: <String>[
        'Fast setup for assignments, quizzes, exams, and projects.',
        'XP and coins are calculated automatically.',
      ],
    ),
    _OnboardingItem(
      icon: Icons.sports_martial_arts_rounded,
      accent: QuestifyTheme.gold,
      title: 'Fight boss deadlines',
      description:
          'Large projects become boss battles with smaller missions you can clear one by one.',
      bullets: <String>[
        'Damage the boss by checking off mission steps.',
        'See health bars and looming danger at a glance.',
      ],
    ),
    _OnboardingItem(
      icon: Icons.workspace_premium_rounded,
      accent: QuestifyTheme.emerald,
      title: 'Keep progress visible',
      description:
          'Badges, levels, streaks, and rewards make effort feel measurable instead of invisible.',
      bullets: <String>[
        'Your Firebase account keeps everything synced.',
        'Light and dark themes stay available from day one.',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: QuestifyBackdrop(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'QUESTIFY',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: QuestifyTheme.violetGlow,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _finish,
                            child: const Text('SKIP'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 520,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged: (value) =>
                              setState(() => _pageIndex = value),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: scheme.surface.withValues(
                                      alpha: 0.64,
                                    ),
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(color: scheme.outline),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: item.accent.withValues(
                                            alpha: 0.16,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          size: 36,
                                          color: item.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        item.title,
                                        style: theme.textTheme.displaySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.description,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'WHY IT HELPS',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(height: 12),
                                ...item.bullets.map(
                                  (bullet) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(top: 6),
                                          decoration: BoxDecoration(
                                            color: item.accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(bullet)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          ...List<Widget>.generate(
                            _items.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.only(right: 8),
                              height: 8,
                              width: _pageIndex == index ? 34 : 10,
                              decoration: BoxDecoration(
                                color: _pageIndex == index
                                    ? QuestifyTheme.violetGlow
                                    : scheme.outline,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                if (_pageIndex == _items.length - 1) {
                                  _finish();
                                  return;
                                }
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              child: Text(
                                _pageIndex == _items.length - 1
                                    ? 'START QUESTING'
                                    : 'NEXT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await context.read<QuestifyController>().markOnboardingComplete();
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.bullets,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final List<String> bullets;
}
