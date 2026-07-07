import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// First-run onboarding — splash → login → invite → email code → details →
/// remember → understood, then into the app. Faithful to `onboarding.jsx`
/// (`.ob-*`). Inputs are local-only; wiring to auth happens when promoted.

const _obBg = Color(0xFFF5F5F5);
const _ink = Color(0xFF1A1C29);
const _obMuted = Color(0xFF8A8A8A);
const _peri = Color(0xFF7E8BC9);

// ── 1. Splash ──────────────────────────────────────────────────────────
class RdSplashScreen extends StatelessWidget {
  const RdSplashScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obBg,
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
                  color: _ink,
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
                    color: _obMuted,
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
class RdLoginScreen extends StatelessWidget {
  const RdLoginScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _ObHeader(title: 'Login or sign up', onBack: () => go('splash')),
              const SizedBox(height: 24),
              const _ObInput(hint: 'Enter Your Email'),
              const SizedBox(height: 14),
              _ObButton(
                label: 'Continue',
                variant: _ObVariant.navy,
                onTap: () => go('invite'),
              ),
              const _OrDivider(),
              _ObButton(
                label: 'Continue with Google',
                variant: _ObVariant.social,
                leading: const _GoogleIcon(),
                onTap: () => go('invite'),
              ),
              const SizedBox(height: 12),
              _ObButton(
                label: 'Continue with Apple',
                variant: _ObVariant.social,
                leading: const _AppleIcon(),
                onTap: () => go('invite'),
              ),
              const Spacer(),
              Text(
                'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply.',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  height: 1.5,
                  color: const Color(0xFF9A9A9A),
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
class RdInviteScreen extends StatelessWidget {
  const RdInviteScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    return _ObFormScaffold(
      onBack: () => go('login'),
      badge: RdIcons.shieldCheck,
      title: 'You need an invite code to join Mira.',
      desc: 'Enter 6-digit code',
      input: const _ObInput(hint: 'Code'),
      ctaLabel: 'Enter',
      ctaVariant: _ObVariant.peri,
      onCta: () => go('email'),
    );
  }
}

// ── 4. Email code (OTP) ────────────────────────────────────────────────
class RdEmailCodeScreen extends StatelessWidget {
  const RdEmailCodeScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ObHeader(onBack: () => go('invite')),
              const SizedBox(height: 26),
              const _ObBadge(icon: RdIcons.shield),
              const SizedBox(height: 16),
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.dosis(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _ink,
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
                  color: _obMuted,
                ),
              ),
              const SizedBox(height: 26),
              const _OtpRow(),
              const SizedBox(height: 22),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Didn’t get the code? '),
                    TextSpan(
                      text: 'Resend',
                      style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF14328C),
                      ),
                    ),
                  ],
                  style: GoogleFonts.vazirmatn(fontSize: 13, color: _obMuted),
                ),
              ),
              const Spacer(),
              _ObButton(
                label: 'Enter',
                variant: _ObVariant.peri,
                onTap: () => go('details'),
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
class RdDetailsScreen extends StatelessWidget {
  const RdDetailsScreen({super.key, required this.go});

  final RdGo go;

  @override
  Widget build(BuildContext context) {
    return _ObFormScaffold(
      onBack: () => go('email'),
      badge: RdIcons.user,
      title: 'Your details',
      desc:
          'Lorem ipsum dolor sit amet, adipiscing elit, sed eiusmod tempor incididunt.',
      input: const _ObInput(hint: 'your name'),
      ctaLabel: 'Enter',
      ctaVariant: _ObVariant.peri,
      onCta: () => go('remember'),
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
    return Scaffold(
      backgroundColor: _obBg,
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
                  color: _ink,
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
                  color: _obMuted,
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
                    color: RdColors.ink,
                    fontFeatures: const [],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TAP TO STOP',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 10,
                    color: const Color(0xFF595959),
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
                    color: _obMuted,
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
    return Scaffold(
      backgroundColor: _obBg,
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
                    color: _ink,
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
                  color: const Color(0xFF14328C),
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
  });

  final VoidCallback onBack;
  final String badge;
  final String title;
  final String desc;
  final Widget input;
  final String ctaLabel;
  final _ObVariant ctaVariant;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obBg,
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
                  color: _ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  height: 1.5,
                  color: _obMuted,
                ),
              ),
              const SizedBox(height: 22),
              input,
              const Spacer(),
              _ObButton(label: ctaLabel, variant: ctaVariant, onTap: onCta),
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
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: const Color(0xFFEDF1FF).withValues(alpha: 0.9),
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
                child: const Center(
                  child: RdIcon(
                    RdIcons.arrowLeft,
                    size: 22,
                    stroke: '#1A1C29',
                    strokeWidth: 1.6,
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
                  color: _ink,
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
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6EA), width: 1),
      ),
      child: Center(
        child: RdIcon(icon, size: 26, stroke: '#293D8C', strokeWidth: 1.7),
      ),
    );
  }
}

class _ObInput extends StatelessWidget {
  const _ObInput({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextField(
        cursorColor: const Color(0xFF3D63F5),
        style: GoogleFonts.vazirmatn(fontSize: 14, color: const Color(0xFF1F1F1F)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.vazirmatn(fontSize: 14, color: const Color(0xFFA8A8AE)),
          filled: true,
          fillColor: const Color(0xFFFCFCFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E2E6), width: 1),
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
  });

  final String label;
  final _ObVariant variant;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    BoxBorder? border;
    switch (variant) {
      case _ObVariant.navy:
        bg = const Color(0xFF14328C);
        fg = Colors.white;
      case _ObVariant.peri:
        bg = _peri;
        fg = Colors.white;
      case _ObVariant.social:
        bg = Colors.white;
        fg = const Color(0xFF1A1A1A);
        border = Border.all(color: const Color(0xFFE2E2E6), width: 1);
      case _ObVariant.ghost:
        bg = Colors.white;
        fg = const Color(0xFF14328C);
        border = Border.all(color: const Color(0xFF14328C), width: 1.4);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 15,
                fontWeight:
                    variant == _ObVariant.social ? FontWeight.w500 : FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E2E6), height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Or',
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                color: const Color(0xFF9A9A9A),
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E2E6), height: 1)),
        ],
      ),
    );
  }
}

class _OtpRow extends StatefulWidget {
  const _OtpRow();

  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController(text: ''));
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _controllers[0].text = '4';
  }

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          _OtpBox(
            controller: _controllers[i],
            focusNode: _nodes[i],
            onChanged: (v) {
              setState(() {});
              if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
            },
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
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      width: 52,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        cursorColor: const Color(0xFF3D63F5),
        style: GoogleFonts.dosis(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: filled ? const Color(0xFF3D63F5) : const Color(0xFFE2E2E6),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFECECEF), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF283CA0).withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: RdIcon(
            RdIcons.attachMic,
            size: 26,
            stroke: '#1A1C29',
            strokeWidth: 1.6,
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
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#1A1A1A">'
      '<path d="M17.05 12.7c-.03-2.6 2.12-3.85 2.22-3.91-1.21-1.77-3.1-2.01-3.77-2.04-1.6-.16-3.13.94-3.94.94-.81 0-2.07-.92-3.4-.9-1.75.03-3.36 1.02-4.26 2.58-1.82 3.15-.47 7.82 1.3 10.38.86 1.25 1.89 2.66 3.23 2.61 1.3-.05 1.79-.84 3.36-.84 1.57 0 2.01.84 3.38.81 1.4-.02 2.28-1.28 3.13-2.54.99-1.45 1.4-2.86 1.42-2.93-.03-.01-2.72-1.05-2.75-4.15M14.5 5.13c.71-.87 1.2-2.07 1.06-3.28-1.03.04-2.27.69-3.01 1.55-.66.76-1.24 1.99-1.09 3.16 1.15.09 2.32-.58 3.04-1.43"/>'
      '</svg>',
      width: 20,
      height: 20,
    );
  }
}
