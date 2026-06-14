import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/widgets/figma_svg_icon.dart';

/// Prompt input bar — functional text field + attach + mic (Figma PromptInputBar).
class PromptInputBar extends StatelessWidget {
  const PromptInputBar({
    super.key,
    required this.controller,
    this.onAddTap,
    this.onMicTap,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback? onAddTap;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onSubmitted;

  static const _designW = 346.0;
  static const _designH = 55.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = screenW / 393.0;
    final barW = _designW * scale;
    final barH = _designH * scale;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 12 * scale),
      child: Center(
        child: Container(
          width: barW,
          height: barH,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(barH / 2),
            border: Border.all(color: AppColors.navBarStroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: barH,
                child: IconButton(
                  onPressed: onAddTap ??
                      () => _showSnack(context, 'Attach photo, link or file'),
                  icon: Icon(
                    Icons.add_rounded,
                    size: 24 * scale,
                    color: AppColors.textPrimary,
                  ),
                  splashRadius: 22 * scale,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: onSubmitted,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14 * scale,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Type here...',
                    hintStyle: GoogleFonts.vazirmatn(
                      fontSize: 14 * scale,
                      color: AppColors.hintText,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * scale),
                  ),
                ),
              ),
              SizedBox(
                width: barH * 0.9,
                child: IconButton(
                  onPressed: onMicTap,
                  icon: FigmaSvgIcon(
                    asset: FigmaAssets.navMic,
                    size: 22 * scale,
                  ),
                  splashRadius: 22 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
