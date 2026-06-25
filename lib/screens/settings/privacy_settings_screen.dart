import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Privacy update failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MiraPageHeader(
              title: 'Privacy',
              onBack: () => Navigator.of(context).pop(_settings),
              trailing: _saving
                  ? const SizedBox(
                      width: PageHeaderTokens.actionSize,
                      height: PageHeaderTokens.actionSize,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(48 * s, 4 * s, 48 * s, 48 * s),
                children: [
                  Text(
                    'Control how Mira uses your data. These settings apply '
                    'across captures, memory, and daily brief.',
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
                      color: const Color(0xFF6B6B6B),
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  FigmaSettingsToggleCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Memory insights',
                    subtitle: _settings.memoryInsightsEnabled
                        ? 'Mira can surface patterns from your memories'
                        : 'Insights from memories are paused',
                    value: _settings.memoryInsightsEnabled,
                    onChanged: (value) =>
                        _save(_settings.copyWith(memoryInsightsEnabled: value)),
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsToggleCard(
                    icon: Icons.shield_outlined,
                    title: 'Diagnostics',
                    subtitle: _settings.analyticsEnabled
                        ? 'Anonymous usage data helps improve Mira'
                        : 'Diagnostics sharing is turned off',
                    value: _settings.analyticsEnabled,
                    onChanged: (value) =>
                        _save(_settings.copyWith(analyticsEnabled: value)),
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsCard(
                    padding: figmaInsets(context, 24, 28, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FigmaSettingsPeachIcon(
                              icon: Icons.lock_outline_rounded,
                            ),
                            SizedBox(width: 16 * s),
                            Expanded(
                              child: Text(
                                'Your data stays yours',
                                style: GoogleFonts.inter(
                                  fontSize: 26 * s,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14 * s),
                        Text(
                          'Memories are stored securely and only used to help '
                          'you. You can delete captures at any time from chat.',
                          style: GoogleFonts.inter(
                            fontSize: 20 * s,
                            color: const Color(0xFF7A7A7A),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
