class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.xp,
    required this.coins,
    required this.streak,
    required this.lastActiveDate,
  });

  final String id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final int coins;
  final int streak;
  final DateTime lastActiveDate;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    int? level,
    int? xp,
    int? coins,
    int? streak,
    DateTime? lastActiveDate,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'xp': xp,
      'coins': coins,
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Student',
      email: map['email'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      lastActiveDate:
          DateTime.tryParse(map['lastActiveDate'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  factory AppUser.initial({
    required String id,
    required String name,
    required String email,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      level: 1,
      xp: 0,
      coins: 0,
      streak: 0,
      lastActiveDate: DateTime.now(),
    );
  }
}
