import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';

import '../theme/rd_theme.dart';
import 'rd_icon.dart';

/// A bottom sheet that records a short phrase, transcribes it (real device
/// recorder + `transcribeVoice`, with the recorder's own simulated fallback on
/// unsupported targets), and pops the transcribed text. Reused wherever the
/// redesign turns speech into text — library voice search, reminder dictation.
class RdVoiceCaptureSheet extends StatefulWidget {
  const RdVoiceCaptureSheet({
    super.key,
    required this.captureRepository,
    this.prompt = 'Listening… tap to stop',
    this.busyLabel = 'Transcribing…',
  });

  final CaptureRepository captureRepository;
  final String prompt;
  final String busyLabel;

  @override
  State<RdVoiceCaptureSheet> createState() => _RdVoiceCaptureSheetState();
}

class _RdVoiceCaptureSheetState extends State<RdVoiceCaptureSheet> {
  final VoiceRecorderPort _recorder = createVoiceRecorder();
  bool _busy = false;
  int _sec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_recorder.start());
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _sec++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_recorder.isRecording) {
      unawaited(_recorder.cancel().catchError((_) {}));
    }
    final r = _recorder;
    if (r is DeviceVoiceRecorder) r.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    if (_busy) return;
    setState(() => _busy = true);
    _timer?.cancel();
    try {
      final result = await _recorder.stop();
      final path = result.filePath;
      var text = '';
      if (!result.simulated && path != null && path.isNotEmpty) {
        final transcript = await widget.captureRepository.transcribeVoice(
          durationMs: result.duration.inMilliseconds,
          audioPath: path,
        );
        text = transcript.text.trim();
      }
      if (mounted) Navigator.of(context).pop(text.isEmpty ? null : text);
    } catch (_) {
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  String get _time => '${_sec ~/ 60}:${(_sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 14, 24, 30 + MediaQuery.of(context).viewPadding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
                color: rd.line, borderRadius: BorderRadius.circular(100)),
          ),
          GestureDetector(
            onTap: _stop,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rd.navy,
                boxShadow: [
                  BoxShadow(
                      color: rd.navy.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: _busy
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                    )
                  : const Center(
                      child: RdIcon(
                          '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>',
                          size: 30,
                          stroke: '#FFFFFF',
                          strokeWidth: 1.9)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _busy ? widget.busyLabel : widget.prompt,
            style: GoogleFonts.vazirmatn(
                fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink),
          ),
          const SizedBox(height: 6),
          Text(
            _busy ? 'Turning your words into text' : _time,
            style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
          ),
        ],
      ),
    );
  }
}
