import 'package:flutter/material.dart';

import '../theme/rd_colors.dart';
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
    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: RdIcons.navHome,
                  label: 'Home',
                  active: active == 'home',
                  onTap: () => go('home'),
                ),
                _NavItem(
                  icon: RdIcons.navLibrary,
                  label: 'Library',
                  active: active == 'library',
                  onTap: () => go('library'),
                ),
                const SizedBox(width: 64),
                _NavItem(
                  icon: RdIcons.navCanvas,
                  label: 'Canvas',
                  active: active == 'canvas',
                  onTap: () => go('canvas'),
                ),
                _NavItem(
                  icon: RdIcons.navBrief,
                  label: 'Brief',
                  active: active == 'daily',
                  onTap: () => go('daily'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
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
    final color = active ? RdColors.navy : RdColors.faint;
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
              stroke: active ? '#14328C' : '#B7B8BE',
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
