import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/l10n/app_localizations.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Listen — the plain recording surface (the orb, a live timer, and a stop
/// button). Faithful to `ListenScreen` in `app.jsx`. Stopping opens the chat.
class RdListenScreen extends StatefulWidget {
  const RdListenScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdListenScreen> createState() => _RdListenScreenState();
}

class _RdListenScreenState extends State<RdListenScreen> {
  int _sec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _sec++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _time =>
      '${(_sec ~/ 60).toString().padLeft(2, '0')}:${(_sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RingButton(icon: RdIcons.arrowLeft, onTap: widget.onBack),
                  GestureDetector(
                    onTap: () => widget.go('daily'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: RdIcon(
                        '<path d="M12 5.2a2.9 2.9 0 0 0-5.6-1.05A2.7 2.7 0 0 0 4.2 9a2.45 2.45 0 0 0 .45 4.45A2.45 2.45 0 0 0 8.1 15.7 2.45 2.45 0 0 0 12 18.4Z"/><path d="M12 5.2a2.9 2.9 0 0 1 5.6-1.05A2.7 2.7 0 0 1 19.8 9a2.45 2.45 0 0 1-.45 4.45 2.45 2.45 0 0 1-3.45 2.25A2.45 2.45 0 0 1 12 18.4Z"/><path d="M12 5.2v13.2"/>',
                        size: 23,
                        stroke: '#1A1C29',
                        strokeWidth: 1.5,
                        color: rd.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            const RdOrb(size: 145),
            const SizedBox(height: 34),
            Text(
              l10n.rdListenTitle,
              style: GoogleFonts.dosis(fontSize: 34, fontWeight: FontWeight.w700, color: rd.ink),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.rdListenSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dosis(fontSize: 18, fontWeight: FontWeight.w500, color: rd.muted),
            ),
            const Spacer(flex: 3),
            GestureDetector(
              onTap: () => widget.go('capture'),
              child: Container(
                width: 72,
                height: 72,
                // Fixed pastel-periwinkle disc with a navy stop square — a
                // colored control, constant across themes.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC7D2FF),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3)],
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: const Color(0xFF00206B), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _time,
              style: GoogleFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w700, color: rd.ink),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.rdListenTapToStop,
              style: GoogleFonts.vazirmatn(fontSize: 10, color: rd.muted, letterSpacing: 0.6),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  const _RingButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    // Glass circle: keep the exact light glass (white 0.7 on the pale page) in
    // light mode; on dark, sit it on a lifted card-tinted disc so it doesn't
    // glare. The back-arrow glyph flips with the ink tone.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        dark ? rd.card.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          boxShadow: [BoxShadow(color: const Color(0xFF141632).withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: RdIcon(icon, size: 22, stroke: '#1A1C29', strokeWidth: 1.6, color: rd.ink)),
      ),
    );
  }
}
