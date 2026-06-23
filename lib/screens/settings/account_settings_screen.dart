import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/features/auth/auth_gate.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key, this.initialUser});

  final AuthUser? initialUser;

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _role = TextEditingController();
  late final TextEditingController _gender = TextEditingController();
  late final TextEditingController _bio = TextEditingController();

  AuthUser? _user;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    if (_user != null) _fill(_user!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    try {
      final user =
          _user ??
          await AppScope.servicesOf(context).settingsRepository.fetchProfile();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
        _error = null;
      });
      _fill(user);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _fill(AuthUser user) {
    _name.text = user.displayName;
    _role.text = user.role ?? '';
    _gender.text = user.gender ?? '';
    _bio.text = user.bio ?? '';
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _saving = true);
    try {
      final user = await AppScope.servicesOf(context).settingsRepository
          .updateProfile(
            displayName: _name.text,
            role: _role.text,
            gender: _gender.text,
            bio: _bio.text,
          );
      if (!mounted) return;
      setState(() {
        _user = user;
        _saving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account updated')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $error')));
    }
  }

  Future<void> _logout() async {
    setState(() => _saving = true);
    await AppScope.servicesOf(context).authRepository.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _gender.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: SettingsErrorView(
          message: _error!,
          onRetry: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            _load();
          },
        ),
      );
    }

    return SettingsPageScaffold(
      title: 'Account',
      isSaving: _saving,
      children: [
        SettingsValueRow(
          label: 'Email',
          value: _user?.email ?? '',
          icon: Icons.alternate_email_rounded,
        ),
        const SettingsSectionLabel('PROFILE'),
        const MiraFieldLabel('Name'),
        MiraInputField(
          controller: _name,
          showMic: false,
          hintText: 'Your name',
          enabled: !_saving,
        ),
        const SizedBox(height: 14),
        const MiraFieldLabel('Role'),
        MiraInputField(
          controller: _role,
          showMic: false,
          hintText: 'Designer, engineer...',
          enabled: !_saving,
        ),
        const SizedBox(height: 14),
        const MiraFieldLabel('Gender'),
        MiraInputField(
          controller: _gender,
          showMic: false,
          hintText: 'Optional',
          enabled: !_saving,
        ),
        const SizedBox(height: 14),
        const MiraFieldLabel('Bio'),
        MiraInputField(
          controller: _bio,
          showMic: false,
          hintText: 'Tell Mira about your context',
          enabled: !_saving,
          height: 112,
          maxLines: 4,
        ),
        const SizedBox(height: 22),
        MiraButton(
          label: _saving ? 'Saving...' : 'Save changes',
          onPressed: _saving ? null : _save,
          size: MiraButtonSize.large,
          expand: true,
        ),
        const SizedBox(height: 12),
        MiraButton(
          label: 'Logout',
          onPressed: _saving ? null : _logout,
          color: MiraButtonColor.danger,
          variant: MiraButtonVariant.outlined,
          size: MiraButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}
