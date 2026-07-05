import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/workspace_models.dart';

class PublishRepository {
  PublishRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<PublishLinkDto> create({
    required String targetType,
    required String targetId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/publish',
      data: {'targetType': targetType, 'targetId': targetId},
    );
    return PublishLinkDto.fromJson(response.data!);
  }
}
