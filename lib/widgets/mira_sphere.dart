import 'package:flutter/material.dart';

/// گوی میرا — asset اصلی طراحی (145×145 @1x)
class MiraSphere extends StatelessWidget {
  const MiraSphere({super.key, this.size = 194});

  final double size;

  static const _assetPath = 'assets/images/mira_sphere.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
