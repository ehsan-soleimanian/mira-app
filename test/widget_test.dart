import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/screens/catalog/component_catalog_screen.dart';

Future<void> _scrollListUntilVisible(WidgetTester tester, Finder target) async {
  final list = find.byType(ListView);
  for (var i = 0; i < 40 && target.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -250));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 120));
}

void main() {
  testWidgets('Component catalog shows design system previews', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ComponentCatalogScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mira Components'), findsOneWidget);
    expect(find.text('Organisms / Bottom Nav'), findsOneWidget);
    expect(find.textContaining('Cradle'), findsWidgets);
    expect(find.textContaining('Ear notch'), findsWidgets);

    final inputTitle = find.text(
      'Molecules / MiraInputField (742:11005 / 742:11091)',
    );
    await _scrollListUntilVisible(tester, inputTitle);
    expect(inputTitle, findsOneWidget);
    expect(find.text('Empty — grey border + mic (742:11005)'), findsOneWidget);
    expect(
      find.text('Active — blue border + send (742:11091)'),
      findsOneWidget,
    );

    final composerTitle = find.text('Organisms / MiraComposerBar (742:11005)');
    await _scrollListUntilVisible(tester, composerTitle);
    expect(composerTitle, findsOneWidget);

    final buttonTitle = find.text('Molecules / MiraButton (742:13615)');
    await _scrollListUntilVisible(tester, buttonTitle);
    expect(buttonTitle, findsOneWidget);
    expect(find.text('Large CTA'), findsOneWidget);

    final micTitle = find.text(
      'Molecules / MiraEarNavMicButton (741:4986-mic)',
    );
    await _scrollListUntilVisible(tester, micTitle);
    expect(micTitle, findsOneWidget);
    expect(find.text('Voice mic well (741:4986-mic)'), findsOneWidget);

    final stopTitle = find.text('Molecules / MiraStopButton (618:3447)');
    await _scrollListUntilVisible(tester, stopTitle);
    expect(stopTitle, findsOneWidget);
    expect(find.text('Stop recording (618:3447)'), findsOneWidget);

    final tapWorkflowTitle = find.text(
      'Organisms / TapCaptureWorkflow (564:2520)',
    );
    await _scrollListUntilVisible(tester, tapWorkflowTitle);
    expect(tapWorkflowTitle, findsOneWidget);
    expect(find.text('Text'), findsWidgets);

    final voiceWorkflowTitle = find.text(
      'Organisms / VoiceRecordingOverlay (long press)',
    );
    await _scrollListUntilVisible(tester, voiceWorkflowTitle);
    expect(voiceWorkflowTitle, findsOneWidget);
    expect(find.text('Recording…'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    final neumorphicTitle = find.text('Molecules / NeumorphicIconButton');
    await _scrollListUntilVisible(tester, neumorphicTitle);
    expect(neumorphicTitle, findsOneWidget);
    expect(find.text('Raised'), findsOneWidget);
  });
}
