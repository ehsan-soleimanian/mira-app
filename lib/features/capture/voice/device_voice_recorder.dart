import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';

/// Device mic recorder — falls back to simulated mode when permission/hardware fails.
class DeviceVoiceRecorder implements VoiceRecorderPort {
  DeviceVoiceRecorder({SimulatedVoiceRecorder? fallback})
      : _fallback = fallback ?? SimulatedVoiceRecorder();

  final AudioRecorder _recorder = AudioRecorder();
  final SimulatedVoiceRecorder _fallback;
  final _ampController = StreamController<double>.broadcast();

  Timer? _ampTimer;
  DateTime? _startedAt;
  String? _path;
  Stream<List<int>>? _realtimeStream;
  bool _recording = false;
  bool _usingFallback = false;
  bool _usingRealtime = false;

  @override
  bool get isRecording => _recording;

  @override
  Stream<double> get amplitudeStream => _usingFallback
      ? _fallback.amplitudeStream
      : _ampController.stream;

  @override
  Stream<List<int>>? get realtimeAudioStream => _realtimeStream;

  @override
  bool get supportsRealtimeAudio => !_usingFallback && _realtimeStream != null;

  @override
  Future<bool> start() async {
    if (_recording) return true;

    if (kIsWeb) {
      return _startFallback();
    }

    try {
      if (!await _recorder.hasPermission()) {
        return _startFallback();
      }
      final dir = await getTemporaryDirectory();
      _path = '${dir.path}/mira_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _path!,
      );
      _recording = true;
      _startedAt = DateTime.now();
      _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
        final amp = await _recorder.getAmplitude();
        final normalized =
            ((amp.current + 50) / 50).clamp(0.15, 1.0).toDouble();
        _ampController.add(normalized);
      });
      return true;
    } catch (_) {
      return _startFallback();
    }
  }

  @override
  Future<bool> startRealtime() async {
    if (_recording) return true;

    try {
      if (!await _recorder.hasPermission()) {
        return false;
      }
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          streamBufferSize: 3200,
        ),
      );
      _realtimeStream = stream;
      _recording = true;
      _usingRealtime = true;
      _startedAt = DateTime.now();
      _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
        final amp = await _recorder.getAmplitude();
        final normalized =
            ((amp.current + 50) / 50).clamp(0.15, 1.0).toDouble();
        _ampController.add(normalized);
      });
      return true;
    } catch (_) {
      _realtimeStream = null;
      _usingRealtime = false;
      return false;
    }
  }

  Future<bool> _startFallback() async {
    _usingFallback = true;
    _recording = true;
    return _fallback.start();
  }

  @override
  Future<VoiceRecordingResult> stop() async {
    if (_usingFallback) {
      _recording = false;
      _usingFallback = false;
      return _fallback.stop();
    }

    final started = _startedAt ?? DateTime.now();
    _ampTimer?.cancel();
    if (_usingRealtime) {
      await _recorder.stop();
      _recording = false;
      _usingRealtime = false;
      _startedAt = null;
      _realtimeStream = null;
      return VoiceRecordingResult(
        duration: DateTime.now().difference(started),
      );
    }
    final path = _path;
    await _recorder.stop();
    _recording = false;
    _startedAt = null;
    _path = null;

    if (path != null && File(path).existsSync()) {
      return VoiceRecordingResult(
        duration: DateTime.now().difference(started),
        filePath: path,
      );
    }
    return VoiceRecordingResult(
      duration: DateTime.now().difference(started),
      simulated: true,
    );
  }

  @override
  Future<void> cancel() async {
    _ampTimer?.cancel();
    if (_usingFallback) {
      await _fallback.cancel();
      _usingFallback = false;
    } else if (_recording) {
      await _recorder.stop();
      if (_path != null) {
        final file = File(_path!);
        if (file.existsSync()) {
          await file.delete();
        }
      }
    }
    _recording = false;
    _usingRealtime = false;
    _startedAt = null;
    _path = null;
    _realtimeStream = null;
  }

  void dispose() {
    _ampTimer?.cancel();
    _ampController.close();
    _fallback.dispose();
    _recorder.dispose();
  }
}

/// Factory — returns device recorder with simulated fallback.
VoiceRecorderPort createVoiceRecorder() => DeviceVoiceRecorder();

/// Format recording duration as M:SS.
String formatRecordingDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString();
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Format recording duration as MM:SS (Figma onboarding step 7).
String formatRecordingClock(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Wave bar height helper for amplitude animation.
double waveBarHeight(double amplitude, int index, {int bars = 12}) {
  final phase = (index / bars) * math.pi * 2;
  return (18 + amplitude * 28 * (0.6 + 0.4 * math.sin(phase))).clamp(8, 46);
}
