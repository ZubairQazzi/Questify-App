import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/quest.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final history = controller.completedQuests;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Quest History')),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.88,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: const Text('Completed quests will appear here.'),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final quest = history[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.88,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              quest.title,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: QuestifyTheme.emerald.withValues(
                                alpha: 0.14,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'DONE',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: QuestifyTheme.emerald,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${quest.subject} • ${quest.questType.label}'),
                      const SizedBox(height: 10),
                      Text(
                        'Completed on ${DateFormat('d MMM, h:mm a').format(quest.completedAt ?? quest.createdAt)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+${quest.xpReward} XP • +${quest.coinReward} coins',
                      ),
                      if (quest.reflection != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.52),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: scheme.outline),
                          ),
                          child: Text('Reflection: ${quest.reflection}'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
