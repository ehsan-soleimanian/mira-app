import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/models/api/auth_models.dart';

/// Auth register/login/refresh against MIRA API.
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _dio = apiClient.dio,
       // Public constructor names stay friendly while fields remain private.
       // ignore: prefer_initializing_formals
       _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthConfig? _cachedAuthConfig;

  /// Client-safe onboarding auth flags (no Bearer required).
  Future<AuthConfig> fetchAuthConfig({bool forceRefresh = false}) async {
    if (_cachedAuthConfig != null && !forceRefresh) {
      return _cachedAuthConfig!;
    }
    final response = await _dio.get<Map<String, dynamic>>('/auth/config');
    final config = AuthConfig.fromJson(response.data!);
    _cachedAuthConfig = config;
    return config;
  }

  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'display_name': displayName},
    );
    final body = AuthSession.fromJson(response.data!);
    await _tokenStorage.saveTokens(
      accessToken: body.tokens.accessToken,
      refreshToken: body.tokens.refreshToken,
    );
    return body.user;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final body = AuthSession.fromJson(response.data!);
    await _tokenStorage.saveTokens(
      accessToken: body.tokens.accessToken,
      refreshToken: body.tokens.refreshToken,
    );
    return body.user;
  }

  Future<EmailStartResult> startEmailFlow(String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/start',
      data: {'email': email.trim()},
    );
    return EmailStartResult.fromJson(response.data!);
  }

  Future<InviteCodeResult> verifyInviteCode({
    required String email,
    required String inviteCode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/invite/verify',
      data: {'email': email.trim(), 'invite_code': inviteCode.trim()},
    );
    return InviteCodeResult.fromJson(response.data!);
  }

  Future<AuthUser> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/verify',
      data: {'email': email.trim(), 'code': code.trim()},
    );
    final body = AuthSession.fromJson(response.data!);
    await _tokenStorage.saveTokens(
      accessToken: body.tokens.accessToken,
      refreshToken: body.tokens.refreshToken,
    );
    return body.user;
  }

  Future<String?> refreshAccessToken() async {
    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final tokens = TokenPair.fromJson(response.data!);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens.accessToken;
    } on DioException {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<AuthUser> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
  }

  Future<void> logout() async {
    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh != null) {
      try {
        await _dio.post('/auth/logout', data: {'refresh_token': refresh});
      } on DioException {
        // Best-effort logout.
      }
    }
    await _tokenStorage.clear();
  }
}
