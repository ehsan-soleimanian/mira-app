import 'package:flutter/material.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Memory graph launcher — Figma brain-in-head asset.
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
                child: Image.asset(
                  FigmaAssets.graphIcon,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.micBlueNav,
                      border: Border.all(color: Colors.white, width: 1.5),
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
