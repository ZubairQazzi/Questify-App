import '../models/app_user.dart';
import '../models/boss_battle.dart';
import '../models/quest.dart';
import '../models/reward_badge.dart';

class GamificationService {
  const GamificationService._();

  static int xpRewardFor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 20;
      case QuestDifficulty.medium:
        return 40;
      case QuestDifficulty.hard:
        return 70;
    }
  }

  static int coinRewardFor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 5;
      case QuestDifficulty.medium:
        return 10;
      case QuestDifficulty.hard:
        return 20;
    }
  }

  static int calculateLevel(int xp) => (xp ~/ 100) + 1;

  static double progressToNextLevel(int xp) => (xp % 100) / 100;

  static String deadlineStatus(DateTime deadline) {
    final hoursLeft = deadline.difference(DateTime.now()).inHours;
    if (hoursLeft < 0) {
      return 'Missed';
    }
    if (hoursLeft < 24) {
      return 'Critical';
    }
    if (hoursLeft < 72) {
      return 'Approaching';
    }
    return 'Safe';
  }

  static String rankTitleForLevel(int level) {
    if (level >= 10) {
      return 'Legend Architect';
    }
    if (level >= 8) {
      return 'Productivity Paladin';
    }
    if (level >= 6) {
      return 'Deadline Defender';
    }
    if (level >= 4) {
      return 'Scholar Captain';
    }
    if (level >= 2) {
      return 'Quest Cadet';
    }
    return 'Fresh Adventurer';
  }

  static AppUser normalizeUser(AppUser user, List<Quest> quests) {
    return user.copyWith(
      level: calculateLevel(user.xp),
      streak: calculateStreak(quests),
      lastActiveDate:
          quests
              .where((quest) => quest.completedAt != null)
              .map((quest) => quest.completedAt!)
              .fold<DateTime?>(null, (latest, current) {
                if (latest == null || current.isAfter(latest)) {
                  return current;
                }
                return latest;
              }) ??
          user.lastActiveDate,
    );
  }

  static int calculateStreak(List<Quest> quests) {
    final completedDates =
        quests
            .where((quest) => quest.completedAt != null)
            .map((quest) {
              final completedAt = quest.completedAt!;
              return DateTime(
                completedAt.year,
                completedAt.month,
                completedAt.day,
              );
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (completedDates.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedYesterday = normalizedToday.subtract(
      const Duration(days: 1),
    );
    if (completedDates.first.isBefore(normalizedYesterday)) {
      return 0;
    }

    var streak = 0;
    DateTime cursor = completedDates.first;
    for (final completedDay in completedDates) {
      if (completedDay == cursor) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  static List<RewardBadge> refreshRewards({
    required AppUser user,
    required List<Quest> quests,
    required List<BossBattle> bossBattles,
    List<RewardBadge> existing = const <RewardBadge>[],
  }) {
    final unlockedMap = {
      for (final badge in existing.where((item) => item.unlocked))
        badge.id: badge,
    };

    final completedQuests = quests
        .where((quest) => quest.status == QuestStatus.completed)
        .length;
    final defeatedBosses = bossBattles
        .where((battle) => battle.status == BossBattleStatus.defeated)
        .length;
    final focusSessions = quests.fold<int>(
      0,
      (count, quest) => count + quest.focusSessionsCompleted,
    );

    final catalog = <RewardBadge>[
      RewardBadge(
        id: 'first_quest',
        title: 'First Win',
        description: 'Complete your first quest.',
        iconKey: 'flag',
        unlocked: completedQuests >= 1,
      ),
      RewardBadge(
        id: 'streak_3',
        title: 'Streak Keeper',
        description: 'Keep a 3-day completion streak.',
        iconKey: 'local_fire_department',
        unlocked: user.streak >= 3,
        accentHex: '0xFFFF8A3D',
      ),
      RewardBadge(
        id: 'boss_slayer',
        title: 'Boss Slayer',
        description: 'Defeat your first boss battle.',
        iconKey: 'sports_martial_arts',
        unlocked: defeatedBosses >= 1,
        accentHex: '0xFFFF5D73',
      ),
      RewardBadge(
        id: 'focus_knight',
        title: 'Focus Knight',
        description: 'Finish 3 focus sessions.',
        iconKey: 'timer',
        unlocked: focusSessions >= 3,
        accentHex: '0xFF5FD5F5',
      ),
      RewardBadge(
        id: 'coin_collector',
        title: 'Coin Collector',
        description: 'Reach 100 coins.',
        iconKey: 'paid',
        unlocked: user.coins >= 100,
        accentHex: '0xFFFFD166',
      ),
      RewardBadge(
        id: 'scholar_rank',
        title: 'Scholar Captain',
        description: 'Reach level 5.',
        iconKey: 'school',
        unlocked: user.level >= 5,
        accentHex: '0xFFA78BFA',
      ),
    ];

    return catalog.map((badge) {
      final unlockedExisting = unlockedMap[badge.id];
      if (badge.unlocked && unlockedExisting != null) {
        return badge.copyWith(unlockedAt: unlockedExisting.unlockedAt);
      }
      if (badge.unlocked && unlockedExisting == null) {
        return badge.copyWith(unlockedAt: DateTime.now());
      }
      return badge;
    }).toList();
  }
}
