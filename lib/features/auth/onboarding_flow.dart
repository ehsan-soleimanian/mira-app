import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/auth/onboarding_flow_step.dart';
import 'package:mira_app/features/auth/screens/auth_screen.dart';
import 'package:mira_app/features/auth/screens/onboarding_first_capture_screen.dart';
import 'package:mira_app/features/auth/screens/onboarding_processing_screen.dart';
import 'package:mira_app/features/auth/screens/onboarding_your_details_screen.dart';
import 'package:mira_app/features/auth/screens/welcome_screen.dart';

/// Coordinates the onboarding flow (Figma welcome → auth → profile → capture).
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.onCompleted,
    this.initialName = '',
  });

  final VoidCallback onCompleted;
  final String initialName;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  OnboardingFlowStep _step = OnboardingFlowStep.welcome;
  AuthCredentialsStep _authStep = AuthCredentialsStep.email;
  String _displayName = '';
  bool _referralRequired = true;
  bool _authConfigLoading = false;
  final _authKey = GlobalKey<State<AuthScreen>>();

  @override
  void initState() {
    super.initState();
    _displayName = widget.initialName;
  }

  void _goTo(OnboardingFlowStep step) {
    setState(() => _step = step);
  }

  void _onWelcomeContinue() {
    _openAuthStep();
  }

  Future<void> _openAuthStep() async {
    setState(() => _authConfigLoading = true);
    try {
      final config = await AppScope.servicesOf(
        context,
      ).authRepository.fetchAuthConfig();
      if (mounted) _referralRequired = config.referralRequired;
    } catch (_) {
      if (mounted) _referralRequired = true;
    }
    if (!mounted) return;
    setState(() {
      _authConfigLoading = false;
      _authStep = AuthCredentialsStep.email;
      _step = OnboardingFlowStep.authEmail;
    });
  }

  void _onAuthStepChanged(AuthCredentialsStep step) {
    setState(() {
      _authStep = step;
      _step = switch (step) {
        AuthCredentialsStep.email => OnboardingFlowStep.authEmail,
        AuthCredentialsStep.invite => OnboardingFlowStep.authInvite,
        AuthCredentialsStep.emailCode => OnboardingFlowStep.authEmailCode,
      };
    });
  }

  Future<void> _afterAuth({required bool wasExistingUser}) async {
    final services = AppScope.servicesOf(context);
    if (!wasExistingUser) {
      try {
        final user = await services.authRepository.fetchMe();
        if (!mounted) return;
        setState(() {
          _displayName = user.displayName;
          _step = OnboardingFlowStep.yourDetails;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _displayName = '';
          _step = OnboardingFlowStep.yourDetails;
        });
      }
      return;
    }

    try {
      final user = await services.authRepository.fetchMe();
      if (user.onboardingCompleted) {
        await services.onboardingRepository.markCompletedLocally(user.id);
        widget.onCompleted();
        return;
      }
      setState(() {
        _displayName = user.displayName;
        _step = OnboardingFlowStep.yourDetails;
      });
    } catch (_) {
      setState(() {
        _displayName = '';
        _step = OnboardingFlowStep.yourDetails;
      });
    }
  }

  AuthCredentialsStep get _authCredentialsStep => switch (_step) {
        OnboardingFlowStep.authEmail => AuthCredentialsStep.email,
        OnboardingFlowStep.authInvite => AuthCredentialsStep.invite,
        OnboardingFlowStep.authEmailCode => AuthCredentialsStep.emailCode,
        _ => _authStep,
      };

  @override
  Widget build(BuildContext context) {
    if (_authConfigLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return switch (_step) {
      OnboardingFlowStep.welcome => WelcomeScreen(
          onContinue: _onWelcomeContinue,
        ),
      OnboardingFlowStep.authEmail ||
      OnboardingFlowStep.authInvite ||
      OnboardingFlowStep.authEmailCode =>
        AuthScreen(
          key: _authKey,
          step: _authCredentialsStep,
          referralRequired: _referralRequired,
          onStepChanged: _onAuthStepChanged,
          onExit: () => _goTo(OnboardingFlowStep.welcome),
          onSuccess: (wasExistingUser) =>
              _afterAuth(wasExistingUser: wasExistingUser),
        ),
      OnboardingFlowStep.yourDetails => OnboardingYourDetailsScreen(
          initialName: _displayName,
          onContinue: (name) {
            setState(() {
              _displayName = name;
              _step = OnboardingFlowStep.firstCapture;
            });
          },
        ),
      OnboardingFlowStep.firstCapture => OnboardingFirstCaptureScreen(
          onBack: () => _goTo(OnboardingFlowStep.yourDetails),
          onContinue: () => _goTo(OnboardingFlowStep.processing),
          onSkip: () => _goTo(OnboardingFlowStep.processing),
        ),
      OnboardingFlowStep.processing => OnboardingProcessingScreen(
          displayName: _displayName,
          onCompleted: widget.onCompleted,
        ),
    };
  }
}

/// @deprecated Use [OnboardingFlow] — kept as export alias for older imports.
typedef AuthFlow = OnboardingFlow;

/// @deprecated Use [OnboardingFlow] instead.
class OnboardingResumeScreen extends StatelessWidget {
  const OnboardingResumeScreen({
    super.key,
    required this.onCompleted,
    this.initialName = '',
  });

  final VoidCallback onCompleted;
  final String initialName;

  @override
  Widget build(BuildContext context) {
    return OnboardingFlow(
      initialName: initialName,
      onCompleted: onCompleted,
    );
  }
}
