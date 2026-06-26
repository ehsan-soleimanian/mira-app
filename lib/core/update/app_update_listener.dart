import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/update/app_update_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Checks for a newer mobile build on startup and opens the update sheet.
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
    await AppUpdateSheet.show(
      context,
      release: release,
      currentVersionLabel: packageInfo.version,
      forceUpdate: forceUpdate,
      dio: services.apiClient.dio,
      dismissedBuildKey: _dismissedBuildKey,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
