import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/l10n/app_localizations.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import 'rd_icon.dart';
import 'rd_orb.dart';

/// Mira's single entry surface. Users choose a transport; the backend decides
/// what the content means and which actions are valid.
class RdCaptureEntrySheet extends StatelessWidget {
  const RdCaptureEntrySheet({
    super.key,
    required this.onPick,
    required this.onClose,
    required this.onNavigate,
    this.attachmentsOnly = false,
  });

  final ValueChanged<RdCaptureMode> onPick;
  final ValueChanged<String> onNavigate;
  final VoidCallback onClose;
  final bool attachmentsOnly;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final methods = attachmentsOnly
        ? [
            (RdCaptureMode.photo, RdIcons.photo, l10n.rdCaptureModePhoto),
            (RdCaptureMode.file, _file, l10n.rdCaptureModeFile),
            (RdCaptureMode.link, RdIcons.linkChain, l10n.rdCaptureModeLink),
            (RdCaptureMode.screenshot, _screen, l10n.rdCaptureModeScreenshot),
          ]
        : [
            (RdCaptureMode.voice, RdIcons.micSimple, l10n.rdCaptureModeVoice),
            (RdCaptureMode.type, RdIcons.pencil, l10n.rdCaptureModeType),
            (RdCaptureMode.photo, RdIcons.photo, l10n.rdCaptureModePhoto),
            (RdCaptureMode.file, _file, l10n.rdCaptureModeFile),
            (RdCaptureMode.link, RdIcons.linkChain, l10n.rdCaptureModeLink),
            (RdCaptureMode.meeting, _meeting, l10n.rdCaptureModeMeeting),
          ];
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  22,
                  11,
                  22,
                  24 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: rd.bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border(top: BorderSide(color: rd.line)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 44,
                      offset: const Offset(0, -14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: rd.line,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const RdOrb(size: 62),
                    const SizedBox(height: 12),
                    Text(
                      l10n.rdCaptureEntryTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: rd.ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.rdCaptureEntrySubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        height: 1.55,
                        color: rd.muted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final method in methods)
                          _RoundAction(
                            icon: method.$2,
                            label: method.$3,
                            onTap: () => onPick(method.$1),
                          ),
                      ],
                    ),
                    if (!attachmentsOnly) ...[
                      const SizedBox(height: 22),
                      Container(height: 1, color: rd.line),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SmallAction(
                            RdIcons.search,
                            l10n.homeAskStarterLabel,
                            () => onNavigate('ask'),
                          ),
                          _SmallAction(
                            RdIcons.navLibrary,
                            l10n.rdNavLibrary,
                            () => onNavigate('library'),
                          ),
                          _SmallAction(
                            RdIcons.navBrief,
                            l10n.rdNavBrief,
                            () => onNavigate('daily'),
                          ),
                          _SmallAction(
                            RdIcons.gear,
                            l10n.rdCommonAccount,
                            () => onNavigate('account'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _file = '<path d="M4 6h6l2 2h8v10H4Z"/>';
  static const _screen =
      '<rect x="4" y="3" width="16" height="14" rx="2"/><path d="M8 21h8"/>';
  static const _meeting =
      '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>';
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 42,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: rd.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: rd.line),
                ),
                child: Center(
                  child: RdIcon(
                    icon,
                    size: 21,
                    color: rd.peri,
                    strokeWidth: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(fontSize: 11.5, color: rd.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction(this.icon, this.label, this.onTap);
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(icon, size: 19, color: rd.faint, strokeWidth: 1.8),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.vazirmatn(fontSize: 10.5, color: rd.faint),
            ),
          ],
        ),
      ),
    );
  }
}
