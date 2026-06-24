import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/components/molecules/mira_back_button.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

/// Consistent top bar — back, centered title, and optional trailing action.
///
/// Place inside [SafeArea] so header controls stay below the status bar on
/// every screen.
class MiraPageHeader extends StatelessWidget {
  const MiraPageHeader({
    super.key,
    this.title,
    this.center,
    this.leading,
    this.trailing,
    this.onBack,
    this.showBack = true,
    this.titleStyle,
  });

  final String? title;
  final Widget? center;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;

    final leadingWidget =
        leading ??
        (showBack
            ? MiraBackButton(
                onTap: onBack,
                size: PageHeaderTokens.actionSize,
              )
            : const SizedBox(width: PageHeaderTokens.actionSize));

    final trailingWidget =
        trailing ?? const SizedBox(width: PageHeaderTokens.actionSize);

    final Widget centerWidget;
    if (center != null) {
      centerWidget = center!;
    } else if (title != null) {
      centerWidget = Text(
        title!,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style:
            titleStyle ??
            GoogleFonts.dosis(
              fontSize: PageHeaderTokens.titleFontSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: titleColor,
            ),
      );
    } else {
      centerWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PageHeaderTokens.horizontalPadding,
        PageHeaderTokens.topPadding,
        PageHeaderTokens.horizontalPadding,
        PageHeaderTokens.bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leadingWidget,
          Expanded(child: Center(child: centerWidget)),
          trailingWidget,
        ],
      ),
    );
  }
}
