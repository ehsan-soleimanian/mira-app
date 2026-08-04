import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/capture_input_catalog.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';
import 'package:mira_app/redesign/models/rd_capture_mode.dart';
import 'package:mira_app/redesign/theme/rd_theme.dart';
import 'package:mira_app/redesign/widgets/rd_bottom_nav.dart';
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

  testWidgets('quick composer keeps voice direct and submits typed input', (
    tester,
  ) async {
    RdCaptureMode? picked;
    String? submittedText;
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
          onSubmitText: (text) => submittedText = text,
          onClose: () {},
        ),
      ),
    );

    expect(find.text('Drop it into Mira'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.byKey(const ValueKey('rd-capture-voice')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rd-capture-voice')));
    expect(picked, RdCaptureMode.voice);

    await tester.enterText(
      find.byKey(const ValueKey('rd-capture-quick-composer')),
      'Remember the launch review tomorrow',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('rd-capture-send')));
    expect(submittedText, 'Remember the launch review tomorrow');
  });

  testWidgets('Mira dock has two destinations and direct voice on hold', (
    tester,
  ) async {
    String? route;
    Object? routeArg;
    void go(String screen, {Object? arg}) {
      route = screen;
      routeArg = arg;
    }

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
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: RdBottomNav(active: 'home', go: go),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Mira'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rd-nav-orb')));
    expect(route, 'capture');

    route = null;
    routeArg = null;
    await tester.longPress(find.byKey(const ValueKey('rd-nav-orb')));
    expect(route, 'captureflow');
    expect(routeArg, isA<RdCaptureModeArg>());
    expect((routeArg! as RdCaptureModeArg).mode, RdCaptureMode.voice);
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
          onSubmitText: (_) {},
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
