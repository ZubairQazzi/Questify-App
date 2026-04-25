import 'package:flutter/material.dart';

enum ThemePreference { dark, light, system }

extension ThemePreferenceX on ThemePreference {
  String get label => switch (this) {
    ThemePreference.dark => 'Dark',
    ThemePreference.light => 'Light',
    ThemePreference.system => 'System',
  };

  ThemeMode get themeMode => switch (this) {
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.system => ThemeMode.system,
  };

  static ThemePreference fromLabel(String? value) {
    return ThemePreference.values.firstWhere(
      (preference) => preference.label.toLowerCase() == value?.toLowerCase(),
      orElse: () => ThemePreference.dark,
    );
  }
}

class UserSettings {
  const UserSettings({
    required this.themePreference,
    required this.notificationsEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.dailyGoalQuests,
    required this.focusDurationMinutes,
  });

  final ThemePreference themePreference;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int dailyGoalQuests;
  final int focusDurationMinutes;

  ThemeMode get themeMode => themePreference.themeMode;
  String get reminderLabel {
    final hour = reminderHour == 0
        ? 12
        : reminderHour > 12
        ? reminderHour - 12
        : reminderHour;
    final minute = reminderMinute.toString().padLeft(2, '0');
    final meridiem = reminderHour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridiem';
  }

  UserSettings copyWith({
    ThemePreference? themePreference,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? dailyGoalQuests,
    int? focusDurationMinutes,
  }) {
    return UserSettings(
      themePreference: themePreference ?? this.themePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      dailyGoalQuests: dailyGoalQuests ?? this.dailyGoalQuests,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themePreference': themePreference.label,
      'notificationsEnabled': notificationsEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'dailyGoalQuests': dailyGoalQuests,
      'focusDurationMinutes': focusDurationMinutes,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      themePreference: ThemePreferenceX.fromLabel(
        map['themePreference'] as String?,
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      reminderHour: map['reminderHour'] as int? ?? 19,
      reminderMinute: map['reminderMinute'] as int? ?? 0,
      dailyGoalQuests: map['dailyGoalQuests'] as int? ?? 3,
      focusDurationMinutes: map['focusDurationMinutes'] as int? ?? 25,
    );
  }

  factory UserSettings.defaults() {
    return const UserSettings(
      themePreference: ThemePreference.dark,
      notificationsEnabled: true,
      reminderHour: 19,
      reminderMinute: 0,
      dailyGoalQuests: 3,
      focusDurationMinutes: 25,
    );
  }
}
