import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_stop_button.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

/// Voice recording HUD — waveform, timer, stop button (Figma flow 564:2520).
class VoiceRecordingOverlay extends StatefulWidget {
  const VoiceRecordingOverlay({
    super.key,
    required this.duration,
    required this.amplitudeStream,
    required this.onStop,
    this.onCancel,
    this.scale = 1,
  });

  final Duration duration;
  final Stream<double> amplitudeStream;
  final VoidCallback onStop;
  final VoidCallback? onCancel;
  final double scale;

  @override
  State<VoiceRecordingOverlay> createState() => _VoiceRecordingOverlayState();
}

class _VoiceRecordingOverlayState extends State<VoiceRecordingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  StreamSubscription<double>? _ampSub;
  double _amplitude = 0.4;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _ampSub = widget.amplitudeStream.listen((value) {
      if (mounted) setState(() => _amplitude = value);
    });
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 14 * s),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: AppColors.micBlueNav.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.micBlueNav.withValues(alpha: 0.12),
                  blurRadius: 24 * s,
                  offset: Offset(0, 8 * s),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recording…',
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w600,
                        color: AppColors.micBlueNav,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Container(
                      width: 8 * s,
                      height: 8 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.micBlueNav.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                _WaveformBars(amplitude: _amplitude, scale: s),
                SizedBox(height: 8 * s),
                Text(
                  formatRecordingDuration(widget.duration),
                  style: TextStyle(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MiraSpacing.md * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RecordingTextAction(
                label: 'Cancel',
                icon: Icons.close_rounded,
                scale: s,
                onTap: widget.onCancel,
              ),
              SizedBox(width: 18 * s),
              FadeTransition(
                opacity: Tween<double>(begin: 0.85, end: 1).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MiraStopButton(
                      size: StopButtonTokens.defaultSize * s,
                      onTap: widget.onStop,
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingTextAction extends StatelessWidget {
  const _RecordingTextAction({
    required this.label,
    required this.icon,
    required this.scale,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: AppColors.surface.withValues(alpha: 0.98),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textHint, size: 18 * s),
              SizedBox(width: 6 * s),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.amplitude, required this.scale});

  final double amplitude;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 12; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              margin: EdgeInsets.symmetric(horizontal: 2 * scale),
              width: 4 * scale,
              height: waveBarHeight(amplitude, i) * scale,
              decoration: BoxDecoration(
                color: AppColors.micBlueNav.withValues(
                  alpha: 0.45 + amplitude * 0.5,
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ],
      ),
    );
  }
}
