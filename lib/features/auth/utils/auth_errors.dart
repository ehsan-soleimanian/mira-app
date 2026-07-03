import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mira_app/core/config/api_config.dart';

/// Maps API auth errors to user-facing strings.
String formatAuthError(Object error) {
  if (error is PlatformException) {
    final blob =
        '${error.code} ${error.message ?? ''} ${error.details ?? ''}'.toLowerCase();
    if (blob.contains('apiexception: 10') ||
        blob.contains('apiexception:10') ||
        (blob.contains('sign_in_failed') && blob.contains('10'))) {
      return 'ورود با گوگل روی این نسخهٔ اپ تأیید نشده است.\n'
          'امضای APK در بیلد جدید عوض شده — SHA-1 کلید release را در Google Cloud Console '
          'برای com.mira.mira_app اضافه کنید، چند دقیقه صبر کنید و دوباره امتحان کنید.';
    }
  }
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Cannot reach API at ${ApiConfig.baseUrl}\n'
          'Check Wi‑Fi or set API URL in dev panel.';
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List) {
        return detail
            .map((item) {
              if (item is Map) {
                final loc = (item['loc'] as List?)?.join('.') ?? 'field';
                final msg = item['msg'] ?? 'invalid';
                return '$loc: $msg';
              }
              return item.toString();
            })
            .join('\n');
      }
    }
    final status = error.response?.statusCode;
    if (status != null) {
      return 'HTTP $status: ${error.message ?? 'request failed'}';
    }
  }
  if (error is StateError) {
    return error.message;
  }
  return '$error';
}

/// Temporary display name from email local-part before onboarding.
String displayNameFromEmail(String email) {
  final local = email.split('@').first.trim();
  if (local.isEmpty) return 'Mira User';
  return local[0].toUpperCase() + local.substring(1);
}
