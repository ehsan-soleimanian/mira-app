import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/models/api/daily_brief_models.dart';
import 'package:mira_app/models/api/daily_update_models.dart';
import 'package:mira_app/models/api/resurfaced_models.dart';

class DailyBriefRepository {
  DailyBriefRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<DailyUpdateResponse> fetchDailyUpdate() async {
    final response = await _dio.get<Map<String, dynamic>>('/daily-update');
    return DailyUpdateResponse.fromJson(response.data!);
  }

  /// Rich redesigned Daily Brief — sections, state, greeting, and counts.
  Future<DailyBriefResponse> fetchDailyBrief() async {
    final response = await _dio.get<Map<String, dynamic>>('/daily-brief');
    return DailyBriefResponse.fromJson(response.data!);
  }

  /// Record a card action (done, snooze, dismiss, open, undo_snooze).
  Future<DailyBriefActionResult> recordAction({
    required String itemId,
    required String action,
    String itemKind = 'task',
    DateTime? snoozeUntil,
    String? note,
  }) async {
    final data = <String, dynamic>{
      'action': action,
      'itemKind': itemKind,
      if (snoozeUntil != null)
        'snoozeUntil': snoozeUntil.toUtc().toIso8601String(),
      'note': ?note,
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '/daily-brief/items/$itemId/actions',
      data: data,
    );
    return DailyBriefActionResult.fromJson(response.data!);
  }

  /// Snooze all overdue Brief tasks until tomorrow.
  Future<int> clearOverdue() async {
    final response =
        await _dio.post<Map<String, dynamic>>('/daily-brief/clear-overdue');
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  /// Memories Mira decided to bring back — the "Mira resurfaced" feed.
  Future<List<ResurfacedItem>> fetchResurfaced() async {
    final response = await _dio.get<Map<String, dynamic>>('/v2/resurfaced');
    return ResurfacedResponse.fromJson(response.data!).items;
  }
}
