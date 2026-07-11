import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/l10n/app_localizations.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Listen — device-mic recording surface (orb, timer, stop). Stopping
/// transcribes best-effort and opens Chat with the transcript prefilled.
class RdListenScreen extends StatefulWidget {
  const RdListenScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdListenScreen> createState() => _RdListenScreenState();
}

class _RdListenScreenState extends State<RdListenScreen> {
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

  String get _time =>
      '${(_sec ~/ 60).toString().padLeft(2, '0')}:${(_sec % 60).toString().padLeft(2, '0')}';

  Future<void> _stop() async {
    if (_busy) return;
    setState(() => _busy = true);
    _timer?.cancel();
    var transcript = '';
    final repo = AppScope.servicesOf(context).captureRepository;
    try {
      final result = await _recorder.stop();
      final path = result.filePath;
      if (!result.simulated && path != null && path.isNotEmpty) {
        final res = await repo.transcribeVoice(
          durationMs: result.duration.inMilliseconds,
          audioPath: path,
        );
        if (!mounted) return;
        transcript = res.text.trim();
      }
    } catch (_) {
      // Fall through — still open chat like the design stop affordance.
    }
    if (!mounted) return;
    if (transcript.isNotEmpty) {
      widget.go(
        'chat',
        arg: RdChatArg(initialPrompt: transcript, autoSend: true),
      );
    } else {
      widget.go('chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RingButton(icon: RdIcons.arrowLeft, onTap: widget.onBack),
                  GestureDetector(
                    onTap: () => widget.go('daily'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: RdIcon(
                        '<path d="M12 5.2a2.9 2.9 0 0 0-5.6-1.05A2.7 2.7 0 0 0 4.2 9a2.45 2.45 0 0 0 .45 4.45A2.45 2.45 0 0 0 8.1 15.7 2.45 2.45 0 0 0 12 18.4Z"/><path d="M12 5.2a2.9 2.9 0 0 1 5.6-1.05A2.7 2.7 0 0 1 19.8 9a2.45 2.45 0 0 1-.45 4.45 2.45 2.45 0 0 1-3.45 2.25A2.45 2.45 0 0 1 12 18.4Z"/><path d="M12 5.2v13.2"/>',
                        size: 23,
                        stroke: '#1A1C29',
                        strokeWidth: 1.5,
                        color: rd.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            const RdOrb(size: 145),
            const SizedBox(height: 34),
            Text(
              _busy ? l10n.rdListenTranscribing : l10n.rdListenTitle,
              style: GoogleFonts.dosis(fontSize: 34, fontWeight: FontWeight.w700, color: rd.ink),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.rdListenSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dosis(fontSize: 18, fontWeight: FontWeight.w500, color: rd.muted),
            ),
            const Spacer(flex: 3),
            GestureDetector(
              onTap: _busy ? null : _stop,
              child: Opacity(
                opacity: _busy ? 0.55 : 1,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC7D2FF),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00206B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _time,
              style: GoogleFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w700, color: rd.ink),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.rdListenTapToStop,
              style: GoogleFonts.vazirmatn(fontSize: 10, color: rd.muted, letterSpacing: 0.6),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  const _RingButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        dark ? rd.card.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF141632).withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: RdIcon(icon, size: 22, stroke: '#1A1C29', strokeWidth: 1.6, color: rd.ink),
        ),
      ),
    );
  }
}
