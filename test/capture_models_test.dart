import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/capture_models.dart';

void main() {
  test('CaptureResponse keeps link crawl provenance', () {
    final capture = CaptureResponse.fromJson({
      'capture_id': 'capture-1',
      'state': 'processing',
      'capture_type': 'link',
      'proposal': null,
      'source_metadata': {
        'url': 'https://example.com/article',
        'is_scraped_url': true,
        'link_extraction_method': 'firecrawl',
        'scraped_title': 'Useful article',
      },
      'created_at': '2026-07-12T00:00:00Z',
    });

    expect(capture.captureType, 'link');
    expect(capture.sourceMetadata['is_scraped_url'], isTrue);
    expect(capture.sourceMetadata['link_extraction_method'], 'firecrawl');
    expect(capture.sourceMetadata['scraped_title'], 'Useful article');
    expect(capture.createdAt, isNotNull);
  });

  test('CaptureInput serializes the canonical twelve-kind contract', () {
    final input = CaptureInput(
      type: 'message',
      data: const {'subject': 'Follow up', 'body': 'Send the deck'},
      sources: const [
        CaptureSourceInput(sourceId: 'src_1', kind: 'message'),
      ],
      channel: 'connector',
    );

    expect(
      input.toJson(timezone: 'Asia/Tehran', locale: 'fa-IR'),
      {
        'type': 'message',
        'data': {'subject': 'Follow up', 'body': 'Send the deck'},
        'sources': [
          {'sourceId': 'src_1', 'kind': 'message', 'retention': 'transient'},
        ],
        'channel': 'connector',
        'timezone': 'Asia/Tehran',
        'locale': 'fa-IR',
      },
    );
  });

  test('CaptureResultCard exposes primary and secondary next-step actions', () {
    final card = CaptureResultCard.fromJson({
      'schemaVersion': 'capture_result.v1',
      'phase': 'review',
      'extractedItems': [
        {
          'id': 'task_1',
          'kind': 'task',
          'role': 'primary',
          'status': 'proposed',
          'fields': {'title': 'Send deck'},
          'confidence': {
            'score': 0.88,
            'level': 'high',
            'requiresReview': false,
            'reasons': [],
          },
          'fieldConfidence': {'title': 0.9},
          'evidenceRefs': ['ev_1'],
          'availableActionIds': ['capture.approve', 'proposal.edit'],
        },
      ],
      'nextStep': {
        'primaryAction': {
          'id': 'capture.approve',
          'label': 'Add to memory',
          'endpoint': '/captures/x/actions/capture.approve',
          'style': 'primary',
          'sideEffect': 'local',
          'requiresConfirmation': true,
          'expectedGraphEffects': ['node'],
        },
        'secondaryActions': [
          {
            'id': 'proposal.edit',
            'label': 'Edit',
            'endpoint': '/captures/x/actions/proposal.edit',
          },
          {
            'id': 'capture.dismiss',
            'label': 'Dismiss',
            'endpoint': '/captures/x/actions/capture.dismiss',
          },
          {
            'id': 'extra',
            'label': 'Extra',
            'endpoint': '/captures/x/actions/extra',
          },
        ],
      },
      'memoryControls': {'retention': 'durable_after_approval'},
    });

    expect(card.phase, 'review');
    expect(card.extractedItems.single.kind, 'task');
    expect(card.extractedItems.single.confidence.level, 'high');
    expect(card.extractedItems.single.fieldConfidence['title'], 0.9);
    expect(card.primaryAction?.isApprove, isTrue);
    expect(card.secondaryActions, hasLength(2));
    expect(card.memoryControls['retention'], 'durable_after_approval');
  });

  test('CaptureResponse parses architecture review fields', () {
    final capture = CaptureResponse.fromJson({
      'capture_id': 'capture-2',
      'state': 'awaiting_approval',
      'capture_type': 'text',
      'proposal': {'title': 'Send deck', 'summary': 'Task'},
      'pending_interaction': {
        'schema_version': 'capture_interaction.v1',
        'kind': 'approval',
        'prompt': 'Add this to memory?',
        'required': true,
        'actions': [
          {
            'id': 'capture.approve',
            'label': 'Confirm',
            'endpoint': '/captures/capture-2/actions/capture.approve',
            'style': 'primary',
          },
        ],
        'context': {},
      },
      'input_manifest': {
        'schemaVersion': 'capture_input.v1',
        'kind': 'text',
      },
      'processing_report': {
        'schemaVersion': 'capture_processing.v1',
        'steps': [
          {
            'step': 'classify',
            'status': 'completed',
            'processor': 'classify',
            'outputRefs': [],
            'warnings': [],
          },
        ],
      },
      'result_card': {
        'schemaVersion': 'capture_result.v1',
        'phase': 'review',
        'nextStep': {
          'primaryAction': {
            'id': 'capture.approve',
            'label': 'Confirm',
            'endpoint': '/captures/capture-2/actions/capture.approve',
          },
          'secondaryActions': [],
        },
      },
      'proposal_revision': 3,
      'available_actions': [
        {
          'id': 'proposal.edit',
          'label': 'Edit',
          'endpoint': '/captures/capture-2/actions/proposal.edit',
        },
      ],
      'created_at': '2026-08-04T12:00:00Z',
    });

    expect(capture.proposalRevision, 3);
    expect(capture.pendingInteraction?.kind, 'approval');
    expect(capture.processingReport?.steps.single.step, 'classify');
    expect(capture.primaryAction?.id, 'capture.approve');
    expect(capture.availableActions.single.id, 'proposal.edit');
  });

  test('CaptureCommitReceipt aggregates projection status', () {
    final receipt = CaptureCommitReceipt.fromJson({
      'schemaVersion': 'capture_commit_receipt.v1',
      'captureId': 'capture-3',
      'ledgerEventId': 'ledger-1',
      'commitStatus': 'committed',
      'projections': [
        {'name': 'operational', 'status': 'APPLIED'},
        {'name': 'graphiti', 'status': 'PENDING'},
        {'name': 'library', 'status': 'APPLIED'},
      ],
      'createdEntities': ['ent_1'],
      'tasks': ['task_1'],
    });

    expect(receipt.commitStatus, 'committed');
    expect(receipt.isProjectionPending, isTrue);
    expect(receipt.projectionStatus, 'PENDING');
    expect(receipt.highlightEntityId, 'ent_1');
  });

  test('CaptureActionOutcome distinguishes commit and mutation replies', () {
    final commit = CaptureActionOutcome.fromJson({
      'schemaVersion': 'capture_commit_receipt.v1',
      'captureId': 'capture-4',
      'ledgerEventId': 'ledger-2',
      'projections': [],
    });
    expect(commit.isCommit, isTrue);
    expect(commit.receipt?.captureId, 'capture-4');

    final mutation = CaptureActionOutcome.fromJson({
      'capture_id': 'capture-4',
      'state': 'awaiting_approval',
      'proposal_revision': 4,
      'actionOutcome': {
        'actionId': 'communication.share',
        'status': 'awaiting_external_confirmation',
      },
    });
    expect(mutation.capture?.proposalRevision, 4);
    expect(mutation.awaitsExternalConfirmation, isTrue);
  });

  test('CaptureExecutionRequest never claims external success for blocked drafts', () {
    final request = CaptureExecutionRequest.fromJson({
      'id': 'req-1',
      'captureId': 'capture-5',
      'kind': 'automation',
      'status': 'BLOCKED_CONFIGURATION',
      'payload': {'trigger': 'daily'},
      'result': {},
      'error': 'No automation executor is configured',
      'confirmedAt': '2026-08-04T12:00:00Z',
      'createdAt': '2026-08-04T11:00:00Z',
      'updatedAt': '2026-08-04T12:00:00Z',
    });

    expect(request.isBlockedConfiguration, isTrue);
    expect(request.claimsExternalSuccess, isFalse);
  });

  test('CaptureActionRequest encodes optimistic concurrency fields', () {
    final body = CaptureActionRequest(
      proposalRevision: 2,
      idempotencyKey: 'device-key-1',
      operations: const [
        ProposalMutationOperation(
          op: 'replace_field',
          itemId: 'task_1',
          field: 'title',
          value: 'Send final deck',
        ),
      ],
    ).toJson();

    expect(body['proposalRevision'], 2);
    expect(body['idempotencyKey'], 'device-key-1');
    expect(body['operations'], [
      {
        'op': 'replace_field',
        'itemId': 'task_1',
        'field': 'title',
        'value': 'Send final deck',
      },
    ]);
  });

  test('liveMeetingMarker builds the realtime websocket payload', () {
    expect(
      liveMeetingMarker(kind: 'decision', atMs: 12000, label: 'Ship v2'),
      {
        'type': 'marker',
        'kind': 'decision',
        'atMs': 12000,
        'label': 'Ship v2',
      },
    );
  });
}
