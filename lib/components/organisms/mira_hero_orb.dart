import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_living_sphere.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Mira orb — same size and screen alignment as [HomeHero].
class MiraHeroOrb extends StatelessWidget {
  const MiraHeroOrb({
    super.key,
    required this.scale,
    this.processing = false,
    this.belowPageHeader = false,
    this.ambient = false,
    this.holdIntensity = 0,
    this.onHoldStart,
    this.onHoldEnd,
  });

  final double scale;
  final bool processing;
  final bool belowPageHeader;

  /// Steady inner aurora (chat, voice listening).
  final bool ambient;

  /// 0–1 ramp from long-press on home orb.
  final double holdIntensity;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final width = MediaQuery.sizeOf(context).width;
    final size = HomeScreenTokens.sphereDiameter(s);
    final top = belowPageHeader
        ? HomeScreenTokens.sphereYBelowHeader(s)
        : HomeScreenTokens.sphereY(s);

    final motion = processing
        ? 1.0
        : ambient
        ? 1.0
        : holdIntensity.clamp(0.0, 1.0);
    final living = motion > 0.02 || processing;

    Widget orb = living
        ? MiraLivingSphere(
            size: size,
            intensity: motion,
            processing: processing,
          )
        : MiraSphere(size: size);

    if (onHoldStart != null || onHoldEnd != null) {
      orb = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => onHoldStart?.call(),
        onLongPressEnd: (_) => onHoldEnd?.call(),
        onLongPressCancel: () => onHoldEnd?.call(),
        child: orb,
      );
    }

    return Positioned(
      top: top,
      left: HomeScreenTokens.sphereLeft(width, s),
      child: orb,
    );
  }
}
