import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/figma_svg_icon.dart';
import 'package:mira_app/components/molecules/mira_ear_nav_mic_button.dart';
import 'package:mira_app/components/molecules/mira_ear_notch_bar_painter.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';

/// Neumorphic bottom navigation bar with twin ear notches (Figma 741:4986).
///
/// Place in a [Stack] at the bottom — the mic button overflows the top edge.
class MiraBottomNavBar extends StatelessWidget {
  const MiraBottomNavBar({
    super.key,
    this.activeTab = NavTab.home,
    this.onItemTap,
    this.onMicTap,
    this.onMicShortTap,
    this.onRecordingStart,
    this.recordingActive = false,
    this.recordingProgress = 0,
  });

  final NavTab activeTab;
  final ValueChanged<NavTab>? onItemTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onMicShortTap;
  final VoidCallback? onRecordingStart;
  final bool recordingActive;
  final double recordingProgress;

  static double scaleOf(double width) => width / MiraEarNavTokens.designWidth;

  static double totalHeightFor(double width) =>
      MiraEarNavTokens.totalHeight * scaleOf(width);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = scaleOf(width);
    final totalH = MiraEarNavTokens.totalHeight * scale;
    final itemH = MiraEarNavTokens.itemAreaHeight * scale;
    final fabSize = MiraEarNavTokens.fabSize * scale;
    final fabTop = MiraEarNavTokens.fabTop * scale;
    final clearance = MiraEarNavTokens.fabClearance * scale;
    final micSize = MiraEarNavTokens.micIconSize * scale;

    return SizedBox(
      height: totalH,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: MiraEarNotchBarPainter(scale: scale)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: itemH,
            child: Row(
              children: [
                Expanded(
                  child: _EarNavItem(
                    label: 'Home',
                    selected: activeTab == NavTab.home,
                    onTap: () => onItemTap?.call(NavTab.home),
                    icon: FigmaSvgIcon(
                      asset: FigmaAssets.navHome,
                      size: 26 * scale,
                      opacity: activeTab == NavTab.home ? 1 : 0.55,
                    ),
                  ),
                ),
                SizedBox(width: fabSize + clearance),
                Expanded(
                  child: _EarNavItem(
                    label: 'Daily Brief',
                    selected: activeTab == NavTab.dailyBrief,
                    onTap: () => onItemTap?.call(NavTab.dailyBrief),
                    icon: FigmaSvgIcon(
                      asset: FigmaAssets.navCoffee,
                      size: 26 * scale,
                      opacity: activeTab == NavTab.dailyBrief ? 1 : 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: fabTop,
            left: 0,
            right: 0,
            child: Center(
              child: MiraEarNavMicButton(
                size: fabSize,
                scale: scale,
                micIconSize: micSize,
                onTap: onMicTap,
                onShortTap: onMicShortTap,
                onRecordingStart: onRecordingStart,
                recordingActive: recordingActive,
                recordingProgress: recordingProgress,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarNavItem extends StatelessWidget {
  const _EarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? MiraEarNavTokens.activeColor
        : MiraEarNavTokens.inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1,
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
