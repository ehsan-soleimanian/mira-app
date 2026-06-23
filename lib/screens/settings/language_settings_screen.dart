import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key, required this.initialSettings});

  final UserSettings initialSettings;

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late UserSettings _settings = widget.initialSettings;
  bool _saving = false;

  Future<void> _setLanguage(MiraLanguagePreference language) async {
    final next = _settings.copyWith(language: language);
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
      ).showSnackBar(SnackBar(content: Text('Language update failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rtl = _settings.language == MiraLanguagePreference.persian;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: SettingsPageScaffold(
        title: rtl ? 'زبان' : 'Language',
        isSaving: _saving,
        children: [
          SettingsListTile(
            title: 'English',
            subtitle: 'Left to right',
            icon: Icons.language_rounded,
            trailing: Icon(
              _settings.language == MiraLanguagePreference.english
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
            ),
            onTap: () => _setLanguage(MiraLanguagePreference.english),
          ),
          SettingsListTile(
            title: 'فارسی',
            subtitle: 'راست به چپ',
            icon: Icons.translate_rounded,
            trailing: Icon(
              _settings.language == MiraLanguagePreference.persian
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
            ),
            onTap: () => _setLanguage(MiraLanguagePreference.persian),
          ),
          const SizedBox(height: 20),
          MiraButton(
            label: rtl ? 'تمام' : 'Done',
            onPressed: _saving
                ? null
                : () => Navigator.of(context).pop(_settings),
            size: MiraButtonSize.large,
            expand: true,
          ),
        ],
      ),
    );
  }
}
