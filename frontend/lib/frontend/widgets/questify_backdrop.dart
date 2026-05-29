import 'package:flutter/material.dart';

import '../theme/questify_theme.dart';

class QuestifyBackdrop extends StatelessWidget {
  const QuestifyBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const <Color>[
                  QuestifyTheme.obsidian,
                  QuestifyTheme.midnight,
                  Color(0xFF120F1F),
                ]
              : const <Color>[
                  Color(0xFFF7F5FF),
                  Color(0xFFF3EEFF),
                  Color(0xFFFFF8EF),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _HudGridPainter(isDark))),
          Positioned(
            top: -120,
            left: -40,
            child: _GlowOrb(
              size: 260,
              color: isDark
                  ? QuestifyTheme.violet.withValues(alpha: 0.34)
                  : QuestifyTheme.violet.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 140,
            right: -60,
            child: _GlowOrb(
              size: 240,
              color: isDark
                  ? QuestifyTheme.cyan.withValues(alpha: 0.18)
                  : QuestifyTheme.gold.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: -110,
            right: 10,
            child: _GlowOrb(
              size: 230,
              color: isDark
                  ? QuestifyTheme.gold.withValues(alpha: 0.18)
                  : QuestifyTheme.emerald.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: 28,
            left: 24,
            child: IgnorePointer(
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, blurRadius: 90, spreadRadius: 0),
          ],
        ),
      ),
    );
  }
}

class _HudGridPainter extends CustomPainter {
  const _HudGridPainter(this.isDark);

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : QuestifyTheme.violet).withValues(
        alpha: isDark ? 0.045 : 0.05,
      );

    const gap = 36.0;
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(
        Offset.zero.translate(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = (isDark ? QuestifyTheme.violetGlow : QuestifyTheme.violet)
          .withValues(alpha: isDark ? 0.14 : 0.08);

    final rect = Rect.fromCircle(
      center: Offset(size.width * 0.86, size.height * 0.18),
      radius: 110,
    );
    canvas.drawArc(rect, 2.8, 1.45, false, arcPaint);

    final rect2 = Rect.fromCircle(
      center: Offset(size.width * 0.18, size.height * 0.76),
      radius: 140,
    );
    canvas.drawArc(rect2, -0.7, 1.7, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _HudGridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
