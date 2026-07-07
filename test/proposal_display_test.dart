import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';

void main() {
  test('legacy proposal keeps title and summary', () {
    final display = resolveProposalDisplay({
      'title': 'Call Alex',
      'summary': 'Tomorrow at 3pm',
      'node_type': 'Task',
    });

    expect(display.title, 'Call Alex');
    expect(display.summary, 'Tomorrow at 3pm');
    expect(display.nodeType, 'Task');
    expect(display.hasSource, isFalse);
    expect(display.hasContent, isTrue);
    expect(
      isGraphV2Proposal({'title': 'Call Alex', 'summary': 'Tomorrow at 3pm'}),
      isFalse,
    );
  });

  test('graph v2 proposal derives display from assertions', () {
    const proposal = {
      'schemaVersion': 'graph_extraction.v2',
      'assertions': [
        {
          'role': 'Product Manager',
          'evidenceText': 'I am a product manager and founder',
        },
        {
          'role': 'Founder',
          'evidenceText': 'I am a product manager and founder',
        },
      ],
      'entities': [
        {'entityType': 'Person', 'canonicalName': 'User'},
      ],
    };

    expect(isGraphV2Proposal(proposal), isTrue);

    final display = resolveProposalDisplay(proposal);

    expect(display.title, 'I am a product manager and founder');
    expect(display.summary, 'Product Manager / Founder');
    expect(display.hasContent, isTrue);
  });

  test('graph v2 task proposal uses task title', () {
    final display = resolveProposalDisplay({
      'schemaVersion': 'graph_extraction.v2',
      'tasks': [
        {'title': 'Review contract with John'},
      ],
      'assertions': [],
    });

    expect(display.title, 'Review contract with John');
    expect(display.nodeType, 'Task');
  });

  test('resource proposal separates source from saved memory draft', () {
    final display = resolveProposalDisplay({
      'title': 'scaled_Capture.JPG',
      'summary': '',
      'node_type': 'Resource',
      'source': {
        'capture_type': 'image',
        'filename': 'scaled_Capture.JPG',
        'stored_raw': false,
      },
    });

    expect(display.title, 'scaled_Capture.JPG');
    expect(display.nodeType, 'Resource');
    expect(display.sourceTitle, 'scaled_Capture.JPG');
    expect(display.sourceType, 'image');
    expect(display.hasSource, isTrue);
    expect(display.needsMoreContext, isTrue);
  });
}
