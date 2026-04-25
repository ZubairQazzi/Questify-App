import 'package:flutter_test/flutter_test.dart';
import 'package:questify_app/backend/models/app_user.dart';
import 'package:questify_app/backend/models/boss_battle.dart';
import 'package:questify_app/backend/models/mission_step.dart';
import 'package:questify_app/backend/models/quest.dart';
import 'package:questify_app/backend/services/gamification_service.dart';

void main() {
  test('level calculation matches XP thresholds', () {
    expect(GamificationService.calculateLevel(0), 1);
    expect(GamificationService.calculateLevel(120), 2);
    expect(GamificationService.calculateLevel(320), 4);
  });

  test('rewards unlock from completed quests and streaks', () {
    final user = AppUser(
      id: 'u1',
      name: 'Student',
      email: 'student@example.com',
      level: 4,
      xp: 320,
      coins: 150,
      streak: 4,
      lastActiveDate: DateTime.now(),
    );
    final quests = <Quest>[
      Quest(
        id: 'q1',
        title: 'Quest',
        subject: 'HCI',
        difficulty: QuestDifficulty.easy,
        deadline: DateTime.now(),
        status: QuestStatus.completed,
        xpReward: 20,
        coinReward: 5,
        questType: QuestType.assignment,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        estimatedMinutes: 20,
        focusSessionsCompleted: 3,
      ),
    ];
    final bosses = <BossBattle>[
      BossBattle(
        id: 'b1',
        title: 'Boss',
        linkedQuestId: 'q1',
        deadline: DateTime.now(),
        missions: const <MissionStep>[
          MissionStep(id: 'm1', title: 'Part 1', isCompleted: true),
        ],
        status: BossBattleStatus.defeated,
        createdAt: DateTime.now(),
      ),
    ];

    final rewards = GamificationService.refreshRewards(
      user: user,
      quests: quests,
      bossBattles: bosses,
    );

    expect(
      rewards.where((reward) => reward.unlocked).length,
      greaterThanOrEqualTo(4),
    );
  });
}
