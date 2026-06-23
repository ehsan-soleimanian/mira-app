import 'package:flutter/material.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/mira_nav_config.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/mira_ear_nav_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/nav_bar_tokens.dart';

/// Interactive bottom-nav preview for the component catalog.
///
/// Shows **both** nav variants stacked so each is visible without toggling.
class BottomNavPreviewPane extends StatefulWidget {
  const BottomNavPreviewPane({super.key});

  @override
  State<BottomNavPreviewPane> createState() => _BottomNavPreviewPaneState();
}

class _BottomNavPreviewPaneState extends State<BottomNavPreviewPane> {
  NavTab _activeTab = NavTab.home;
  MiraNavVariant _appDefault = MiraNavConfig.variant;

  double _frameHeight(MiraNavVariant variant, double width) {
    final scale = width / NavBarTokens.designWidth;
    return switch (variant) {
      MiraNavVariant.cradle => NavBarTokens.designHeight * scale + 40,
      MiraNavVariant.earNotch => MiraEarNavTokens.totalHeight * scale + 16,
    };
  }

  void _onItemTap(NavTab tab) {
    setState(() => _activeTab = tab);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tab == NavTab.home ? 'Home' : 'Daily Brief'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _applyAsAppDefault(MiraNavVariant variant) {
    MiraNavConfig.variant = variant;
    setState(() => _appDefault = variant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('App nav set to ${variant.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFrame({
    required String title,
    required String figmaId,
    required MiraNavVariant variant,
    required double width,
  }) {
    final bg = variant == MiraNavVariant.earNotch
        ? MiraEarNavTokens.background
        : AppColors.background;
    final frameH = _frameHeight(variant, width);
    final isDefault = _appDefault == variant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$title · Figma $figmaId',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.micBlueNav.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'App default',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.micBlueNav,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: MiraSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: frameH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDefault ? AppColors.micBlueNav : AppColors.border,
                width: isDefault ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              clipBehavior: Clip.none,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: Text(
                      _activeTab == NavTab.home ? 'Home' : 'Daily Brief',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: variant == MiraNavVariant.earNotch
                            ? MiraEarNavTokens.activeColor
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: variant == MiraNavVariant.cradle
                        ? MiraBottomNav(
                            activeTab: _activeTab,
                            onHomeTap: () => _onItemTap(NavTab.home),
                            onDailyBriefTap: () =>
                                _onItemTap(NavTab.dailyBrief),
                            onVoiceShortTap: () =>
                                _showMicSnack(context),
                          )
                        : MiraBottomNavBar(
                            activeTab: _activeTab,
                            onItemTap: _onItemTap,
                            onMicShortTap: () => _showMicSnack(context),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isDefault
                ? null
                : () => _applyAsAppDefault(variant),
            child: Text(isDefault ? 'Active in app' : 'Use in app'),
          ),
        ),
      ],
    );
  }

  void _showMicSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mic short tap'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - MiraSpacing.md * 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap the grid icon on Home (top-left) or Settings → Component library.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
              ),
        ),
        const SizedBox(height: MiraSpacing.md),
        _buildFrame(
          title: 'Cradle',
          figmaId: '741:4963',
          variant: MiraNavVariant.cradle,
          width: width,
        ),
        const SizedBox(height: MiraSpacing.lg),
        _buildFrame(
          title: 'Ear notch',
          figmaId: '741:4986',
          variant: MiraNavVariant.earNotch,
          width: width,
        ),
      ],
    );
  }
}
