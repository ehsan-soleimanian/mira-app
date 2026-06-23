import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads a Figma-exported SVG asset with optional size and opacity.
class FigmaSvgIcon extends StatelessWidget {
  const FigmaSvgIcon({
    super.key,
    required this.asset,
    required this.size,
    this.opacity = 1,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double size;
  final double opacity;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: fit,
      semanticsLabel: '',
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
    );

    if (opacity >= 1) return icon;
    return Opacity(opacity: opacity, child: icon);
  }
}

/// Preloads SVG assets at startup to avoid first-frame loader issues.
Future<void> preloadFigmaSvgAssets(Iterable<String> assets) {
  return Future.wait(
    assets.map((path) {
      final loader = SvgAssetLoader(path);
      return svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }),
  );
}
