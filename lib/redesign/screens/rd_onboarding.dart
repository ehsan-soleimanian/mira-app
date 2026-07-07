import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// First-run onboarding — splash → login → invite → email code → details →
/// remember → understood, then into the app. Faithful to `onboarding.jsx`
/// (`.ob-*`). Login/invite/email are wired to the real auth backend
/// (`AuthRepository`): the email flow obtains and stores session tokens, and
/// the [main] auth gate boots returning users straight past this flow.

/// Shows a transient error toast for a failed auth step.
void _authError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

/// The peri CTA fill (`_ObVariant.peri`) is a fixed brand accent — white text
/// rides on it in both themes, matching `RdColors.peri` / `context.rd.peri`.
const _peri = Color(0xFF7E8BC9);

/// A few neutral control surfaces here (input fills, glass circles, badge
/// backgrounds) have no palette token. To keep light rendering byte-identical
/// while still flipping for dark, pick the exact light literal in light mode
/// and a dark-tuned value otherwise.
bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Formats a [Color] as an `#RRGGBB` string for inline SVG `fill` attributes
/// (used by the brand-mark icons that must flip with the palette).
String _hex(Color c) {
  final r = (c.r * 255.0).round() & 0xff;
  final g = (c.g * 255.0).round() & 0xff;
  final b = (c.b * 255.0).round() & 0xff;
  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

// ── 1. Splash ──────────────────────────────────────────────────────────
class RdSplashScreen extends StatelessWidget {
  const RdSplashScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 5),
              Text(
                'Mira. Your\nsecond mind.',
                style: GoogleFonts.dosis(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 260,
                child: Text(
                  'A second mind. For when you don’t want to forget anything.',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    height: 1.5,
                    color: rd.muted,
                  ),
                ),
              ),
              const Spacer(flex: 4),
              _ObButton(
                label: 'See how it works',
                variant: _ObVariant.navy,
                onTap: () => go('login'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 2. Login ───────────────────────────────────────────────────────────
class RdLoginScreen extends StatefulWidget {
  const RdLoginScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdLoginScreen> createState() => _RdLoginScreenState();
}

class _RdLoginScreenState extends State<RdLoginScreen> {
  final _email = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  /// Start the email flow: the backend sends a code and tells us whether an
  /// invite gate is required, so we branch to 'invite' or straight to 'email'.
  Future<void> _continue() async {
    if (_busy) return;
    final email = _email.text.trim();
    if (!email.contains('@') || email.length < 5) {
      _authError(context, 'Enter a valid email address.');
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await AppScope.servicesOf(context)
          .authRepository
          .startEmailFlow(email);
      if (!mounted) return;
      widget.go(res.inviteRequired ? 'invite' : 'email', arg: email);
    } catch (_) {
      if (mounted) _authError(context, 'Could not send a code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Exchange a Google ID token for a MIRA session, then enter the app.
  Future<void> _google() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final services = AppScope.servicesOf(context);
      final idToken = await services.googleSignInService.signInAndGetIdToken();
      if (idToken == null) {
        if (mounted) setState(() => _busy = false);
        return; // cancelled, or Google isn't configured on this build
      }
      final session =
          await services.authRepository.signInWithGoogle(idToken: idToken);
      if (mounted) {
        // New Google users still run first-run setup; returning users go home.
        widget.go(session.user.onboardingCompleted ? 'home' : 'details');
      }
    } catch (_) {
      if (mounted) _authError(context, 'Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _ObHeader(
                title: 'Login or sign up',
                onBack: () => widget.go('splash'),
              ),
              const SizedBox(height: 24),
              _ObInput(
                hint: 'Enter Your Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _continue(),
                autofocus: true,
              ),
              const SizedBox(height: 14),
              _ObButton(
                label: 'Continue',
                variant: _ObVariant.navy,
                loading: _busy,
                onTap: _continue,
              ),
              const _OrDivider(),
              _ObButton(
                label: 'Continue with Google',
                variant: _ObVariant.social,
                leading: const _GoogleIcon(),
                onTap: _google,
              ),
              const SizedBox(height: 12),
              _ObButton(
                label: 'Continue with Apple',
                variant: _ObVariant.social,
                leading: const _AppleIcon(),
                onTap: () => _authError(context, 'Apple sign-in is coming soon.'),
              ),
              const Spacer(),
              Text(
                'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  height: 1.5,
                  color: rd.muted,
                ),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 3. Invite code ─────────────────────────────────────────────────────
class RdInviteScreen extends StatefulWidget {
  const RdInviteScreen({super.key, required this.go, this.email});

  final RdGo go;

  /// Email carried forward from the login step (needed to verify the invite).
  final String? email;

  @override
  State<RdInviteScreen> createState() => _RdInviteScreenState();
}

class _RdInviteScreenState extends State<RdInviteScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = widget.email;
    if (email == null) {
      widget.go('login'); // lost the flow state — restart cleanly
      return;
    }
    final code = _code.text.trim();
    if (code.isEmpty) {
      _authError(context, 'Enter your invite code.');
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await AppScope.servicesOf(context)
          .authRepository
          .verifyInviteCode(email: email, inviteCode: code);
      if (!mounted) return;
      if (res.accepted) {
        widget.go('email', arg: email);
      } else {
        _authError(context, 'That invite code was not accepted.');
      }
    } catch (_) {
      if (mounted) _authError(context, 'Could not verify the code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ObFormScaffold(
      onBack: () => widget.go('login'),
      badge: RdIcons.shieldCheck,
      title: 'You need an invite code to join Mira.',
      desc: 'Enter your invite code',
      input: _ObInput(
        hint: 'Code',
        controller: _code,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _submit(),
        autofocus: true,
      ),
      ctaLabel: 'Enter',
      ctaVariant: _ObVariant.peri,
      busy: _busy,
      onCta: _submit,
    );
  }
}

// ── 4. Email code (OTP) ────────────────────────────────────────────────
class RdEmailCodeScreen extends StatefulWidget {
  const RdEmailCodeScreen({super.key, required this.go, this.email});

  final RdGo go;

  /// Email carried forward from login/invite (needed to verify the code).
  final String? email;

  @override
  State<RdEmailCodeScreen> createState() => _RdEmailCodeScreenState();
}

class _RdEmailCodeScreenState extends State<RdEmailCodeScreen> {
  String _code = '';
  bool _busy = false;

  /// Verify the emailed code. On success the repository stores the session
  /// tokens, so from here the app is authenticated.
  Future<void> _submit() async {
    if (_busy) return;
    final email = widget.email;
    if (email == null) {
      widget.go('login');
      return;
    }
    if (_code.trim().length < 4) {
      _authError(context, 'Enter the code we emailed you.');
      return;
    }
    setState(() => _busy = true);
    try {
      final user = await AppScope.servicesOf(context)
          .authRepository
          .verifyEmailCode(email: email, code: _code.trim());
      if (!mounted) return;
      // Returning users (already onboarded) skip straight into the app.
      widget.go(user.onboardingCompleted ? 'home' : 'details', arg: email);
    } catch (_) {
      if (mounted) _authError(context, 'That code did not match. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final email = widget.email;
    if (email == null || _busy) return;
    try {
      await AppScope.servicesOf(context).authRepository.startEmailFlow(email);
      if (mounted) _authError(context, 'We sent a new code.');
    } catch (_) {
      if (mounted) _authError(context, 'Could not resend the code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ObHeader(onBack: () => widget.go('invite')),
              const SizedBox(height: 26),
              const _ObBadge(icon: RdIcons.shield),
              const SizedBox(height: 16),
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.dosis(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We sent you a 6-digit code',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  height: 1.5,
                  color: rd.muted,
                ),
              ),
              const SizedBox(height: 26),
              _OtpRow(
                length: 6,
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn’t get the code? ',
                    style:
                        GoogleFonts.vazirmatn(fontSize: 13, color: rd.muted),
                  ),
                  GestureDetector(
                    onTap: _resend,
                    child: Text(
                      'Resend',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rd.navy,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _ObButton(
                label: 'Enter',
                variant: _ObVariant.peri,
                loading: _busy,
                onTap: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 5. Details ─────────────────────────────────────────────────────────
class RdDetailsScreen extends StatefulWidget {
  const RdDetailsScreen({super.key, required this.go, this.email});

  final RdGo go;
  final String? email;

  @override
  State<RdDetailsScreen> createState() => _RdDetailsScreenState();
}

class _RdDetailsScreenState extends State<RdDetailsScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  // The name is confirmed and persisted in the setup wizard's onboarding POST;
  // here we just collect it and move on.
  void _next() => widget.go('remember');

  @override
  Widget build(BuildContext context) {
    return _ObFormScaffold(
      onBack: () => widget.go('email'),
      badge: RdIcons.user,
      title: 'Your details',
      desc: 'This is how Mira will greet you. You can change it later in Settings.',
      input: _ObInput(
        hint: 'your name',
        controller: _name,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _next(),
        autofocus: true,
      ),
      ctaLabel: 'Enter',
      ctaVariant: _ObVariant.peri,
      onCta: _next,
    );
  }
}

// ── 6. Remember (record moment) ────────────────────────────────────────
class RdRememberScreen extends StatefulWidget {
  const RdRememberScreen({super.key, required this.go});

  final RdGo go;

  @override
  State<RdRememberScreen> createState() => _RdRememberScreenState();
}

class _RdRememberScreenState extends State<RdRememberScreen> {
  bool _recording = false;
  int _sec = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _recording = true;
      _sec = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _sec++);
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _recording = false);
    widget.go('understood');
  }

  String get _time =>
      '${(_sec ~/ 60).toString().padLeft(2, '0')}:${(_sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _ObHeader(onBack: () => widget.go('details')),
              ),
              const SizedBox(height: 8),
              RdOrb(size: 120, ring: !_recording),
              const SizedBox(height: 26),
              Text(
                'What do you want Mira to remember?',
                textAlign: TextAlign.center,
                style: GoogleFonts.dosis(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Anything you don’t want to forget. An idea. A task. A link. Even a feeling.',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  height: 1.5,
                  color: rd.muted,
                ),
              ),
              const Spacer(),
              if (_recording) ...[
                _ObStopButton(onTap: _stop),
                const SizedBox(height: 14),
                Text(
                  _time,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: rd.ink,
                    fontFeatures: const [],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TAP TO STOP',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 10,
                    color: rd.muted,
                    letterSpacing: 0.6,
                  ),
                ),
              ] else ...[
                Text(
                  'Press the button and speak or type',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    height: 1.5,
                    color: rd.muted,
                  ),
                ),
                const SizedBox(height: 22),
                _RecordButton(onTap: _start),
              ],
              const Spacer(),
              _ObButton(
                label: 'Next',
                variant: _ObVariant.peri,
                onTap: () => widget.go('understood'),
              ),
              const SizedBox(height: 12),
              _ObButton(
                label: 'I’ll do it later',
                variant: _ObVariant.ghost,
                onTap: () => widget.go('home'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 7. Understood ──────────────────────────────────────────────────────
class RdUnderstoodScreen extends StatelessWidget {
  const RdUnderstoodScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _ObHeader(onBack: () => go('remember')),
              ),
              const SizedBox(height: 8),
              const RdOrb(size: 120),
              const SizedBox(height: 26),
              Opacity(
                opacity: 0.35,
                child: Text(
                  'What do you want Mira to remember?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dosis(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: rd.ink,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'MIRA understands you',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: rd.navy,
                ),
              ),
              const Spacer(),
              _ObButton(
                label: 'Next',
                variant: _ObVariant.navy,
                onTap: () => go('wizard'),
              ),
              const SizedBox(height: 12),
              _ObButton(
                label: 'I’ll do it later',
                variant: _ObVariant.ghost,
                onTap: () => go('home'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ══ shared building blocks ═════════════════════════════════════════════

/// Standard "badge + title + desc + input + bottom CTA" onboarding page.
class _ObFormScaffold extends StatelessWidget {
  const _ObFormScaffold({
    required this.onBack,
    required this.badge,
    required this.title,
    required this.desc,
    required this.input,
    required this.ctaLabel,
    required this.ctaVariant,
    required this.onCta,
    this.busy = false,
  });

  final VoidCallback onBack;
  final String badge;
  final String title;
  final String desc;
  final Widget input;
  final String ctaLabel;
  final _ObVariant ctaVariant;
  final VoidCallback onCta;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ObHeader(onBack: onBack),
              const SizedBox(height: 26),
              _ObBadge(icon: badge),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.dosis(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  height: 1.5,
                  color: rd.muted,
                ),
              ),
              const SizedBox(height: 22),
              input,
              const Spacer(),
              _ObButton(
                label: ctaLabel,
                variant: ctaVariant,
                loading: busy,
                onTap: onCta,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObHeader extends StatelessWidget {
  const _ObHeader({required this.onBack, this.title});

  final VoidCallback onBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final dark = _isDark(context);
    // Glass back-button circle: keep the exact light glass (white 0.7 on the
    // pale page) in light mode; on dark, sit it on a lifted card-tinted disc so
    // it doesn't glare, with a hairline border matching the palette line.
    final circleFill =
        dark ? rd.card.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7);
    final circleBorder = dark
        ? rd.line.withValues(alpha: 0.9)
        : const Color(0xFFEDF1FF).withValues(alpha: 0.9);
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleFill,
                  border: Border.all(
                    color: circleBorder,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF141632).withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: RdIcon(
                    RdIcons.arrowLeft,
                    size: 22,
                    stroke: '#1A1C29',
                    strokeWidth: 1.6,
                    color: rd.ink,
                  ),
                ),
              ),
            ),
          ),
          if (title != null)
            Center(
              child: Text(
                title!,
                style: GoogleFonts.dosis(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ObBadge extends StatelessWidget {
  const _ObBadge({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rd.line, width: 1),
      ),
      // Navy brand glyph — kept fixed across themes (a colored accent, like the
      // peri/navy CTAs), reading against the card tint beneath it.
      child: Center(
        child: RdIcon(icon, size: 26, stroke: '#293D8C', strokeWidth: 1.7),
      ),
    );
  }
}

class _ObInput extends StatelessWidget {
  const _ObInput({
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        // Vivid brand focus blue — kept fixed across themes.
        cursorColor: const Color(0xFF3D63F5),
        style: GoogleFonts.vazirmatn(fontSize: 14, color: rd.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.vazirmatn(fontSize: 14, color: rd.faint),
          filled: true,
          fillColor: rd.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: rd.line, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3D63F5), width: 1.5),
          ),
        ),
      ),
    );
  }
}

enum _ObVariant { navy, peri, social, ghost }

class _ObButton extends StatelessWidget {
  const _ObButton({
    required this.label,
    required this.variant,
    required this.onTap,
    this.leading,
    this.loading = false,
  });

  final String label;
  final _ObVariant variant;
  final VoidCallback onTap;
  final Widget? leading;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    late final Color bg;
    late final Color fg;
    BoxBorder? border;
    switch (variant) {
      case _ObVariant.navy:
        // Fixed navy CTA with white label — constant across themes.
        bg = const Color(0xFF14328C);
        fg = Colors.white;
      case _ObVariant.peri:
        // Fixed peri CTA with white label — constant across themes.
        bg = _peri;
        fg = Colors.white;
      case _ObVariant.social:
        // Ambient card button — surface, ink and hairline all flip.
        bg = rd.card;
        fg = rd.ink;
        border = Border.all(color: rd.line, width: 1);
      case _ObVariant.ghost:
        // Card fill with a fixed navy brand outline + navy label.
        bg = rd.card;
        fg = rd.navy;
        border = Border.all(color: rd.navy, width: 1.4);
    }

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Text(
                    label,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      fontWeight: variant == _ObVariant.social
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: rd.line, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Or',
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                color: rd.muted,
              ),
            ),
          ),
          Expanded(child: Divider(color: rd.line, height: 1)),
        ],
      ),
    );
  }
}

class _OtpRow extends StatefulWidget {
  const _OtpRow({this.length = 6, this.onChanged, this.onCompleted});

  final int length;

  /// Fires on every edit with the current concatenated code.
  final ValueChanged<String>? onChanged;

  /// Fires once all [length] boxes are filled.
  final ValueChanged<String>? onCompleted;

  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _nodes =
      List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < widget.length - 1) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    setState(() {});
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    // Boxes flex to share the row width, so 6 digits always fit on narrow
    // screens without overflow.
    return Row(
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _OtpBox(
              controller: _controllers[i],
              focusNode: _nodes[i],
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        // Vivid brand focus blue — kept fixed across themes.
        cursorColor: const Color(0xFF3D63F5),
        style: GoogleFonts.dosis(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: rd.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: rd.card,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: filled ? const Color(0xFF3D63F5) : rd.line,
              width: filled ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3D63F5), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: rd.card,
          border: Border.all(color: rd.line, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF283CA0).withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: RdIcon(
            RdIcons.attachMic,
            size: 26,
            stroke: '#1A1C29',
            strokeWidth: 1.6,
            color: rd.ink,
          ),
        ),
      ),
    );
  }
}

class _ObStopButton extends StatelessWidget {
  const _ObStopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFC7D2FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF00206B),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24">'
      '<path fill="#4285F4" d="M22.5 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.9a5.05 5.05 0 0 1-2.19 3.31v2.77h3.55c2.08-1.92 3.24-4.74 3.24-8.09Z"/>'
      '<path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.55-2.77c-.98.66-2.24 1.06-3.73 1.06-2.87 0-5.3-1.94-6.16-4.55H2.18v2.86A11 11 0 0 0 12 23Z"/>'
      '<path fill="#FBBC05" d="M5.84 14.08a6.6 6.6 0 0 1 0-4.16V7.06H2.18a11 11 0 0 0 0 9.88l3.66-2.86Z"/>'
      '<path fill="#EA4335" d="M12 4.95c1.62 0 3.07.56 4.21 1.65l3.15-3.15C17.45 1.7 14.97.7 12 .7A11 11 0 0 0 2.18 7.06l3.66 2.86C6.7 7.31 9.13 4.95 12 4.95Z"/>'
      '</svg>',
      width: 20,
      height: 20,
    );
  }
}

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    // Apple wordmark rides on the social button (an ambient card surface); its
    // near-black glyph flips to the ink tone so it stays visible on dark cards.
    final fill = _hex(context.rd.ink);
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="$fill">'
      '<path d="M17.05 12.7c-.03-2.6 2.12-3.85 2.22-3.91-1.21-1.77-3.1-2.01-3.77-2.04-1.6-.16-3.13.94-3.94.94-.81 0-2.07-.92-3.4-.9-1.75.03-3.36 1.02-4.26 2.58-1.82 3.15-.47 7.82 1.3 10.38.86 1.25 1.89 2.66 3.23 2.61 1.3-.05 1.79-.84 3.36-.84 1.57 0 2.01.84 3.38.81 1.4-.02 2.28-1.28 3.13-2.54.99-1.45 1.4-2.86 1.42-2.93-.03-.01-2.72-1.05-2.75-4.15M14.5 5.13c.71-.87 1.2-2.07 1.06-3.28-1.03.04-2.27.69-3.01 1.55-.66.76-1.24 1.99-1.09 3.16 1.15.09 2.32-.58 3.04-1.43"/>'
      '</svg>',
      width: 20,
      height: 20,
    );
  }
}
