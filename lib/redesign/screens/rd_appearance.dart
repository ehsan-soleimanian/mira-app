import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/app_theme_controller.dart';
import 'package:mira_app/models/api/settings_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// The Appearance screen — theme, accent, text size, motion & app icon. A
/// pushed screen under Account, sharing the grouped-row aesthetic with
/// `rd_settings.dart` (its `_Ac*` section / row / toggle primitives are mirrored
/// here as local `_Ap*` variants). Dark-aware throughout via `context.rd`.
///
/// Theme, accent and text size are wired live: they drive
/// [AppThemeController], whose `notifyListeners()` rebuilds `MaterialApp` at the
/// root — so a tap here recolors the whole app immediately.

/// The four selectable accents. The first is the default periwinkle `--peri`.
const List<Color> _accents = [
  Color(0xFF7E8BC9),
  Color(0xFF1F8A5B),
  Color(0xFFC6613C),
  Color(0xFFA65C86),
];

/// Human names for each accent, in the same order.
const List<String> _accentNames = ['Periwinkle', 'Sage', 'Clay', 'Plum'];

String _accentNameFor(Color c) {
  final i = _accents.indexWhere((a) => a == c);
  return i == -1 ? 'Custom' : _accentNames[i];
}

/// Text-size steps mapped to their scale factors (S / M / L).
const List<(String, double)> _textSizes = [
  ('S', 0.9),
  ('M', 1.0),
  ('L', 1.15),
];

/// App-icon variants — a label plus the two gradient stops shown in the swatch.
/// Only the selected id is persisted; the runtime launcher swap is native.
const List<({String id, String label, Color a, Color b})> _appIcons = [
  (id: 'default', label: 'Default', a: Color(0xFF9AA6DA), b: Color(0xFF4B5BA6)),
  (id: 'sage', label: 'Sage', a: Color(0xFF7FBFA0), b: Color(0xFF2F7D57)),
  (id: 'dusk', label: 'Dusk', a: Color(0xFF2A2B33), b: Color(0xFF14151A)),
];

/// Neutral surfaces here (segmented track) have no palette token — keep the
/// exact light literal in light mode, and a dark-tuned value otherwise.
bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

class RdAppearanceScreen extends StatelessWidget {
  const RdAppearanceScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.themeOf(context);
    return _ApScaffold(
      onBack: onBack,
      title: 'Appearance',
      intro: 'Make Mira feel like yours — colour, contrast and calm.',
      children: [
        _ApSection(
          label: 'Theme',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ApSegmented(
                options: const ['System', 'Light', 'Dark'],
                selected: switch (theme.preference) {
                  MiraThemePreference.system => 0,
                  MiraThemePreference.light => 1,
                  MiraThemePreference.dark => 2,
                },
                onSelected: (i) => theme.setPreference(switch (i) {
                  1 => MiraThemePreference.light,
                  2 => MiraThemePreference.dark,
                  _ => MiraThemePreference.system,
                }),
              ),
              if (_isDark(context)) ...[
                const SizedBox(height: 10),
                Text(
                  'Dark mode is on — tuned for calm, low-light reading.',
                  style: GoogleFonts.vazirmatn(
                      fontSize: 12.5, color: context.rd.muted),
                ),
              ],
            ],
          ),
        ),
        _ApSection(
          label: 'Accent color',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ApSwatchRow(
                colors: _accents,
                selected: theme.accent,
                onSelected: theme.setAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _accentNameFor(theme.accent),
                style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.rd.muted),
              ),
            ],
          ),
        ),
        _ApSection(
          label: 'Text size',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ApSegmented(
                options: const ['Small', 'Default', 'Large'],
                selected: () {
                  final i =
                      _textSizes.indexWhere((s) => s.$2 == theme.textScale);
                  return i == -1 ? 1 : i;
                }(),
                onSelected: (i) => theme.setTextScale(_textSizes[i].$2),
              ),
              const SizedBox(height: 14),
              // Live preview — the whole screen is already scaled by the global
              // textScaler, so this line grows/shrinks as you change the size.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.rd.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.rd.line, width: 1),
                ),
                child: Text(
                  'The coast trip is coming together.',
                  style: GoogleFonts.vazirmatn(
                      fontSize: 15, height: 1.4, color: context.rd.ink),
                ),
              ),
            ],
          ),
        ),
        _ApSection(
          child: _ApToggleRow(
            icon:
                '<path d="M12 2v4M12 18v4M2 12h4M18 12h4M4.9 4.9l2.8 2.8M16.3 16.3l2.8 2.8M19.1 4.9l-2.8 2.8M7.7 16.3l-2.8 2.8"/>',
            title: 'Reduce motion',
            sub: 'Calmer transitions and less movement',
            on: theme.reduceMotion,
            onTap: () => theme.setReduceMotion(!theme.reduceMotion),
          ),
        ),
        _ApSection(
          label: 'App icon',
          child: _ApIconRow(
            options: _appIcons,
            selected: theme.appIcon,
            onSelected: theme.setAppIcon,
          ),
        ),
        const _ApFoot('Appearance changes apply instantly.'),
      ],
    );
  }
}

// ══ shared primitives (mirrors rd_settings `_Ac*`) ═══════════════════════
class _ApScaffold extends StatelessWidget {
  const _ApScaffold({
    required this.onBack,
    required this.title,
    required this.children,
    this.intro,
  });

  final VoidCallback onBack;
  final String title;
  final String? intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 20, 0),
                child: GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RdIcon(RdIcons.chevronLeft,
                            size: 20, color: rd.navy, strokeWidth: 2),
                        const SizedBox(width: 3),
                        Text('Account',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 15, color: rd.navy)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 12, 26, 4),
                child: Text(title,
                    style: GoogleFonts.dosis(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: rd.ink)),
              ),
              if (intro != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
                  child: Text(intro!,
                      style: GoogleFonts.vazirmatn(
                          fontSize: 14, height: 1.5, color: rd.muted)),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ApSection extends StatelessWidget {
  const _ApSection({required this.child, this.label});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 9),
              child: Text(
                label!.toUpperCase(),
                style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: rd.faint),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: rd.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Segmented control (Theme / Text size). One pill per option, the selected one
/// filled with the accent (`peri`).
class _ApSegmented extends StatelessWidget {
  const _ApSegmented({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    // Track has no token: keep the exact light literal, darken for dark mode.
    final trackBg =
        _isDark(context) ? const Color(0xFF2A2B33) : const Color(0xFFEDEDE8);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: trackBg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: i == selected ? rd.peri : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        options[i],
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: i == selected ? Colors.white : rd.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The accent swatch row — a filled circle per colour, the active one ringed.
class _ApSwatchRow extends StatelessWidget {
  const _ApSwatchRow({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          for (final color in colors) ...[
            _Swatch(
              color: color,
              active: color.toARGB32() == selected.toARGB32(),
              ringColor: rd.card,
              onTap: () => onSelected(color),
            ),
            if (color != colors.last) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.active,
    required this.ringColor,
    required this.onTap,
  });

  final Color color;
  final bool active;
  final Color ringColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // Active swatch reads as ringed: a card-coloured gap then the colour.
          border: active
              ? Border.all(color: ringColor, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 0, spreadRadius: 2)]
              : null,
        ),
        child: active
            ? const Center(
                child: RdIcon(RdIcons.checkThick,
                    size: 18, stroke: '#FFFFFF', strokeWidth: 2.6),
              )
            : null,
      ),
    );
  }
}

/// A single toggle row (Reduce motion), matching `rd_settings` `_AcRow`.
class _ApToggleRow extends StatelessWidget {
  const _ApToggleRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.on,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String sub;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child:
                  RdIcon(icon, size: 19, color: rd.peri, strokeWidth: 1.8),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: rd.ink)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: GoogleFonts.vazirmatn(
                          fontSize: 12.5, color: rd.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _ApToggle(on: on),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApToggle extends StatelessWidget {
  const _ApToggle({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    // On-track is brand navy (fixed accent). Off-track has no token: keep the
    // exact light literal, and use a lifted neutral on dark for contrast.
    final offTrack =
        _isDark(context) ? const Color(0xFF3A3B44) : const Color(0xFFD8D8D2);
    return Container(
      width: 46,
      height: 28,
      decoration: BoxDecoration(
        color: on ? context.rd.navy : offTrack,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 22,
            height: 22,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// App-icon chooser — a row of tappable gradient tiles, the selected one ringed
/// with the accent and captioned.
class _ApIconRow extends StatelessWidget {
  const _ApIconRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<({String id, String label, Color a, Color b})> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          for (final opt in options) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(opt.id),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      height: 62,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [opt.a, opt.b],
                        ),
                        border: Border.all(
                          color: opt.id == selected ? rd.peri : rd.line,
                          width: opt.id == selected ? 2.5 : 1,
                        ),
                      ),
                      child: opt.id == selected
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      color: rd.peri, shape: BoxShape.circle),
                                  child: const Center(
                                    child: RdIcon(RdIcons.checkThick,
                                        size: 12,
                                        stroke: '#FFFFFF',
                                        strokeWidth: 3),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opt.label,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12.5,
                        fontWeight: opt.id == selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: opt.id == selected ? rd.ink : rd.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (opt.id != options.last.id) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _ApFoot extends StatelessWidget {
  const _ApFoot(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Center(
        child: Text(text,
            style: GoogleFonts.vazirmatn(fontSize: 12, color: context.rd.faint)),
      ),
    );
  }
}
