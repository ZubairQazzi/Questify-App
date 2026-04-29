import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/quest.dart';
import '../../../backend/services/gamification_service.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/questify_feedback.dart';

class AddQuestScreen extends StatefulWidget {
  const AddQuestScreen({this.existingQuest, super.key});

  final Quest? existingQuest;

  @override
  State<AddQuestScreen> createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _noteController;
  late final TextEditingController _estimatedMinutesController;
  late QuestDifficulty _difficulty;
  late QuestType _questType;
  late DateTime _deadline;
  late bool _bossBattleMode;
  late List<TextEditingController> _stepControllers;

  @override
  void initState() {
    super.initState();
    final quest = widget.existingQuest;
    _titleController = TextEditingController(text: quest?.title ?? '');
    _subjectController = TextEditingController(text: quest?.subject ?? '');
    _noteController = TextEditingController(text: quest?.note ?? '');
    _estimatedMinutesController = TextEditingController(
      text: (quest?.estimatedMinutes ?? 25).toString(),
    );
    _difficulty = quest?.difficulty ?? QuestDifficulty.medium;
    _questType = quest?.questType ?? QuestType.assignment;
    _deadline = quest?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _bossBattleMode = quest?.bossBattleMode ?? false;
    _stepControllers = (quest?.steps ?? const []).isEmpty
        ? <TextEditingController>[
            TextEditingController(),
            TextEditingController(),
          ]
        : quest!.steps
              .map((step) => TextEditingController(text: step.title))
              .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _noteController.dispose();
    _estimatedMinutesController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEditing = widget.existingQuest != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Quest' : 'Add Quest')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
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
                    Text(
                      'BUILD A NEW MISSION',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Patch your existing quest.'
                          : 'Turn your next deadline into a clean, rewarding mission.',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose the difficulty, battle type, deadline, and rewards. The app will calculate XP and coins automatically.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Quest basics',
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Quest title',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a quest title.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Difficulty',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: QuestDifficulty.values.map((difficulty) {
                    return ChoiceChip(
                      label: Text(difficulty.label.toUpperCase()),
                      selected: _difficulty == difficulty,
                      onSelected: (_) =>
                          setState(() => _difficulty = difficulty),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Quest type',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: QuestType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.label.toUpperCase()),
                      selected: _questType == type,
                      onSelected: (_) => setState(() => _questType = type),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Timing & rewards',
                child: Column(
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _pickDeadline,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.54),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: scheme.outline),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: QuestifyTheme.violetGlow,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Deadline',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'EEE, d MMM - h:mm a',
                                    ).format(_deadline),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _estimatedMinutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimated focus time (minutes)',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid number of minutes.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _RewardPreview(
                            label: 'XP reward',
                            value:
                                '+${GamificationService.xpRewardFor(_difficulty)}',
                            accent: QuestifyTheme.violetGlow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RewardPreview(
                            label: 'Coins',
                            value:
                                '+${GamificationService.coinRewardFor(_difficulty)}',
                            accent: QuestifyTheme.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Boss battle mode',
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      value: _bossBattleMode,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) =>
                          setState(() => _bossBattleMode = value),
                      title: const Text('Turn this quest into a boss battle'),
                      subtitle: const Text(
                        'Best for big projects with multiple steps to clear.',
                      ),
                    ),
                    if (_bossBattleMode) ...<Widget>[
                      const SizedBox(height: 10),
                      ..._stepControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final textController = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                    labelText: 'Mission ${index + 1}',
                                    prefixIcon: const Icon(Icons.flag_outlined),
                                  ),
                                  validator: (value) {
                                    if (_bossBattleMode &&
                                        index < 2 &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Add at least two mission titles.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _stepControllers.length <= 2
                                    ? null
                                    : () {
                                        final removed = _stepControllers
                                            .removeAt(index);
                                        removed.dispose();
                                        setState(() {});
                                      },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _stepControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('ADD MISSION'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Notes',
                child: TextFormField(
                  controller: _noteController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Optional notes',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: controller.isSaving ? null : _submit,
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'UPDATE QUEST' : 'SAVE QUEST'),
              ),
              if (controller.isSaving) ...<Widget>[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_deadline.isBefore(DateTime.now())) {
      showQuestifyFeedback(
        context,
        'Please choose a future deadline.',
        tone: QuestifyFeedbackTone.warning,
      );
      return;
    }

    final controller = context.read<QuestifyController>();
    final draft = controller.createQuestDraft(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      difficulty: _difficulty,
      questType: _questType,
      deadline: _deadline,
      estimatedMinutes: int.parse(_estimatedMinutesController.text.trim()),
      note: _noteController.text.trim(),
      bossBattleMode: _bossBattleMode,
      steps: _stepControllers.map((controller) => controller.text).toList(),
      existing: widget.existingQuest,
    );
    final message = await controller.saveQuest(draft);
    if (!mounted) {
      return;
    }
    if (message != null) {
      showQuestifyFeedback(
        context,
        message,
        tone: QuestifyFeedbackTone.error,
      );
      return;
    }
    Navigator.of(context).pop(true);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({
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
        color: scheme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}
