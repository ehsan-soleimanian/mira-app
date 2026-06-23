/// Google OAuth client IDs — set via `--dart-define-from-file=dart_defines.json`.
///
/// Android: register package `com.mira.mira_app` + SHA-1 in Google Cloud Console.
/// iOS: set [iosClientId] + update `ios/Runner/Info.plist` (GIDClientID + URL scheme).
class GoogleSignInConfig {
  GoogleSignInConfig._();

  /// Web OAuth client ID — required on Android for a verifiable `id_token`.
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// iOS OAuth client ID — required when building for iOS.
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static bool get isConfigured => webClientId.isNotEmpty;
}
