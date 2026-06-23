import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Figma step 5 — «Your details» (display name only).
class OnboardingYourDetailsScreen extends StatefulWidget {
  const OnboardingYourDetailsScreen({
    super.key,
    required this.onContinue,
    this.initialName = '',
  });

  final ValueChanged<String> onContinue;
  final String initialName;

  @override
  State<OnboardingYourDetailsScreen> createState() =>
      _OnboardingYourDetailsScreenState();
}

class _OnboardingYourDetailsScreenState
    extends State<OnboardingYourDetailsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName.trim());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onContinue(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ProfileDetailsIcon(),
                        const SizedBox(height: 28),
                        const Text(
                          'Your details',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            color: OnboardingTokens.headlineColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tell Mira what to call you so your home and memories feel personal.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: OnboardingTokens.subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 28),
                        MiraInputField(
                          controller: _nameController,
                          hintText: 'your name',
                          showMic: false,
                          variant: MiraInputVariant.flat,
                          height: 58,
                          radius: ComposerTokens.flatFieldRadius,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MiraSpacing.lg,
                    MiraSpacing.sm,
                    MiraSpacing.lg,
                    MiraSpacing.lg,
                  ),
                  child: AuthFormCtaButton(
                    label: 'Enter',
                    controller: _nameController,
                    isReady: (text) => text.trim().isNotEmpty,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDetailsIcon extends StatelessWidget {
  const _ProfileDetailsIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(painter: _ProfileDetailsIconPainter()),
    );
  }
}

class _ProfileDetailsIconPainter extends CustomPainter {
  const _ProfileDetailsIconPainter();

  static const _stroke = Color(0xFF6B6560);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, paint);

    final cx = size.width / 2;
    canvas.drawCircle(Offset(cx, size.height * 0.36), size.width * 0.13, paint);

    final shoulders = Path()
      ..moveTo(cx - size.width * 0.22, size.height * 0.76)
      ..quadraticBezierTo(
        cx,
        size.height * 0.56,
        cx + size.width * 0.22,
        size.height * 0.76,
      );
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
