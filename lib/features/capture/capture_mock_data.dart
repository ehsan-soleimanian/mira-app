import 'package:mira_app/models/api/capture_models.dart';

/// Offline / fallback sample pipeline when the voice API is unreachable.
abstract final class CaptureMockData {
  static const sampleTranscript =
      'Task: review pricing plan with the team on Friday';

  static Map<String, dynamic> sampleTaskProposal() => {
        'node_type': 'Task',
        'title': 'Review pricing plan with the team',
        'summary': sampleTranscript,
        'deadline': 'Friday',
        'displaySummary': {
          'headline': 'Review pricing plan with the team',
          'items': [
            {'text': 'Review pricing plan with the team'},
            {'text': 'Friday'},
          ],
        },
      };

  static CaptureResultCard sampleResultCard() => CaptureResultCard(
        phase: 'review',
        interpretation: const {
          'intent': 'save',
          'summary': sampleTranscript,
        },
        extractedItems: const [
          CaptureDetectedItem(
            id: 'task_1',
            kind: 'task',
            role: 'primary',
            fields: {
              'title': 'Review pricing plan with the team',
              'dueText': 'Friday',
            },
            confidence: CaptureConfidence(
              score: 0.9,
              level: 'high',
              requiresReview: false,
            ),
            availableActionIds: ['capture.approve', 'proposal.edit'],
          ),
        ],
        nextStep: {
          'primaryAction': {
            'id': 'capture.approve',
            'label': 'Add to memory',
            'endpoint': '/captures/mock-voice-capture/actions/capture.approve',
            'style': 'primary',
            'phase': 'commit',
            'sideEffect': 'local',
            'requiresConfirmation': true,
            'expectedGraphEffects': ['node', 'evidence'],
          },
          'secondaryActions': [
            {
              'id': 'capture.dismiss',
              'label': 'Dismiss',
              'endpoint': '/captures/mock-voice-capture/actions/capture.dismiss',
              'style': 'secondary',
              'phase': 'review',
              'sideEffect': 'none',
              'requiresConfirmation': true,
            },
          ],
        },
        memoryControls: const {
          'retention': 'durable_after_approval',
          'learningMode': 'default',
        },
      );

  /// Simulates STT + processing SSE for voice captures without backend.
  static Stream<CaptureStreamEvent> voiceProcessingStream() async* {
    yield const CaptureStreamEvent(
      event: 'status',
      data: {
        'state': 'processing',
        'processing': {
          'schemaVersion': 'capture_processing.v1',
          'steps': [
            {
              'step': 'transcribe',
              'status': 'completed',
              'processor': 'stt',
            },
            {
              'step': 'classify',
              'status': 'completed',
              'processor': 'classify',
            },
          ],
        },
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    yield CaptureStreamEvent(
      event: 'proposal',
      data: sampleTaskProposal(),
    );
    yield CaptureStreamEvent(
      event: 'result',
      data: {
        'schemaVersion': 'capture_result.v1',
        'phase': 'review',
        'interpretation': {'intent': 'save', 'summary': sampleTranscript},
        'extractedItems': [
          {
            'id': 'task_1',
            'kind': 'task',
            'role': 'primary',
            'status': 'proposed',
            'fields': {
              'title': 'Review pricing plan with the team',
              'dueText': 'Friday',
            },
            'confidence': {
              'score': 0.9,
              'level': 'high',
              'requiresReview': false,
              'reasons': [],
            },
            'fieldConfidence': {},
            'evidenceRefs': [],
            'availableActionIds': ['capture.approve', 'proposal.edit'],
          },
        ],
        'workLog': [],
        'plannedEffects': [
          {'kind': 'node', 'label': 'Create task'},
        ],
        'committedEffects': [],
        'nextStep': sampleResultCard().nextStep,
        'provenance': {'sources': [], 'evidence': []},
        'memoryControls': {
          'retention': 'durable_after_approval',
          'learningMode': 'default',
        },
      },
    );
    yield const CaptureStreamEvent(
      event: 'done',
      data: {'state': 'awaiting_approval'},
    );
  }

  static CaptureResponse mockVoiceCaptureResponse() => CaptureResponse(
        captureId: 'mock-voice-capture',
        state: 'awaiting_approval',
        captureType: 'voice',
        proposal: sampleTaskProposal(),
        resultCard: sampleResultCard(),
        proposalRevision: 1,
        availableActions: sampleResultCard().secondaryActions,
      );

  static CaptureCommitReceipt mockCommitReceipt() => const CaptureCommitReceipt(
        captureId: 'mock-voice-capture',
        ledgerEventId: 'mock-ledger-event',
        projections: [
          CaptureProjectionStatus(name: 'operational', status: 'APPLIED'),
          CaptureProjectionStatus(name: 'graphiti', status: 'APPLIED'),
          CaptureProjectionStatus(name: 'library', status: 'APPLIED'),
        ],
        createdEntities: ['mock-entity-1'],
        tasks: ['mock-task-1'],
      );
}
