import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

enum MiraTextVariant { headline, title, body, caption }

/// Base text atom — maps design typography to widgets.
class MiraText extends StatelessWidget {
  const MiraText(
    this.data, {
    super.key,
    this.variant = MiraTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final MiraTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final style = switch (variant) {
      MiraTextVariant.headline => AppTypography.dosis(
          size: 40,
          weight: FontWeight.w700,
          height: 1.3,
          color: color ?? AppColors.textPrimary,
        ),
      MiraTextVariant.title => AppTypography.dosis(
          size: 16,
          weight: FontWeight.w700,
          color: color ?? AppColors.textPrimary,
        ),
      MiraTextVariant.body => AppTypography.vazirmatn(
          size: 14,
          color: color ?? AppColors.textSecondary,
        ),
      MiraTextVariant.caption => AppTypography.vazirmatn(
          size: 12,
          color: color ?? AppColors.textHint,
        ),
    };

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
