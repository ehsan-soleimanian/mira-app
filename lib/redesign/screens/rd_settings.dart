import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/auth_models.dart';

import '../theme/rd_colors.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// The settings cluster — Account, Notifications, Connected apps. All three
/// share the grouped-row aesthetic (`.rd-account`), so the row / group / toggle
/// / tile primitives live here and every screen composes them. Faithful to
/// `account.jsx`, `notifications.jsx`, `connectedapps.jsx`. Toggles are local.

const _danger = Color(0xFFC0392B);
const _green = Color(0xFF1F8A5B);

// ══ Account ════════════════════════════════════════════════════════════
class RdAccountScreen extends StatefulWidget {
  const RdAccountScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdAccountScreen> createState() => _RdAccountScreenState();
}

class _RdAccountScreenState extends State<RdAccountScreen> {
  bool _faceId = true;
  bool _autoLock = true;

  // Sample fallbacks — used until the real profile loads, or if it can't.
  static const _sampleName = 'Sara Kim';
  static const _sampleEmail = 'sara.kim@hey.com';

  /// The signed-in user from `authRepository.fetchMe()`; null until loaded /
  /// unreachable, in which case the sample profile shows.
  AuthUser? _user;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final user = await AppScope.servicesOf(context).authRepository.fetchMe();
      if (mounted) setState(() => _user = user);
    } catch (_) {
      // Backend unreachable — keep the sample profile.
    }
  }

  String get _name {
    final name = _user?.displayName.trim() ?? '';
    return name.isEmpty ? _sampleName : name;
  }

  String get _email {
    final email = _user?.email.trim() ?? '';
    return email.isEmpty ? _sampleEmail : email;
  }

  /// First-letter initials for the avatar (e.g. "Sara Kim" → "SK").
  String get _initials {
    final parts =
        _name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'SK';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: RdColors.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
          ),
        ),
      );
  }

  Future<void> _signOut() async {
    try {
      await AppScope.servicesOf(context).authRepository.logout();
    } catch (_) {
      // Best-effort — clear whatever we can and let the user know.
    }
    _toast('Signed out');
  }

  @override
  Widget build(BuildContext context) {
    return _AcScaffold(
      onBack: widget.onBack,
      title: 'Account',
      children: [
        _AcProfile(name: _name, email: _email, initials: _initials),
        const SizedBox(height: 8),
        _AcSection(
          label: 'Profile',
          rows: [
            _AcRow(icon: '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>', title: 'Name', value: _name),
            _AcRow(icon: '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m4 7 8 6 8-6"/>', title: 'Email', value: _email),
            const _AcRow(icon: '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L16 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2Z"/>', title: 'Phone', value: '+1 (415) •••-2231'),
          ],
        ),
        _AcSection(
          label: 'Security',
          rows: [
            _AcRow(
              icon: '<rect x="4" y="10" width="16" height="10" rx="2.5"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
              title: 'Face ID unlock',
              sub: 'Require Face ID to open Mira',
              chevron: false,
              trailing: _AcToggle(on: _faceId),
              onTap: () => setState(() => _faceId = !_faceId),
            ),
            _AcRow(
              icon: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
              title: 'Auto-lock',
              sub: 'Lock after 5 minutes idle',
              chevron: false,
              trailing: _AcToggle(on: _autoLock),
              onTap: () => setState(() => _autoLock = !_autoLock),
            ),
            const _AcRow(icon: '<rect x="3" y="11" width="18" height="10" rx="2"/><path d="M7 11V8a5 5 0 0 1 10 0v3"/>', title: 'Change password'),
          ],
        ),
        _AcSection(
          label: 'Plan',
          rows: const [
            _AcRow(icon: '<path d="M3 8l4 3 5-6 5 6 4-3-2 11H5L3 8Z"/>', title: 'Mira Plus', sub: 'Renews Aug 12 · \$8 / month', value: 'Manage'),
          ],
        ),
        _AcSection(
          label: 'Preferences',
          rows: [
            _AcRow(
              icon: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>',
              title: 'Notifications',
              sub: 'Brief, reminders & quiet hours',
              onTap: () => widget.go('notifications'),
            ),
            _AcRow(
              icon: '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
              title: 'Connected apps',
              sub: 'Calendar, Notes, Photos & more',
              onTap: () => widget.go('connectedapps'),
            ),
          ],
        ),
        _AcSection(
          label: 'Memory & data',
          rows: const [
            _AcStorage(),
            _AcRow(icon: '<path d="M12 3v12"/><path d="m8 11 4 4 4-4"/><path d="M4 19h16"/>', title: 'Export my data', sub: 'Download everything Mira holds'),
            _AcRow(icon: '<path d="M12 3a9 9 0 1 0 9 9"/><path d="M12 7v5l3 2"/>', title: 'Memory history', sub: 'See what was captured & when'),
          ],
        ),
        _AcSection(
          rows: [
            _AcRow(icon: '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/>', title: 'Sign out', chevron: false, onTap: _signOut),
            _AcRow(icon: '<path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M6 6v14a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V6"/>', title: 'Delete account', chevron: false, danger: true),
          ],
        ),
        const _AcFoot('Mira · Version 1.0'),
      ],
    );
  }
}

// ══ Notifications ══════════════════════════════════════════════════════
class RdNotificationsScreen extends StatefulWidget {
  const RdNotificationsScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdNotificationsScreen> createState() => _RdNotificationsScreenState();
}

class _RdNotificationsScreenState extends State<RdNotificationsScreen> {
  // Designed defaults — shown until backend settings load, or if unreachable.
  final Map<String, bool> _st = {
    'brief': true, 'briefResurface': true, 'timeSensitive': true, 'nudges': true,
    'captureConfirm': true, 'weekly': false, 'quiet': true, 'sound': true, 'haptics': true,
  };

  /// Maps each toggle key to its backend camelCase field on
  /// `/notification-settings`. Every toggle is backend-persisted.
  static const _backendField = <String, String>{
    'brief': 'dailyBriefEnabled',
    'briefResurface': 'briefResurfaceEnabled',
    'nudges': 'remindersEnabled',
    'timeSensitive': 'timeSensitiveEnabled',
    'captureConfirm': 'captureSuccessEnabled',
    'weekly': 'weeklyDigestEnabled',
    'quiet': 'quietHoursEnabled',
    'sound': 'soundEnabled',
    'haptics': 'hapticsEnabled',
  };

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final data = await AppScope.servicesOf(context)
          .settingsRepository
          .notificationSettings();
      if (!mounted) return;
      setState(() {
        _backendField.forEach((key, field) {
          final value = data[field];
          if (value is bool) _st[key] = value;
        });
      });
    } catch (_) {
      // Backend unreachable — keep the designed defaults.
    }
  }

  /// Optimistically flip the toggle, then PATCH the mapped backend field
  /// best-effort. Local-only toggles simply update the UI.
  void _t(String k) {
    final next = !(_st[k] ?? false);
    setState(() => _st[k] = next);
    final field = _backendField[k];
    if (field == null) return;
    unawaited(_push(field, next));
  }

  Future<void> _push(String field, bool value) async {
    try {
      await AppScope.servicesOf(context)
          .settingsRepository
          .updateNotificationSettings({field: value});
    } catch (_) {
      // Best-effort — the optimistic UI stays; nothing to roll back offline.
    }
  }

  _AcRow _toggleRow(String icon, String title, String? sub, String k) => _AcRow(
        icon: icon,
        title: title,
        sub: sub,
        chevron: false,
        trailing: _AcToggle(on: _st[k] ?? false),
        onTap: () => _t(k),
      );

  @override
  Widget build(BuildContext context) {
    return _AcScaffold(
      onBack: widget.onBack,
      title: 'Notifications',
      intro: 'Mira stays quiet by default — and only speaks up when it truly helps.',
      children: [
        _AcSection(
          label: 'Daily Brief',
          rows: [
            _toggleRow('<circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M1 12h2M21 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4"/>', 'Morning brief', 'A calm summary to start the day', 'brief'),
            const _AcRow(icon: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>', title: 'Brief time', value: '8:00 AM'),
            _toggleRow('<path d="M12 3a9 9 0 1 0 9 9 6 6 0 0 1-9-9Z"/>', 'Resurface a memory', 'Occasionally revisit something worth holding', 'briefResurface'),
          ],
        ),
        _AcSection(
          label: 'Reminders',
          rows: [
            _toggleRow('<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>', 'Time-sensitive reminders', 'Dates, tickets, and things that expire', 'timeSensitive'),
            _toggleRow('<path d="M12 2v4M12 18v4M2 12h4M18 12h4"/><circle cx="12" cy="12" r="4"/>', 'Gentle nudges', 'Soft prompts for unfinished threads', 'nudges'),
          ],
        ),
        _AcSection(
          label: 'Captures',
          rows: [
            _toggleRow('<path d="M20 6 9 17l-5-5"/>', 'Confirm before saving', 'Ask before adding a capture to your graph', 'captureConfirm'),
            _toggleRow('<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>', 'Weekly recap', 'A Sunday look back at the week', 'weekly'),
          ],
        ),
        _AcSection(
          label: 'Quiet hours',
          rows: [
            _toggleRow('<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8Z"/>', 'Quiet hours', 'Hold all notifications while you rest', 'quiet'),
            const _AcRow(icon: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>', title: 'Schedule', value: '10:00 PM – 7:00 AM'),
          ],
        ),
        _AcSection(
          label: 'Delivery',
          rows: [
            _toggleRow('<path d="M11 5 6 9H2v6h4l5 4V5Z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/>', 'Sound', null, 'sound'),
            _toggleRow('<rect x="7" y="2" width="10" height="20" rx="3"/><path d="M11 18h2"/>', 'Haptics', null, 'haptics'),
          ],
        ),
        const _AcFoot('Mira notifies you gently, or not at all.'),
      ],
    );
  }
}

// ══ Connected apps ═════════════════════════════════════════════════════
class RdConnectedAppsScreen extends StatefulWidget {
  const RdConnectedAppsScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdConnectedAppsScreen> createState() => _RdConnectedAppsScreenState();
}

class _RdConnectedAppsScreenState extends State<RdConnectedAppsScreen> {
  final Map<String, bool> _conn = {'gmail': false, 'safari': false, 'readwise': false, 'voice': false};

  @override
  Widget build(BuildContext context) {
    return _AcScaffold(
      onBack: widget.onBack,
      title: 'Connected apps',
      intro: 'Mira quietly weaves these sources into your memory — nothing leaves without your say.',
      children: [
        _AcSection(
          label: 'Connected',
          rows: const [
            _AcRow(tile: (Color(0x20E94848), '<path d="M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Zm0 3 8 5 8-5"/>'), title: 'Calendar', sub: 'Synced 2m ago · feeds your Brief', subDot: true),
            _AcRow(tile: (Color(0x20F0B545), '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>'), title: 'Notes', sub: 'Synced 1h ago · 128 notes', subDot: true),
            _AcRow(tile: (Color(0x205B8DEF), '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="8.5" cy="10" r="1.6"/><path d="m5 18 5-4 3 2 3-3 5 4"/>'), title: 'Photos', sub: 'Synced today · screenshots & scans', subDot: true),
          ],
        ),
        _AcSection(
          label: 'Available',
          rows: [
            _available('gmail', const Color(0x20EA4335), '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m3 7 9 6 9-6"/>', 'Gmail', 'Turn important mail into memories'),
            _available('safari', const Color(0x202A9DF4), '<circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5-5 2 2-5 5-2Z"/>', 'Safari', 'Save pages & highlights as you browse'),
            _available('readwise', const Color(0x207C6BEA), '<path d="M4 5a2 2 0 0 1 2-2h12v18H6a2 2 0 0 1-2-2Z"/><path d="M18 3v18"/>', 'Readwise', 'Import book & article highlights'),
            _available('voice', const Color(0x20E86868), '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>', 'Voice Memos', 'Transcribe recordings into your graph'),
          ],
        ),
        const _CaPrivacy(),
        const _AcFoot('4 sources available to connect'),
      ],
    );
  }

  _AcRow _available(String k, Color bg, String icon, String name, String sub) {
    final on = _conn[k] ?? false;
    return _AcRow(
      tile: (bg, icon),
      title: name,
      sub: sub,
      chevron: false,
      trailing: on
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RdIcon(RdIcons.checkThick, size: 15, stroke: '#1F8A5B', strokeWidth: 2.4),
                const SizedBox(width: 4),
                Text('Connected', style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: _green)),
              ],
            )
          : GestureDetector(
              onTap: () => setState(() => _conn[k] = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: RdColors.ink, borderRadius: BorderRadius.circular(100)),
                child: Text('Connect', style: GoogleFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
    );
  }
}

// ══ shared primitives ══════════════════════════════════════════════════
class _AcScaffold extends StatelessWidget {
  const _AcScaffold({required this.onBack, required this.title, required this.children, this.intro});

  final VoidCallback onBack;
  final String title;
  final String? intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RdColors.bg,
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
                        const RdIcon(RdIcons.chevronLeft, size: 20, stroke: '#14328C', strokeWidth: 2),
                        const SizedBox(width: 3),
                        Text('Settings', style: GoogleFonts.vazirmatn(fontSize: 15, color: RdColors.navy)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 12, 26, 4),
                child: Text(title, style: GoogleFonts.dosis(fontSize: 30, fontWeight: FontWeight.w700, color: RdColors.ink)),
              ),
              if (intro != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
                  child: Text(intro!, style: GoogleFonts.vazirmatn(fontSize: 14, height: 1.5, color: RdColors.muted)),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _AcSection extends StatelessWidget {
  const _AcSection({required this.rows, this.label});

  final String? label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
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
                style: GoogleFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: RdColors.faint),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: RdColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RdColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.only(left: 52),
                      child: Divider(height: 1, thickness: 1, color: RdColors.line),
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcRow extends StatelessWidget {
  const _AcRow({
    this.icon,
    this.tile,
    required this.title,
    this.sub,
    this.value,
    this.trailing,
    this.chevron = true,
    this.danger = false,
    this.subDot = false,
    this.onTap,
  });

  final String? icon;
  final (Color, String)? tile;
  final String title;
  final String? sub;
  final String? value;
  final Widget? trailing;
  final bool chevron;
  final bool danger;
  final bool subDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            if (tile != null) ...[
              _AcTile(bg: tile!.$1, icon: tile!.$2),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              SizedBox(
                width: 24,
                child: RdIcon(icon!, size: 19, stroke: danger ? '#C0392B' : '#7E8BC9', strokeWidth: 1.8),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: danger ? _danger : RdColors.ink,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (subDot) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            sub!,
                            style: GoogleFonts.vazirmatn(fontSize: 12.5, color: RdColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(value!, style: GoogleFonts.vazirmatn(fontSize: 14, color: RdColors.muted)),
              ),
            if (trailing != null)
              Padding(padding: const EdgeInsets.only(left: 8), child: trailing!)
            else if (chevron)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: RdIcon('<path d="m9 6 6 6-6 6"/>', size: 18, stroke: '#B7B8BE', strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}

class _AcTile extends StatelessWidget {
  const _AcTile({required this.bg, required this.icon});

  final Color bg;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Center(child: RdIcon(icon, size: 19, stroke: '#1B1C24', strokeWidth: 1.9)),
    );
  }
}

class _AcToggle extends StatelessWidget {
  const _AcToggle({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 28,
      decoration: BoxDecoration(
        color: on ? RdColors.navy : const Color(0xFFD8D8D2),
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
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _AcProfile extends StatelessWidget {
  const _AcProfile({
    required this.name,
    required this.email,
    required this.initials,
  });

  final String name;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RdColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RdColors.line, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.36, -0.44),
                colors: [Color(0xFF9AA6DA), Color(0xFF4B5BA6)],
              ),
            ),
            child: Center(
              child: Text(initials, style: GoogleFonts.dosis(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.dosis(fontSize: 20, fontWeight: FontWeight.w700, color: RdColors.ink)),
                const SizedBox(height: 2),
                Text(email, style: GoogleFonts.vazirmatn(fontSize: 13.5, color: RdColors.muted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
                  decoration: BoxDecoration(color: const Color(0xFFE7F3EC), borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _green)),
                      const SizedBox(width: 5),
                      Text('All memories synced', style: GoogleFonts.vazirmatn(fontSize: 11.5, fontWeight: FontWeight.w600, color: _green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcStorage extends StatelessWidget {
  const _AcStorage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('34 memories', style: GoogleFonts.dosis(fontSize: 17, fontWeight: FontWeight.w700, color: RdColors.ink)),
              const Spacer(),
              Text('of 2,000 · plenty of room', style: GoogleFonts.vazirmatn(fontSize: 12.5, color: RdColors.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 7,
            decoration: BoxDecoration(color: const Color(0xFFE7E7E1), borderRadius: BorderRadius.circular(100)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.22,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(colors: [Color(0xFF7E8BC9), Color(0xFF14328C)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaPrivacy extends StatelessWidget {
  const _CaPrivacy();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F7), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RdIcon(
            '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/>',
            size: 18,
            stroke: '#6B7A99',
            strokeWidth: 1.8,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mira only reads what you connect, and processes it privately. Disconnect anytime.',
              style: GoogleFonts.vazirmatn(fontSize: 12.5, height: 1.5, color: RdColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcFoot extends StatelessWidget {
  const _AcFoot(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Center(
        child: Text(text, style: GoogleFonts.vazirmatn(fontSize: 12, color: RdColors.faint)),
      ),
    );
  }
}
