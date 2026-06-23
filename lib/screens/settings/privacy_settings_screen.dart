import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key, required this.initialSettings});

  final UserSettings initialSettings;

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late UserSettings _settings = widget.initialSettings;
  bool _saving = false;

  Future<void> _save(UserSettings next) async {
    setState(() {
      _settings = next;
      _saving = true;
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Privacy update failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Privacy',
      isSaving: _saving,
      children: [
        SettingsListTile(
          title: 'Memory insights',
          subtitle: _settings.memoryInsightsEnabled ? 'Enabled' : 'Disabled',
          icon: Icons.auto_awesome_outlined,
          trailing: Switch.adaptive(
            value: _settings.memoryInsightsEnabled,
            onChanged: (value) =>
                _save(_settings.copyWith(memoryInsightsEnabled: value)),
          ),
        ),
        SettingsListTile(
          title: 'Diagnostics',
          subtitle: _settings.analyticsEnabled ? 'Enabled' : 'Disabled',
          icon: Icons.shield_outlined,
          trailing: Switch.adaptive(
            value: _settings.analyticsEnabled,
            onChanged: (value) =>
                _save(_settings.copyWith(analyticsEnabled: value)),
          ),
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
