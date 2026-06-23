import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Step 2 — Login or sign up (email + social).
class AuthEmailStep extends StatelessWidget {
  const AuthEmailStep({
    super.key,
    required this.emailController,
    required this.emailFocus,
    required this.loading,
    required this.canSubmit,
    required this.onSubmit,
    required this.onGoogle,
    required this.onApple,
  });

  final TextEditingController emailController;
  final FocusNode emailFocus;
  final bool loading;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MiraInputField(
          controller: emailController,
          focusNode: emailFocus,
          hintText: 'Enter Your Email',
          showMic: false,
          variant: MiraInputVariant.flat,
          radius: ComposerTokens.flatFieldRadius,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          height: 58,
        ),
        const SizedBox(height: 18),
        AuthFormCtaButton(
          controller: emailController,
          isReady: (text) => text.trim().contains('@'),
          label: 'Continue',
          loading: loading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 46),
        const AuthOrDivider(),
        const SizedBox(height: 28),
        AuthSocialButton(
          label: 'Continue with Google',
          leading: const Text(
            'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: loading ? null : onGoogle,
        ),
        const SizedBox(height: 12),
        AuthSocialButton(
          label: 'Continue with Apple',
          leading: const Icon(
            Icons.apple,
            color: Color(0xFF1F2029),
            size: 28,
          ),
          onPressed: loading ? null : onApple,
        ),
        const Spacer(),
        const AuthLegalFooter(),
      ],
    );
  }
}

/// Step 3 — Invite code.
class AuthInviteStep extends StatelessWidget {
  const AuthInviteStep({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.canSubmit,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: AuthShieldBadge(verified: true)),
        const SizedBox(height: 26),
        const Text(
          'You need an invite code to join Mira.',
          style: AuthStepText.title,
        ),
        const SizedBox(height: 12),
        const Text('Enter 6-digit code', style: AuthStepText.subtitle),
        const SizedBox(height: 30),
        MiraInputField(
          controller: controller,
          focusNode: focusNode,
          hintText: 'code',
          showMic: false,
          variant: MiraInputVariant.flat,
          radius: ComposerTokens.flatFieldRadius,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          height: 58,
        ),
        const Spacer(),
        AuthFormCtaButton(
          controller: controller,
          isReady: (text) => text.trim().length >= 6,
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

/// Step 4 — Email OTP verification.
class AuthEmailCodeStep extends StatelessWidget {
  const AuthEmailCodeStep({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.canSubmit,
    required this.devCode,
    required this.onSubmit,
    required this.onResend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final bool canSubmit;
  final String? devCode;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        const Center(child: AuthShieldBadge()),
        const SizedBox(height: 34),
        const Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: AuthStepText.title,
        ),
        const SizedBox(height: 18),
        const Text(
          'We sent you a 6-digit code',
          textAlign: TextAlign.center,
          style: AuthStepText.subtitle,
        ),
        const SizedBox(height: 34),
        AuthOtpField(
          controller: controller,
          focusNode: focusNode,
          onCompleted: onSubmit,
        ),
        if (devCode != null) ...[
          const SizedBox(height: 14),
          Text(
            'Dev code: $devCode',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: OnboardingTokens.mutedText,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 42),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't get the code? ",
              style: TextStyle(
                color: OnboardingTokens.subtitleColor,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: loading ? null : onResend,
              child: const Text(
                'Resend',
                style: TextStyle(
                  color: OnboardingTokens.subtitleColor,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const Spacer(flex: 3),
        AuthFormCtaButton(
          controller: controller,
          isReady: AuthOtp.isComplete,
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
