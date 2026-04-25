import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/quest.dart';
import '../models/reward_badge.dart';
import '../models/user_settings.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    tz.initializeTimeZones();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);
    await requestPermissions();
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    await macPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncReminders({
    required UserSettings settings,
    required List<Quest> quests,
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.cancelAll();
    if (!settings.notificationsEnabled) {
      return;
    }

    await _scheduleDailyReminder(settings);
    await _scheduleQuestWarnings(quests);
  }

  Future<void> showRewardUnlocked(RewardBadge badge) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.show(
      id: badge.id.hashCode,
      title: 'Badge unlocked',
      body: '${badge.title} is now yours.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'rewards',
          'Rewards',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showFocusComplete(String questTitle) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.show(
      id: questTitle.hashCode,
      title: 'Focus session complete',
      body: 'Your focus sprint for "$questTitle" just finished.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus',
          'Focus Sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _scheduleDailyReminder(UserSettings settings) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.reminderHour,
      settings.reminderMinute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 9001,
      title: 'Daily quest session',
      body: 'Time to tackle today\'s quests and protect your streak.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleQuestWarnings(List<Quest> quests) async {
    final now = DateTime.now();
    final pendingQuests = quests
        .where((quest) => !quest.isCompleted && quest.deadline.isAfter(now))
        .toList();

    for (final quest in pendingQuests) {
      final warningTime = quest.deadline.subtract(const Duration(hours: 3));
      if (warningTime.isBefore(now)) {
        continue;
      }
      final scheduled = tz.TZDateTime.from(warningTime, tz.local);
      await _plugin.zonedSchedule(
        id: quest.id.hashCode,
        title: 'Quest deadline approaching',
        body:
            '${quest.title} is getting close. Finish the mission before the boss hits back.',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_alerts',
            'Deadline Alerts',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
