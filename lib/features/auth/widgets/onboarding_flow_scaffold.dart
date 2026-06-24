import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/features/auth/onboarding_flow_step.dart';
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
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MiraPageHeader(
                    showBack: onBack != null,
                    onBack: onBack,
                    title: centerTitle,
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
