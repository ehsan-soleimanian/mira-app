import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/main.dart';
import 'package:mira_app/screens/daily_brief_screen.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/daily_brief/task_brief_checkbox.dart';
import 'package:mira_app/widgets/mira_bottom_nav.dart';

void main() {
  testWidgets('Home screen renders headline', (WidgetTester tester) async {
    await tester.pumpWidget(MiraApp(themeController: AppThemeController()));
    await tester.pumpAndSettle();

    expect(find.text('How can I help you ?'), findsOneWidget);
  });

  testWidgets('Bottom nav renders tabs and mic', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MiraBottomNav(activeTab: NavTab.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Daily Brief'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Daily Brief checkbox toggles', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DailyBriefScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product review with the team'), findsOneWidget);
    expect(find.byType(TaskBriefCheckbox), findsWidgets);

    final checkbox = find.byType(TaskBriefCheckbox).first;
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_rounded), findsWidgets);
  });

  testWidgets('Note more expands text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DailyBriefScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('more'), findsWidgets);
    await tester.tap(find.text('more').first);
    await tester.pumpAndSettle();

    expect(find.text('less'), findsOneWidget);
    expect(find.textContaining('eiusmod tempor'), findsOneWidget);
  });
}
