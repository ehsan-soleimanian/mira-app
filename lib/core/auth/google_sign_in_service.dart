import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mira_app/core/auth/google_sign_in_config.dart';

/// Native Google Sign-In — returns an ID token for backend verification.
class GoogleSignInService {
  GoogleSignInService({GoogleSignIn? signIn})
    : _signIn =
          signIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            serverClientId: GoogleSignInConfig.webClientId.isNotEmpty
                ? GoogleSignInConfig.webClientId
                : null,
            clientId:
                !kIsWeb &&
                    Platform.isIOS &&
                    GoogleSignInConfig.iosClientId.isNotEmpty
                ? GoogleSignInConfig.iosClientId
                : null,
          );

  final GoogleSignIn _signIn;

  bool get isConfigured => GoogleSignInConfig.isConfigured;

  /// Opens the Google account picker and returns a verified ID token, or null if cancelled.
  Future<String?> signInAndGetIdToken() async {
    if (!isConfigured) {
      throw StateError('Google Sign-In client IDs are not configured');
    }

    final account = await _signIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In did not return an id_token');
    }
    return idToken;
  }

  Future<void> signOut() => _signIn.signOut();
}
