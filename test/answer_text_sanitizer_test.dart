import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/utils/answer_text_sanitizer.dart';

void main() {
  test('sanitizeAssistantAnswer removes raw source memory markers', () {
    final answer = sanitizeAssistantAnswer(
      'Parsa is a person you cycle with daily.\n'
      '[Source memory: d5083b6b-a4d6-4619-8bd9-dc38475393fd]',
    );

    expect(answer, 'Parsa is a person you cycle with daily.');
  });
}
