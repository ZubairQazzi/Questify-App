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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: QuestifyBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                          SizedBox(
                            width: 96,
                            child: FilledButton.tonal(
                              onPressed: _finish,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              child: const FittedBox(child: Text('SKIP')),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        height: screenHeight < 760 ? 430 : 520,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged: (value) {
                            setState(() => _pageIndex = value);
                          },
                          itemBuilder: (context, index) {
                            final item = _items[index];

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: scheme.surface.withValues(
                                        alpha: 0.64,
                                      ),
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                        color: scheme.outline,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 66,
                                          height: 66,
                                          decoration: BoxDecoration(
                                            color: item.accent.withValues(
                                              alpha: 0.16,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          child: Icon(
                                            item.icon,
                                            size: 34,
                                            color: item.accent,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        Text(
                                          item.title,
                                          style: theme.textTheme.displaySmall
                                              ?.copyWith(
                                            fontSize:
                                                screenHeight < 760 ? 28 : null,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

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

                                  const SizedBox(height: 16),

                                  Text(
                                    'WHY IT HELPS',
                                    style: theme.textTheme.labelMedium,
                                  ),

                                  const SizedBox(height: 12),

                                  ...item.bullets.map(
                                    (bullet) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin:
                                                const EdgeInsets.only(top: 6),
                                            decoration: BoxDecoration(
                                              color: item.accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              bullet,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

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

                          SizedBox(
                            width: 170,
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
                              child: FittedBox(
                                child: Text(
                                  _pageIndex == _items.length - 1
                                      ? 'START QUESTING'
                                      : 'NEXT',
                                ),
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
