import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import 'rd_icon.dart';

/// Bottom sheet shown when the user taps capture — mirrors design2 `CaptureSheet`.
class RdCaptureEntrySheet extends StatelessWidget {
  const RdCaptureEntrySheet({
    super.key,
    required this.onPick,
    required this.onClose,
  });

  final ValueChanged<RdCaptureMode> onPick;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black.withValues(alpha: 0.32),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: rd.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                22,
                12,
                22,
                34 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: rd.line,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Capture a memory',
                    style: GoogleFonts.dosis(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mira will understand it — you confirm before it\'s kept',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      color: rd.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      _ModeTile(
                        icon: RdIcons.micSimple,
                        iconBg: const Color(0xFFE7ECFB),
                        name: 'Voice',
                        hint: 'Just speak',
                        onTap: () => onPick(RdCaptureMode.voice),
                      ),
                      _ModeTile(
                        icon:
                            '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/>',
                        name: 'Photo',
                        hint: 'Snap a scene',
                        onTap: () => onPick(RdCaptureMode.photo),
                      ),
                      _ModeTile(
                        icon:
                            '<rect x="4" y="3" width="16" height="14" rx="2"/><path d="M8 21h8"/>',
                        name: 'Screenshot',
                        hint: 'From your library',
                        onTap: () => onPick(RdCaptureMode.screenshot),
                      ),
                      _ModeTile(
                        icon:
                            '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
                        name: 'Link',
                        hint: 'Paste a URL',
                        onTap: () => onPick(RdCaptureMode.link),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ModeTile(
                    wide: true,
                    name: 'Type it instead',
                    onTap: () => onPick(RdCaptureMode.type),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.name,
    this.hint,
    this.icon,
    this.iconBg,
    this.wide = false,
    required this.onTap,
  });

  final String name;
  final String? hint;
  final String? icon;
  final Color? iconBg;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Material(
      color: wide ? Colors.transparent : rd.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: rd.line, width: 1),
            color: wide ? Colors.transparent : rd.card,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 0 : 16,
            vertical: wide ? 14 : 16,
          ),
          child: wide
              ? Center(
                  child: Text(
                    name,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: rd.ink,
                    ),
                  ),
                )
              : Row(
                  children: [
                    if (icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg ?? rd.periSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: RdIcon(
                            icon!,
                            size: 20,
                            stroke: '#14328C',
                            strokeWidth: 1.8,
                          ),
                        ),
                      ),
                    if (icon != null) const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: rd.ink,
                            ),
                          ),
                          if (hint != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              hint!,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 11.5,
                                color: rd.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
