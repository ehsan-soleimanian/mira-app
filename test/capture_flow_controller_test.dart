import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';

void main() {
  test('startRecording enters recording phase from idle', () async {
    final recorder = _FakeVoiceRecorder();
    final controller = _controller(recorder);

    await controller.startRecording();

    expect(controller.phase, CaptureUiPhase.recording);
    expect(recorder.startCount, 1);

    controller.dispose();
  });

  test('startRecording is ignored while processing', () async {
    final recorder = _FakeVoiceRecorder();
    final controller = _controller(recorder)..phase = CaptureUiPhase.processing;

    await controller.startRecording();

    expect(controller.phase, CaptureUiPhase.processing);
    expect(recorder.startCount, 0);

    controller.dispose();
  });
}

CaptureFlowController _controller(VoiceRecorderPort recorder) {
  final apiClient = ApiClient(tokenStorage: TokenStorage());
  final repository = CaptureRepository(apiClient: apiClient);
  return CaptureFlowController(
    captureRepository: repository,
    voiceRecorder: recorder,
  );
}

class _FakeVoiceRecorder implements VoiceRecorderPort {
  int startCount = 0;
  bool _recording = false;

  @override
  Stream<double> get amplitudeStream => const Stream.empty();

  @override
  bool get isRecording => _recording;

  @override
  Future<bool> start() async {
    startCount++;
    _recording = true;
    return true;
  }

  @override
  Future<VoiceRecordingResult> stop() async {
    _recording = false;
    return const VoiceRecordingResult(duration: Duration(milliseconds: 800));
  }

  @override
  Future<void> cancel() async {
    _recording = false;
  }
}
