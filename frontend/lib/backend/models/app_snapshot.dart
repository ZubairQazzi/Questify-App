import 'app_user.dart';
import 'boss_battle.dart';
import 'quest.dart';
import 'reward_badge.dart';
import 'user_settings.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.user,
    required this.settings,
    required this.quests,
    required this.bossBattles,
    required this.rewards,
  });

  final AppUser user;
  final UserSettings settings;
  final List<Quest> quests;
  final List<BossBattle> bossBattles;
  final List<RewardBadge> rewards;

  AppSnapshot copyWith({
    AppUser? user,
    UserSettings? settings,
    List<Quest>? quests,
    List<BossBattle>? bossBattles,
    List<RewardBadge>? rewards,
  }) {
    return AppSnapshot(
      user: user ?? this.user,
      settings: settings ?? this.settings,
      quests: quests ?? this.quests,
      bossBattles: bossBattles ?? this.bossBattles,
      rewards: rewards ?? this.rewards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'settings': settings.toMap(),
      'quests': quests.map((quest) => quest.toMap()).toList(),
      'bossBattles': bossBattles.map((battle) => battle.toMap()).toList(),
      'rewards': rewards.map((reward) => reward.toMap()).toList(),
    };
  }

  factory AppSnapshot.fromMap(Map<String, dynamic> map) {
    final questMaps = (map['quests'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((quest) => Quest.fromMap(Map<String, dynamic>.from(quest)))
        .toList();
    final bossMaps = (map['bossBattles'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((boss) => BossBattle.fromMap(Map<String, dynamic>.from(boss)))
        .toList();
    final rewardMaps = (map['rewards'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((reward) => RewardBadge.fromMap(Map<String, dynamic>.from(reward)))
        .toList();

    return AppSnapshot(
      user: AppUser.fromMap(Map<String, dynamic>.from(map['user'] as Map)),
      settings: UserSettings.fromMap(
        Map<String, dynamic>.from(map['settings'] as Map),
      ),
      quests: questMaps,
      bossBattles: bossMaps,
      rewards: rewardMaps,
    );
  }
}
