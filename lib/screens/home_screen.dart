import 'package:flutter/material.dart';
import 'package:mira_app/screens/daily_brief_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';
import 'package:mira_app/widgets/app_bottom_shell.dart';
import 'package:mira_app/widgets/hint_bar.dart';
import 'package:mira_app/widgets/mira_sphere.dart';
import 'package:mira_app/widgets/settings_button.dart';

/// Home screen — Figma iPhone 16 - 150 (692:4127).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDailyBrief(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyBriefScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scaler = FigmaScaler(width);
    final s = scaler.scale;

    final tipBottom = bottomInset +
        NavBarTokens.designHeight * s +
        HomeScreenTokens.tipGapAboveNav * s;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: HomeScreenTokens.settingsTop * s,
              right: HomeScreenTokens.settingsRight * s,
              child: SettingsButton(size: HomeScreenTokens.settingsSize * s),
            ),
            Positioned(
              top: HomeScreenTokens.sphereTop * s,
              left: (width - HomeScreenTokens.sphereSize * s) / 2,
              child: MiraSphere(size: HomeScreenTokens.sphereSize * s),
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
            Positioned(
              bottom: tipBottom,
              left: (width - HomeScreenTokens.tipWidth * s) / 2,
              width: HomeScreenTokens.tipWidth * s,
              child: HintBar(scale: s),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.home,
        onDailyBriefTap: () => _openDailyBrief(context),
      ),
    );
  }
}
