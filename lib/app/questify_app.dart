import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../frontend/controllers/questify_controller.dart';
import '../frontend/screens/root_flow.dart';
import '../frontend/theme/questify_theme.dart';

class QuestifyApp extends StatelessWidget {
  const QuestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestifyController>(
      builder: (context, controller, _) {
        return MaterialApp(
          title: 'Questify',
          debugShowCheckedModeBanner: false,
          theme: QuestifyTheme.lightTheme,
          darkTheme: QuestifyTheme.darkTheme,
          themeMode: controller.settings.themeMode,
          home: const RootFlow(),
        );
      },
    );
  }
}
