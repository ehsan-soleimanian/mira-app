import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class AssistantRepository {
  AssistantRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<AssistantResponse> run(
    String prompt, {
    String action = 'ask',
    List<String> contextItemIds = const [],
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/assistant/run',
      data: {
        'prompt': prompt,
        'action': action,
        if (contextItemIds.isNotEmpty) 'contextItemIds': contextItemIds,
      },
    );
    return AssistantResponse.fromJson(response.data!);
  }
}
