import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_back_button.dart';
import 'package:mira_app/features/auth/onboarding_flow_step.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Shared chrome for auth steps 2–4 (back + optional title).
class OnboardingFlowScaffold extends StatelessWidget {
  const OnboardingFlowScaffold({
    super.key,
    required this.step,
    required this.child,
    this.onBack,
    this.centerTitle,
  });

  final OnboardingFlowStep step;
  final Widget child;
  final VoidCallback? onBack;
  final String? centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (onBack != null)
                        MiraBackButton(size: 58, onTap: onBack)
                      else
                        const SizedBox(width: 58),
                      Expanded(
                        child: centerTitle == null
                            ? const SizedBox.shrink()
                            : Text(
                                centerTitle!,
                                textAlign: TextAlign.center,
                                style: AppTypography.dosis(
                                  size: 20,
                                  weight: FontWeight.w800,
                                  color: OnboardingTokens.headlineColor,
                                ),
                              ),
                      ),
                      const SizedBox(width: 58),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
