import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/app_release_models.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checks for a newer mobile build on startup and prompts the user to update.
class AppUpdateListener extends StatefulWidget {
  const AppUpdateListener({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateListener> createState() => _AppUpdateListenerState();
}

class _AppUpdateListenerState extends State<AppUpdateListener> {
  static const _dismissedBuildKey = 'dismissed_app_build_number';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (kDebugMode) return;

    final services = AppScope.servicesOf(context);
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    final release = await services.appReleaseRepository.fetchLatest();
    if (!mounted || release == null) return;
    if (release.buildNumber <= currentBuild) return;

    final prefs = await SharedPreferences.getInstance();
    final dismissedBuild = prefs.getInt(_dismissedBuildKey) ?? 0;
    final forceUpdate = currentBuild < release.minBuildNumber;
    if (!forceUpdate && release.optional && dismissedBuild >= release.buildNumber) {
      return;
    }

    if (!mounted) return;
    await _showUpdateDialog(
      release: release,
      currentVersionLabel: packageInfo.version,
      forceUpdate: forceUpdate,
    );
  }

  Future<void> _showUpdateDialog({
    required AppReleaseInfo release,
    required String currentVersionLabel,
    required bool forceUpdate,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) {
        var downloading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.appUpdateTitle),
              content: Text(
                l10n.appUpdateBody(
                  currentVersionLabel,
                  release.versionName,
                  release.buildNumber,
                ),
              ),
              actions: [
                if (!forceUpdate && release.optional)
                  TextButton(
                    onPressed: downloading
                        ? null
                        : () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt(
                              _dismissedBuildKey,
                              release.buildNumber,
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                    child: Text(l10n.appUpdateLater),
                  ),
                FilledButton(
                  onPressed: downloading
                      ? null
                      : () async {
                          setDialogState(() => downloading = true);
                          await _downloadUpdate(release.downloadUrl);
                          if (dialogContext.mounted) {
                            setDialogState(() => downloading = false);
                          }
                        },
                  child: downloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.appUpdateDownload),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadUpdate(String url) async {
    if (Platform.isAndroid) {
      try {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/mira-update.apk';
        final dio = AppScope.servicesOf(context).apiClient.dio;
        await dio.download(url, path);
        final result = await OpenFilex.open(path);
        if (result.type == ResultType.done) return;
      } catch (_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final failedText = AppLocalizations.of(context)!.appUpdateDownloadFailed;
        messenger.showSnackBar(SnackBar(content: Text(failedText)));
      }
    }

    if (!mounted) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
