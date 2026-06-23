import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/models/api/auth_models.dart';

void main() {
  group('AuthConfig', () {
    test('parses referral_required from API', () {
      final config = AuthConfig.fromJson({'referral_required': false});
      expect(config.referralRequired, isFalse);
    });

    test('defaults referral_required to true when missing', () {
      final config = AuthConfig.fromJson({});
      expect(config.referralRequired, isTrue);
    });
  });
}
