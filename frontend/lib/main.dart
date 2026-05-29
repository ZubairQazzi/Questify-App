import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'frontend/app/questify_app.dart';
import 'frontend/controllers/questify_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => QuestifyController()..bootstrap(),
      child: const QuestifyApp(),
    ),
  );
}
