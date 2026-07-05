import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/auth/auth_gate.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/account_settings_screen.dart';
import 'package:mira_app/screens/settings/help_support_screen.dart';
import 'package:mira_app/screens/settings/notification_settings_screen.dart';
import 'package:mira_app/screens/settings/privacy_settings_screen.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/screens/workspace/connector_marketplace_screen.dart';
import 'package:mira_app/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _inviteCode = 'Mira_23456';
  static const _miraLink = 'Mira_23456';

  AuthUser? _user;
  UserSettings? _settings;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    try {
      final services = AppScope.servicesOf(context);
      final themeController = AppScope.themeOf(context);
      final results = await Future.wait<Object>([
        services.settingsRepository.fetchProfile(),
        services.settingsRepository.fetchSettings(),
      ]);
      final settings = results[1] as UserSettings;
      themeController.setPreference(settings.theme);
      if (!mounted) return;
      setState(() {
        _user = results[0] as AuthUser;
        _settings = settings;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _load();
  }

  Future<void> _logout() async {
    final authRepository = AppScope.servicesOf(context).authRepository;
    final navigator = Navigator.of(context);
    final s = figmaSettingsScale(context);
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Log out',
      barrierColor: Colors.black.withValues(alpha: 0.02),
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.sizeOf(context).width - 96,
                constraints: const BoxConstraints(maxWidth: 690),
                padding: EdgeInsets.fromLTRB(31 * s, 36 * s, 31 * s, 31 * s),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15 * s),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you want to log out?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.18,
                      ),
                    ),
                    SizedBox(height: 22 * s),
                    Text(
                      "You'll need your email and password to log back",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Row(
                      children: [
                        Expanded(
                          child: _DialogActionButton(
                            label: 'Cancel',
                            outlined: true,
                            onTap: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        SizedBox(width: 32 * s),
                        Expanded(
                          child: _DialogActionButton(
                            label: 'Log Out',
                            onTap: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;
    await authRepository.logout();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      miraRoute((_) => const AuthGate()),
      (_) => false,
    );
  }

  Future<void> _openNotifications() async {
    final current = _settings;
    if (current == null) return;
    final updated = await Navigator.of(context).pushMira<UserSettings>(
      (_) => NotificationSettingsScreen(initialSettings: current),
    );
    if (!mounted || updated == null) return;
    setState(() => _settings = updated);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _refresh, child: const Text('Retry')),
            ],
          ),
        ),
      );
    } else {
      body = _SettingsContent(
        user: _user!,
        settings: _settings!,
        inviteCode: _inviteCode,
        miraLink: _miraLink,
        onRefresh: _refresh,
        onAccount: () => Navigator.of(
          context,
        ).pushMira((_) => AccountSettingsScreen(initialUser: _user)),
        onNotifications: _openNotifications,
        onConnectors: () => Navigator.of(
          context,
        ).pushMira((_) => const ConnectorMarketplaceScreen()),
        onPrivacy: () => Navigator.of(
          context,
        ).pushMira((_) => PrivacySettingsScreen(initialSettings: _settings!)),
        onAbout: () => Navigator.of(
          context,
        ).pushMira((_) => HelpSupportScreen(user: _user)),
        onLogout: _logout,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            FigmaSettingsHeader(
              title: 'Setting',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.user,
    required this.settings,
    required this.inviteCode,
    required this.miraLink,
    required this.onRefresh,
    required this.onAccount,
    required this.onNotifications,
    required this.onConnectors,
    required this.onPrivacy,
    required this.onAbout,
    required this.onLogout,
  });

  final AuthUser user;
  final UserSettings settings;
  final String inviteCode;
  final String miraLink;
  final Future<void> Function() onRefresh;
  final VoidCallback onAccount;
  final VoidCallback onNotifications;
  final VoidCallback onConnectors;
  final VoidCallback onPrivacy;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(48 * s, 0, 48 * s, 52 * s),
        children: [
          const FigmaSettingsSectionLabel('Account'),
          FigmaSettingsCard(
            padding: figmaInsets(context, 31, 30, 31, 32),
            onTap: onAccount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isEmpty ? 'sajad' : user.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 28 * s,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2A2A2A),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16 * s),
                Text(
                  user.email.isEmpty ? 'Example @gmail.com' : user.email,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 25 * s,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2A2A2A),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const FigmaSettingsSectionLabel('Preferences'),
          FigmaSettingsCard(
            padding: figmaInsets(context, 16, 31, 28, 31),
            onTap: onNotifications,
            child: _PrimaryTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: settings.notificationsEnabled
                  ? 'Task reminders are active on this device'
                  : 'Notifications are turned off',
              showBadge: settings.notificationsEnabled,
            ),
          ),
          SizedBox(height: 16 * s),
          FigmaSettingsCard(
            padding: figmaInsets(context, 16, 31, 28, 31),
            onTap: onConnectors,
            child: const _PrimaryTile(
              icon: Icons.sync_alt_rounded,
              title: 'Connectors',
              subtitle: 'Provider sync, OAuth, and automation',
            ),
          ),
          const FigmaSettingsSectionLabel('Invite'),
          FigmaSettingsCard(
            padding: figmaInsets(context, 16, 31, 16, 31),
            child: Column(
              children: [
                const _PrimaryTile(
                  icon: Icons.group_outlined,
                  title: 'Invite with code',
                  subtitle: "You've had 0 successful invites",
                  showChevron: false,
                ),
                SizedBox(height: 18 * s),
                _CopyField(value: inviteCode),
              ],
            ),
          ),
          const FigmaSettingsSectionLabel('Get Mira'),
          FigmaSettingsCard(
            padding: figmaInsets(context, 16, 31, 16, 31),
            child: Column(
              children: [
                const _PrimaryTile(
                  icon: Icons.link_rounded,
                  title: 'Get link',
                  subtitle: 'link to access Mira anywhere',
                  showChevron: false,
                ),
                SizedBox(height: 18 * s),
                _CopyField(value: miraLink),
              ],
            ),
          ),
          SizedBox(height: 32 * s),
          FigmaSettingsCard(
            padding: EdgeInsets.symmetric(horizontal: 31 * s, vertical: 17 * s),
            child: Column(
              children: [
                _SimpleNavRow(
                  icon: Icons.shield_outlined,
                  label: 'Privacy details',
                  onTap: onPrivacy,
                ),
                Divider(height: 42 * s, color: const Color(0xFFE3E3E3)),
                _SimpleNavRow(
                  icon: Icons.workspace_premium_outlined,
                  label: 'About us',
                  onTap: onAbout,
                ),
              ],
            ),
          ),
          SizedBox(height: 67 * s),
          Center(
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(8),
              child: Text(
                'Log out',
                style: GoogleFonts.inter(
                  fontSize: 25 * s,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA6192E),
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFFA6192E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryTile extends StatelessWidget {
  const _PrimaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBadge = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBadge;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Row(
      children: [
        _PeachIconBox(icon: icon, showBadge: showBadge),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 29 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF292929),
                  height: 1.05,
                ),
              ),
              SizedBox(height: 14 * s),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 25 * s,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        if (showChevron)
          Icon(
            Icons.chevron_right_rounded,
            size: 55 * s,
            color: const Color(0xFF202020),
          ),
      ],
    );
  }
}

class _PeachIconBox extends StatelessWidget {
  const _PeachIconBox({required this.icon, this.showBadge = false});

  final IconData icon;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80 * s,
          height: 80 * s,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2ED),
            borderRadius: BorderRadius.circular(13 * s),
          ),
          child: Icon(icon, size: 38 * s, color: const Color(0xFF756A66)),
        ),
        if (showBadge)
          Positioned(
            top: 0,
            right: -2,
            child: Container(
              width: 17 * s,
              height: 17 * s,
              decoration: const BoxDecoration(
                color: Color(0xFF4A6EFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _CopyField extends StatefulWidget {
  const _CopyField({required this.value});

  final String value;

  @override
  State<_CopyField> createState() => _CopyFieldState();
}

class _CopyFieldState extends State<_CopyField> {
  static const _copiedFill = Color(0xFFDFF5E4);
  static const _copiedBorder = Color(0xFF3D9B5A);
  static const _defaultFill = Color(0xFFEFF3FF);

  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _copied ? _copiedFill : _defaultFill,
        borderRadius: BorderRadius.circular(13 * s),
        border: Border.all(
          color: _copied ? _copiedBorder : Colors.transparent,
          width: 1.5 * s,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _copy,
          borderRadius: BorderRadius.circular(13 * s),
          child: Container(
            height: 80 * s,
            padding: EdgeInsets.only(left: 16 * s, right: 28 * s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value,
                    style: GoogleFonts.inter(
                      fontSize: 29 * s,
                      fontWeight: FontWeight.w400,
                      color: _copied ? _copiedBorder : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 40 * s,
                  color: _copied ? _copiedBorder : const Color(0xFF202020),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleNavRow extends StatelessWidget {
  const _SimpleNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 72 * s,
        child: Row(
          children: [
            Icon(icon, size: 30 * s, color: const Color(0xFF33469A)),
            SizedBox(width: 16 * s),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF252525),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 55 * s,
              color: const Color(0xFF202020),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Material(
      color: outlined ? Colors.white : const Color(0xFFA6192E),
      borderRadius: BorderRadius.circular(14 * s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * s),
        child: Container(
          height: 76 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * s),
            border: outlined
                ? Border.all(color: const Color(0xFF003EAD), width: 2 * s)
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 27 * s,
              fontWeight: FontWeight.w700,
              color: outlined ? const Color(0xFF003EAD) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
