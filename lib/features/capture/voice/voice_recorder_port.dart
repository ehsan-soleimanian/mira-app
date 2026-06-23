import 'dart:async';

/// Result of a completed voice recording session.
class VoiceRecordingResult {
  const VoiceRecordingResult({
    required this.duration,
    this.filePath,
    this.simulated = false,
  });

  final Duration duration;
  final String? filePath;
  final bool simulated;
}

/// Port for device/simulated voice recording (Adapter pattern).
abstract class VoiceRecorderPort {
  Future<bool> start();
  Future<VoiceRecordingResult> stop();
  Future<void> cancel();
  Stream<double> get amplitudeStream;
  bool get isRecording;
}

/// Simulated recorder — works on web/desktop when mic hardware is unavailable.
class SimulatedVoiceRecorder implements VoiceRecorderPort {
  SimulatedVoiceRecorder();

  Timer? _ampTimer;
  final _ampController = StreamController<double>.broadcast();
  DateTime? _startedAt;
  bool _recording = false;

  @override
  bool get isRecording => _recording;

  @override
  Stream<double> get amplitudeStream => _ampController.stream;

  @override
  Future<bool> start() async {
    if (_recording) return true;
    _recording = true;
    _startedAt = DateTime.now();
    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      final t = timer.tick;
      final wave = (0.35 + (t % 7) * 0.08).clamp(0.2, 0.95);
      _ampController.add(wave);
    });
    return true;
  }

  @override
  Future<VoiceRecordingResult> stop() async {
    final started = _startedAt ?? DateTime.now();
    _ampTimer?.cancel();
    _recording = false;
    _startedAt = null;
    return VoiceRecordingResult(
      duration: DateTime.now().difference(started),
      simulated: true,
    );
  }

  @override
  Future<void> cancel() async {
    _ampTimer?.cancel();
    _recording = false;
    _startedAt = null;
  }

  void dispose() {
    _ampTimer?.cancel();
    _ampController.close();
  }
}
