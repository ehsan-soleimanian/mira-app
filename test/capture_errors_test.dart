import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/utils/capture_errors.dart';

void main() {
  test('formatVoiceCaptureError maps empty transcript to Persian', () {
    final message = formatVoiceCaptureError(
      Exception('Voice capture produced empty transcript'),
    );
    expect(message, contains('نشنیدم'));
  });
}
