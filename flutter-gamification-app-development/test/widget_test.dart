// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:remembrances/main.dart';
import 'package:remembrances/providers/app_provider.dart';
import 'package:remembrances/providers/habit_provider.dart';
import 'package:remembrances/providers/settings_provider.dart';
import 'package:remembrances/services/hive_service.dart';

void main() {
  testWidgets('app loads dashboard with providers available', (WidgetTester tester) async {
    await HiveService.init();

    final settingsProvider = SettingsProvider();
    final habitProvider = HabitProvider();
    await settingsProvider.loadSettings();
    await habitProvider.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: habitProvider),
        ],
        child: const KhairukumApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('مشروع خيركم'), findsWidgets);
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
