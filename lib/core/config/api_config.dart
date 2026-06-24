import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:mira_app/core/config/dev_machine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API base URL — compile-time [API_BASE_URL], dev override, or platform default.
class ApiConfig {
  ApiConfig._();

  static const String _productionBase = 'https://api.miramind.io';
  static const String _prefsKey = 'dev_api_base_url';
  static const String _defineBase =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String _devOverride = '';

  static bool get hasExplicitBaseUrl => _defineBase.isNotEmpty;

  /// Load persisted dev URL before creating [ApiClient].
  static Future<void> init() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    _devOverride = prefs.getString(_prefsKey) ?? '';
  }

  static String get baseUrl {
    if (kReleaseMode) return _normalize(_productionBase);
    if (_defineBase.isNotEmpty) return _normalize(_defineBase);
    if (_devOverride.isNotEmpty) return _normalize(_devOverride);
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  /// URLs tried in order when auto-probing in debug builds.
  static List<String> get probeCandidates {
    final lan = 'http://$kDevMachineLanIp:$kDevApiPort';
    return [
      if (_devOverride.isNotEmpty) _normalize(_devOverride),
      if (_defineBase.isNotEmpty) _normalize(_defineBase),
      lan,
      'http://10.0.2.2:$kDevApiPort',
      'http://127.0.0.1:$kDevApiPort',
      'http://localhost:$kDevApiPort',
    ];
  }

  static Future<void> setDevBaseUrl(String url) async {
    _devOverride = _normalize(url);
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _devOverride);
    }
  }

  static String _normalize(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }
}
