import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/icons/daily_brief_nav_icon.dart';
import 'package:mira_app/widgets/icons/home_nav_icon.dart';
import 'package:mira_app/widgets/record_mic_button.dart';

/// Navbar پایین — asset Componnets-png/Navbar.png (396×100)
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

  static const _assetPath = 'Componnets-png/Navbar.png';
  static const _designW = 396.0;
  static const _designH = 100.0;
  static const _micDesignSize = 70.0;
  static const _micCenterFromTop = 35.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final s = screenW / _designW;
    final barH = _designH * s;
    final micSize = _micDesignSize * s;
    final micCenterFromBottom = (_designH - _micCenterFromTop) * s;
    final iconSize = 32 * s;

    final homeActive = activeTab == NavTab.home;
    final homeColor = homeActive ? AppColors.textPrimary : DailyBriefColors.navInactive;
    final briefColor = homeActive ? DailyBriefColors.navInactive : AppColors.textPrimary;

    final homeStyle = GoogleFonts.dosis(
      fontSize: 16 * s,
      fontWeight: homeActive ? FontWeight.w700 : FontWeight.w400,
      height: 1.25,
      color: homeColor,
    );
    final briefStyle = GoogleFonts.dosis(
      fontSize: 16 * s,
      fontWeight: homeActive ? FontWeight.w400 : FontWeight.w700,
      height: 1.25,
      color: briefColor,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        width: screenW,
        height: barH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                _assetPath,
                width: screenW,
                height: barH,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: screenW * (38 / 393),
              bottom: barH * 0.12,
              child: IgnorePointer(
                child: _NavTabMask(
                  width: iconSize + 56 * s,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HomeNavIcon(size: iconSize, color: homeColor),
                      SizedBox(height: 4 * s),
                      Text('Home', style: homeStyle),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: screenW * (24 / 393),
              bottom: barH * 0.12,
              child: IgnorePointer(
                child: _NavTabMask(
                  width: iconSize + 88 * s,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DailyBriefNavIcon(size: iconSize, color: briefColor),
                      SizedBox(height: 4 * s),
                      Text('Daily Brief', style: briefStyle),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: barH * 0.64,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onHomeTap,
                    ),
                  ),
                  SizedBox(width: micSize + 8),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDailyBriefTap,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: screenW / 2 - micSize / 2,
              bottom: micCenterFromBottom - micSize / 2,
              child: RecordMicButton(
                size: micSize,
                drawBackground: false,
                onShortTap: onVoiceShortTap,
                onRecordComplete: onRecordComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabMask extends StatelessWidget {
  const _NavTabMask({
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.navBarFill,
      alignment: Alignment.bottomCenter,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: child,
      ),
    );
  }
}
