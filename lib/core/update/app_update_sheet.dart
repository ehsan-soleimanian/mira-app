import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/app_release_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum _UpdatePhase { ready, downloading, installing, done, error }

/// Bottom sheet for in-app update with auto-download and progress.
class AppUpdateSheet extends StatefulWidget {
  const AppUpdateSheet({
    super.key,
    required this.release,
    required this.currentVersionLabel,
    required this.forceUpdate,
    required this.dio,
    required this.dismissedBuildKey,
  });

  final AppReleaseInfo release;
  final String currentVersionLabel;
  final bool forceUpdate;
  final Dio dio;
  final String dismissedBuildKey;

  static Future<void> show(
    BuildContext context, {
    required AppReleaseInfo release,
    required String currentVersionLabel,
    required bool forceUpdate,
    required Dio dio,
    required String dismissedBuildKey,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: !forceUpdate,
      enableDrag: !forceUpdate,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AppUpdateSheet(
        release: release,
        currentVersionLabel: currentVersionLabel,
        forceUpdate: forceUpdate,
        dio: dio,
        dismissedBuildKey: dismissedBuildKey,
      ),
    );
  }

  @override
  State<AppUpdateSheet> createState() => _AppUpdateSheetState();
}

class _AppUpdateSheetState extends State<AppUpdateSheet> {
  _UpdatePhase _phase = _UpdatePhase.ready;
  double _progress = 0;
  int _receivedBytes = 0;
  int? _totalBytes;
  String? _statusMessage;
  bool _signatureMismatch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDownload());
  }

  Future<void> _startDownload() async {
    if (_phase == _UpdatePhase.downloading) return;
    setState(() {
      _phase = _UpdatePhase.downloading;
      _progress = 0;
      _receivedBytes = 0;
      _totalBytes = null;
      _statusMessage = null;
      _signatureMismatch = false;
    });

    if (!Platform.isAndroid) {
      await _openInBrowser();
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/mira-update.apk';
      await widget.dio.download(
        widget.release.downloadUrl,
        path,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _receivedBytes = received;
            _totalBytes = total > 0 ? total : _totalBytes;
            if (total > 0) {
              _progress = received / total;
            }
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _phase = _UpdatePhase.installing;
        _progress = 1;
      });

      final result = await OpenFilex.open(path);
      if (!mounted) return;

      if (result.type == ResultType.done) {
        setState(() => _phase = _UpdatePhase.done);
        return;
      }

      final mapped = _mapInstallError(
        AppLocalizations.of(context)!,
        result.message,
      );
      setState(() {
        _phase = _UpdatePhase.error;
        _statusMessage = mapped.message;
        _signatureMismatch = mapped.signatureMismatch;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _UpdatePhase.error;
        _statusMessage = AppLocalizations.of(context)!.appUpdateDownloadFailed;
      });
    }
  }

  ({String message, bool signatureMismatch}) _mapInstallError(
    AppLocalizations l10n,
    String? raw,
  ) {
    final message = (raw ?? '').toLowerCase();
    if (message.contains('signature') ||
        message.contains('conflict') ||
        message.contains('incompatible') ||
        message.contains('update')) {
      return (
        message: l10n.appUpdateSignatureMismatch,
        signatureMismatch: true,
      );
    }
    return (message: l10n.appUpdateInstallFailed, signatureMismatch: false);
  }

  Future<void> _openAppSettings() async {
    const package = 'com.mira.mira_app';
    final uri = Uri.parse('package:$package');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(widget.release.downloadUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _dismissLater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.dismissedBuildKey, widget.release.buildNumber);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final progressLabel = _totalBytes != null && _totalBytes! > 0
        ? l10n.appUpdateProgress(((_progress.clamp(0, 1)) * 100).round())
        : l10n.appUpdateProgressIndeterminate(_formatBytes(_receivedBytes));

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.14),
                    AppColors.accent.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.system_update_alt_rounded,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appUpdateTitle,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.appUpdateVersionLabel(
                              widget.currentVersionLabel,
                              widget.release.versionName,
                              widget.release.buildNumber,
                            ),
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_phase == _UpdatePhase.downloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _totalBytes != null && _totalBytes! > 0
                      ? _progress.clamp(0, 1)
                      : null,
                  minHeight: 10,
                  backgroundColor: AppColors.hintBarFill,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                progressLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
          ] else if (_phase == _UpdatePhase.installing) ...[
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.appUpdateInstalling,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ] else if (_phase == _UpdatePhase.done) ...[
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 40),
            const SizedBox(height: 8),
            Text(
              l10n.appUpdateInstallStarted,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ] else if (_phase == _UpdatePhase.error && _statusMessage != null) ...[
            Icon(Icons.error_outline_rounded, color: Colors.orange.shade700, size: 36),
            const SizedBox(height: 8),
            Text(
              _statusMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ] else ...[
            Text(
              l10n.appUpdateBody(
                widget.currentVersionLabel,
                widget.release.versionName,
                widget.release.buildNumber,
              ),
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (_phase == _UpdatePhase.error) ...[
            if (_signatureMismatch) ...[
              OutlinedButton.icon(
                onPressed: _openAppSettings,
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: Text(l10n.appUpdateOpenSettings),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _startDownload,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.appUpdateRetry),
            ),
            if (!widget.forceUpdate && widget.release.optional) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _dismissLater,
                child: Text(l10n.appUpdateLater),
              ),
            ],
          ] else if (_phase == _UpdatePhase.done) ...[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.appUpdateClose),
            ),
          ] else if (!widget.forceUpdate &&
              widget.release.optional &&
              _phase == _UpdatePhase.downloading) ...[
            TextButton(
              onPressed: _dismissLater,
              child: Text(l10n.appUpdateLater),
            ),
          ],
          ],
        ),
      ),
    );
  }
}
