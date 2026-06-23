import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/auth/onboarding_flow.dart';
import 'package:mira_app/screens/home/home_screen.dart';

/// Routes between onboarding flow and home based on session state.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _loggedIn;
  bool? _onboardingComplete;
  bool _bootstrapped = false;
  String _initialName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    final services = AppScope.servicesOf(context);
    final loggedIn = await services.authRepository.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      setState(() {
        _loggedIn = false;
        _onboardingComplete = null;
      });
      return;
    }

    var complete = false;
    try {
      final user = await services.authRepository.fetchMe();
      complete = user.onboardingCompleted;
      _initialName = user.displayName;
      if (complete) {
        await services.onboardingRepository.markCompletedLocally(user.id);
        final settings = await services.settingsRepository.fetchSettings();
        if (mounted) {
          AppScope.themeOf(context).setPreference(settings.theme);
        }
      }
    } catch (_) {
      complete = false;
    }

    if (mounted) {
      setState(() {
        _loggedIn = true;
        _onboardingComplete = complete;
      });
    }
  }

  void _onAuthenticated() {
    setState(() {
      _loggedIn = true;
      _onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_onboardingComplete == true) {
      return const HomeScreen();
    }

    return OnboardingFlow(
      initialName: _initialName,
      onCompleted: _onAuthenticated,
    );
  }
}
