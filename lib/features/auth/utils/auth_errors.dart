import 'package:dio/dio.dart';
import 'package:mira_app/core/config/api_config.dart';

/// Maps API auth errors to user-facing strings.
String formatAuthError(Object error) {
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
  return '$error';
}

/// Temporary display name from email local-part before onboarding.
String displayNameFromEmail(String email) {
  final local = email.split('@').first.trim();
  if (local.isEmpty) return 'Mira User';
  return local[0].toUpperCase() + local.substring(1);
}
