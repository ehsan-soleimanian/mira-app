import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Interactive task checkbox — Figma task card (618:2893 / 672:7695).
class TaskBriefCheckbox extends StatelessWidget {
  const TaskBriefCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 22,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      button: true,
      label: checked ? 'Task completed' : 'Task not completed',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!checked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: size,
          height: size,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: checked ? DailyBriefColors.checkboxBorder : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: DailyBriefColors.checkboxBorder,
              width: 1.8,
            ),
          ),
          child: checked
              ? Icon(
                  Icons.check_rounded,
                  size: size * 0.72,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
