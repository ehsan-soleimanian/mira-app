import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_living_sphere.dart';

/// Pulsing Mira orb during capture processing (PRD: subtle glow while thinking).
class CaptureProcessingSphere extends StatelessWidget {
  const CaptureProcessingSphere({
    super.key,
    required this.size,
    this.processing = false,
  });

  final double size;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    return MiraLivingSphere(
      size: size,
      intensity: processing ? 1 : 0,
      processing: processing,
    );
  }
}
