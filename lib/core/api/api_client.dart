import 'package:dio/dio.dart';
import 'package:mira_app/core/auth/access_token_utils.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/core/config/api_config.dart';

typedef TokenRefreshCallback = Future<String?> Function();

/// Dio client with auth header injection and optional refresh.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    TokenRefreshCallback? onRefresh,
  })
    // Public constructor names stay friendly while fields remain private.
    // ignore: prefer_initializing_formals
    : _tokenStorage = tokenStorage,
       // ignore: prefer_initializing_formals
       _onRefresh = onRefresh {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isPublicAuthPath(options.path)) {
            var token = await _tokenStorage.readAccessToken();
            if (token != null && token.isNotEmpty) {
              if (isAccessTokenExpired(token)) {
                final refreshed = await _refreshAccessToken();
                if (refreshed != null) {
                  await _tokenStorage.saveAccessToken(refreshed);
                  token = refreshed;
                }
              }
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final refresh = _onRefresh;
          if (error.response?.statusCode == 401 &&
              refresh != null &&
              !_isPublicAuthPath(error.requestOptions.path)) {
            final refreshed = await _refreshAccessToken();
            if (refreshed != null) {
              await _tokenStorage.saveAccessToken(refreshed);
              final request = error.requestOptions;
              request.headers['Authorization'] = 'Bearer $refreshed';
              // Multipart bodies are single-use streams — caller must retry.
              if (request.data is FormData) {
                handler.next(error);
                return;
              }
              try {
                final response = await _dio.fetch(request);
                handler.resolve(response);
                return;
              } on DioException {
                handler.next(error);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final TokenRefreshCallback? _onRefresh;
  late final Dio _dio;
  Future<String?>? _refreshInFlight;

  Dio get dio => _dio;

  Future<String?> _refreshAccessToken() async {
    final refresh = _onRefresh;
    if (refresh == null) return null;
    if (_refreshInFlight != null) return _refreshInFlight;
    _refreshInFlight = refresh();
    try {
      return await _refreshInFlight;
    } finally {
      _refreshInFlight = null;
    }
  }

  bool _isPublicAuthPath(String path) {
    return path == '/auth/config' ||
        path == '/auth/register' ||
        path == '/auth/login' ||
        path == '/auth/email/start' ||
        path == '/auth/invite/verify' ||
        path == '/auth/email/verify' ||
        path == '/auth/refresh';
  }

  /// Point all requests at a new base URL (dev override on login screen).
  void setBaseUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    _dio.options.baseUrl = u;
  }
}
