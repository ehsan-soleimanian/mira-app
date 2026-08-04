import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/capture_input_catalog.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';
import 'package:mira_app/redesign/models/rd_capture_mode.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';
import 'package:mira_app/redesign/widgets/rd_capture_entry_sheet.dart';

void main() {
  test('catalog covers every canonical capture input exactly once', () {
    expect(captureInputCatalog, hasLength(12));
    expect(
      captureInputCatalog.map((definition) => definition.kind).toSet(),
      canonicalCaptureInputKinds,
    );
  });

  test('direct UI methods map to canonical transport kinds', () {
    expect(RdCaptureMode.type.canonicalInputKind, 'text');
    expect(RdCaptureMode.voice.canonicalInputKind, 'voice');
    expect(RdCaptureMode.photo.canonicalInputKind, 'camera_scan');
    expect(RdCaptureMode.screenshot.canonicalInputKind, 'image');
    expect(RdCaptureMode.file.canonicalInputKind, 'file');
    expect(RdCaptureMode.link.canonicalInputKind, 'link');
    expect(RdCaptureMode.meeting.canonicalInputKind, 'live_meeting');
  });

  test(
    'contextual inputs stay automatic instead of becoming picker clutter',
    () {
      const automatic = {
        'message',
        'calendar',
        'contact',
        'integration_event',
        'bundle',
      };
      expect(
        captureInputCatalog
            .where((definition) => !definition.direct)
            .map((definition) => definition.kind)
            .toSet(),
        automatic,
      );
    },
  );

  test('every contextual input can enter the shared capture flow', () {
    for (final kind in const {
      'message',
      'calendar',
      'contact',
      'integration_event',
      'bundle',
    }) {
      final arg = RdCanonicalCaptureArg(
        CaptureInput(type: kind, data: const {'source': 'test'}),
      );
      expect(arg.input.type, kind);
    }
  });

  testWidgets('drop hub exposes capture methods and routes from one surface', (
    tester,
  ) async {
    RdCaptureMode? picked;
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(extensions: const [RdTheme.light]),
        home: RdCaptureEntrySheet(
          onPick: (mode) => picked = mode,
          onNavigate: (screen) => destination = screen,
          onClose: () {},
        ),
      ),
    );

    expect(find.text('Drop it into Mira'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);

    await tester.tap(find.text('Voice'));
    expect(picked, RdCaptureMode.voice);

    await tester.tap(find.text('Library'));
    expect(destination, 'library');
  });

  testWidgets('drop hub stays focused in a mobile viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(extensions: const [RdTheme.light]),
        home: RdCaptureEntrySheet(
          onPick: (_) {},
          onNavigate: (_) {},
          onClose: () {},
        ),
      ),
    );

    await expectLater(
      find.byType(RdCaptureEntrySheet),
      matchesGoldenFile('goldens/rd_capture_drop_hub.png'),
    );
  });
}
