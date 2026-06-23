import 'package:flutter/material.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Step progress dots — Figma onboarding flow (659:3546).
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = OnboardingSteps.count,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < totalSteps; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == currentStep ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? OnboardingTokens.progressActive
                  : OnboardingTokens.progressInactive,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}
