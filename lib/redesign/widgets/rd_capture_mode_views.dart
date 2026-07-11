import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/rd_theme.dart';
import 'rd_icon.dart';

/// Photo capture with camera UI + scan animation — design2 `.cam`.
class RdPhotoCaptureView extends StatefulWidget {
  const RdPhotoCaptureView({
    super.key,
    required this.onCapture,
    required this.onClose,
    required this.onGallery,
  });

  final Future<void> Function() onCapture;
  final VoidCallback onClose;
  final VoidCallback onGallery;

  @override
  State<RdPhotoCaptureView> createState() => _RdPhotoCaptureViewState();
}

class _RdPhotoCaptureViewState extends State<RdPhotoCaptureView>
    with SingleTickerProviderStateMixin {
  bool _scanning = false;
  late final AnimationController _scan =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  Future<void> _shutter() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    _scan.repeat();
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    _scan.stop();
    await widget.onCapture();
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0D0E12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [Color(0xFF2A2C34), Color(0xFF16171C), Color(0xFF0B0C0F)],
              ),
            ),
          ),
          Center(
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-0.12)
                ..rotateX(0.05),
              alignment: Alignment.center,
              child: Container(
                width: 236,
                height: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B2B6B), Color(0xFF22357E), Color(0xFF0F1C4D)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.75),
                      blurRadius: 50,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE MUSIC',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDFB877),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Blue\nNote',
                      style: GoogleFonts.dosis(
                        fontSize: 40,
                        height: 0.96,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Fri · Jul 18 · 8 PM',
                      style: GoogleFonts.dosis(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'THE CORNER ROOM · 4TH ST',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: const Color(0xFFB9C0DA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_scanning) ...[
            Positioned(
              top: 92,
              left: 44,
              right: 44,
              bottom: 200,
              child: IgnorePointer(
                child: CustomPaint(painter: _BracketPainter()),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 176,
              child: Text(
                'Frame a poster, page, or place',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
          if (_scanning) ...[
            AnimatedBuilder(
              animation: _scan,
              builder: (_, __) {
                return Positioned(
                  left: MediaQuery.sizeOf(context).width * 0.08,
                  right: MediaQuery.sizeOf(context).width * 0.08,
                  top: MediaQuery.sizeOf(context).height * (0.16 + 0.62 * _scan.value % 1),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, Color(0xFF8B98D6), Colors.transparent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B98D6).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141828).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'Reading this photo…',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CamIconBtn(onTap: widget.onClose),
                      _CamIconBtn(
                        icon: '<path d="M13 2 4 14h7l-1 8 9-12h-7z"/>',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!_scanning)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: widget.onGallery,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3A3D4A), Color(0xFF20222B)],
                              ),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _shutter,
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _CamIconBtn(
                          icon:
                              '<path d="M15 4h4a2 2 0 0 1 2 2v4"/><path d="m21 4-4 4"/><path d="M9 20H5a2 2 0 0 1-2-2v-4"/><path d="m3 20 4-4"/><circle cx="12" cy="12" r="3"/>',
                          onTap: () {},
                        ),
                      ],
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

class _CamIconBtn extends StatelessWidget {
  const _CamIconBtn({required this.onTap, this.icon});

  final VoidCallback onTap;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
        ),
        child: Center(
          child: RdIcon(
            icon ?? '<path d="M6 6l12 12M18 6 6 18"/>',
            size: 18,
            stroke: '#FFFFFF',
            strokeWidth: 2.2,
          ),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    const len = 26.0;
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Screenshot grid picker — design2 `.shot`.
class RdScreenshotPickerView extends StatefulWidget {
  const RdScreenshotPickerView({
    super.key,
    required this.onSelected,
    required this.onClose,
  });

  final Future<void> Function() onSelected;
  final VoidCallback onClose;

  @override
  State<RdScreenshotPickerView> createState() => _RdScreenshotPickerViewState();
}

class _RdScreenshotPickerViewState extends State<RdScreenshotPickerView> {
  int? _picked;
  bool _scanning = false;

  Future<void> _confirm() async {
    if (_picked == null || _scanning) return;
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    await widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    if (_scanning) {
      return const ColoredBox(
        color: Color(0xFF0D0E12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(height: 12),
              Text('Reading screenshot…', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onClose,
                child: const RdIcon(RdIcons.chevronLeft, size: 22, stroke: '#6B6C73'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pick a screenshot',
                style: GoogleFonts.dosis(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Mira reads text and details from your image',
                style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.muted),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Text(
            'RECENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFFB7B8BE),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 9 / 16,
            ),
            itemCount: 6,
            itemBuilder: (_, i) {
              final sel = _picked == i;
              return GestureDetector(
                onTap: () => setState(() => _picked = i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? rd.peri : rd.line,
                      width: sel ? 2 : 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: i.isEven
                          ? [const Color(0xFF1B2B6B), const Color(0xFF0F1C4D)]
                          : [const Color(0xFFEEF0F6), const Color(0xFFE3E6EF)],
                    ),
                  ),
                  child: sel
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              i == 4 ? 'Pass' : 'Chat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: FilledButton(
            onPressed: _picked == null ? null : _confirm,
            style: FilledButton.styleFrom(
              backgroundColor: rd.navy,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Use screenshot',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Link capture with unfurl preview — design2 `.lk`.
class RdLinkCaptureView extends StatefulWidget {
  const RdLinkCaptureView({
    super.key,
    required this.onSubmit,
    required this.onClose,
  });

  final void Function(String url, String? title) onSubmit;
  final VoidCallback onClose;

  @override
  State<RdLinkCaptureView> createState() => _RdLinkCaptureViewState();
}

class _RdLinkCaptureViewState extends State<RdLinkCaptureView> {
  final _url = TextEditingController();
  bool _focused = false;
  bool _reading = false;
  bool _showPreview = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final raw = _url.text.trim();
    if (raw.isEmpty) return;
    setState(() {
      _reading = true;
      _showPreview = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _reading = false;
      _showPreview = true;
    });
  }

  void _submit() {
    final raw = _url.text.trim();
    if (raw.isEmpty) return;
    widget.onSubmit(raw, 'Article from link');
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final canGo = _url.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: widget.onClose,
              child: const RdIcon(RdIcons.chevronLeft, size: 22, stroke: '#6B6C73'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save a link',
                style: GoogleFonts.dosis(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paste a URL — Mira reads the page for you',
                style: GoogleFonts.vazirmatn(fontSize: 13.5, color: rd.muted),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
          child: Container(
            height: 56,
            padding: const EdgeInsets.only(left: 18, right: 8),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focused ? rd.peri : rd.line,
                width: _focused ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                RdIcon(RdIcons.linkChain, size: 18, color: rd.faint),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _url,
                    onChanged: (_) => setState(() {}),
                    onTap: () => setState(() => _focused = true),
                    onTapOutside: (_) => setState(() => _focused = false),
                    decoration: InputDecoration(
                      hintText: 'https://…',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.vazirmatn(color: rd.faint, fontSize: 14.5),
                    ),
                    style: GoogleFonts.vazirmatn(fontSize: 14.5, color: rd.ink),
                    keyboardType: TextInputType.url,
                  ),
                ),
                IconButton(
                  onPressed: canGo ? _go : null,
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: rd.navy,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Center(
                      child: RdIcon('<path d="M5 12h14M13 6l6 6-6 6"/>', size: 18, stroke: '#FFFFFF'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_reading)
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF141828).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2, color: rd.navy),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Reading page…',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: rd.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_showPreview)
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
            child: Container(
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: rd.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF243056), Color(0xFF121A33)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _url.text.replaceFirst(RegExp(r'^https?://'), '').split('/').first,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: rd.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Article from link',
                          style: GoogleFonts.dosis(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: rd.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mira will extract the readable text and keep it searchable.',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            height: 1.5,
                            color: rd.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: FilledButton(
            onPressed: _showPreview ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: rd.navy,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Thumbnail preview bytes for review header.
Uint8List? capturePreviewBytes;
