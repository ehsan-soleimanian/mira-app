import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

/// LTR markdown body text for chat / capture surfaces.
class MiraMarkdownText extends StatelessWidget {
  const MiraMarkdownText({
    super.key,
    required this.data,
    this.scale = 1.0,
    this.fontSize = 16,
    this.color,
    this.textAlign = TextAlign.left,
    this.selectable = true,
  });

  final String data;
  final double scale;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bodyColor = color ?? AppColors.textPrimary;
    final base = GoogleFonts.dosis(
      fontSize: fontSize * s,
      height: 1.35,
      color: bodyColor,
    );

    final styleSheet = MarkdownStyleSheet(
      p: base,
      strong: base.copyWith(fontWeight: FontWeight.w700),
      em: base.copyWith(fontStyle: FontStyle.italic),
      h1: base.copyWith(fontSize: (fontSize + 6) * s, fontWeight: FontWeight.w700),
      h2: base.copyWith(fontSize: (fontSize + 4) * s, fontWeight: FontWeight.w700),
      h3: base.copyWith(fontSize: (fontSize + 2) * s, fontWeight: FontWeight.w600),
      listBullet: base,
      blockquote: base.copyWith(color: AppColors.textSecondary),
      code: GoogleFonts.dosis(
        fontSize: (fontSize - 1) * s,
        color: bodyColor,
        backgroundColor: const Color(0xFFF0F2F5),
      ),
      blockSpacing: 8 * s,
      listIndent: 20 * s,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MarkdownBody(
        data: data,
        selectable: selectable,
        styleSheet: styleSheet,
        shrinkWrap: true,
        fitContent: true,
      ),
    );
  }
}
