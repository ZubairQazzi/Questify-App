class MissionStep {
  const MissionStep({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;

  MissionStep copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return MissionStep(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory MissionStep.fromMap(Map<String, dynamic> map) {
    return MissionStep(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
    );
  }
}
