import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/graph/entity_type_labels.dart';
import 'package:mira_app/l10n/app_localizations.dart';

void main() {
  testWidgets('graphEntityTypeLabel maps Organization to localized company label',
      (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fa'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(graphEntityTypeLabel(l10n, 'Organization'), 'شرکت');
    expect(graphEntityTypeLabel(l10n, 'Person'), 'شخص');
    expect(graphEntityTypeLabel(l10n, 'Topic'), 'موضوع');
  });
}
