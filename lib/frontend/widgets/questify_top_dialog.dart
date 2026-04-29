import 'package:flutter/material.dart';

Future<T?> showQuestifyTopDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  final barrierLabel = MaterialLocalizations.of(
    context,
  ).modalBarrierDismissLabel;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) {
      final theme = Theme.of(dialogContext);
      final scheme = theme.colorScheme;
      final media = MediaQuery.of(dialogContext);
      final maxWidth = media.size.width > 720 ? 620.0 : media.size.width - 24;
      final maxHeight =
          media.size.height -
          media.padding.top -
          media.padding.bottom -
          32;

      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.98),
                elevation: 18,
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
