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
      };

  /// Simulates STT + processing SSE for voice captures without backend.
  static Stream<CaptureStreamEvent> voiceProcessingStream() async* {
    yield const CaptureStreamEvent(
      event: 'status',
      data: {'state': 'processing'},
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    yield CaptureStreamEvent(
      event: 'proposal',
      data: sampleTaskProposal(),
    );
    yield const CaptureStreamEvent(
      event: 'done',
      data: {'state': 'awaiting_approval'},
    );
  }

  static CaptureResponse mockVoiceCaptureResponse() => CaptureResponse(
        captureId: 'mock-voice-capture',
        state: 'awaiting_approval',
        proposal: sampleTaskProposal(),
      );
}
