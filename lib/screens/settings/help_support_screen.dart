import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/figma_assets.dart';
import 'package:mira_app/models/api/auth_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/theme/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, this.user});

  final AuthUser? user;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _appVersion = '1.0.0';
  static const _buildNumber = '1';

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
      'Version: $_appVersion ($_buildNumber)',
      'API: ${ApiConfig.baseUrl}',
      'User: ${widget.user?.email ?? 'unknown'}',
      'Ready: $readyText',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support details copied')),
    );
  }

  String get _apiStatusLabel {
    if (_checking) return 'Checking...';
    if (_apiReady == null) return 'Tap to check';
    return _apiReady! ? 'Connected' : 'Unavailable';
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
              title: 'About us',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(48 * s, 4 * s, 48 * s, 48 * s),
                children: [
                  FigmaSettingsCard(
                    padding: figmaInsets(context, 28, 32, 28, 32),
                    child: Column(
                      children: [
                        Image.asset(
                          FigmaAssets.ball,
                          width: 88 * s,
                          height: 88 * s,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 18 * s),
                        Text(
                          'Mira',
                          style: GoogleFonts.inter(
                            fontSize: 34 * s,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Text(
                          'Your calm memory companion',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22 * s,
                            color: const Color(0xFF6B6B6B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsCard(
                    padding: figmaInsets(context, 24, 26, 24, 26),
                    child: Row(
                      children: [
                        FigmaSettingsPeachIcon(icon: Icons.info_outline_rounded),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Version',
                                style: GoogleFonts.inter(
                                  fontSize: 26 * s,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6 * s),
                              Text(
                                '$_appVersion · Build $_buildNumber',
                                style: GoogleFonts.inter(
                                  fontSize: 20 * s,
                                  color: const Color(0xFF7A7A7A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsActionRow(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact support',
                    subtitle: 'hello@miramind.io',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support email copied to clipboard'),
                        ),
                      );
                      Clipboard.setData(
                        const ClipboardData(text: 'hello@miramind.io'),
                      );
                    },
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsActionRow(
                    icon: Icons.copy_rounded,
                    title: 'Copy diagnostics',
                    subtitle: 'Share app details with our team',
                    onTap: _copyDiagnostics,
                    trailing: Icon(
                      Icons.content_copy_rounded,
                      size: 36 * s,
                      color: const Color(0xFF202020),
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  FigmaSettingsActionRow(
                    icon: Icons.cloud_outlined,
                    title: 'API status',
                    subtitle: _apiStatusLabel,
                    onTap: _checking ? null : _checkApi,
                    trailing: _checking
                        ? SizedBox(
                            width: 28 * s,
                            height: 28 * s,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _apiReady == true
                                ? Icons.check_circle_outline_rounded
                                : Icons.refresh_rounded,
                            size: 36 * s,
                            color: _apiReady == true
                                ? const Color(0xFF3D9B5A)
                                : const Color(0xFF202020),
                          ),
                  ),
                  SizedBox(height: 10 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                    child: Text(
                      ApiConfig.baseUrl,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        color: const Color(0xFF9A9AA1),
                      ),
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
