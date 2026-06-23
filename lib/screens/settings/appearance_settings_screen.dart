import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key, required this.initialSettings});

  final UserSettings initialSettings;

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  late UserSettings _settings = widget.initialSettings;
  bool _saving = false;

  Future<void> _setTheme(MiraThemePreference theme) async {
    final next = _settings.copyWith(theme: theme);
    setState(() {
      _settings = next;
      _saving = true;
    });
    AppScope.themeOf(context).setPreference(theme);
    try {
      final saved = await AppScope.servicesOf(
        context,
      ).settingsRepository.updateSettings(next);
      if (!mounted) return;
      setState(() {
        _settings = saved;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appearance update failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Appearance',
      isSaving: _saving,
      children: [
        const SettingsSectionLabel('THEME'),
        _ThemeTile(
          label: 'System',
          icon: Icons.phone_iphone_rounded,
          selected: _settings.theme == MiraThemePreference.system,
          onTap: () => _setTheme(MiraThemePreference.system),
        ),
        _ThemeTile(
          label: 'Light',
          icon: Icons.light_mode_outlined,
          selected: _settings.theme == MiraThemePreference.light,
          onTap: () => _setTheme(MiraThemePreference.light),
        ),
        _ThemeTile(
          label: 'Dark',
          icon: Icons.dark_mode_outlined,
          selected: _settings.theme == MiraThemePreference.dark,
          onTap: () => _setTheme(MiraThemePreference.dark),
        ),
        const SizedBox(height: 20),
        MiraButton(
          label: 'Done',
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(_settings),
          size: MiraButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: label,
      icon: icon,
      trailing: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      onTap: onTap,
    );
  }
}
