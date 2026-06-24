import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Google OAuth client IDs — compile-time (`--dart-define-from-file`) or
/// debug asset fallback (`dart_defines.json` bundled in [pubspec.yaml]).
///
/// Android: register package `com.mira.mira_app` + SHA-1 in Google Cloud Console.
/// iOS: set [iosClientId] + update `ios/Runner/Info.plist` (GIDClientID + URL scheme).
class GoogleSignInConfig {
  GoogleSignInConfig._();

  static String _webClientId = '';
  static String _iosClientId = '';
  static bool _loaded = false;

  static String get webClientId => _webClientId;
  static String get iosClientId => _iosClientId;
  static bool get isConfigured => _webClientId.isNotEmpty;

  /// Loads IDs from `--dart-define` first, then bundled `dart_defines.json` in debug.
  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;

    const envWeb = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );
    const envIos = String.fromEnvironment(
      'GOOGLE_IOS_CLIENT_ID',
      defaultValue: '',
    );
    if (envWeb.isNotEmpty) {
      _webClientId = envWeb;
      _iosClientId = envIos;
      return;
    }

    for (final path in const ['dart_defines.json', 'dart_defines.example.json']) {
      try {
        final raw = await rootBundle.loadString(path);
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final web = (map['GOOGLE_WEB_CLIENT_ID'] as String? ?? '').trim();
        if (web.isEmpty || web.startsWith('YOUR_')) continue;
        _webClientId = web;
        _iosClientId = (map['GOOGLE_IOS_CLIENT_ID'] as String? ?? '').trim();
        if (kDebugMode) {
          debugPrint('GoogleSignInConfig loaded from asset: $path');
        }
        return;
      } on Object {
        // Try next asset path.
      }
    }

    if (kDebugMode) {
      debugPrint(
        'GoogleSignInConfig: no client IDs. '
        'Copy dart_defines.example.json → dart_defines.json or run with '
        '--dart-define-from-file=dart_defines.json',
      );
    }
  }
}
