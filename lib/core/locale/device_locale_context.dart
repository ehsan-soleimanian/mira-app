import 'dart:ui';

import 'device_timezone.dart';

/// Runtime locale/timezone facts sent to the backend as interpretation context.
///
/// Business rules remain server-owned; this class only reports the device's
/// BCP-47 locale and IANA timezone.
class DeviceLocaleContext {
  DeviceLocaleContext._();

  static String _timezone = 'UTC';
  static String _languageTag = 'en';

  static String get timezone => _timezone;
  static String get languageTag => _languageTag;

  static Future<void> initialize() async {
    _languageTag = PlatformDispatcher.instance.locale.toLanguageTag();
    try {
      final identifier = (await readDeviceTimezone()).trim();
      if (identifier.isNotEmpty) {
        _timezone = identifier;
      }
    } catch (_) {
      _timezone = 'UTC';
    }
  }
}
