import 'package:flutter/material.dart';

/// PromptInputBar — asset Componnets-png/PromptInputBar.png (346×55)
class PromptInputBar extends StatelessWidget {
  const PromptInputBar({
    super.key,
    this.onAddTap,
    this.onFieldTap,
    this.onMicTap,
  });

  final VoidCallback? onAddTap;
  final VoidCallback? onFieldTap;
  final VoidCallback? onMicTap;

  static const _assetPath = 'Componnets-png/PromptInputBar.png';
  static const _designW = 346.0;
  static const _designH = 55.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final s = screenW / 393.0;
    final barW = _designW * s;
    final barH = _designH * s;
    final hPad = (screenW - barW) / 2;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 12 * s),
      child: SizedBox(
        width: screenW,
        height: barH,
        child: Stack(
          children: [
            Positioned(
              left: hPad,
              child: Image.asset(
                _assetPath,
                width: barW,
                height: barH,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: hPad,
              width: barW,
              height: barH,
              child: Row(
                children: [
                  SizedBox(
                    width: barH,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAddTap,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFieldTap,
                    ),
                  ),
                  SizedBox(
                    width: barH * 0.85,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onMicTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
