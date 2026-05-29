import 'mission_step.dart';

enum BossBattleStatus { active, defeated, overdue }

extension BossBattleStatusX on BossBattleStatus {
  String get label => switch (this) {
    BossBattleStatus.active => 'Active',
    BossBattleStatus.defeated => 'Defeated',
    BossBattleStatus.overdue => 'Missed',
  };

  static BossBattleStatus fromLabel(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return BossBattleStatus.active;
      case 'defeated':
        return BossBattleStatus.defeated;
      case 'overdue':
      case 'missed':
        return BossBattleStatus.overdue;
      default:
        return BossBattleStatus.active;
    }
  }
}

class BossBattle {
  const BossBattle({
    required this.id,
    required this.title,
    required this.linkedQuestId,
    required this.deadline,
    required this.missions,
    required this.status,
    required this.createdAt,
    this.rewardBonus = 25,
  });

  final String id;
  final String title;
  final String linkedQuestId;
  final DateTime deadline;
  final List<MissionStep> missions;
  final BossBattleStatus status;
  final DateTime createdAt;
  final int rewardBonus;

  int get totalMissions => missions.length;
  int get completedMissions =>
      missions.where((mission) => mission.isCompleted).length;
  double get healthPercent {
    if (missions.isEmpty) {
      return 1;
    }
    return 1 - (completedMissions / totalMissions);
  }

  BossBattle copyWith({
    String? id,
    String? title,
    String? linkedQuestId,
    DateTime? deadline,
    List<MissionStep>? missions,
    BossBattleStatus? status,
    DateTime? createdAt,
    int? rewardBonus,
  }) {
    return BossBattle(
      id: id ?? this.id,
      title: title ?? this.title,
      linkedQuestId: linkedQuestId ?? this.linkedQuestId,
      deadline: deadline ?? this.deadline,
      missions: missions ?? this.missions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rewardBonus: rewardBonus ?? this.rewardBonus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'linkedQuestId': linkedQuestId,
      'deadline': deadline.toIso8601String(),
      'missions': missions.map((mission) => mission.toMap()).toList(),
      'status': status.label,
      'createdAt': createdAt.toIso8601String(),
      'rewardBonus': rewardBonus,
    };
  }

  factory BossBattle.fromMap(Map<String, dynamic> map) {
    final rawMissions = (map['missions'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (mission) => MissionStep.fromMap(Map<String, dynamic>.from(mission)),
        )
        .toList();

    return BossBattle(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      linkedQuestId: map['linkedQuestId'] as String? ?? '',
      deadline:
          DateTime.tryParse(map['deadline'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      missions: rawMissions,
      status: BossBattleStatusX.fromLabel(map['status'] as String?),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      rewardBonus: map['rewardBonus'] as int? ?? 25,
    );
  }
}
