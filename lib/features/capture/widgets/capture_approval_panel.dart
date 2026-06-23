import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// Figma conversation approval — proposal bubble + Save / cancel.
class CaptureApprovalPanel extends StatelessWidget {
  const CaptureApprovalPanel({
    super.key,
    required this.scale,
    required this.proposal,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    this.prompt,
  });

  final double scale;
  final Map<String, dynamic> proposal;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? prompt;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final title = proposal['title']?.toString();
    final summary = proposal['summary']?.toString();
    final userLine = (prompt?.trim().isNotEmpty == true)
        ? prompt!.trim()
        : (summary ?? title ?? '');

    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 96 * s, 24 * s, 120 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (userLine.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: _Bubble(scale: s, text: userLine, maxWidth: 252 * s),
            ),
          SizedBox(height: 22 * s),
          if (title != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: _Bubble(scale: s, text: title, maxWidth: 286 * s),
            ),
            SizedBox(height: 20 * s),
          ],
          Text(
            "Save this to your memory. If this is wrong, tell me. I'll change it.",
            style: AppTypography.vazirmatn(
              size: 16 * s,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          if (summary != null && summary != title) ...[
            SizedBox(height: 30 * s),
            Align(
              alignment: Alignment.centerRight,
              child: _Bubble(scale: s, text: summary, maxWidth: 230 * s),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: MiraButton(
                  label: 'Save',
                  size: MiraButtonSize.large,
                  expand: true,
                  onPressed: busy ? null : onSave,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: MiraButton(
                  label: 'cancel',
                  variant: MiraButtonVariant.outlined,
                  size: MiraButtonSize.large,
                  expand: true,
                  onPressed: busy ? null : onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.scale,
    required this.text,
    required this.maxWidth,
  });

  final double scale;
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 12 * scale,
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: AppTypography.vazirmatn(
              size: 15 * scale,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
