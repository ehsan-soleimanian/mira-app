import 'package:flutter/material.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/widgets/figma_svg_icon.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';
import 'package:mira_app/widgets/nav_bar_shell_painter.dart';
import 'package:mira_app/widgets/record_mic_button.dart';

/// Bottom navbar — Figma Group 48095737 (741:4987).
class MiraBottomNav extends StatelessWidget {
  const MiraBottomNav({
    super.key,
    this.activeTab = NavTab.home,
    this.onHomeTap,
    this.onVoiceShortTap,
    this.onRecordComplete,
    this.onDailyBriefTap,
  });

  final NavTab activeTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onVoiceShortTap;
  final VoidCallback? onRecordComplete;
  final VoidCallback? onDailyBriefTap;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = screenW / NavBarTokens.designWidth;
    final barH = NavBarTokens.designHeight * scale;
    final panelTop = barH * NavBarTokens.panelTopFactor;
    final iconSize = NavBarTokens.iconSize * scale;
    final micIconSize = NavBarTokens.micIconSize * scale;
    final homeActive = activeTab == NavTab.home;
    final inactive = NavBarTokens.inactiveOpacity;

    final iconY = panelTop + NavBarTokens.iconTopInPanel * scale;
    final labelY = panelTop + NavBarTokens.labelTopInPanel * scale;
    final dailyBriefLabelX =
        screenW / 2 + NavBarTokens.dailyBriefLabelCenterOffset * scale;

    final micWidth = screenW *
        (1 - NavBarTokens.micLeftFactor - NavBarTokens.micRightFactor);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        width: screenW,
        height: barH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(screenW, barH),
              painter: NavBarShellPainter(scale: scale),
            ),
            Positioned(
              left: NavBarTokens.homeIconLeft * scale,
              top: iconY,
              width: iconSize,
              height: iconSize + (labelY - iconY) + 20 * scale,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHomeTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FigmaSvgIcon(
                      asset: FigmaAssets.navHome,
                      size: iconSize,
                    ),
                    Positioned(
                      left: (NavBarTokens.homeLabelLeft -
                              NavBarTokens.homeIconLeft) *
                          scale,
                      top: labelY - iconY,
                      child: Text(
                        'Home',
                        style: homeActive
                            ? AppTypography.navActive(scale)
                            : AppTypography.navInactive(scale).copyWith(
                                color: AppColors.textPrimary
                                    .withValues(alpha: inactive),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: NavBarTokens.coffeeIconLeft * scale,
              top: iconY,
              width: screenW - NavBarTokens.coffeeIconLeft * scale,
              height: iconSize + (labelY - iconY) + 20 * scale,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDailyBriefTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FigmaSvgIcon(
                      asset: FigmaAssets.navCoffee,
                      size: iconSize,
                      opacity: homeActive ? inactive : 1,
                    ),
                    Positioned(
                      left: dailyBriefLabelX -
                          NavBarTokens.coffeeIconLeft * scale,
                      top: labelY - iconY,
                      child: Opacity(
                        opacity: homeActive ? inactive : 1,
                        child: Text(
                          'Daily Brief',
                          style: homeActive
                              ? AppTypography.navInactive(scale)
                              : AppTypography.navActive(scale),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: screenW * NavBarTokens.micLeftFactor,
              top: 0,
              width: micWidth,
              height: barH * (1 - NavBarTokens.micBottomFactor),
              child: RecordMicButton(
                size: micWidth,
                drawBackground: false,
                onShortTap: onVoiceShortTap,
                onRecordComplete: onRecordComplete,
              ),
            ),
            Positioned(
              left: screenW / 2 - micIconSize / 2,
              top: NavBarTokens.micIconTop * scale,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.micIconGlow,
                        blurRadius: 2.5 * scale,
                      ),
                    ],
                  ),
                  child: FigmaSvgIcon(
                    asset: FigmaAssets.navMic,
                    size: micIconSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
