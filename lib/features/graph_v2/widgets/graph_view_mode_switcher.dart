import 'package:flutter/material.dart';
import 'package:mira_app/models/api/graph_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// Toggle between knowledge / evidence / hybrid / tasks graph views.
class GraphViewModeSwitcher extends StatelessWidget {
  const GraphViewModeSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
    this.scale = 1,
  });

  final GraphViewMode value;
  final ValueChanged<GraphViewMode> onChanged;
  final double scale;

  static const _labels = {
    GraphViewMode.knowledge: 'Knowledge',
    GraphViewMode.evidence: 'Evidence',
    GraphViewMode.hybrid: 'Hybrid',
    GraphViewMode.tasks: 'Tasks',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: GraphViewMode.values.map((mode) {
          final selected = mode == value;
          return Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: ChoiceChip(
              label: Text(
                _labels[mode]!,
                style: AppTypography.dosis(
                  size: 13 * scale,
                  weight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: selected,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.surface,
              onSelected: (_) => onChanged(mode),
            ),
          );
        }).toList(),
      ),
    );
  }
}
