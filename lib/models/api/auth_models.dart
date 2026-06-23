class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.role,
    this.gender,
    this.bio,
    this.voiceIntroCompleted = false,
    this.isActive = true,
    this.createdAt,
    this.onboardingCompleted = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String,
    role: json['role'] as String?,
    gender: json['gender'] as String?,
    bio: json['bio'] as String?,
    onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    voiceIntroCompleted: json['voice_intro_completed'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );

  final String id;
  final String email;
  final String displayName;
  final String? role;
  final String? gender;
  final String? bio;
  final bool onboardingCompleted;
  final bool voiceIntroCompleted;
  final bool isActive;
  final DateTime? createdAt;
}

class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresIn: json['expires_in'] as int? ?? 900,
  );

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.tokens,
    this.isNewUser = false,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    isNewUser: json['is_new_user'] as bool? ?? false,
  );

  final AuthUser user;
  final TokenPair tokens;
  final bool isNewUser;
}

/// Public onboarding auth settings from `GET /auth/config`.
class AuthConfig {
  const AuthConfig({
    required this.referralRequired,
    this.googleSignInEnabled = false,
  });

  factory AuthConfig.fromJson(Map<String, dynamic> json) => AuthConfig(
    referralRequired: json['referral_required'] as bool? ?? true,
    googleSignInEnabled: json['google_sign_in_enabled'] as bool? ?? false,
  );

  final bool referralRequired;
  final bool googleSignInEnabled;
}

class EmailStartResult {
  const EmailStartResult({
    required this.email,
    required this.existingUser,
    required this.inviteRequired,
    required this.codeSent,
    this.devCode,
  });

  factory EmailStartResult.fromJson(Map<String, dynamic> json) =>
      EmailStartResult(
        email: json['email'] as String,
        existingUser: json['existing_user'] as bool? ?? false,
        inviteRequired: json['invite_required'] as bool? ?? true,
        codeSent: json['code_sent'] as bool? ?? false,
        devCode: json['dev_code'] as String?,
      );

  final String email;
  final bool existingUser;
  final bool inviteRequired;
  final bool codeSent;
  final String? devCode;
}

class InviteCodeResult {
  const InviteCodeResult({
    required this.email,
    required this.accepted,
    required this.codeSent,
    this.devCode,
  });

  factory InviteCodeResult.fromJson(Map<String, dynamic> json) =>
      InviteCodeResult(
        email: json['email'] as String,
        accepted: json['accepted'] as bool? ?? false,
        codeSent: json['code_sent'] as bool? ?? false,
        devCode: json['dev_code'] as String?,
      );

  final String email;
  final bool accepted;
  final bool codeSent;
  final String? devCode;
}
