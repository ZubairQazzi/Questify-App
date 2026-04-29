import 'mission_step.dart';

enum QuestDifficulty { easy, medium, hard }

enum QuestStatus { pending, inProgress, completed, overdue }

enum QuestType { assignment, quiz, exam, project, presentation, studySession }

extension QuestDifficultyX on QuestDifficulty {
  String get label => switch (this) {
    QuestDifficulty.easy => 'Easy',
    QuestDifficulty.medium => 'Medium',
    QuestDifficulty.hard => 'Hard',
  };

  static QuestDifficulty fromLabel(String? value) {
    return QuestDifficulty.values.firstWhere(
      (difficulty) => difficulty.label.toLowerCase() == value?.toLowerCase(),
      orElse: () => QuestDifficulty.medium,
    );
  }
}

extension QuestStatusX on QuestStatus {
  String get label => switch (this) {
    QuestStatus.pending => 'Pending',
    QuestStatus.inProgress => 'In Progress',
    QuestStatus.completed => 'Completed',
    QuestStatus.overdue => 'Missed',
  };

  static QuestStatus fromLabel(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return QuestStatus.pending;
      case 'in progress':
        return QuestStatus.inProgress;
      case 'completed':
        return QuestStatus.completed;
      case 'overdue':
      case 'missed':
        return QuestStatus.overdue;
      default:
        return QuestStatus.pending;
    }
  }
}

extension QuestTypeX on QuestType {
  String get label => switch (this) {
    QuestType.assignment => 'Assignment',
    QuestType.quiz => 'Quiz',
    QuestType.exam => 'Exam',
    QuestType.project => 'Project',
    QuestType.presentation => 'Presentation',
    QuestType.studySession => 'Study Session',
  };

  static QuestType fromLabel(String? value) {
    return QuestType.values.firstWhere(
      (type) => type.label.toLowerCase() == value?.toLowerCase(),
      orElse: () => QuestType.assignment,
    );
  }
}

class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.deadline,
    required this.status,
    required this.xpReward,
    required this.coinReward,
    required this.questType,
    required this.createdAt,
    required this.estimatedMinutes,
    this.completedAt,
    this.note,
    this.steps = const <MissionStep>[],
    this.reflection,
    this.focusSessionsCompleted = 0,
    this.bossBattleMode = false,
  });

  final String id;
  final String title;
  final String subject;
  final QuestDifficulty difficulty;
  final DateTime deadline;
  final QuestStatus status;
  final int xpReward;
  final int coinReward;
  final QuestType questType;
  final DateTime createdAt;
  final int estimatedMinutes;
  final DateTime? completedAt;
  final String? note;
  final List<MissionStep> steps;
  final String? reflection;
  final int focusSessionsCompleted;
  final bool bossBattleMode;

  bool get isCompleted => status == QuestStatus.completed;
  bool get hasSteps => steps.isNotEmpty;

  Quest copyWith({
    String? id,
    String? title,
    String? subject,
    QuestDifficulty? difficulty,
    DateTime? deadline,
    QuestStatus? status,
    int? xpReward,
    int? coinReward,
    QuestType? questType,
    DateTime? createdAt,
    int? estimatedMinutes,
    DateTime? completedAt,
    String? note,
    List<MissionStep>? steps,
    String? reflection,
    int? focusSessionsCompleted,
    bool? bossBattleMode,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      questType: questType ?? this.questType,
      createdAt: createdAt ?? this.createdAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      steps: steps ?? this.steps,
      reflection: reflection ?? this.reflection,
      focusSessionsCompleted:
          focusSessionsCompleted ?? this.focusSessionsCompleted,
      bossBattleMode: bossBattleMode ?? this.bossBattleMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subject': subject,
      'difficulty': difficulty.label,
      'deadline': deadline.toIso8601String(),
      'status': status.label,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'questType': questType.label,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'note': note,
      'steps': steps.map((step) => step.toMap()).toList(),
      'reflection': reflection,
      'focusSessionsCompleted': focusSessionsCompleted,
      'bossBattleMode': bossBattleMode,
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    final rawSteps = (map['steps'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((step) => MissionStep.fromMap(Map<String, dynamic>.from(step)))
        .toList();

    return Quest(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      difficulty: QuestDifficultyX.fromLabel(map['difficulty'] as String?),
      deadline:
          DateTime.tryParse(map['deadline'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      status: QuestStatusX.fromLabel(map['status'] as String?),
      xpReward: map['xpReward'] as int? ?? 20,
      coinReward: map['coinReward'] as int? ?? 5,
      questType: QuestTypeX.fromLabel(map['questType'] as String?),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
      estimatedMinutes: map['estimatedMinutes'] as int? ?? 25,
      note: map['note'] as String?,
      steps: rawSteps,
      reflection: map['reflection'] as String?,
      focusSessionsCompleted: map['focusSessionsCompleted'] as int? ?? 0,
      bossBattleMode: map['bossBattleMode'] as bool? ?? false,
    );
  }
}
