import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/redesign/screens/rd_my_mira_screen.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';

Widget _app() => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(useMaterial3: true, extensions: const [RdTheme.light]),
  home: RdMyMiraScreen(live: false, go: (screen, {arg}) {}),
);

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('confirmation removes the pending learning', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pump();
    expect(
      find.text('You’re training for a half marathon in October.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(
      find.text('You’re training for a half marathon in October.'),
      findsNothing,
    );
    expect(find.text('Learning confirmed'), findsOneWidget);
  });

  testWidgets('correction replaces the learning in preview mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.text('Correct'));
    await tester.pump(const Duration(milliseconds: 500));

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, 'You’re training for a 10K in October.');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('You’re training for a 10K in October.'), findsOneWidget);
    expect(find.text('Correction sent to Mira'), findsOneWidget);
  });
}
