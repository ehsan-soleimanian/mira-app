import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

double figmaSettingsScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final scale = width / 785;
  return scale.clamp(0.45, 1.0).toDouble();
}

EdgeInsets figmaInsets(
  BuildContext context,
  double left,
  double top,
  double right,
  double bottom,
) {
  final s = figmaSettingsScale(context);
  return EdgeInsets.fromLTRB(left * s, top * s, right * s, bottom * s);
}

class FigmaSettingsHeader extends StatelessWidget {
  const FigmaSettingsHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return MiraPageHeader(title: title, onBack: onBack);
  }
}

class FigmaSettingsSectionLabel extends StatelessWidget {
  const FigmaSettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 26 * s, 0, 20 * s),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 25 * s,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8F8F8F),
          height: 1,
        ),
      ),
    );
  }
}

class FigmaSettingsCard extends StatelessWidget {
  const FigmaSettingsCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15 * s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15 * s),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15 * s),
            border: Border.all(color: const Color(0xFFD9D9D9)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.isSaving = false,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onBack;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            MiraPageHeader(
              title: title,
              onBack: onBack ?? () => Navigator.of(context).pop(),
              trailing: isSaving
                  ? const SizedBox(
                      width: PageHeaderTokens.actionSize,
                      height: PageHeaderTokens.actionSize,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF9CA3AF)
        : AppColors.textHint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFF9CA3AF) : AppColors.textHint;
    final valueColor = isDark ? Colors.white : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: labelColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsErrorView extends StatelessWidget {
  const SettingsErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Peach icon box used across Figma-style settings screens.
class FigmaSettingsPeachIcon extends StatelessWidget {
  const FigmaSettingsPeachIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Container(
      width: 80 * s,
      height: 80 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2ED),
        borderRadius: BorderRadius.circular(13 * s),
      ),
      child: Icon(icon, size: 38 * s, color: const Color(0xFF756A66)),
    );
  }
}

/// Toggle row inside a [FigmaSettingsCard].
class FigmaSettingsToggleCard extends StatelessWidget {
  const FigmaSettingsToggleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return FigmaSettingsCard(
      padding: figmaInsets(context, 20, 22, 20, 22),
      child: Row(
        children: [
          FigmaSettingsPeachIcon(icon: icon),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 20 * s,
                    color: const Color(0xFF7A7A7A),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.micBlueNav,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Tappable info row inside a [FigmaSettingsCard].
class FigmaSettingsActionRow extends StatelessWidget {
  const FigmaSettingsActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return FigmaSettingsCard(
      padding: figmaInsets(context, 20, 22, 20, 22),
      onTap: onTap,
      child: Row(
        children: [
          FigmaSettingsPeachIcon(icon: icon),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 26 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 20 * s,
                    color: const Color(0xFF7A7A7A),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                size: 48 * s,
                color: const Color(0xFF202020),
              ),
        ],
      ),
    );
  }
}
