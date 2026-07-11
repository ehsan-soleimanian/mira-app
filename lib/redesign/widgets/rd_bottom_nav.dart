import 'package:flutter/material.dart';

import 'package:mira_app/l10n/app_localizations.dart';

import '../theme/rd_theme.dart';
import '../theme/rd_typography.dart';
import 'rd_icon.dart';

/// A navigation callback carrying a screen id (matches the design's `go(screen)`
/// model) plus an optional argument for screens that need one (e.g. the tapped
/// memory for `go('memory', arg: RdMemoryArg(...))`). Screen ids: home, daily,
/// library, canvas, account, memory, capture…
typedef RdGo = void Function(String screen, {Object? arg});

/// Argument for `go('memory', arg: ...)` — the memory the user tapped, so the
/// detail opens on real data instead of the placeholder.
class RdMemoryArg {
  const RdMemoryArg({
    this.id,
    required this.title,
    this.body,
    this.isVoice = false,
  });

  final String? id;
  final String title;
  final String? body;
  final bool isVoice;
}

/// Argument for `go('chat', arg: ...)` — optional voice transcript from Listen.
class RdChatArg {
  const RdChatArg({
    this.initialPrompt,
    this.autoSend = false,
    this.memory,
  });

  /// Prefills the compose bar (e.g. after Listen transcribes).
  final String? initialPrompt;

  /// When true, sends [initialPrompt] to the assistant on open.
  final bool autoSend;

  /// Optional memory anchor (same shape as memory detail navigation).
  final RdMemoryArg? memory;
}

/// Carries onboarding context (email, display name, optional first capture)
/// across the first-run flow screens.
class RdOnboardingArg {
  const RdOnboardingArg({
    this.email,
    this.displayName,
    this.firstCaptureText,
  });

  final String? email;
  final String? displayName;
  final String? firstCaptureText;

  RdOnboardingArg copyWith({
    String? email,
    String? displayName,
    String? firstCaptureText,
  }) =>
      RdOnboardingArg(
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        firstCaptureText: firstCaptureText ?? this.firstCaptureText,
      );
}

/// The shared bottom navigation used by every tab-rooted screen (Home, Daily
/// Brief, Library, Canvas). Home / Library on the left, Canvas / Brief on the
/// right, with the floating capture mic centred over the gap. [active] is the
/// current tab's id.
class RdBottomNav extends StatelessWidget {
  const RdBottomNav({super.key, required this.active, required this.go});

  final String active;
  final RdGo go;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navInset = context.rdNavBarInset;
    return SizedBox(
      height: 96 + navInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 22 + navInset),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: RdIcons.navHome,
                  label: l10n.rdNavHome,
                  active: active == 'home',
                  onTap: () => go('home'),
                ),
                _NavItem(
                  icon: RdIcons.navLibrary,
                  label: l10n.rdNavLibrary,
                  active: active == 'library',
                  onTap: () => go('library'),
                ),
                const SizedBox(width: 64),
                _NavItem(
                  icon: RdIcons.navCanvas,
                  label: l10n.rdNavCanvas,
                  active: active == 'canvas',
                  onTap: () => go('canvas'),
                ),
                _NavItem(
                  icon: RdIcons.navBrief,
                  label: l10n.rdNavBrief,
                  active: active == 'daily',
                  onTap: () => go('daily'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40 + navInset,
            left: 0,
            right: 0,
            child: Center(child: _NavMic(onTap: () => go('capture'))),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final color = active ? rd.navy : rd.faint;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(
              icon,
              size: 22,
              color: color,
              strokeWidth: 1.8,
            ),
            const SizedBox(height: 5),
            Text(label, style: RdText.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _NavMic extends StatelessWidget {
  const _NavMic({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.24, -0.4),
            radius: 0.9,
            colors: [Color(0xFF8B98D6), Color(0xFF5B69AD)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(70, 85, 150, 0.6),
              blurRadius: 28,
              spreadRadius: -8,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Center(
          child: RdIcon(RdIcons.mic, size: 24, stroke: '#FFFFFF', strokeWidth: 1.9),
        ),
      ),
    );
  }
}
