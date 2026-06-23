import 'package:flutter/material.dart';
import 'package:mira_app/core/figma_assets.dart';

/// Mira orb — Figma Ball component (692:4137), 145×145 @1x.
class MiraSphere extends StatelessWidget {
  const MiraSphere({super.key, this.size = 145});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Image.asset(
        FigmaAssets.ball,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
