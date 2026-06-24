import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/features/capture/widgets/capture_processing_sphere.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Mira orb — same size and screen alignment as [HomeHero].
class MiraHeroOrb extends StatelessWidget {
  const MiraHeroOrb({
    super.key,
    required this.scale,
    this.processing = false,
    this.belowPageHeader = false,
  });

  final double scale;
  final bool processing;
  final bool belowPageHeader;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final width = MediaQuery.sizeOf(context).width;
    final size = HomeScreenTokens.sphereDiameter(s);
    final top = belowPageHeader
        ? HomeScreenTokens.sphereYBelowHeader(s)
        : HomeScreenTokens.sphereY(s);

    return Positioned(
      top: top,
      left: HomeScreenTokens.sphereLeft(width, s),
      child: processing
          ? CaptureProcessingSphere(size: size, processing: true)
          : MiraSphere(size: size),
    );
  }
}
