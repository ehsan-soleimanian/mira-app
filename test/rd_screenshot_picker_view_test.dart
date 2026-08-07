import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';
import 'package:mira_app/redesign/widgets/rd_capture_mode_views.dart';

Widget _app({required Future<void> Function() onSelected}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(useMaterial3: true, extensions: const [RdTheme.light]),
  home: Scaffold(
    body: SafeArea(
      child: RdScreenshotPickerView(onSelected: onSelected, onClose: () {}),
    ),
  ),
);

void main() {
  testWidgets('uses the real system picker instead of fake recent cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 825);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var opened = 0;
    await tester.pumpWidget(
      _app(
        onSelected: () async {
          opened += 1;
        },
      ),
    );
    await tester.pump();

    expect(find.text('RECENT'), findsNothing);
    expect(find.byType(GridView), findsNothing);
    expect(
      find.text(
        'Android opens its system photo picker. Mira can only access the image you choose.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('screenshot_browse_device')));
    await tester.pump();
    expect(opened, 1);
  });
}
