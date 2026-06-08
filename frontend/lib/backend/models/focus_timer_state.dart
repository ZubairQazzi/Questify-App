class FocusTimerState {
  const FocusTimerState({
    required this.id,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.updatedAt,
    this.questId,
  });

  static const activeTimerId = 'active';

  final String id;
  final String? questId;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final DateTime updatedAt;

  bool get isActive =>
      questId != null && remainingSeconds > 0 && totalSeconds > 0;

  FocusTimerState copyWith({
    String? id,
    String? questId,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    DateTime? updatedAt,
    bool clearQuestId = false,
  }) {
    return FocusTimerState(
      id: id ?? this.id,
      questId: clearQuestId ? null : questId ?? this.questId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'questId': questId,
      'remainingSeconds': remainingSeconds,
      'totalSeconds': totalSeconds,
      'isRunning': isRunning,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FocusTimerState.fromMap(Map<String, dynamic> map) {
    return FocusTimerState(
      id: map['id'] as String? ?? activeTimerId,
      questId: map['questId'] as String?,
      remainingSeconds: map['remainingSeconds'] as int? ?? 0,
      totalSeconds: map['totalSeconds'] as int? ?? 0,
      isRunning: map['isRunning'] as bool? ?? false,
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  factory FocusTimerState.inactive() {
    return FocusTimerState(
      id: activeTimerId,
      remainingSeconds: 0,
      totalSeconds: 0,
      isRunning: false,
      updatedAt: DateTime.now(),
    );
  }
}
