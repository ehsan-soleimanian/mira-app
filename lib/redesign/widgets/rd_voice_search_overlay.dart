import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';

import '../theme/rd_theme.dart';

/// Full-screen voice search overlay — mirrors design2 `.lb-voice` in Library.
class RdVoiceSearchOverlay extends StatefulWidget {
  const RdVoiceSearchOverlay({
    super.key,
    required this.onResult,
    required this.onCancel,
  });

  final ValueChanged<String> onResult;
  final VoidCallback onCancel;

  @override
  State<RdVoiceSearchOverlay> createState() => _RdVoiceSearchOverlayState();
}

class _RdVoiceSearchOverlayState extends State<RdVoiceSearchOverlay> {
  final VoiceRecorderPort _recorder = createVoiceRecorder();
  bool _busy = false;
  int _sec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_recorder.start());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _sec++),
    );
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

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    _timer?.cancel();
    try {
      final result = await _recorder.stop();
      final path = result.filePath;
      var text = '';
      if (!result.simulated && path != null && path.isNotEmpty) {
        final repo = AppScope.servicesOf(context).captureRepository;
        final transcript = await repo.transcribeVoice(
          durationMs: result.duration.inMilliseconds,
          audioPath: path,
        );
        if (!mounted) return;
        text = transcript.text.trim();
      }
      if (!mounted) return;
      if (text.isNotEmpty) {
        widget.onResult(text);
      } else {
        widget.onCancel();
      }
    } catch (_) {
      if (mounted) widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Material(
      color: const Color(0xFF141828).withValues(alpha: 0.44),
      child: GestureDetector(
        onTap: widget.onCancel,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 264,
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _VoiceBars(),
                  const SizedBox(height: 16),
                  Text(
                    _busy ? 'SEARCHING' : 'LISTENING',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: rd.faint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _busy ? 'One moment…' : 'Speak your search',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dosis(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_sec ~/ 60}:${(_sec % 60).toString().padLeft(2, '0')}',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      color: rd.muted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: rd.peri,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Search',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: rd.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceBars extends StatefulWidget {
  const _VoiceBars();

  @override
  State<_VoiceBars> createState() => _VoiceBarsState();
}

class _VoiceBarsState extends State<_VoiceBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final h = 12.0 + 22 * ((_c.value + i * 0.18) % 1.0);
            return Container(
              width: 7,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == 1 ? rd.peri : rd.navy,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
