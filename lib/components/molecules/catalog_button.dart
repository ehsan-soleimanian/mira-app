import 'package:flutter/material.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/screens/catalog/component_catalog_screen.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Opens the in-app component library (design system previews).
class CatalogButton extends StatelessWidget {
  const CatalogButton({super.key, this.onTap, this.size = 48});

  final VoidCallback? onTap;
  final double size;

  void _openCatalog(BuildContext context) {
    Navigator.of(context).pushMira((_) => const ComponentCatalogScreen());
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = size * (22 / 48);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _openCatalog(context),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              Icons.widgets_outlined,
              size: iconSize,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
