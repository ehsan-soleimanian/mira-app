import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mira_app/features/capture/widgets/voice_recording_overlay.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Catalog preview for the long-press voice recording workflow.
class VoiceRecordingWorkflowPreviewPane extends StatefulWidget {
  const VoiceRecordingWorkflowPreviewPane({super.key});

  @override
  State<VoiceRecordingWorkflowPreviewPane> createState() =>
      _VoiceRecordingWorkflowPreviewPaneState();
}

class _VoiceRecordingWorkflowPreviewPaneState
    extends State<VoiceRecordingWorkflowPreviewPane> {
  late final StreamController<double> _amplitudes;
  Timer? _timer;
  var _tick = 0;

  @override
  void initState() {
    super.initState();
    _amplitudes = StreamController<double>.broadcast();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _tick++;
      final wave = 0.35 + math.sin(_tick * 0.8).abs() * 0.55;
      _amplitudes.add(wave);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudes.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MiraSpacing.lg),
        child: VoiceRecordingOverlay(
          duration: const Duration(seconds: 7),
          amplitudeStream: _amplitudes.stream,
          onCancel: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cancel voice recording'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 900),
            ),
          ),
          onStop: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Save voice recording'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 900),
            ),
          ),
        ),
      ),
    );
  }
}
