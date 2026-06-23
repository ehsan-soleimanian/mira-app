import 'package:flutter/material.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Selectable pill for role / gender onboarding steps.
class OnboardingChoiceChip extends StatelessWidget {
  const OnboardingChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: selected
            ? OnboardingTokens.chipSelectedFill
            : Colors.white,
        elevation: selected ? 2 : 0,
        shadowColor: OnboardingTokens.chipSelectedFill.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: selected
                ? OnboardingTokens.chipSelectedFill
                : OnboardingTokens.chipBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected
                    ? OnboardingTokens.chipSelectedText
                    : OnboardingTokens.headlineColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
