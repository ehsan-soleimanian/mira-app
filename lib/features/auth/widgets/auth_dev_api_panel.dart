import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/components/molecules/mira_primary_button.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/config/api_endpoint_resolver.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Dev-only API URL panel (preserved from legacy login screen).
class AuthDevApiPanel extends StatefulWidget {
  const AuthDevApiPanel({super.key});

  @override
  State<AuthDevApiPanel> createState() => _AuthDevApiPanelState();
}

class _AuthDevApiPanelState extends State<AuthDevApiPanel> {
  final _apiUrlController = TextEditingController();
  bool _probingApi = false;
  String? _apiStatus;

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = ApiConfig.baseUrl;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _applyApiUrl({bool autoProbe = false}) async {
    setState(() {
      _probingApi = true;
      _apiStatus = null;
    });

    final services = AppScope.servicesOf(context);
    String? target;

    if (autoProbe) {
      target = await ApiEndpointResolver.probeFirstReachable();
    } else {
      final manual = _apiUrlController.text.trim();
      if (manual.isNotEmpty) {
        try {
          final dio = Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 4),
            ),
          );
          final r = await dio.get<Map<String, dynamic>>('$manual/health');
          if (r.statusCode == 200) target = manual;
        } on DioException {
          target = null;
        }
      }
    }

    if (!mounted) return;

    if (target != null) {
      await ApiConfig.setDevBaseUrl(target);
      services.apiClient.setBaseUrl(target);
      _apiUrlController.text = target;
      setState(() => _apiStatus = 'Connected: $target');
    } else {
      setState(
        () => _apiStatus = 'No API found. Start backend + check Wi‑Fi.',
      );
    }

    setState(() => _probingApi = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MiraFieldLabel('API (dev)'),
        MiraInputField(
          controller: _apiUrlController,
          hintText: 'http://192.168.x.x:8000',
          showMic: false,
          keyboardType: TextInputType.url,
          autocorrect: false,
          trailing: _probingApi
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.radar, size: 20),
                      color: ComposerTokens.glyphColor,
                      tooltip: 'Auto-detect',
                      onPressed: () => _applyApiUrl(autoProbe: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.link, size: 20),
                      color: ComposerTokens.glyphColor,
                      tooltip: 'Test URL',
                      onPressed: () => _applyApiUrl(autoProbe: false),
                    ),
                  ],
                ),
        ),
        if (_apiStatus != null) ...[
          const SizedBox(height: MiraSpacing.sm),
          Text(
            _apiStatus!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _apiStatus!.startsWith('Connected')
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
        const SizedBox(height: MiraSpacing.lg),
      ],
    );
  }
}
