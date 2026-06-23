import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Auth CTA — same navy [MiraButton] as Welcome «Next»; grey when inactive.
class AuthCtaButton extends StatelessWidget {
  const AuthCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;

    if (loading) {
      return const SizedBox(
        height: 53,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    return MiraButton(
      label: label,
      size: MiraButtonSize.large,
      expand: true,
      onPressed: active ? onPressed : null,
    );
  }
}

/// Muted Enter/Next CTA bound to a text controller — enables when [isReady].
///
/// Use for OTP, invite code, onboarding name fields, etc.
class AuthFormCtaButton extends StatelessWidget {
  const AuthFormCtaButton({
    super.key,
    required this.controller,
    required this.isReady,
    required this.onPressed,
    this.label = 'Enter',
    this.loading = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool Function(String text) isReady;
  final VoidCallback onPressed;
  final String label;
  final bool loading;
  /// Extra gate (e.g. block while recording).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final ready = isReady(value.text);
        final active = ready && !loading && enabled;
        return AuthCtaButton(
          label: label,
          loading: loading,
          enabled: active,
          onPressed: active ? onPressed : null,
        );
      },
    );
  }
}

/// OTP digit helpers — accepts ASCII + Persian/Arabic numerals.
abstract final class AuthOtp {
  static const length = 6;

  static String normalizeDigits(String raw) {
    final buffer = StringBuffer();
    for (final code in raw.runes) {
      if (code >= 0x30 && code <= 0x39) {
        buffer.writeCharCode(code);
      } else if (code >= 0x660 && code <= 0x669) {
        buffer.writeCharCode(0x30 + (code - 0x660));
      } else if (code >= 0x6f0 && code <= 0x6f9) {
        buffer.writeCharCode(0x30 + (code - 0x6f0));
      }
    }
    return buffer.toString();
  }

  static bool isComplete(String raw) => normalizeDigits(raw).length == length;
}

/// Keeps OTP input ASCII digits only (max 6).
class AuthOtpInputFormatter extends TextInputFormatter {
  const AuthOtpInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = AuthOtp.normalizeDigits(newValue.text);
    final clipped = normalized.length > AuthOtp.length
        ? normalized.substring(0, AuthOtp.length)
        : normalized;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  }
}

/// Centered "Or" divider between email and social auth.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFDCDCDC))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Or',
            style: TextStyle(
              color: Color(0xFF6E6E6E),
              fontSize: 16,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFDCDCDC))),
      ],
    );
  }
}

/// Outlined provider row — Google / Apple (Figma step 2).
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OnboardingTokens.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFDADADA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: OnboardingTokens.headlineColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Terms footer on the login screen.
class AuthLegalFooter extends StatelessWidget {
  const AuthLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'If you are creating a new account,\n',
        children: [
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' will apply.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: OnboardingTokens.subtitleColor,
        fontSize: 13,
        height: 1.55,
      ),
    );
  }
}

/// Orange shield icon for invite / OTP steps.
class AuthShieldBadge extends StatelessWidget {
  const AuthShieldBadge({super.key, this.verified = false});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2EB),
        shape: BoxShape.circle,
      ),
      child: Icon(
        verified ? Icons.verified_user_outlined : Icons.shield_outlined,
        color: const Color(0xFF776F6A),
        size: 38,
      ),
    );
  }
}

/// Six-box OTP entry (Figma step 4).
class AuthOtpField extends StatelessWidget {
  const AuthOtpField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.length = AuthOtp.length,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCompleted;
  final int length;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final digits = AuthOtp.normalizeDigits(value.text);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => focusNode.requestFocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              return SizedBox(
                height: 52,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.02,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: const [AuthOtpInputFormatter()],
                          onChanged: (raw) {
                            final normalized = AuthOtp.normalizeDigits(raw);
                            onChanged?.call(normalized);
                            if (AuthOtp.isComplete(normalized)) {
                              onCompleted?.call();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Row(
                        children: [
                          for (var i = 0; i < length; i++) ...[
                            Expanded(
                              child: _OtpDigitBox(
                                value: i < digits.length ? digits[i] : '',
                              ),
                            ),
                            if (i != length - 1) const SizedBox(width: gap),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: OnboardingTokens.headlineColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Shared auth step typography.
abstract final class AuthStepText {
  static const title = TextStyle(
    color: OnboardingTokens.headlineColor,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );

  static const subtitle = TextStyle(
    color: OnboardingTokens.subtitleColor,
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
}
