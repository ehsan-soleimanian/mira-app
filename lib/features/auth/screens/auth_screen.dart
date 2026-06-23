import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/auth/onboarding_flow_step.dart';
import 'package:mira_app/features/auth/screens/auth_email_steps.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/features/auth/widgets/onboarding_flow_scaffold.dart';

/// Passwordless email substeps inside [OnboardingFlowStep] 2–4.
enum AuthCredentialsStep { email, invite, emailCode }

/// Passwordless email auth — steps 2–4 of the onboarding flow.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.step,
    required this.onStepChanged,
    required this.onExit,
    required this.onSuccess,
    this.referralRequired = true,
  });

  final AuthCredentialsStep step;
  final ValueChanged<AuthCredentialsStep> onStepChanged;
  final VoidCallback onExit;
  /// Callback after OTP verification.
  /// `wasExistingUser=false` means first-time signup and should enter onboarding.
  final ValueChanged<bool> onSuccess;

  /// From `GET /auth/config` — when false, back from OTP skips invite step.
  final bool referralRequired;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _inviteController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailFocus = FocusNode();
  final _inviteFocus = FocusNode();
  final _codeFocus = FocusNode();

  AuthCredentialsStep get _step => widget.step;
  bool _loading = false;
  String? _devEmailCode;
  bool _wasExistingUser = true;
  bool _referralRequired = true;

  @override
  void initState() {
    super.initState();
    _referralRequired = widget.referralRequired;
    _emailController.addListener(_refresh);
    _inviteController.addListener(_refresh);
    _codeController.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referralRequired != widget.referralRequired) {
      _referralRequired = widget.referralRequired;
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_refresh);
    _inviteController.removeListener(_refresh);
    _codeController.removeListener(_refresh);
    _emailController.dispose();
    _inviteController.dispose();
    _codeController.dispose();
    _emailFocus.dispose();
    _inviteFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    if (_loading) return false;
    return switch (_step) {
      AuthCredentialsStep.email => _emailController.text.trim().contains('@'),
      AuthCredentialsStep.invite => _inviteController.text.trim().length >= 6,
      AuthCredentialsStep.emailCode => AuthOtp.isComplete(_codeController.text),
    };
  }

  String get _otpCode => AuthOtp.normalizeDigits(_codeController.text);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    final auth = AppScope.servicesOf(context).authRepository;
    try {
      switch (_step) {
        case AuthCredentialsStep.email:
          final result = await auth.startEmailFlow(_emailController.text);
          if (!mounted) return;
          _wasExistingUser = result.existingUser;
          if (result.inviteRequired) {
            widget.onStepChanged(AuthCredentialsStep.invite);
            _inviteFocus.requestFocus();
          } else {
            _devEmailCode = result.devCode;
            _prefillDevCode(result.devCode);
            widget.onStepChanged(AuthCredentialsStep.emailCode);
            _codeFocus.requestFocus();
          }
        case AuthCredentialsStep.invite:
          final result = await auth.verifyInviteCode(
            email: _emailController.text,
            inviteCode: _inviteController.text,
          );
          if (!mounted) return;
          _devEmailCode = result.devCode;
          _prefillDevCode(result.devCode);
          widget.onStepChanged(AuthCredentialsStep.emailCode);
          _codeFocus.requestFocus();
        case AuthCredentialsStep.emailCode:
          await auth.verifyEmailCode(
            email: _emailController.text,
            code: _otpCode,
          );
          if (mounted) widget.onSuccess(_wasExistingUser);
      }
    } catch (error) {
      if (mounted) _snack(formatAuthError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prefillDevCode(String? code) {
    if (code == null || code.isEmpty) return;
    _codeController.value = TextEditingValue(
      text: AuthOtp.normalizeDigits(code),
    );
  }

  void _back() {
    if (_loading) return;
    if (_step == AuthCredentialsStep.email) {
      widget.onExit();
      return;
    }
    if (_step == AuthCredentialsStep.emailCode &&
        _referralRequired &&
        _inviteController.text.isNotEmpty) {
      widget.onStepChanged(AuthCredentialsStep.invite);
    } else {
      widget.onStepChanged(AuthCredentialsStep.email);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  OnboardingFlowStep get _flowStep => switch (_step) {
        AuthCredentialsStep.email => OnboardingFlowStep.authEmail,
        AuthCredentialsStep.invite => OnboardingFlowStep.authInvite,
        AuthCredentialsStep.emailCode => OnboardingFlowStep.authEmailCode,
      };

  @override
  Widget build(BuildContext context) {
    return OnboardingFlowScaffold(
      step: _flowStep,
      onBack: _back,
      centerTitle:
          _step == AuthCredentialsStep.email ? 'Login or sign up' : null,
      child: switch (_step) {
        AuthCredentialsStep.email => AuthEmailStep(
            emailController: _emailController,
            emailFocus: _emailFocus,
            loading: _loading,
            canSubmit: _canSubmit,
            onSubmit: _submit,
            onGoogle: () => _snack('Social sign-in is not enabled yet'),
            onApple: () => _snack('Social sign-in is not enabled yet'),
          ),
        AuthCredentialsStep.invite => AuthInviteStep(
            controller: _inviteController,
            focusNode: _inviteFocus,
            loading: _loading,
            canSubmit: _canSubmit,
            onSubmit: _submit,
          ),
        AuthCredentialsStep.emailCode => AuthEmailCodeStep(
            controller: _codeController,
            focusNode: _codeFocus,
            loading: _loading,
            canSubmit: _canSubmit,
            devCode: _devEmailCode,
            onSubmit: _submit,
            onResend: () {
              _codeController.clear();
              widget.onStepChanged(AuthCredentialsStep.email);
            },
          ),
      },
    );
  }
}
