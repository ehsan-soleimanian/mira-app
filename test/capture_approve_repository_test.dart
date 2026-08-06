import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/models/api/capture_models.dart';

void main() {
  test(
    'revision zero uses compatibility approve instead of stale action',
    () async {
      final paths = <String>[];
      final apiClient = ApiClient(tokenStorage: TokenStorage());
      apiClient.dio.interceptors
        ..clear()
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              paths.add(options.path);
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: _receipt,
                ),
              );
            },
          ),
        );
      final repository = CaptureRepository(apiClient: apiClient);

      final receipt = await repository.approve(
        'capture-1',
        proposalRevision: 0,
        idempotencyKey: 'approve-capture-1-0',
      );

      expect(paths, ['/captures/capture-1/approve']);
      expect(receipt.ledgerEventId, 'event-1');
    },
  );

  test('positive revision uses server-owned approve action', () async {
    final paths = <String>[];
    Object? requestBody;
    final apiClient = ApiClient(tokenStorage: TokenStorage());
    apiClient.dio.interceptors
      ..clear()
      ..add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            requestBody = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _receipt,
              ),
            );
          },
        ),
      );
    final repository = CaptureRepository(apiClient: apiClient);

    await repository.approve(
      'capture-2',
      proposalRevision: 3,
      idempotencyKey: 'approve-capture-2-3',
    );

    expect(paths, ['/captures/capture-2/actions/capture.approve']);
    expect(requestBody, {
      'proposalRevision': 3,
      'idempotencyKey': 'approve-capture-2-3',
    });
  });

  test('convert action sends the backend convert_item contract', () async {
    Object? requestBody;
    final apiClient = ApiClient(tokenStorage: TokenStorage());
    apiClient.dio.interceptors
      ..clear()
      ..add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestBody = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: const {
                  'capture_id': 'capture-3',
                  'state': 'awaiting_approval',
                  'proposal_revision': 5,
                },
              ),
            );
          },
        ),
      );
    final repository = CaptureRepository(apiClient: apiClient);

    await repository.executeAction(
      captureId: 'capture-3',
      actionId: 'proposal.convert',
      proposalRevision: 4,
      idempotencyKey: 'proposal.convert-capture-3-4',
      operations: const [
        ProposalMutationOperation(
          op: 'convert_item',
          itemId: 'note_1',
          toKind: 'task',
        ),
      ],
    );

    expect(requestBody, {
      'proposalRevision': 4,
      'idempotencyKey': 'proposal.convert-capture-3-4',
      'operations': [
        {'op': 'convert_item', 'itemId': 'note_1', 'toKind': 'task'},
      ],
    });
  });
}

const _receipt = <String, dynamic>{
  'schemaVersion': 'capture_commit_receipt.v1',
  'captureId': 'capture-1',
  'ledgerEventId': 'event-1',
  'commitStatus': 'committed',
  'projections': <Map<String, dynamic>>[],
};
