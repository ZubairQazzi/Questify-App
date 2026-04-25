import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../backend/data/firebase_repository.dart';
import '../../backend/data/questify_repository.dart';
import '../../backend/models/app_snapshot.dart';
import '../../backend/models/app_user.dart';
import '../../backend/models/boss_battle.dart';
import '../../backend/models/mission_step.dart';
import '../../backend/models/quest.dart';
import '../../backend/models/reward_badge.dart';
import '../../backend/models/user_settings.dart';
import '../../backend/services/gamification_service.dart';
import '../../backend/services/notification_service.dart';

class QuestifyController extends ChangeNotifier {
  QuestifyController({
    FirebaseRepository? firebaseRepository,
    NotificationService? notificationService,
    Uuid? uuid,
  }) : _firebaseRepository = firebaseRepository ?? FirebaseRepository(),
       _notificationService =
           notificationService ?? NotificationService.instance,
       _uuid = uuid ?? const Uuid();

  static const _onboardingCompleteKey = 'questify_onboarding_complete';
  static const _themePreferenceKey = 'questify_theme_preference';

  final FirebaseRepository _firebaseRepository;
  final NotificationService _notificationService;
  final Uuid _uuid;

  bool _initialized = false;
  bool _onboardingComplete = false;
  bool _isAuthenticating = false;
  bool _isSaving = false;
  bool _firebaseConfigured = false;
  AppUser? _user;
  UserSettings _settings = UserSettings.defaults();
  List<Quest> _quests = <Quest>[];
  List<BossBattle> _bossBattles = <BossBattle>[];
  List<RewardBadge> _rewards = <RewardBadge>[];

  Timer? _focusTimer;
  String? _activeFocusQuestId;
  int _focusRemainingSeconds = 0;
  int _focusTotalSeconds = 0;

  bool get initialized => _initialized;
  bool get onboardingComplete => _onboardingComplete;
  bool get isAuthenticating => _isAuthenticating;
  bool get isSaving => _isSaving;
  bool get isSignedIn => _user != null;
  bool get firebaseConfigured => _firebaseConfigured;
  AppUser? get user => _user;
  UserSettings get settings => _settings;
  List<Quest> get quests => List<Quest>.unmodifiable(_quests);
  List<BossBattle> get bossBattles =>
      List<BossBattle>.unmodifiable(_bossBattles);
  List<RewardBadge> get rewards => List<RewardBadge>.unmodifiable(_rewards);
  String? get activeFocusQuestId => _activeFocusQuestId;
  int get focusRemainingSeconds => _focusRemainingSeconds;
  int get focusTotalSeconds => _focusTotalSeconds;
  double get levelProgress =>
      _user == null ? 0 : GamificationService.progressToNextLevel(_user!.xp);

  List<Quest> get activeQuests =>
      _quests.where((quest) => quest.status != QuestStatus.completed).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<Quest> get completedQuests =>
      _quests.where((quest) => quest.status == QuestStatus.completed).toList()
        ..sort(
          (a, b) => (b.completedAt ?? b.createdAt).compareTo(
            a.completedAt ?? a.createdAt,
          ),
        );

  List<BossBattle> get activeBossBattles =>
      _bossBattles
          .where((battle) => battle.status == BossBattleStatus.active)
          .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<RewardBadge> get unlockedRewards =>
      _rewards.where((reward) => reward.unlocked).toList();

  Quest? get urgentQuest {
    final now = DateTime.now();
    final pending =
        activeQuests.where((quest) => quest.deadline.isAfter(now)).toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return pending.firstOrNull;
  }

  String get rankTitle {
    if (_user == null) {
      return 'Fresh Adventurer';
    }
    return GamificationService.rankTitleForLevel(_user!.level);
  }

  int get completedTodayCount {
    final today = DateTime.now();
    return completedQuests.where((quest) {
      final completedAt = quest.completedAt;
      if (completedAt == null) {
        return false;
      }
      return completedAt.year == today.year &&
          completedAt.month == today.month &&
          completedAt.day == today.day;
    }).length;
  }

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _firebaseConfigured = await _firebaseRepository.isAvailable();
    _onboardingComplete = prefs.getBool(_onboardingCompleteKey) ?? false;
    _settings = _settings.copyWith(
      themePreference: ThemePreferenceX.fromLabel(
        prefs.getString(_themePreferenceKey),
      ),
    );

    await _notificationService.initialize();

    if (_firebaseConfigured) {
      try {
        final snapshot = await _firebaseRepository.restoreSession();
        if (snapshot != null) {
          _applySnapshot(snapshot);
          await _notificationService.syncReminders(
            settings: _settings,
            quests: _quests,
          );
        }
      } on BackendException {
        // Leave the user at the auth screen if session restore fails.
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    _onboardingComplete = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _settings = _settings.copyWith(themePreference: preference);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, preference.label);

    if (_user == null) {
      notifyListeners();
      return;
    }

    await _persistAll();
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();
    try {
      final snapshot = await _firebaseRepository.signIn(
        email: email,
        password: password,
      );
      _applySnapshot(snapshot);
      await _notificationService.syncReminders(
        settings: _settings,
        quests: _quests,
      );
      return null;
    } on BackendException catch (error) {
      return error.message;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isAuthenticating = true;
    notifyListeners();
    try {
      final snapshot = await _firebaseRepository.register(
        name: name,
        email: email,
        password: password,
      );
      _applySnapshot(snapshot);
      await _notificationService.syncReminders(
        settings: _settings,
        quests: _quests,
      );
      return null;
    } on BackendException catch (error) {
      return error.message;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _focusTimer?.cancel();
    _activeFocusQuestId = null;
    await _firebaseRepository.signOut();
    _user = null;
    _quests = <Quest>[];
    _bossBattles = <BossBattle>[];
    _rewards = <RewardBadge>[];
    notifyListeners();
  }

  Future<String?> saveQuest(Quest quest) async {
    _isSaving = true;
    notifyListeners();
    try {
      final existingIndex = _quests.indexWhere((item) => item.id == quest.id);
      if (existingIndex == -1) {
        _quests = <Quest>[..._quests, quest];
      } else {
        final updated = [..._quests];
        updated[existingIndex] = quest;
        _quests = updated;
      }

      if (quest.bossBattleMode && quest.steps.isNotEmpty) {
        final boss = BossBattle(
          id: 'boss_${quest.id}',
          title: 'Boss Battle: ${quest.title}',
          linkedQuestId: quest.id,
          deadline: quest.deadline,
          missions: quest.steps,
          status: _bossStatusFromQuest(quest),
          createdAt: quest.createdAt,
        );
        final existingBossIndex = _bossBattles.indexWhere(
          (item) => item.linkedQuestId == quest.id,
        );
        if (existingBossIndex == -1) {
          _bossBattles = <BossBattle>[..._bossBattles, boss];
        } else {
          final updatedBattles = [..._bossBattles];
          updatedBattles[existingBossIndex] = boss;
          _bossBattles = updatedBattles;
        }
      } else {
        _bossBattles = _bossBattles
            .where((battle) => battle.linkedQuestId != quest.id)
            .toList();
      }

      await _persistAll();
      return null;
    } on BackendException catch (error) {
      return error.message;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> deleteQuest(String questId) async {
    _isSaving = true;
    notifyListeners();
    try {
      _quests = _quests.where((quest) => quest.id != questId).toList();
      _bossBattles = _bossBattles
          .where((battle) => battle.linkedQuestId != questId)
          .toList();
      await _persistAll();
      return null;
    } on BackendException catch (error) {
      return error.message;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> completeQuest({
    required String questId,
    required String reflection,
  }) async {
    final quest = _quests.where((item) => item.id == questId).firstOrNull;
    if (quest == null) {
      return 'Quest not found.';
    }
    if (quest.isCompleted) {
      return 'This quest is already complete.';
    }

    final updatedQuest = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
      reflection: reflection,
      steps: quest.steps
          .map(
            (step) => step.copyWith(
              isCompleted: true,
              completedAt: step.completedAt ?? DateTime.now(),
            ),
          )
          .toList(),
    );

    _quests = _quests
        .map((item) => item.id == questId ? updatedQuest : item)
        .toList();
    _bossBattles = _bossBattles.map((battle) {
      if (battle.linkedQuestId != questId) {
        return battle;
      }
      return battle.copyWith(
        missions: battle.missions
            .map(
              (mission) => mission.copyWith(
                isCompleted: true,
                completedAt: mission.completedAt ?? DateTime.now(),
              ),
            )
            .toList(),
        status: BossBattleStatus.defeated,
      );
    }).toList();

    _user = _user?.copyWith(
      xp: (_user?.xp ?? 0) + quest.xpReward,
      coins: (_user?.coins ?? 0) + quest.coinReward,
      lastActiveDate: DateTime.now(),
    );

    await _persistAll();
    return 'Quest complete. +${quest.xpReward} XP and +${quest.coinReward} coins earned.';
  }

  Future<String?> toggleBossMission({
    required String bossBattleId,
    required String missionId,
    required bool completed,
  }) async {
    final battle = _bossBattles
        .where((item) => item.id == bossBattleId)
        .firstOrNull;
    if (battle == null) {
      return 'Boss battle not found.';
    }
    final linkedQuestBeforeUpdate = _quests
        .where((quest) => quest.id == battle.linkedQuestId)
        .firstOrNull;
    final questWasCompleted = linkedQuestBeforeUpdate?.isCompleted ?? false;

    final updatedMissions = battle.missions.map((mission) {
      if (mission.id != missionId) {
        return mission;
      }
      return mission.copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
      );
    }).toList();

    final allCompleted = updatedMissions.every(
      (mission) => mission.isCompleted,
    );
    final updatedBattle = battle.copyWith(
      missions: updatedMissions,
      status: allCompleted
          ? BossBattleStatus.defeated
          : battle.deadline.isBefore(DateTime.now())
          ? BossBattleStatus.overdue
          : BossBattleStatus.active,
    );

    _bossBattles = _bossBattles
        .map((item) => item.id == bossBattleId ? updatedBattle : item)
        .toList();

    _quests = _quests.map((quest) {
      if (quest.id != battle.linkedQuestId) {
        return quest;
      }
      final status = allCompleted
          ? QuestStatus.completed
          : QuestStatus.inProgress;
      return quest.copyWith(
        steps: updatedMissions,
        status: status,
        completedAt: allCompleted ? DateTime.now() : quest.completedAt,
        reflection: allCompleted ? 'Difficult' : quest.reflection,
      );
    }).toList();

    final linkedQuest = _quests
        .where((quest) => quest.id == battle.linkedQuestId)
        .firstOrNull;
    if (allCompleted && linkedQuest != null && !questWasCompleted) {
      _user = _user?.copyWith(
        xp: (_user?.xp ?? 0) + linkedQuest.xpReward,
        coins:
            (_user?.coins ?? 0) +
            linkedQuest.coinReward +
            updatedBattle.rewardBonus,
        lastActiveDate: DateTime.now(),
      );
    }

    await _persistAll();
    if (allCompleted) {
      return 'Boss defeated. You earned the quest rewards and a bonus chest.';
    }
    return null;
  }

  Future<String?> toggleQuestStep({
    required String questId,
    required String stepId,
    required bool completed,
  }) async {
    final quest = _quests.where((item) => item.id == questId).firstOrNull;
    if (quest == null) {
      return 'Quest not found.';
    }
    if (quest.isCompleted) {
      return 'This quest is already complete.';
    }

    final updatedSteps = quest.steps.map((step) {
      if (step.id != stepId) {
        return step;
      }
      return step.copyWith(
        isCompleted: completed,
        completedAt: completed ? DateTime.now() : null,
      );
    }).toList();

    final anyCompleted = updatedSteps.any((step) => step.isCompleted);
    final allCompleted =
        updatedSteps.isNotEmpty &&
        updatedSteps.every((step) => step.isCompleted);
    final linkedBattle = _bossBattles
        .where((battle) => battle.linkedQuestId == questId)
        .firstOrNull;

    _quests = _quests.map((item) {
      if (item.id != questId) {
        return item;
      }
      return item.copyWith(
        steps: updatedSteps,
        status: allCompleted
            ? QuestStatus.completed
            : anyCompleted
            ? QuestStatus.inProgress
            : QuestStatus.pending,
        completedAt: allCompleted ? DateTime.now() : null,
      );
    }).toList();

    if (linkedBattle != null) {
      final updatedBattle = linkedBattle.copyWith(
        missions: updatedSteps,
        status: allCompleted
            ? BossBattleStatus.defeated
            : linkedBattle.deadline.isBefore(DateTime.now())
            ? BossBattleStatus.overdue
            : BossBattleStatus.active,
      );
      _bossBattles = _bossBattles
          .map(
            (battle) => battle.id == linkedBattle.id ? updatedBattle : battle,
          )
          .toList();
    }

    if (allCompleted) {
      _user = _user?.copyWith(
        xp: (_user?.xp ?? 0) + quest.xpReward,
        coins:
            (_user?.coins ?? 0) +
            quest.coinReward +
            (linkedBattle?.rewardBonus ?? 0),
        lastActiveDate: DateTime.now(),
      );
    }

    await _persistAll();
    if (allCompleted) {
      return linkedBattle != null
          ? 'Boss defeated. You earned the quest rewards and a bonus chest.'
          : 'All mission steps complete.';
    }
    return null;
  }

  Future<String?> updateSettings(UserSettings updatedSettings) async {
    _settings = updatedSettings;
    await _persistAll();
    return null;
  }

  Future<void> startFocusTimer(String questId) async {
    final quest = _quests.where((item) => item.id == questId).firstOrNull;
    if (quest == null) {
      return;
    }

    _focusTimer?.cancel();
    _activeFocusQuestId = questId;
    _focusTotalSeconds = _settings.focusDurationMinutes * 60;
    _focusRemainingSeconds = _focusTotalSeconds;
    _quests = _quests.map((item) {
      if (item.id == questId && item.status == QuestStatus.pending) {
        return item.copyWith(status: QuestStatus.inProgress);
      }
      return item;
    }).toList();
    await _persistAll(rescheduleNotifications: false);

    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_focusRemainingSeconds == 0) {
        timer.cancel();
        unawaited(_completeFocusSession(questId));
        return;
      }
      _focusRemainingSeconds -= 1;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseFocusTimer() {
    _focusTimer?.cancel();
    notifyListeners();
  }

  void resetFocusTimer() {
    _focusTimer?.cancel();
    _activeFocusQuestId = null;
    _focusRemainingSeconds = 0;
    _focusTotalSeconds = 0;
    notifyListeners();
  }

  String formatFocusTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Quest createQuestDraft({
    required String title,
    required String subject,
    required QuestDifficulty difficulty,
    required QuestType questType,
    required DateTime deadline,
    required int estimatedMinutes,
    required String note,
    required bool bossBattleMode,
    required List<String> steps,
    Quest? existing,
  }) {
    final now = DateTime.now();
    final mappedSteps = steps
        .where((item) => item.trim().isNotEmpty)
        .map((step) => MissionStep(id: _uuid.v4(), title: step.trim()))
        .toList();

    return Quest(
      id: existing?.id ?? _uuid.v4(),
      title: title,
      subject: subject,
      difficulty: difficulty,
      deadline: deadline,
      status: existing?.status ?? QuestStatus.pending,
      xpReward: GamificationService.xpRewardFor(difficulty),
      coinReward: GamificationService.coinRewardFor(difficulty),
      questType: questType,
      createdAt: existing?.createdAt ?? now,
      completedAt: existing?.completedAt,
      estimatedMinutes: estimatedMinutes,
      note: note.isEmpty ? null : note,
      steps: existing != null && existing.steps.isNotEmpty
          ? _mergeMissionProgress(existing.steps, mappedSteps)
          : mappedSteps,
      reflection: existing?.reflection,
      focusSessionsCompleted: existing?.focusSessionsCompleted ?? 0,
      bossBattleMode: bossBattleMode,
    );
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }

  void _applySnapshot(AppSnapshot snapshot) {
    _user = GamificationService.normalizeUser(snapshot.user, snapshot.quests);
    _settings = snapshot.settings;
    _quests = [...snapshot.quests]..sort(_questSort);
    _bossBattles = [...snapshot.bossBattles]..sort(_bossSort);
    _rewards = GamificationService.refreshRewards(
      user: _user!,
      quests: _quests,
      bossBattles: _bossBattles,
      existing: snapshot.rewards,
    );
  }

  Future<void> _persistAll({bool rescheduleNotifications = true}) async {
    if (_user == null) {
      return;
    }

    final previousUnlocked = unlockedRewards.map((reward) => reward.id).toSet();
    _user = GamificationService.normalizeUser(_user!, _quests);
    _rewards = GamificationService.refreshRewards(
      user: _user!,
      quests: _quests,
      bossBattles: _bossBattles,
      existing: _rewards,
    );
    _quests.sort(_questSort);
    _bossBattles.sort(_bossSort);

    await _firebaseRepository.persistSnapshot(
      AppSnapshot(
        user: _user!,
        settings: _settings,
        quests: _quests,
        bossBattles: _bossBattles,
        rewards: _rewards,
      ),
    );

    if (rescheduleNotifications) {
      await _notificationService.syncReminders(
        settings: _settings,
        quests: _quests,
      );
    }

    final newUnlock = unlockedRewards.firstWhere(
      (reward) => !previousUnlocked.contains(reward.id),
      orElse: () => const RewardBadge(
        id: '',
        title: '',
        description: '',
        iconKey: '',
        unlocked: false,
      ),
    );
    if (newUnlock.id.isNotEmpty) {
      await _notificationService.showRewardUnlocked(newUnlock);
    }

    notifyListeners();
  }

  Future<void> _completeFocusSession(String questId) async {
    final quest = _quests.where((item) => item.id == questId).firstOrNull;
    if (quest == null) {
      resetFocusTimer();
      return;
    }

    _quests = _quests.map((item) {
      if (item.id != questId) {
        return item;
      }
      return item.copyWith(
        focusSessionsCompleted: item.focusSessionsCompleted + 1,
        status: item.status == QuestStatus.pending
            ? QuestStatus.inProgress
            : item.status,
      );
    }).toList();

    await _notificationService.showFocusComplete(quest.title);
    resetFocusTimer();
    await _persistAll(rescheduleNotifications: false);
  }

  List<MissionStep> _mergeMissionProgress(
    List<MissionStep> existing,
    List<MissionStep> incoming,
  ) {
    return incoming.map((step) {
      final match = existing
          .where((item) => item.title == step.title)
          .firstOrNull;
      if (match == null) {
        return step;
      }
      return step.copyWith(
        isCompleted: match.isCompleted,
        completedAt: match.completedAt,
      );
    }).toList();
  }

  BossBattleStatus _bossStatusFromQuest(Quest quest) {
    if (quest.steps.isEmpty) {
      return BossBattleStatus.active;
    }
    final completedSteps = quest.steps.where((step) => step.isCompleted).length;
    if (completedSteps == quest.steps.length) {
      return BossBattleStatus.defeated;
    }
    if (quest.deadline.isBefore(DateTime.now())) {
      return BossBattleStatus.overdue;
    }
    return BossBattleStatus.active;
  }

  static int _questSort(Quest a, Quest b) {
    if (a.isCompleted && !b.isCompleted) {
      return 1;
    }
    if (!a.isCompleted && b.isCompleted) {
      return -1;
    }
    return a.deadline.compareTo(b.deadline);
  }

  static int _bossSort(BossBattle a, BossBattle b) {
    if (a.status == BossBattleStatus.active &&
        b.status != BossBattleStatus.active) {
      return -1;
    }
    if (a.status != BossBattleStatus.active &&
        b.status == BossBattleStatus.active) {
      return 1;
    }
    return a.deadline.compareTo(b.deadline);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
