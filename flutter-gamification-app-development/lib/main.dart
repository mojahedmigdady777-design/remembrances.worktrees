import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'providers/app_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/settings_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await NotificationService.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final habitProvider = HabitProvider();
  await habitProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: habitProvider),
      ],
      child: const KhairukumApp(),
    ),
  );
}

class KhairukumApp extends StatelessWidget {
  const KhairukumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'مشروع خيركم',
          theme: settingsProvider.settings.darkMode
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          home: const home1(),
        );
      },
    );
  }
}
