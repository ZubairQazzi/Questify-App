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
  bool _persistInFlight = false;
  bool _persistQueued = false;
  bool _persistQueuedNeedsNotificationSync = false;
  AppUser? _user;
  UserSettings _settings = UserSettings.defaults();
  List<Quest> _quests = <Quest>[];
  List<BossBattle> _bossBattles = <BossBattle>[];
  List<RewardBadge> _rewards = <RewardBadge>[];

  Timer? _focusTimer;
  String? _activeFocusQuestId;
  int _focusRemainingSeconds = 0;
  int _focusTotalSeconds = 0;
  bool _isFocusTimerRunning = false;
  DateTime _currentTime = DateTime.now();

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
  bool get isFocusTimerRunning => _isFocusTimerRunning;
  DateTime get currentTime => _currentTime;

  double get levelProgress =>
      _user == null ? 0 : GamificationService.progressToNextLevel(_user!.xp);

  List<Quest> get activeQuests =>
      _quests
          .where(
            (quest) =>
                quest.status == QuestStatus.pending ||
                quest.status == QuestStatus.inProgress,
          )
          .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<Quest> get completedQuests =>
      _quests.where((quest) => quest.status == QuestStatus.completed).toList()
        ..sort(
          (a, b) => (b.completedAt ?? b.createdAt).compareTo(
            a.completedAt ?? a.createdAt,
          ),
        );

  List<Quest> get historyQuests =>
      _quests
          .where(
            (quest) =>
                quest.status == QuestStatus.completed ||
                quest.status == QuestStatus.overdue,
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.status == QuestStatus.completed
              ? (a.completedAt ?? a.createdAt)
              : a.deadline;
          final bDate = b.status == QuestStatus.completed
              ? (b.completedAt ?? b.createdAt)
              : b.deadline;
          return bDate.compareTo(aDate);
        });

  List<BossBattle> get activeBossBattles =>
      _bossBattles
          .where((battle) => battle.status == BossBattleStatus.active)
          .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<BossBattle> get missedBossBattles =>
      _bossBattles
          .where((battle) => battle.status == BossBattleStatus.overdue)
          .toList()
        ..sort((a, b) => b.deadline.compareTo(a.deadline));

  List<RewardBadge> get unlockedRewards =>
      _rewards.where((reward) => reward.unlocked).toList();

  Quest? get urgentQuest {
    final now = DateTime.now();
    final pending =
        activeQuests.where((quest) => quest.deadline.isAfter(now)).toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return pending.firstOrNull;
  }

  Quest? get currentQuest => urgentQuest ?? activeQuests.firstOrNull;

  String get rankTitle {
    if (_user == null) {
      return 'Fresh Adventurer';
    }
    return GamificationService.rankTitleForLevel(_user!.level);
  }

  int get completedTodayCount {
    final today = _currentTime;
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

  int get completedQuestCount => completedQuests.length;

  int get remainingQuestCount => _quests
      .where(
        (quest) =>
            quest.status == QuestStatus.pending ||
            quest.status == QuestStatus.inProgress,
      )
      .length;

  int get missedQuestCount =>
      _quests.where((quest) => quest.status == QuestStatus.overdue).length;

  int get totalFocusSessionsCount => _quests.fold<int>(
    0,
    (count, quest) => count + quest.focusSessionsCompleted,
  );

  int get defeatedBossesCount => _bossBattles
      .where((battle) => battle.status == BossBattleStatus.defeated)
      .length;

  List<Quest> get todayQuests => activeQuests
      .where((quest) => _isSameDay(quest.deadline, _currentTime))
      .toList()
    ..sort(_questSort);

  Future<void> bootstrap() async {
    _currentTime = DateTime.now();
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
          await refreshTimeSensitiveState(persistIfChanged: true);
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
    notifyListeners();

    if (_user == null) {
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
      notifyListeners();
      unawaited(_runPostAuthenticationSync());

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
      notifyListeners();
      unawaited(_runPostAuthenticationSync());

      return null;
    } on BackendException catch (error) {
      return error.message;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      await _firebaseRepository.sendPasswordResetEmail(email: email);
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
    _focusTimer = null;
    _isFocusTimerRunning = false;
    _activeFocusQuestId = null;
    _focusRemainingSeconds = 0;
    _focusTotalSeconds = 0;
    _currentTime = DateTime.now();

    await _firebaseRepository.signOut();

    _user = null;
    _quests = <Quest>[];
    _bossBattles = <BossBattle>[];
    _rewards = <RewardBadge>[];

    notifyListeners();
  }

  Future<void> refreshTimeSensitiveState({
    bool persistIfChanged = false,
  }) async {
    _currentTime = DateTime.now();
    if (_user == null) {
      notifyListeners();
      return;
    }

    final before = _stateSignature();
    _reconcileCollections();
    final changed = before != _stateSignature();

    notifyListeners();

    if (changed && persistIfChanged) {
      await _persistAll();
    }
  }

  Future<String?> saveQuest(Quest quest) async {
    _isSaving = true;
    notifyListeners();

    try {
      _currentTime = DateTime.now();
      final normalizedQuest = _normalizeQuest(quest, _currentTime);
      final existingIndex = _quests.indexWhere(
        (item) => item.id == normalizedQuest.id,
      );

      if (existingIndex == -1) {
        _quests = <Quest>[..._quests, normalizedQuest];
      } else {
        final updated = [..._quests];
        updated[existingIndex] = normalizedQuest;
        _quests = updated;
      }

      if (normalizedQuest.bossBattleMode && normalizedQuest.steps.isNotEmpty) {
        final boss = BossBattle(
          id: 'boss_${normalizedQuest.id}',
          title: 'Boss Battle: ${normalizedQuest.title}',
          linkedQuestId: normalizedQuest.id,
          deadline: normalizedQuest.deadline,
          missions: normalizedQuest.steps,
          status: _bossStatusFromQuest(normalizedQuest),
          createdAt: normalizedQuest.createdAt,
        );

        final existingBossIndex = _bossBattles.indexWhere(
          (item) => item.linkedQuestId == normalizedQuest.id,
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
            .where((battle) => battle.linkedQuestId != normalizedQuest.id)
            .toList();
      }

      _reconcileCollections();
      _schedulePersist();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> deleteQuest(String questId) async {
    _isSaving = true;
    notifyListeners();

    try {
      _currentTime = DateTime.now();
      _quests = _quests.where((quest) => quest.id != questId).toList();
      _bossBattles = _bossBattles
          .where((battle) => battle.linkedQuestId != questId)
          .toList();

      if (_activeFocusQuestId == questId) {
        resetFocusTimer();
      }

      _reconcileCollections();
      _schedulePersist();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> completeQuest({
    required String questId,
    required String reflection,
  }) async {
    _currentTime = DateTime.now();
    final quest = _quests.where((item) => item.id == questId).firstOrNull;

    if (quest == null) {
      return 'Quest not found.';
    }

    if (quest.isCompleted) {
      return 'This quest is already complete.';
    }

    if (_hasPassedDeadline(quest.deadline, _currentTime)) {
      _markQuestAsMissed(questId);
      _reconcileCollections();
      notifyListeners();
      _schedulePersist();
      return 'Deadline passed. This quest is now marked missed.';
    }

    if (quest.steps.isNotEmpty &&
        quest.steps.any((step) => !step.isCompleted)) {
      return 'Complete each mission step first. Unchecked steps stay incomplete.';
    }

    if (_activeFocusQuestId == questId) {
      resetFocusTimer();
    }

    final updatedQuest = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
      reflection: reflection,
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
      lastActiveDate: _currentTime,
    );

    _reconcileCollections();
    notifyListeners();
    _schedulePersist();

    return 'Quest complete. +${quest.xpReward} XP and +${quest.coinReward} coins earned.';
  }

  Future<String?> toggleBossMission({
    required String bossBattleId,
    required String missionId,
    required bool completed,
  }) async {
    _currentTime = DateTime.now();
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
    final anyCompleted = updatedMissions.any((mission) => mission.isCompleted);
    final deadlinePassed = _hasPassedDeadline(battle.deadline, _currentTime);

    final updatedBattle = battle.copyWith(
      missions: updatedMissions,
      status: deadlinePassed
          ? BossBattleStatus.overdue
          : allCompleted
          ? BossBattleStatus.defeated
          : BossBattleStatus.active,
    );

    _bossBattles = _bossBattles
        .map((item) => item.id == bossBattleId ? updatedBattle : item)
        .toList();

    _quests = _quests.map((quest) {
      if (quest.id != battle.linkedQuestId) {
        return quest;
      }

      final status = deadlinePassed
          ? QuestStatus.overdue
          : allCompleted
          ? QuestStatus.completed
          : anyCompleted
          ? QuestStatus.inProgress
          : QuestStatus.pending;

      return quest.copyWith(
        steps: updatedMissions,
        status: status,
        completedAt: !deadlinePassed && allCompleted ? _currentTime : null,
        reflection:
            !deadlinePassed && allCompleted ? 'Difficult' : quest.reflection,
      );
    }).toList();

    final linkedQuest = _quests
        .where((quest) => quest.id == battle.linkedQuestId)
        .firstOrNull;

    if (!deadlinePassed && allCompleted && linkedQuest != null && !questWasCompleted) {
      _user = _user?.copyWith(
        xp: (_user?.xp ?? 0) + linkedQuest.xpReward,
        coins:
            (_user?.coins ?? 0) +
            linkedQuest.coinReward +
            updatedBattle.rewardBonus,
        lastActiveDate: _currentTime,
      );
    }

    _reconcileCollections();
    notifyListeners();
    _schedulePersist();

    if (allCompleted) {
      if (deadlinePassed) {
        return 'Deadline passed. This boss battle stays marked missed.';
      }
      return 'Boss defeated. You earned the quest rewards and a bonus chest.';
    }

    if (deadlinePassed) {
      return 'Deadline passed. This boss battle is marked missed.';
    }

    return null;
  }

  Future<String?> toggleQuestStep({
    required String questId,
    required String stepId,
    required bool completed,
  }) async {
    _currentTime = DateTime.now();
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
    final deadlinePassed = _hasPassedDeadline(quest.deadline, _currentTime);

    final linkedBattle = _bossBattles
        .where((battle) => battle.linkedQuestId == questId)
        .firstOrNull;

    _quests = _quests.map((item) {
      if (item.id != questId) {
        return item;
      }

      return item.copyWith(
        steps: updatedSteps,
        status: deadlinePassed
            ? QuestStatus.overdue
            : allCompleted
            ? QuestStatus.completed
            : anyCompleted
            ? QuestStatus.inProgress
            : QuestStatus.pending,
        completedAt: !deadlinePassed && allCompleted ? _currentTime : null,
      );
    }).toList();

    if (linkedBattle != null) {
      final updatedBattle = linkedBattle.copyWith(
        missions: updatedSteps,
        status: deadlinePassed
            ? BossBattleStatus.overdue
            : allCompleted
            ? BossBattleStatus.defeated
            : BossBattleStatus.active,
      );

      _bossBattles = _bossBattles
          .map(
            (battle) => battle.id == linkedBattle.id ? updatedBattle : battle,
          )
          .toList();
    }

    if (!deadlinePassed && allCompleted) {
      if (_activeFocusQuestId == questId) {
        resetFocusTimer();
      }

      _user = _user?.copyWith(
        xp: (_user?.xp ?? 0) + quest.xpReward,
        coins:
            (_user?.coins ?? 0) +
            quest.coinReward +
            (linkedBattle?.rewardBonus ?? 0),
        lastActiveDate: _currentTime,
      );
    }

    _reconcileCollections();
    notifyListeners();
    _schedulePersist();

    if (allCompleted) {
      if (deadlinePassed) {
        return 'Deadline passed. This quest stays marked missed.';
      }
      return linkedBattle != null
          ? 'Boss defeated. You earned the quest rewards and a bonus chest.'
          : 'All mission steps complete.';
    }

    if (deadlinePassed) {
      return 'Deadline passed. This quest is marked missed.';
    }

    return null;
  }

  Future<String?> updateSettings(UserSettings updatedSettings) async {
    _settings = updatedSettings;
    notifyListeners();
    _schedulePersist();
    return null;
  }

  Future<void> startFocusTimer(String questId) async {
    _currentTime = DateTime.now();
    final quest = _quests.where((item) => item.id == questId).firstOrNull;

    if (quest == null) {
      return;
    }

    if (_hasPassedDeadline(quest.deadline, _currentTime)) {
      _markQuestAsMissed(questId);
      _reconcileCollections();
      notifyListeners();
      _schedulePersist();
      return;
    }

    if (_isFocusTimerRunning) {
      return;
    }

    final isResumingSameQuest =
        _activeFocusQuestId == questId &&
        _focusRemainingSeconds > 0 &&
        _focusTotalSeconds > 0;

    _activeFocusQuestId = questId;

    if (!isResumingSameQuest) {
      _focusTotalSeconds = _settings.focusDurationMinutes * 60;
      _focusRemainingSeconds = _focusTotalSeconds;
    }

    _isFocusTimerRunning = true;

    _quests = _quests.map((item) {
      if (item.id == questId && item.status == QuestStatus.pending) {
        return item.copyWith(status: QuestStatus.inProgress);
      }

      return item;
    }).toList();

    notifyListeners();

    _focusTimer?.cancel();

    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isFocusTimerRunning) {
        timer.cancel();
        return;
      }

      if (_focusRemainingSeconds <= 1) {
        timer.cancel();
        _focusTimer = null;
        _isFocusTimerRunning = false;
        _focusRemainingSeconds = 0;
        notifyListeners();

        unawaited(_completeFocusSession(questId));
        return;
      }

      _focusRemainingSeconds -= 1;
      notifyListeners();
    });

    unawaited(_persistAll(rescheduleNotifications: false));
  }

  void pauseFocusTimer() {
    _focusTimer?.cancel();
    _focusTimer = null;
    _isFocusTimerRunning = false;

    notifyListeners();
  }

  void resetFocusTimer() {
    _focusTimer?.cancel();
    _focusTimer = null;
    _isFocusTimerRunning = false;
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
    _focusTimer = null;
    _isFocusTimerRunning = false;
    super.dispose();
  }

  void _applySnapshot(AppSnapshot snapshot) {
    _currentTime = DateTime.now();
    _user = snapshot.user;
    _settings = snapshot.settings;
    _quests = [...snapshot.quests];
    _bossBattles = [...snapshot.bossBattles];
    _rewards = [...snapshot.rewards];
    _reconcileCollections(rewardSeed: snapshot.rewards);
  }

  Future<void> _persistAll({bool rescheduleNotifications = true}) async {
    if (_user == null) {
      return;
    }

    final previousUnlocked = unlockedRewards.map((reward) => reward.id).toSet();
    _currentTime = DateTime.now();
    _reconcileCollections();

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

  void _schedulePersist({bool rescheduleNotifications = true}) {
    if (_user == null) {
      return;
    }

    _persistQueued = true;
    _persistQueuedNeedsNotificationSync =
        _persistQueuedNeedsNotificationSync || rescheduleNotifications;

    if (_persistInFlight) {
      return;
    }

    unawaited(_drainPersistQueue());
  }

  Future<void> _drainPersistQueue() async {
    _persistInFlight = true;

    while (_persistQueued) {
      final shouldReschedule = _persistQueuedNeedsNotificationSync;
      _persistQueued = false;
      _persistQueuedNeedsNotificationSync = false;

      try {
        await _persistAll(rescheduleNotifications: shouldReschedule);
      } on BackendException catch (error, stackTrace) {
        debugPrint('Questify background sync failed: ${error.message}');
        debugPrintStack(stackTrace: stackTrace);
      } catch (error, stackTrace) {
        debugPrint('Questify background sync failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    _persistInFlight = false;
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

  Future<void> _runPostAuthenticationSync() async {
    try {
      await refreshTimeSensitiveState(persistIfChanged: true);
      await _notificationService.syncReminders(
        settings: _settings,
        quests: _quests,
      );
    } on BackendException catch (error, stackTrace) {
      debugPrint('Questify post-login sync failed: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('Questify post-login sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
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
    if (_isQuestCompletedOnTime(quest)) {
      return BossBattleStatus.defeated;
    }

    if (_hasPassedDeadline(quest.deadline, _currentTime)) {
      return BossBattleStatus.overdue;
    }

    return BossBattleStatus.active;
  }

  void _reconcileCollections({List<RewardBadge>? rewardSeed}) {
    if (_user == null) {
      return;
    }

    final normalizedQuests = _quests
        .map((quest) => _normalizeQuest(quest, _currentTime))
        .toList();
    final questById = {for (final quest in normalizedQuests) quest.id: quest};
    final normalizedBosses = _bossBattles
        .map(
          (battle) => _normalizeBossBattle(
            battle,
            questById[battle.linkedQuestId],
            _currentTime,
          ),
        )
        .toList();

    normalizedQuests.sort(_questSort);
    normalizedBosses.sort(_bossSort);

    _quests = normalizedQuests;
    _bossBattles = normalizedBosses;
    _user = GamificationService.normalizeUser(_user!, _quests);
    _rewards = GamificationService.refreshRewards(
      user: _user!,
      quests: _quests,
      bossBattles: _bossBattles,
      existing: rewardSeed ?? _rewards,
    );
  }

  Quest _normalizeQuest(Quest quest, DateTime now) {
    final anyStepsComplete = quest.steps.any((step) => step.isCompleted);
    final completedOnTime = _isQuestCompletedOnTime(quest);
    final deadlinePassed = _hasPassedDeadline(quest.deadline, now);

    QuestStatus status;
    if (completedOnTime) {
      status = QuestStatus.completed;
    } else if (deadlinePassed) {
      status = QuestStatus.overdue;
    } else if (quest.steps.isNotEmpty) {
      status = anyStepsComplete ? QuestStatus.inProgress : QuestStatus.pending;
    } else if (quest.status == QuestStatus.inProgress ||
        quest.focusSessionsCompleted > 0) {
      status = QuestStatus.inProgress;
    } else {
      status = QuestStatus.pending;
    }

    return quest.copyWith(
      status: status,
      completedAt: completedOnTime ? quest.completedAt : null,
    );
  }

  BossBattle _normalizeBossBattle(
    BossBattle battle,
    Quest? linkedQuest,
    DateTime now,
  ) {
    final normalizedMissions =
        linkedQuest?.steps.isNotEmpty == true
        ? linkedQuest!.steps
        : battle.missions;
    final deadlinePassed = _hasPassedDeadline(battle.deadline, now);
    final allMissionsComplete = normalizedMissions.isNotEmpty &&
        normalizedMissions.every((mission) => mission.isCompleted);

    final status = linkedQuest?.status == QuestStatus.completed
        ? BossBattleStatus.defeated
        : deadlinePassed
        ? BossBattleStatus.overdue
        : allMissionsComplete
        ? BossBattleStatus.defeated
        : BossBattleStatus.active;

    return battle.copyWith(
      missions: normalizedMissions,
      status: status,
      deadline: linkedQuest?.deadline ?? battle.deadline,
      title: linkedQuest == null
          ? battle.title
          : 'Boss Battle: ${linkedQuest.title}',
    );
  }

  bool _isQuestCompletedOnTime(Quest quest) {
    final completedAt = quest.completedAt;
    if (completedAt == null) {
      return false;
    }
    return !completedAt.isAfter(quest.deadline);
  }

  bool _hasPassedDeadline(DateTime deadline, DateTime now) {
    return deadline.isBefore(now);
  }

  void _markQuestAsMissed(String questId) {
    _quests = _quests.map((quest) {
      if (quest.id != questId) {
        return quest;
      }
      return quest.copyWith(
        status: QuestStatus.overdue,
        completedAt: null,
      );
    }).toList();

    _bossBattles = _bossBattles.map((battle) {
      if (battle.linkedQuestId != questId) {
        return battle;
      }
      return battle.copyWith(status: BossBattleStatus.overdue);
    }).toList();
  }

  String _stateSignature() {
    return [
      _user?.toMap().toString() ?? 'no-user',
      _quests.map((quest) => quest.toMap().toString()).join('|'),
      _bossBattles.map((battle) => battle.toMap().toString()).join('|'),
      _rewards.map((reward) => reward.toMap().toString()).join('|'),
    ].join('::');
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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

    if (a.status == BossBattleStatus.overdue &&
        b.status == BossBattleStatus.defeated) {
      return -1;
    }

    if (a.status == BossBattleStatus.defeated &&
        b.status == BossBattleStatus.overdue) {
      return 1;
    }

    return a.deadline.compareTo(b.deadline);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
