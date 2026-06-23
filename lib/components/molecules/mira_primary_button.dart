import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_gradient_border_painter.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Full-width raised pill button — matches [MiraInputField] surface style.
class MiraPrimaryButton extends StatelessWidget {
  const MiraPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = ComposerTokens.inputHeight,
    this.radius = ComposerTokens.inputRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: ComposerTokens.raisedSurfaceDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: CustomPaint(
            painter: MiraGradientBorderPainter(radius: radius),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? ComposerTokens.glyphColor
                            : ComposerTokens.hintColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small caption label above auth / form fields.
class MiraFieldLabel extends StatelessWidget {
  const MiraFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ComposerTokens.hintColor,
        ),
      ),
    );
  }
}
