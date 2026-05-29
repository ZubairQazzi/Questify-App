import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:questify_app/backend/data/firebase_repository.dart';
import 'package:questify_app/backend/models/app_snapshot.dart';
import 'package:questify_app/backend/models/app_user.dart';
import 'package:questify_app/backend/models/boss_battle.dart';
import 'package:questify_app/backend/models/mission_step.dart';
import 'package:questify_app/backend/models/quest.dart';
import 'package:questify_app/backend/models/user_settings.dart';
import 'package:questify_app/backend/services/gamification_service.dart';
import 'package:questify_app/frontend/controllers/questify_controller.dart';
import 'package:questify_app/frontend/screens/auth/auth_screen.dart';
import 'package:questify_app/frontend/screens/boss/boss_battles_screen.dart';
import 'package:questify_app/frontend/screens/dashboard/add_quest_screen.dart';
import 'package:questify_app/frontend/screens/dashboard/quest_detail_screen.dart';
import 'package:questify_app/frontend/screens/home_shell.dart';
import 'package:questify_app/frontend/screens/onboarding/onboarding_screen.dart';
import 'package:questify_app/frontend/screens/profile/history_screen.dart';
import 'package:questify_app/frontend/screens/profile/profile_screen.dart';
import 'package:questify_app/frontend/screens/profile/progress_map_screen.dart';
import 'package:questify_app/frontend/screens/rewards/rewards_screen.dart';
import 'package:questify_app/frontend/theme/questify_theme.dart';
import 'package:timezone/timezone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlutterLocalNotificationsPlatform.instance =
        _FakeAndroidNotificationsPlatform();
  });

  testWidgets('onboarding screen renders without layout exceptions', (
    tester,
  ) async {
    _setWideViewport(tester);
    final controller = QuestifyController(
      firebaseRepository: _FakeFirebaseRepository(_sampleSnapshot()),
    );

    await tester.pumpWidget(_appWrapper(controller, const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('QUESTIFY'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auth screen renders without layout exceptions', (tester) async {
    _setWideViewport(tester);
    final controller = QuestifyController(
      firebaseRepository: _FakeFirebaseRepository(_sampleSnapshot()),
    );

    await tester.pumpWidget(_appWrapper(controller, const AuthScreen()));
    await tester.pumpAndSettle();

    expect(find.text('WELCOME BACK'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home shell tabs render and switch cleanly', (tester) async {
    _setWideViewport(tester);
    final controller = await _createSignedInController();

    await tester.pumpWidget(_appWrapper(controller, const HomeShell()));
    await tester.pumpAndSettle();

    expect(find.text('Command Center'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.sports_martial_arts_rounded));
    await tester.pumpAndSettle();
    expect(find.text('BOSS BATTLES'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.workspace_premium_rounded));
    await tester.pumpAndSettle();
    expect(find.text('REWARD VAULT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail and utility screens render without runtime errors', (
    tester,
  ) async {
    _setWideViewport(tester);
    final controller = await _createSignedInController();

    final screens = <Widget>[
      const AddQuestScreen(),
      QuestDetailScreen(questId: 'quest_active'),
      const BossBattleDetailScreen(bossBattleId: 'boss_quest_active'),
      const ProgressMapScreen(),
      const HistoryScreen(),
      Scaffold(
        body: ProfileScreen(
          onOpenProgressMap: () {},
          onOpenHistory: () {},
          onSignOut: () {},
        ),
      ),
      Scaffold(body: RewardsScreen(onOpenProgressMap: () {})),
      Scaffold(body: BossBattlesScreen(onOpenBattle: (_) {})),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(_appWrapper(controller, screen));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Screen ${screen.runtimeType} threw during build/render.',
      );
    }

    await tester.pumpWidget(
      _appWrapper(controller, const Scaffold(body: HistoryScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('MISSED'), findsOneWidget);

    await tester.pumpWidget(
      _appWrapper(
        controller,
        Scaffold(body: BossBattlesScreen(onOpenBattle: (_) {})),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('MISSED'), findsWidgets);
  });

  testWidgets('quest completion responds immediately without locking the page', (
    tester,
  ) async {
    _setWideViewport(tester);
    final controller = await _createSignedInController();
    final quest = controller.createQuestDraft(
      title: 'Complete one tap quest',
      subject: 'HCI',
      difficulty: QuestDifficulty.medium,
      questType: QuestType.project,
      deadline: DateTime.now().add(const Duration(hours: 6)),
      estimatedMinutes: 25,
      note: 'Quick quest',
      bossBattleMode: false,
      steps: const <String>[],
    );
    final saveMessage = await controller.saveQuest(quest);
    expect(saveMessage, isNull);

    await tester.pumpWidget(
      _appWrapper(controller, QuestDetailScreen(questId: quest.id)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('COMPLETE QUEST & CLAIM REWARDS'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('QUEST ALREADY COMPLETE'), findsOneWidget);
    expect(find.textContaining('Quest complete.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

void _setWideViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1400, 1000);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget _appWrapper(QuestifyController controller, Widget child) {
  return ChangeNotifierProvider<QuestifyController>.value(
    value: controller,
    child: MaterialApp(
      theme: QuestifyTheme.lightTheme,
      darkTheme: QuestifyTheme.darkTheme,
      home: child,
    ),
  );
}

Future<QuestifyController> _createSignedInController() async {
  final controller = QuestifyController(
    firebaseRepository: _FakeFirebaseRepository(_sampleSnapshot()),
  );

  final message = await controller.signIn(
    email: 'zubair@example.com',
    password: 'password123',
  );

  expect(message, isNull);
  return controller;
}

AppSnapshot _sampleSnapshot() {
  final now = DateTime.now();
  final activeSteps = <MissionStep>[
    const MissionStep(id: 'step_1', title: 'Prototype'),
    const MissionStep(id: 'step_2', title: 'Complete project'),
  ];

  final activeQuest = Quest(
    id: 'quest_active',
    title: 'Prepare HCI presentation',
    subject: 'HCI',
    difficulty: QuestDifficulty.medium,
    deadline: now.add(const Duration(hours: 8)),
    status: QuestStatus.inProgress,
    xpReward: 40,
    coinReward: 12,
    questType: QuestType.project,
    createdAt: now.subtract(const Duration(days: 1)),
    estimatedMinutes: 120,
    note: 'Finish the slides and practice the demo.',
    steps: activeSteps,
    focusSessionsCompleted: 1,
    bossBattleMode: true,
  );

  final completedQuest = Quest(
    id: 'quest_done',
    title: 'Submit proposal draft',
    subject: 'Software Engineering',
    difficulty: QuestDifficulty.easy,
    deadline: now.subtract(const Duration(days: 1)),
    status: QuestStatus.completed,
    xpReward: 20,
    coinReward: 6,
    questType: QuestType.assignment,
    createdAt: now.subtract(const Duration(days: 3)),
    completedAt: now.subtract(const Duration(days: 2)),
    estimatedMinutes: 45,
    reflection: 'Felt manageable after splitting it up.',
    focusSessionsCompleted: 2,
  );

  final missedSteps = <MissionStep>[
    const MissionStep(id: 'step_m1', title: 'Research references'),
    const MissionStep(id: 'step_m2', title: 'Write report'),
  ];

  final missedQuest = Quest(
    id: 'quest_missed',
    title: 'Submit database reflection',
    subject: 'Database Systems',
    difficulty: QuestDifficulty.medium,
    deadline: now.subtract(const Duration(hours: 6)),
    status: QuestStatus.overdue,
    xpReward: 40,
    coinReward: 10,
    questType: QuestType.assignment,
    createdAt: now.subtract(const Duration(days: 2)),
    estimatedMinutes: 50,
    steps: missedSteps,
    bossBattleMode: true,
  );

  final bossBattle = BossBattle(
    id: 'boss_quest_active',
    title: 'Boss Battle: Prepare HCI presentation',
    linkedQuestId: 'quest_active',
    deadline: activeQuest.deadline,
    missions: activeSteps,
    status: BossBattleStatus.active,
    createdAt: activeQuest.createdAt,
  );

  final missedBossBattle = BossBattle(
    id: 'boss_quest_missed',
    title: 'Boss Battle: Submit database reflection',
    linkedQuestId: 'quest_missed',
    deadline: missedQuest.deadline,
    missions: missedSteps,
    status: BossBattleStatus.overdue,
    createdAt: missedQuest.createdAt,
  );

  final user = AppUser(
    id: 'user_1',
    name: 'Zubair Qazi',
    email: 'zubair@example.com',
    level: 4,
    xp: 320,
    coins: 150,
    streak: 3,
    lastActiveDate: now,
  );

  final rewards = GamificationService.refreshRewards(
    user: user,
    quests: <Quest>[activeQuest, completedQuest, missedQuest],
    bossBattles: <BossBattle>[bossBattle, missedBossBattle],
  );

  return AppSnapshot(
    user: user,
    settings: UserSettings.defaults(),
    quests: <Quest>[activeQuest, completedQuest, missedQuest],
    bossBattles: <BossBattle>[bossBattle, missedBossBattle],
    rewards: rewards,
  );
}

class _FakeFirebaseRepository extends FirebaseRepository {
  _FakeFirebaseRepository(this._snapshot);

  AppSnapshot _snapshot;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<AppSnapshot?> restoreSession() async => _snapshot;

  @override
  Future<AppSnapshot> signIn({
    required String email,
    required String password,
  }) async => _snapshot;

  @override
  Future<AppSnapshot> register({
    required String name,
    required String email,
    required String password,
  }) async => _snapshot;

  @override
  Future<void> persistSnapshot(AppSnapshot snapshot) async {
    _snapshot = snapshot;
  }

  @override
  Future<void> signOut() async {}
}

class _FakeAndroidNotificationsPlatform
    extends AndroidFlutterLocalNotificationsPlugin {
  @override
  Future<bool> initialize({
    required AndroidInitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<bool?> requestNotificationsPermission() async => true;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    AndroidNotificationDetails? notificationDetails,
    String? payload,
  }) async {}

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails,
    required AndroidScheduleMode scheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {}
}
