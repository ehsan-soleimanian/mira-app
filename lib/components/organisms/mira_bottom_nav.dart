import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/figma_svg_icon.dart';
import 'package:mira_app/components/molecules/mira_ear_nav_mic_button.dart';
import 'package:mira_app/components/molecules/nav_bar_shell_painter.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';

/// Bottom navbar — Figma frame 741:4963.
class MiraBottomNav extends StatelessWidget {
  const MiraBottomNav({
    super.key,
    this.activeTab = NavTab.home,
    this.onHomeTap,
    this.onVoiceShortTap,
    this.onRecordingStart,
    this.recordingActive = false,
    this.recordingProgress = 0,
    this.onDailyBriefTap,
  });

  final NavTab activeTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onVoiceShortTap;
  final VoidCallback? onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;
  final VoidCallback? onDailyBriefTap;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = screenW / NavBarTokens.designWidth;
    final barH = NavBarTokens.designHeight * scale;
    final panelTop = barH * NavBarTokens.panelTopFactor;
    final iconSize = NavBarTokens.iconSize * scale;
    final micButtonSize = MiraEarNavTokens.fabSize * scale;
    final micIconSize = MiraEarNavTokens.micIconSize * scale;
    final homeActive = activeTab == NavTab.home;
    final dailyBriefActive = activeTab == NavTab.dailyBrief;
    final inactive = NavBarTokens.inactiveOpacity;

    final iconY = panelTop + NavBarTokens.iconTopInPanel * scale;
    final labelY = panelTop + NavBarTokens.labelTopInPanel * scale;
    final dailyBriefLabelX =
        screenW / 2 + NavBarTokens.dailyBriefLabelCenterOffset * scale;

    final barSize = Size(screenW, barH);
    final fabCenter = NavBarPathBuilder.fabCenter(barSize, scale);
    final fabLeft = fabCenter.dx - micButtonSize / 2;
    final fabTop = fabCenter.dy - micButtonSize / 2;

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
              child: _NavItem(
                label: 'Home',
                selected: homeActive,
                onTap: onHomeTap,
                icon: FigmaSvgIcon(
                  asset: FigmaAssets.navHome,
                  size: iconSize,
                  opacity: homeActive ? 1 : inactive,
                ),
                labelLeft:
                    (NavBarTokens.homeLabelLeft - NavBarTokens.homeIconLeft) *
                    scale,
                labelTop: labelY - iconY,
                scale: scale,
              ),
            ),
            Positioned(
              left: NavBarTokens.coffeeIconLeft * scale,
              top: iconY,
              width: screenW - NavBarTokens.coffeeIconLeft * scale,
              height: iconSize + (labelY - iconY) + 20 * scale,
              child: _NavItem(
                label: 'Daily Brief',
                selected: dailyBriefActive,
                onTap: onDailyBriefTap,
                icon: FigmaSvgIcon(
                  asset: FigmaAssets.navCoffee,
                  size: iconSize,
                  opacity: dailyBriefActive ? 1 : inactive,
                ),
                labelLeft:
                    dailyBriefLabelX - NavBarTokens.coffeeIconLeft * scale,
                labelTop: labelY - iconY,
                scale: scale,
              ),
            ),
            Positioned(
              left: fabLeft,
              top: fabTop,
              width: micButtonSize,
              height: micButtonSize,
              child: MiraEarNavMicButton(
                size: micButtonSize,
                scale: scale,
                micIconSize: micIconSize,
                onShortTap: onVoiceShortTap,
                onRecordingStart: onRecordingStart,
                recordingActive: recordingActive,
                recordingProgress: recordingProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.labelLeft,
    required this.labelTop,
    required this.scale,
    this.onTap,
  });

  final String label;
  final Widget icon;
  final bool selected;
  final double labelLeft;
  final double labelTop;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = selected
        ? AppTypography.navActive(scale)
        : AppTypography.navInactive(scale).copyWith(
            color: AppColors.textPrimary.withValues(
              alpha: NavBarTokens.inactiveOpacity,
            ),
          );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              left: labelLeft,
              top: labelTop,
              child: Text(label, style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}
