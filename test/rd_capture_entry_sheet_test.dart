import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/redesign/models/rd_capture_mode.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';
import 'package:mira_app/redesign/widgets/rd_capture_entry_sheet.dart';

Widget _app({required ValueChanged<RdCaptureMode> onPick}) => MaterialApp(
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
    body: RdCaptureEntrySheet(
      onPick: onPick,
      onClose: () {},
      onSubmitText: (_) {},
    ),
  ),
);

void main() {
  testWidgets(
    'all capture transports and the confirmation contract are visible',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      RdCaptureMode? picked;
      await tester.pumpWidget(_app(onPick: (mode) => picked = mode));
      await tester.pump();

      expect(find.text('Nothing is saved until you confirm.'), findsOneWidget);
      for (final label in ['Photo', 'Screenshot', 'File', 'Link', 'Meeting']) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }

      await tester.tap(find.text('Meeting'));
      expect(picked, RdCaptureMode.meeting);
    },
  );

  for (final size in [const Size(320, 700), const Size(430, 932)]) {
    testWidgets('capture entry fits ${size.width.toInt()}px wide screens', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_app(onPick: (_) {}));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Meeting').hitTestable(), findsOneWidget);
      expect(
        find.text('Nothing is saved until you confirm.').hitTestable(),
        findsOneWidget,
      );
    });
  }
}
