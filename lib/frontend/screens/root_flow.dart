import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/questify_controller.dart';
import '../theme/questify_theme.dart';
import '../widgets/questify_backdrop.dart';
import 'auth/auth_screen.dart';
import 'home_shell.dart';
import 'onboarding/onboarding_screen.dart';

class RootFlow extends StatelessWidget {
  const RootFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();

    Widget child;
    if (!controller.initialized) {
      child = const _BootScreen();
    } else if (!controller.onboardingComplete) {
      child = const OnboardingScreen();
    } else if (!controller.isSignedIn) {
      child = const AuthScreen();
    } else {
      child = const HomeShell();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey<String>(
          !controller.initialized
              ? 'boot'
              : !controller.onboardingComplete
              ? 'onboarding'
              : !controller.isSignedIn
              ? 'auth'
              : 'home',
        ),
        child: child,
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: QuestifyBackdrop(
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: QuestifyTheme.violet.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: QuestifyTheme.violetGlow.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: QuestifyTheme.violetGlow,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 20),
                Text('QUESTIFY', style: theme.textTheme.displaySmall),
                const SizedBox(height: 10),
                Text(
                  'Loading your quest board...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
