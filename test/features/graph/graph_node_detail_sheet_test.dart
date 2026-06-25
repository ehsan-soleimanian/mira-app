import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/features/graph/graph_repository.dart';
import 'package:mira_app/features/graph/widgets/graph_node_detail_sheet.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/graph_models.dart';

GraphRepository _testRepository() {
  return GraphRepository(apiClient: ApiClient(tokenStorage: TokenStorage()));
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

GraphNode _taskNode({String status = 'OPEN'}) => GraphNode(
      id: 'task_1',
      title: 'Call Alex',
      summary: 'Follow up tomorrow',
      kind: 'TASK',
      nodeType: 'Task',
      status: status,
      captureId: 'cap_1',
    );

GraphNode _captureNode() => GraphNode(
      id: 'cap_1',
      title: 'Mobbina is 39',
      summary: 'Age note',
      kind: 'CAPTURE',
      nodeType: 'Capture',
      status: 'ACTIVE',
    );

void main() {
  testWidgets('task sheet shows mark done and cancel actions', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GraphNodeDetailSheet(
          node: _taskNode(),
          related: const [],
          scale: 1,
          repository: _testRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark done'), findsOneWidget);
    expect(find.text('Cancel task'), findsOneWidget);
    expect(find.text('Edit memory'), findsNothing);
  });

  testWidgets('done task hides mark done action', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GraphNodeDetailSheet(
          node: _taskNode(status: 'DONE'),
          related: const [],
          scale: 1,
          repository: _testRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark done'), findsNothing);
    expect(find.text('Cancel task'), findsNothing);
  });

  testWidgets('capture sheet shows edit and delete actions', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GraphNodeDetailSheet(
          node: _captureNode(),
          related: const [],
          scale: 1,
          repository: _testRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit memory'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    expect(find.text('Mark done'), findsNothing);
  });
}
