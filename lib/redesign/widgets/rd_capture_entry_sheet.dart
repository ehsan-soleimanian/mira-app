import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/l10n/app_localizations.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import 'rd_icon.dart';
import 'rd_orb.dart';

/// Mira's compact command surface.
///
/// It opens with a focused composer instead of a mode picker. Voice remains a
/// direct action and every other transport is presented as a lightweight
/// attachment. Mira and the backend decide what the submitted content means.
class RdCaptureEntrySheet extends StatefulWidget {
  const RdCaptureEntrySheet({
    super.key,
    required this.onPick,
    required this.onClose,
    required this.onSubmitText,
    this.attachmentsOnly = false,
  });

  final ValueChanged<RdCaptureMode> onPick;
  final ValueChanged<String> onSubmitText;
  final VoidCallback onClose;
  final bool attachmentsOnly;

  @override
  State<RdCaptureEntrySheet> createState() => _RdCaptureEntrySheetState();
}

class _RdCaptureEntrySheetState extends State<RdCaptureEntrySheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitText(text);
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final methods = widget.attachmentsOnly
        ? [
            (RdCaptureMode.photo, RdIcons.photo, l10n.rdCaptureModePhoto),
            (RdCaptureMode.screenshot, _screen, l10n.rdCaptureModeScreenshot),
            (RdCaptureMode.file, _file, l10n.rdCaptureModeFile),
            (RdCaptureMode.link, RdIcons.linkChain, l10n.rdCaptureModeLink),
          ]
        : [
            (RdCaptureMode.photo, RdIcons.photo, l10n.rdCaptureModePhoto),
            (RdCaptureMode.screenshot, _screen, l10n.rdCaptureModeScreenshot),
            (RdCaptureMode.file, _file, l10n.rdCaptureModeFile),
            (RdCaptureMode.link, RdIcons.linkChain, l10n.rdCaptureModeLink),
            (RdCaptureMode.meeting, _meeting, l10n.rdCaptureModeMeeting),
          ];

    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    keyboardInset == 0
                        ? 20 + MediaQuery.viewPaddingOf(context).bottom
                        : 16,
                  ),
                  decoration: BoxDecoration(
                    color: rd.bg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border(top: BorderSide(color: rd.line)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 42,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: rd.line,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          const RdOrb(size: 40, ring: false),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.rdCaptureEntryTitle,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: rd.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.attachmentsOnly
                                      ? l10n.rdCaptureEntrySubtitle
                                      : l10n.rdCaptureOrbHint,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 11.5,
                                    height: 1.4,
                                    color: rd.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                            onPressed: widget.onClose,
                            icon: RdIcon(
                              RdIcons.close,
                              size: 19,
                              color: rd.faint,
                              strokeWidth: 1.8,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.attachmentsOnly) ...[
                        const SizedBox(height: 15),
                        Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.fromLTRB(14, 5, 6, 5),
                          decoration: BoxDecoration(
                            color: rd.card,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: rd.line),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 18,
                                spreadRadius: -10,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  key: const ValueKey(
                                    'rd-capture-quick-composer',
                                  ),
                                  controller: _controller,
                                  autofocus: true,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: rd.ink,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: l10n.rdHomeComposerHint,
                                    hintStyle: GoogleFonts.vazirmatn(
                                      fontSize: 14,
                                      color: rd.faint,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _submit(),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                child: _controller.text.trim().isEmpty
                                    ? _ComposerAction(
                                        key: const ValueKey('rd-capture-voice'),
                                        icon: RdIcons.micSimple,
                                        label: l10n.rdCaptureModeVoice,
                                        onTap: () =>
                                            widget.onPick(RdCaptureMode.voice),
                                      )
                                    : _ComposerAction(
                                        key: const ValueKey('rd-capture-send'),
                                        icon: _send,
                                        label: l10n.rdCaptureSend,
                                        filled: true,
                                        onTap: _submit,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < methods.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              _TransportAction(
                                icon: methods[i].$2,
                                label: methods[i].$3,
                                onTap: () => widget.onPick(methods[i].$1),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
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
  static const _send = '<path d="M12 19V5M6.5 10.5 12 5l5.5 5.5"/>';
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: filled ? rd.peri : rd.peri.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: RdIcon(
              icon,
              size: 20,
              color: filled ? Colors.white : rd.peri,
              strokeWidth: 1.9,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportAction extends StatelessWidget {
  const _TransportAction({
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rd.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RdIcon(icon, size: 18, color: rd.peri, strokeWidth: 1.8),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.vazirmatn(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: rd.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
