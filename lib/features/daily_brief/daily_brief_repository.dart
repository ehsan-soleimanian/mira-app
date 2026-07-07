import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/api/resurfaced_models.dart';

class DailyBriefRepository {
  DailyBriefRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<DailyUpdateResponse> fetchDailyUpdate() async {
    final response = await _dio.get<Map<String, dynamic>>('/daily-update');
    return DailyUpdateResponse.fromJson(response.data!);
  }

  /// Memories Mira decided to bring back — the "Mira resurfaced" feed.
  /// Returns the parsed `items`; the backend supplies a short `reason` for each.
  Future<List<ResurfacedItem>> fetchResurfaced() async {
    final response = await _dio.get<Map<String, dynamic>>('/v2/resurfaced');
    return ResurfacedResponse.fromJson(response.data!).items;
  }
}
