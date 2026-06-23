import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/auth/access_token_utils.dart';

String _fakeJwt({required int exp}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode('{"sub":"user","type":"access","exp":$exp}'),
  );
  return '$header.$payload.signature';
}

void main() {
  test('isAccessTokenExpired returns false for future exp', () {
    final exp = DateTime.now().toUtc().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    expect(isAccessTokenExpired(_fakeJwt(exp: exp)), isFalse);
  });

  test('isAccessTokenExpired returns true for past exp', () {
    final exp = DateTime.now().toUtc().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    expect(isAccessTokenExpired(_fakeJwt(exp: exp)), isTrue);
  });

  test('isAccessTokenExpired returns true for malformed token', () {
    expect(isAccessTokenExpired('not-a-jwt'), isTrue);
  });
}
