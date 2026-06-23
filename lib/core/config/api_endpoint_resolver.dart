import 'package:dio/dio.dart';
import 'package:mira_app/core/config/api_config.dart';

/// Picks the first reachable API base URL by calling `GET /health`.
class ApiEndpointResolver {
  ApiEndpointResolver._();

  static Future<String?> probeFirstReachable({
    List<String>? candidates,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ),
    );

    final seen = <String>{};
    for (final raw in candidates ?? ApiConfig.probeCandidates) {
      final base = raw.trim();
      if (base.isEmpty || !seen.add(base)) continue;
      try {
        final response = await dio.get<Map<String, dynamic>>('$base/health');
        if (response.statusCode == 200) return base;
      } on DioException {
        // try next candidate
      }
    }
    return null;
  }
}
