import 'package:flutter/services.dart';

const _deviceContextChannel = MethodChannel('mira/device_context');

/// Returns the platform's IANA timezone identifier when the host supports it.
///
/// Unsupported desktop embedders intentionally return UTC instead of sending
/// an ambiguous abbreviation such as "CST" to the backend.
Future<String> readDeviceTimezone() async {
  return await _deviceContextChannel.invokeMethod<String>('getTimezone') ??
      'UTC';
}
