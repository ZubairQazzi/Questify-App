import 'package:flutter/material.dart';

import '../theme/questify_theme.dart';

enum QuestifyFeedbackTone { info, success, warning, error }

void showQuestifyFeedback(
  BuildContext context,
  String message, {
  QuestifyFeedbackTone tone = QuestifyFeedbackTone.info,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final messenger = ScaffoldMessenger.of(context);

  final accent = switch (tone) {
    QuestifyFeedbackTone.info => QuestifyTheme.violetGlow,
    QuestifyFeedbackTone.success => QuestifyTheme.emerald,
    QuestifyFeedbackTone.warning => QuestifyTheme.gold,
    QuestifyFeedbackTone.error => scheme.error,
  };

  final icon = switch (tone) {
    QuestifyFeedbackTone.info => Icons.info_outline_rounded,
    QuestifyFeedbackTone.success => Icons.check_circle_outline_rounded,
    QuestifyFeedbackTone.warning => Icons.warning_amber_rounded,
    QuestifyFeedbackTone.error => Icons.error_outline_rounded,
  };

  messenger.clearSnackBars();
  messenger.hideCurrentMaterialBanner();
  messenger.showMaterialBanner(
    MaterialBanner(
      elevation: 0,
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.98),
      dividerColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          child: const Text('Dismiss'),
        ),
      ],
    ),
  );

  Future<void>.delayed(const Duration(seconds: 3)).then((_) {
    messenger.hideCurrentMaterialBanner();
  });
}
