import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_markdown_text.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// Layout tokens for capture chat — content starts at top, not orb/home Y.
abstract final class CaptureChatTokens {
  static const contentTopPadding = 12.0;
  static const horizontalPadding = 24.0;
  static const bottomPadding = 120.0;
}

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

/// Memory saved badge — blue verified icon + label.
class CaptureMemoryToggle extends StatelessWidget {
  const CaptureMemoryToggle({
    super.key,
    required this.scale,
    required this.saved,
    this.onTap,
  });

  final double scale;
  final bool saved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    if (!saved) return const SizedBox.shrink();

    final color = AppColors.micBlueNav;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified,
              size: 22 * s,
              color: color,
            ),
            SizedBox(width: 8 * s),
            Text(
              'save to memory',
              style: AppTypography.dosis(
                size: 16 * s,
                weight: FontWeight.w500,
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

/// White attach menu — camera / picture / file (Figma).
class CaptureAttachMenu extends StatelessWidget {
  const CaptureAttachMenu({
    super.key,
    required this.scale,
    required this.onCamera,
    required this.onPicture,
    required this.onFile,
  });

  final double scale;
  final VoidCallback onCamera;
  final VoidCallback onPicture;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      width: 200 * s,
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20 * s,
            offset: Offset(0, 8 * s),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttachRow(
            scale: s,
            icon: Icons.photo_camera_outlined,
            label: 'camera',
            onTap: onCamera,
          ),
          SizedBox(height: 18 * s),
          _AttachRow(
            scale: s,
            icon: Icons.add_photo_alternate_outlined,
            label: 'picture',
            onTap: onPicture,
          ),
          SizedBox(height: 18 * s),
          _AttachRow(
            scale: s,
            icon: Icons.create_new_folder_outlined,
            label: 'file',
            onTap: onFile,
          ),
        ],
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * s),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4 * s),
          child: Row(
            children: [
              Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22 * s, color: AppColors.textPrimary),
              ),
              SizedBox(width: 14 * s),
              Text(
                label,
                style: AppTypography.dosis(
                  size: 18 * s,
                  weight: FontWeight.w500,
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
