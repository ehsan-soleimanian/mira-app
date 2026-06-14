import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/theme/app_typography.dart';

/// Tip tooltip — Figma component Tip (742:10883).
class HintBar extends StatelessWidget {
  const HintBar({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(8 * s),
          child: Text(
            'Hold take a voic / Click send photo , link and text',
            textAlign: TextAlign.center,
            style: AppTypography.tip(s),
          ),
        ),
        SizedBox(
          width: 17 * s,
          height: 5 * s,
          child: SvgPicture.asset(
            FigmaAssets.tipArrow,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
