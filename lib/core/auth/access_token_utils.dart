import 'dart:convert';

/// Returns true when the JWT access token is expired or within [leeway].
bool isAccessTokenExpired(
  String token, {
  Duration leeway = const Duration(seconds: 60),
}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final normalized = _normalizeBase64Url(parts[1]);
    final payload = jsonDecode(utf8.decode(base64.decode(normalized)));
    if (payload is! Map<String, dynamic>) return true;
    final exp = payload['exp'];
    if (exp is! int) return true;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    return DateTime.now().toUtc().add(leeway).isAfter(expiresAt);
  } catch (_) {
    return true;
  }
}

String _normalizeBase64Url(String input) {
  var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  final pad = normalized.length % 4;
  if (pad > 0) {
    normalized += '=' * (4 - pad);
  }
  return normalized;
}
