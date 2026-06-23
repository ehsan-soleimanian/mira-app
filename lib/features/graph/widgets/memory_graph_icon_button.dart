import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Brain / memory graph launcher — Figma inset circle with psychology icon.
class MemoryGraphIconButton extends StatelessWidget {
  const MemoryGraphIconButton({
    super.key,
    required this.size,
    this.onTap,
    this.active = false,
  });

  final double size;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: MiraInnerShadowPainter(
                    shape: (s) => Path()..addOval(Offset.zero & s),
                    baseColor: ComposerTokens.insetBase,
                    darkShadow: ComposerTokens.softShadow.withValues(alpha: 0.7),
                    lightShadow: Colors.white,
                    blur: size * 0.17,
                    offset: size * 0.10,
                  ),
                  child: Icon(
                    Icons.psychology_alt_outlined,
                    size: size * 0.48,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (active)
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.16,
                    constraints: const BoxConstraints(minWidth: 7, minHeight: 7),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.micBlueNav,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
