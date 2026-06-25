import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/hint_bar.dart';
import 'package:mira_app/components/organisms/mira_hero_orb.dart';
import 'package:mira_app/components/molecules/catalog_button.dart';
import 'package:mira_app/components/molecules/settings_button.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

/// Home hero stack — sphere, headline, subtitle, tip (Figma 692:4127).
class HomeHero extends StatefulWidget {
  const HomeHero({
    super.key,
    required this.scale,
    this.processing = false,
  });

  final double scale;
  final bool processing;

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdRamp;
  late final Animation<double> _holdCurve;

  @override
  void initState() {
    super.initState();
    _holdRamp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _holdCurve = CurvedAnimation(
      parent: _holdRamp,
      curve: Curves.easeInOutCubic,
    );
    _holdRamp.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _holdRamp.dispose();
    super.dispose();
  }

  void _onHoldStart() {
    if (widget.processing) return;
    _holdRamp.forward();
  }

  void _onHoldEnd() {
    _holdRamp.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: PageHeaderTokens.topPadding,
          left: PageHeaderTokens.horizontalPadding,
          child: CatalogButton(size: PageHeaderTokens.actionSize),
        ),
        Positioned(
          top: PageHeaderTokens.topPadding,
          right: PageHeaderTokens.horizontalPadding,
          child: SettingsButton(size: PageHeaderTokens.actionSize),
        ),
        MiraHeroOrb(
          scale: s,
          processing: widget.processing,
          holdIntensity: _holdCurve.value,
          onHoldStart: _onHoldStart,
          onHoldEnd: _onHoldEnd,
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
