import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/capture_repository.dart';

void main() {
  test('encodes an explicit multiple-people identity decision', () {
    expect(
      buildEntityEquivalenceConfirmationPayload(decision: 'MULTIPLE_PEOPLE'),
      {'decision': 'MULTIPLE_PEOPLE'},
    );
  });

  test('keeps the legacy same-entity request backward compatible', () {
    expect(
      buildEntityEquivalenceConfirmationPayload(
        same: true,
        targetEntityId: 'entity-1',
      ),
      {'same': true, 'targetEntityId': 'entity-1'},
    );
  });

  test('rejects missing or unknown identity decisions', () {
    expect(
      () => buildEntityEquivalenceConfirmationPayload(),
      throwsArgumentError,
    );
    expect(
      () => buildEntityEquivalenceConfirmationPayload(decision: 'MAYBE'),
      throwsArgumentError,
    );
  });
}
