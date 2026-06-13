import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/main.dart';

void main() {
  testWidgets('Home screen renders headline', (WidgetTester tester) async {
    await tester.pumpWidget(MiraApp(themeController: AppThemeController()));
    await tester.pumpAndSettle();

    expect(find.text('How can I help you ?'), findsOneWidget);
  });
}
