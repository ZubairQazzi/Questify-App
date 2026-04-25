import 'package:flutter/material.dart';

import '../theme/questify_theme.dart';

class BossHealthBar extends StatelessWidget {
  const BossHealthBar({
    required this.healthPercent,
    this.completedMissions,
    this.totalMissions,
    super.key,
  });

  final double healthPercent;
  final int? completedMissions;
  final int? totalMissions;

  @override
  Widget build(BuildContext context) {
    final remaining = (healthPercent.clamp(0, 1) * 100).round();
    final cleared = completedMissions ?? 0;
    final total = totalMissions ?? 0;
    final missionProgress = total <= 0
        ? 0.0
        : (cleared / total).clamp(0.0, 1.0).toDouble();
    final defeated = total > 0 && cleared >= total;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('BOSS HP', style: theme.textTheme.labelMedium),
            const Spacer(),
            Text(
              defeated ? 'DEFEATED' : '$remaining% LEFT',
              style: theme.textTheme.labelLarge?.copyWith(
                color: defeated ? QuestifyTheme.emerald : QuestifyTheme.coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _MeterTrack(
          borderColor: scheme.outline,
          fillColor: QuestifyTheme.coral,
          fillRatio: healthPercent.clamp(0, 1),
          emptyLabel: defeated ? 'All boss HP removed' : 'Boss at full health',
          overlayLabel: defeated ? 'BOSS DEFEATED' : '$remaining% HP',
          overlayColor: defeated ? QuestifyTheme.emerald : QuestifyTheme.coral,
        ),
        if (totalMissions != null && totalMissions! > 0) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text('MISSION PROGRESS', style: theme.textTheme.labelMedium),
              const Spacer(),
              Text(
                '$cleared/$total cleared',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: QuestifyTheme.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MeterTrack(
            borderColor: scheme.outline,
            fillColor: QuestifyTheme.emerald,
            fillRatio: missionProgress,
            emptyLabel: 'No missions cleared yet',
            overlayLabel: defeated
                ? 'ALL MISSIONS CLEARED'
                : '$cleared OF $total MISSIONS',
            overlayColor: QuestifyTheme.emerald,
          ),
        ],
      ],
    );
  }
}

class _MeterTrack extends StatelessWidget {
  const _MeterTrack({
    required this.borderColor,
    required this.fillColor,
    required this.fillRatio,
    required this.emptyLabel,
    required this.overlayLabel,
    required this.overlayColor,
  });

  final Color borderColor;
  final Color fillColor;
  final double fillRatio;
  final String emptyLabel;
  final String overlayLabel;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    final clamped = fillRatio.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (clamped > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: clamped,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          fillColor.withValues(alpha: 0.9),
                          fillColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: Text(
                clamped == 0 ? emptyLabel : overlayLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: clamped == 0 ? overlayColor : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
