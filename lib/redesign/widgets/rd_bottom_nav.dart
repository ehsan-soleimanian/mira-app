import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mira_app/l10n/app_localizations.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import '../theme/rd_typography.dart';
import 'rd_icon.dart';
import 'rd_orb.dart';

/// A navigation callback carrying a screen id (matches the design's `go(screen)`
/// model) plus an optional argument for screens that need one (e.g. the tapped
/// memory for `go('memory', arg: RdMemoryArg(...))`).
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
  const RdChatArg({this.initialPrompt, this.autoSend = false, this.memory});

  final String? initialPrompt;
  final bool autoSend;
  final RdMemoryArg? memory;
}

/// Carries onboarding context (email, display name, optional first capture)
/// across the first-run flow screens.
class RdOnboardingArg {
  const RdOnboardingArg({this.email, this.displayName, this.firstCaptureText});

  final String? email;
  final String? displayName;
  final String? firstCaptureText;

  RdOnboardingArg copyWith({
    String? email,
    String? displayName,
    String? firstCaptureText,
  }) => RdOnboardingArg(
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    firstCaptureText: firstCaptureText ?? this.firstCaptureText,
  );
}

/// Mira's deliberately small navigation dock.
///
/// Home and Library are the only persistent destinations. The central Orb is
/// an action surface: tap opens the quick composer, while a long press starts
/// voice capture immediately. This keeps microphone semantics honest and
/// leaves secondary destinations inside the screens that own them.
class RdBottomNav extends StatelessWidget {
  const RdBottomNav({super.key, required this.active, required this.go});

  final String active;
  final RdGo go;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final navInset = context.rdNavBarInset;

    return SizedBox(
      height: 94 + navInset,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 12,
            right: 12,
            top: 20,
            bottom: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: rd.card.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: rd.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 28,
                    spreadRadius: -12,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: navInset),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        key: const ValueKey('rd-nav-home'),
                        icon: RdIcons.navHome,
                        label: l10n.rdNavHome,
                        active: active == 'home',
                        onTap: () => go('home'),
                      ),
                    ),
                    const SizedBox(width: 82),
                    Expanded(
                      child: _NavItem(
                        key: const ValueKey('rd-nav-library'),
                        icon: RdIcons.navLibrary,
                        label: l10n.rdNavLibrary,
                        active: active == 'library',
                        onTap: () => go('library'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.rdNavMira,
            hint: l10n.rdCaptureOrbHint,
            child: GestureDetector(
              key: const ValueKey('rd-nav-orb'),
              behavior: HitTestBehavior.opaque,
              onTap: () => go('capture'),
              onLongPress: () {
                HapticFeedback.mediumImpact();
                go(
                  'captureflow',
                  arg: const RdCaptureModeArg(RdCaptureMode.voice),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RdOrb(size: 58, ring: false),
                  const SizedBox(height: 2),
                  Text(
                    l10n.rdNavMira,
                    style: RdText.navLabel.copyWith(
                      color: rd.peri,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
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
    final color = active ? rd.peri : rd.faint;
    return Semantics(
      selected: active,
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 34,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 27,
                decoration: BoxDecoration(
                  color: active
                      ? rd.peri.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: RdIcon(icon, size: 20, color: color, strokeWidth: 1.8),
                ),
              ),
              const SizedBox(height: 3),
              Text(label, style: RdText.navLabel.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
