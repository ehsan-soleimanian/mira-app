import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_markdown_text.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// User prompt — right-aligned white bubble.
class CaptureUserBubble extends StatelessWidget {
  const CaptureUserBubble({
    super.key,
    required this.text,
    required this.scale,
    this.maxWidth = 252,
  });

  final String text;
  final double scale;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth * s),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10 * s,
                offset: Offset(0, 3 * s),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
            child: MiraMarkdownText(
              data: text,
              scale: s,
              fontSize: 16,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mira reply — left-aligned plain text (no bubble), markdown.
class CaptureMiraMessage extends StatelessWidget {
  const CaptureMiraMessage({
    super.key,
    required this.text,
    required this.scale,
    this.fontSize = 16,
    this.color,
  });

  final String text;
  final double scale;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Align(
      alignment: Alignment.centerLeft,
      child: MiraMarkdownText(
        data: text,
        scale: s,
        fontSize: fontSize,
        color: color ?? AppColors.textPrimary,
        textAlign: TextAlign.left,
      ),
    );
  }
}

/// Memory save indicator under Mira text.
class CaptureMemoryToggle extends StatelessWidget {
  const CaptureMemoryToggle({
    super.key,
    required this.scale,
    required this.saved,
    required this.onTap,
  });

  final double scale;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = saved ? AppColors.micBlueNav : const Color(0xFF9B2C2C);

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              saved ? Icons.verified_outlined : Icons.cancel_outlined,
              size: 16 * s,
              color: color,
            ),
            SizedBox(width: 5 * s),
            Text(
              saved ? 'save to memory' : 'Remove memory',
              style: AppTypography.dosis(
                size: 14 * s,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Save / cancel row at bottom of approval flow.
class CaptureApprovalActions extends StatelessWidget {
  const CaptureApprovalActions({
    super.key,
    required this.scale,
    required this.busy,
    required this.onSave,
    required this.onCancel,
  });

  final double scale;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38 * s,
            child: ElevatedButton(
              onPressed: busy ? null : onSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0B399D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                ),
              ),
              child: Text(
                'Save',
                style: AppTypography.dosis(
                  size: 14 * s,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: SizedBox(
            height: 38 * s,
            child: OutlinedButton(
              onPressed: busy ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B399D),
                side: const BorderSide(color: Color(0xFF0B399D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                ),
              ),
              child: Text(
                'cancel',
                style: AppTypography.dosis(
                  size: 14 * s,
                  weight: FontWeight.w600,
                  color: const Color(0xFF0B399D),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Scrollable LTR conversation column for capture chat.
class CaptureConversationColumn extends StatelessWidget {
  const CaptureConversationColumn({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
