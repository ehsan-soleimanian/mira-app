import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/hint_bar.dart';
import 'package:mira_app/features/capture/widgets/capture_processing_sphere.dart';
import 'package:mira_app/components/molecules/catalog_button.dart';
import 'package:mira_app/components/molecules/settings_button.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Home hero stack — sphere, headline, subtitle, tip (Figma 692:4127).
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.scale,
    this.processing = false,
  });

  final double scale;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final width = MediaQuery.sizeOf(context).width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: HomeScreenTokens.settingsTop * s,
          left: HomeScreenTokens.catalogLeft * s,
          child: CatalogButton(size: HomeScreenTokens.settingsSize * s),
        ),
        Positioned(
          top: HomeScreenTokens.settingsTop * s,
          right: HomeScreenTokens.settingsRight * s,
          child: SettingsButton(size: HomeScreenTokens.settingsSize * s),
        ),
        Positioned(
          top: HomeScreenTokens.sphereTop * s,
          left: (width - HomeScreenTokens.sphereSize * s) / 2,
          child: CaptureProcessingSphere(
            size: HomeScreenTokens.sphereSize * s,
            processing: processing,
          ),
        ),
        Positioned(
          top: HomeScreenTokens.headlineTop * s,
          left: 0,
          right: 0,
          child: Text(
            'How can I help you ?',
            textAlign: TextAlign.center,
            style: AppTypography.homeHeadline(s),
          ),
        ),
        Positioned(
          top: HomeScreenTokens.subtitleTop * s,
          left: 0,
          right: 0,
          child: Text(
            'Speak,ask or share anythings',
            textAlign: TextAlign.center,
            style: AppTypography.homeSubtitle(s),
          ),
        ),
      ],
    );
  }
}

/// Tip bar positioned above bottom nav.
class HomeTipBar extends StatelessWidget {
  const HomeTipBar({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = scale;

    return SizedBox(
      width: width,
      child: Center(
        child: SizedBox(
          width: HomeScreenTokens.tipWidth * s,
          child: HintBar(scale: s),
        ),
      ),
    );
  }
}
