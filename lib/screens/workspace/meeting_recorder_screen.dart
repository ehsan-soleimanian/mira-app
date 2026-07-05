import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

enum _MeetingRecorderPhase { starting, recording, recorded, saving, failed }

class MeetingRecorderScreen extends StatefulWidget {
  const MeetingRecorderScreen({super.key});

  @override
  State<MeetingRecorderScreen> createState() => _MeetingRecorderScreenState();
}

class _MeetingRecorderScreenState extends State<MeetingRecorderScreen>
    with WidgetsBindingObserver {
  late final VoiceRecorderPort _recorder;
  late final TextEditingController _title;

  _MeetingRecorderPhase _phase = _MeetingRecorderPhase.starting;
  Timer? _timer;
  Duration _duration = Duration.zero;
  String? _audioPath;
  String? _error;
  bool _titleSeeded = false;
  bool _interrupted = false;
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _recorder = createVoiceRecorder();
    _title = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRecording());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_titleSeeded) return;
    _title.text = _defaultTitle(AppLocalizations.of(context)!);
    _titleSeeded = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase != _MeetingRecorderPhase.recording || _stopping) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_stopRecording(interrupted: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    if (_phase == _MeetingRecorderPhase.recording) {
      unawaited(_recorder.cancel());
    }
    if (_recorder is DeviceVoiceRecorder) {
      _recorder.dispose();
    } else if (_recorder is SimulatedVoiceRecorder) {
      _recorder.dispose();
    }
    _title.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _phase = _MeetingRecorderPhase.starting;
      _error = null;
      _interrupted = false;
      _duration = Duration.zero;
      _audioPath = null;
    });
    final started = await _recorder.start();
    if (!mounted) return;
    if (!started) {
      setState(() {
        _phase = _MeetingRecorderPhase.failed;
        _error = l10n.meetingRecorderStartFailed;
      });
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _duration += const Duration(seconds: 1));
      }
    });
    setState(() => _phase = _MeetingRecorderPhase.recording);
  }

  Future<void> _stopRecording({bool interrupted = false}) async {
    if (_phase != _MeetingRecorderPhase.recording || _stopping) return;
    _stopping = true;
    _timer?.cancel();
    final result = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _duration = result.duration;
      _audioPath = result.filePath;
      _interrupted = interrupted;
      _phase = _MeetingRecorderPhase.recorded;
      _error = result.filePath == null
          ? AppLocalizations.of(context)!.meetingRecorderNoAudio
          : null;
      _stopping = false;
    });
  }

  Future<void> _discard() async {
    if (_phase == _MeetingRecorderPhase.recording ||
        _phase == _MeetingRecorderPhase.starting) {
      await _recorder.cancel();
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final path = _audioPath;
    if (path == null) {
      setState(() => _error = l10n.meetingRecorderNoAudio);
      return;
    }
    setState(() {
      _phase = _MeetingRecorderPhase.saving;
      _error = null;
    });
    try {
      await AppScope.servicesOf(context).libraryRepository.importMeetingAudio(
        title: _meetingTitle(l10n),
        audioPath: path,
        filename: 'mira_meeting_${DateTime.now().millisecondsSinceEpoch}.m4a',
        mimeType: 'audio/mp4',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.meetingRecorderSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _MeetingRecorderPhase.recorded;
        _error = l10n.meetingRecorderSaveFailed;
      });
    }
  }

  String _meetingTitle(AppLocalizations l10n) {
    final value = _title.text.trim();
    return value.isEmpty ? _defaultTitle(l10n) : value;
  }

  String _defaultTitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '${l10n.meetingRecorderDefaultTitle} - ${now.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saving = _phase == _MeetingRecorderPhase.saving;
    final recording = _phase == _MeetingRecorderPhase.recording;

    return PopScope(
      canPop: !saving,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!saving) unawaited(_discard());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.meetingRecorderCancel,
                    onPressed: saving ? null : () => unawaited(_discard()),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      l10n.meetingRecorderTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.dosis(
                        size: 24,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _title,
                enabled: !saving,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: l10n.meetingRecorderTitleHint,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _RecorderSurface(
                phaseLabel: _phaseLabel(l10n),
                durationLabel: l10n.meetingRecorderDurationLabel(
                  formatRecordingDuration(_duration),
                ),
                recording: recording,
                amplitudeStream: _recorder.amplitudeStream,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.meetingRecorderBody,
                style: AppTypography.dosis(
                  size: 14,
                ).copyWith(color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 10),
              _InfoStrip(
                icon: Icons.phone_paused_rounded,
                text: l10n.meetingRecorderPhoneCallNote,
              ),
              if (_interrupted) ...[
                const SizedBox(height: 12),
                _InterruptionPanel(
                  title: l10n.meetingRecorderInterrupted,
                  body: l10n.meetingRecorderInterruptedBody,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTypography.dosis(
                    size: 14,
                    weight: FontWeight.w700,
                  ).copyWith(color: const Color(0xFFB42318)),
                ),
              ],
              const SizedBox(height: 24),
              _Actions(
                phase: _phase,
                canSave: _audioPath != null,
                onStop: () => unawaited(_stopRecording()),
                onSave: () => unawaited(_save()),
                onDiscard: () => unawaited(_discard()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel(AppLocalizations l10n) {
    switch (_phase) {
      case _MeetingRecorderPhase.starting:
        return l10n.meetingRecorderStarting;
      case _MeetingRecorderPhase.recording:
        return l10n.meetingRecorderRecording;
      case _MeetingRecorderPhase.recorded:
        return l10n.meetingRecorderReady;
      case _MeetingRecorderPhase.saving:
        return l10n.meetingRecorderSaving;
      case _MeetingRecorderPhase.failed:
        return l10n.meetingRecorderStartFailed;
    }
  }
}

class _RecorderSurface extends StatelessWidget {
  const _RecorderSurface({
    required this.phaseLabel,
    required this.durationLabel,
    required this.recording,
    required this.amplitudeStream,
  });

  final String phaseLabel;
  final String durationLabel;
  final bool recording;
  final Stream<double> amplitudeStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                recording
                    ? Icons.fiber_manual_record_rounded
                    : Icons.check_circle_rounded,
                size: 16,
                color: recording ? const Color(0xFFE11D48) : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                phaseLabel,
                style: AppTypography.dosis(size: 16, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            durationLabel,
            style: AppTypography.dosis(size: 34, weight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          StreamBuilder<double>(
            stream: amplitudeStream,
            initialData: 0.32,
            builder: (context, snapshot) {
              final amp = recording ? (snapshot.data ?? 0.32) : 0.18;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(18, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 5,
                    height: waveBarHeight(amp, index, bars: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(
                        alpha: recording ? 0.85 : 0.35,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.dosis(
                size: 13,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterruptionPanel extends StatelessWidget {
  const _InterruptionPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.dosis(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.dosis(
              size: 13,
            ).copyWith(color: AppColors.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.phase,
    required this.canSave,
    required this.onStop,
    required this.onSave,
    required this.onDiscard,
  });

  final _MeetingRecorderPhase phase;
  final bool canSave;
  final VoidCallback onStop;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (phase) {
      case _MeetingRecorderPhase.starting:
        return const Center(child: CircularProgressIndicator());
      case _MeetingRecorderPhase.saving:
        return FilledButton.icon(
          onPressed: null,
          icon: const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(l10n.meetingRecorderSaving),
        );
      case _MeetingRecorderPhase.recording:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDiscard,
                icon: const Icon(Icons.close_rounded),
                label: Text(l10n.meetingRecorderCancel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded),
                label: Text(l10n.meetingRecorderStop),
              ),
            ),
          ],
        );
      case _MeetingRecorderPhase.recorded:
      case _MeetingRecorderPhase.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: canSave ? onSave : null,
              icon: const Icon(Icons.library_add_check_rounded),
              label: Text(l10n.meetingRecorderSave),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onDiscard,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.meetingRecorderDiscard),
            ),
          ],
        );
    }
  }
}
