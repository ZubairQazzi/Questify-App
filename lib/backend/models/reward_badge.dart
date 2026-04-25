class RewardBadge {
  const RewardBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.unlocked,
    this.unlockedAt,
    this.accentHex = '0xFF45D6A8',
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String accentHex;

  RewardBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? iconKey,
    bool? unlocked,
    DateTime? unlockedAt,
    String? accentHex,
  }) {
    return RewardBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      accentHex: accentHex ?? this.accentHex,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'iconKey': iconKey,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'accentHex': accentHex,
    };
  }

  factory RewardBadge.fromMap(Map<String, dynamic> map) {
    return RewardBadge(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? 'military_tech',
      unlocked: map['unlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] == null
          ? null
          : DateTime.tryParse(map['unlockedAt'] as String),
      accentHex: map['accentHex'] as String? ?? '0xFF45D6A8',
    );
  }
}
