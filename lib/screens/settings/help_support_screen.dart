import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, this.user});

  final AuthUser? user;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool? _apiReady;
  bool _checking = false;

  Future<void> _checkApi() async {
    setState(() => _checking = true);
    final ready = await AppScope.servicesOf(
      context,
    ).settingsRepository.checkApiReady();
    if (!mounted) return;
    setState(() {
      _apiReady = ready;
      _checking = false;
    });
  }

  Future<void> _copyDiagnostics() async {
    final readyText = _apiReady?.toString() ?? 'not checked';
    final text = [
      'Mira App',
      'API: ${ApiConfig.baseUrl}',
      'User: ${widget.user?.email ?? 'unknown'}',
      'Ready: $readyText',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Support details copied')));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Help & support',
      isSaving: _checking,
      children: [
        SettingsValueRow(
          label: 'API base URL',
          value: ApiConfig.baseUrl,
          icon: Icons.cloud_outlined,
        ),
        SettingsValueRow(
          label: 'API status',
          value: _apiReady == null
              ? 'Not checked'
              : _apiReady!
              ? 'Ready'
              : 'Unavailable',
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: 18),
        MiraButton(
          label: _checking ? 'Checking...' : 'Check API status',
          onPressed: _checking ? null : _checkApi,
          size: MiraButtonSize.large,
          expand: true,
        ),
        const SizedBox(height: 12),
        MiraButton(
          label: 'Copy support details',
          onPressed: _copyDiagnostics,
          variant: MiraButtonVariant.outlined,
          size: MiraButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}
