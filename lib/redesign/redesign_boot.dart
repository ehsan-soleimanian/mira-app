import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/config/api_endpoint_resolver.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';

/// Boots the real service container the redesign runs on. Mirrors the shipping
/// `main.dart` bootstrap (API base-url resolution + services), minus the pieces
/// the redesign doesn't need yet. Both redesign entry points call this.
Future<MiraServices> bootstrapMiraServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.init();
  final services = MiraServices.create();

  // Notifications aren't available on every preview target (e.g. web) — never
  // let their init block the app from booting.
  try {
    await services.notificationService.initialize();
  } catch (_) {}

  if (kDebugMode && !ApiConfig.hasExplicitBaseUrl) {
    final resolved = await ApiEndpointResolver.probeFirstReachable();
    if (resolved != null) {
      await ApiConfig.setDevBaseUrl(resolved);
      services.apiClient.setBaseUrl(resolved);
    }
  }

  return services;
}
