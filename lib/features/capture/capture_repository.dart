import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/core/config/api_config.dart';
import 'package:mira_app/core/locale/device_locale_context.dart';
import 'package:mira_app/features/capture/capture_mock_data.dart';
import 'package:mira_app/models/api/capture_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Capture create, SSE stream, action protocol, and execution requests.
class CaptureRepository {
  CaptureRepository({required ApiClient apiClient, TokenStorage? tokenStorage})
    : _dio = apiClient.dio,
      // ignore: prefer_initializing_formals
      _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage? _tokenStorage;

  /// Canonical `POST /captures` for any of the 12 input kinds.
  Future<CaptureResponse> createCapture(CaptureInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures',
      data: input.toJson(
        timezone: DeviceLocaleContext.timezone,
        locale: DeviceLocaleContext.languageTag,
      ),
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> createTextCapture(String text) =>
      createCapture(CaptureInput(type: 'text', text: text));

  /// Submit a URL (+ optional note) for Resource-style processing.
  Future<CaptureResponse> createLinkCapture({
    required String url,
    String? title,
    String? note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/link',
      data: {
        'url': url,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'channel': 'mobile',
        'timezone': DeviceLocaleContext.timezone,
        'locale': DeviceLocaleContext.languageTag,
      },
      // Firecrawl may legitimately fall back to a direct reader before the
      // capture is queued; keep this request above the global 60s ceiling.
      options: Options(receiveTimeout: const Duration(seconds: 75)),
    );
    return CaptureResponse.fromJson(response.data!);
  }

  /// Fetch the latest durable/transient state when an SSE event was missed.
  Future<CaptureResponse> getCapture(String captureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/captures/$captureId',
    );
    return CaptureResponse.fromJson(response.data!);
  }

  /// Poll `GET /captures/{id}` until the worker reaches a terminal review state.
  ///
  /// Redis pub/sub SSE is fire-and-forget: if the client subscribes after the
  /// worker publishes `proposal`/`done`, those events are gone. Polling recovers
  /// the same `awaiting_approval` / clarification / question payload that the
  /// stream would have delivered. Returns the last response seen (possibly still
  /// `processing`) when [maxAttempts] is exhausted.
  Future<CaptureResponse> pollCaptureUntilReady(
    String captureId, {
    int maxAttempts = 8,
    Duration interval = const Duration(milliseconds: 700),
  }) async {
    CaptureResponse? last;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      last = await getCapture(captureId);
      final state = last.state;
      if (last.proposal != null ||
          state == 'awaiting_approval' ||
          state == 'question_answered' ||
          state == 'clarification_needed' ||
          state == 'dismissed') {
        return last;
      }
      if (attempt + 1 < maxAttempts) {
        await Future<void>.delayed(interval);
      }
    }
    return last!;
  }

  /// Upload voice audio for STT only — returns transcript; no capture job.
  Future<VoiceTranscriptResult> transcribeVoice({
    required int durationMs,
    String? audioPath,
  }) async {
    return _transcribeVoiceWithRetry(
      durationMs: durationMs,
      audioPath: audioPath,
      allowRetry: true,
    );
  }

  Future<VoiceTranscriptResult> _transcribeVoiceWithRetry({
    required int durationMs,
    String? audioPath,
    required bool allowRetry,
  }) async {
    try {
      return await _postTranscribeVoice(
        durationMs: durationMs,
        audioPath: audioPath,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && audioPath != null) {
        return _postTranscribeVoice(
          durationMs: durationMs,
          audioPath: audioPath,
        );
      }
      if (allowRetry && _isRetriableVoiceError(error)) {
        return _transcribeVoiceWithRetry(
          durationMs: durationMs,
          audioPath: audioPath,
          allowRetry: false,
        );
      }
      rethrow;
    }
  }

  Future<VoiceTranscriptResult> _postTranscribeVoice({
    required int durationMs,
    String? audioPath,
  }) async {
    final formData = FormData.fromMap({
      'duration_ms': durationMs,
      if (audioPath != null)
        'file': await MultipartFile.fromFile(audioPath, filename: 'voice.m4a'),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/transcribe',
      data: formData,
    );
    final data = response.data!;
    return VoiceTranscriptResult(
      text: data['text'] as String,
      source: data['source'] as String? ?? 'unknown',
    );
  }

  /// Upload voice audio for mock STT + capture pipeline on backend.
  Future<CaptureResponse> createVoiceCapture({
    required int durationMs,
    String? audioPath,
  }) async {
    return _createVoiceCaptureWithRetry(
      durationMs: durationMs,
      audioPath: audioPath,
      allowRetry: true,
    );
  }

  Future<CaptureResponse> _createVoiceCaptureWithRetry({
    required int durationMs,
    String? audioPath,
    required bool allowRetry,
  }) async {
    try {
      return await _postVoiceCapture(
        durationMs: durationMs,
        audioPath: audioPath,
      );
    } on DioException catch (error) {
      if (_shouldUseVoiceMock(error)) {
        return CaptureMockData.mockVoiceCaptureResponse();
      }
      if (error.response?.statusCode == 401 && audioPath != null) {
        return _postVoiceCapture(durationMs: durationMs, audioPath: audioPath);
      }
      if (allowRetry && _isRetriableVoiceError(error)) {
        return _createVoiceCaptureWithRetry(
          durationMs: durationMs,
          audioPath: audioPath,
          allowRetry: false,
        );
      }
      rethrow;
    }
  }

  Future<CaptureResponse> _postVoiceCapture({
    required int durationMs,
    String? audioPath,
  }) async {
    final formData = FormData.fromMap({
      'duration_ms': durationMs,
      'channel': 'mobile',
      'timezone': DeviceLocaleContext.timezone,
      'locale': DeviceLocaleContext.languageTag,
      if (audioPath != null)
        'file': await MultipartFile.fromFile(audioPath, filename: 'voice.m4a'),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/voice',
      data: formData,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<RealtimeVoiceSession> startRealtimeVoiceSession({
    String captureType = 'voice',
    String? title,
    List<String> participants = const [],
  }) async {
    final query = <String, dynamic>{
      'capture_type': captureType,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (participants.isNotEmpty) 'participants': participants.join(','),
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/voice/realtime',
      queryParameters: query,
    );
    return RealtimeVoiceSession.fromJson(response.data!);
  }

  Stream<CaptureStreamEvent> streamRealtimeVoiceEvents(
    RealtimeVoiceSession session,
  ) async* {
    final response = await _dio.get<ResponseBody>(
      session.eventsPath,
      options: Options(responseType: ResponseType.stream),
    );
    yield* _parseSseStream(response.data!.stream);
  }

  Future<void> sendRealtimeVoiceAudio({
    required RealtimeVoiceSession session,
    required Stream<List<int>> audioStream,
    required Future<int> durationMs,
    Stream<Map<String, dynamic>>? controlMessages,
  }) async {
    final token = await _tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Missing access token for realtime voice');
    }
    final channel = WebSocketChannel.connect(
      _webSocketUri(session.audioWsPath, token),
    );
    StreamSubscription<Map<String, dynamic>>? controlSub;
    try {
      await channel.ready;
      if (controlMessages != null) {
        controlSub = controlMessages.listen((message) {
          channel.sink.add(jsonEncode(message));
        });
      }
      await for (final chunk in audioStream) {
        if (chunk.isNotEmpty) {
          channel.sink.add(chunk);
        }
      }
      channel.sink.add(
        jsonEncode({'type': 'end', 'durationMs': await durationMs}),
      );
    } finally {
      await controlSub?.cancel();
      await channel.sink.close();
    }
  }

  bool _shouldUseVoiceMock(DioException error) {
    final code = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        code == 404 ||
        code == 501;
  }

  bool _isRetriableVoiceError(DioException error) {
    final code = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        code == 503;
  }

  Future<CaptureResponse> createImageCapture({
    required List<int> bytes,
    required String filename,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      if (caption != null && caption.trim().isNotEmpty)
        'caption': caption.trim(),
      'channel': 'mobile',
      'timezone': DeviceLocaleContext.timezone,
      'locale': DeviceLocaleContext.languageTag,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/image',
      data: formData,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> createCameraCapture({
    required List<int> bytes,
    required String filename,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      if (caption != null && caption.trim().isNotEmpty)
        'caption': caption.trim(),
      'channel': 'mobile',
      'timezone': DeviceLocaleContext.timezone,
      'locale': DeviceLocaleContext.languageTag,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/camera',
      data: formData,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> createFileCapture({
    required List<int> bytes,
    required String filename,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      if (caption != null && caption.trim().isNotEmpty)
        'caption': caption.trim(),
      'channel': 'mobile',
      'timezone': DeviceLocaleContext.timezone,
      'locale': DeviceLocaleContext.languageTag,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/file',
      data: formData,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Stream<CaptureStreamEvent> streamCapture(String captureId) async* {
    if (captureId == CaptureMockData.mockVoiceCaptureResponse().captureId) {
      yield* CaptureMockData.voiceProcessingStream();
      return;
    }

    final response = await _dio.get<ResponseBody>(
      '/captures/$captureId/stream',
      options: Options(responseType: ResponseType.stream),
    );

    yield* _parseSseStream(response.data!.stream);
  }

  Stream<CaptureStreamEvent> _parseSseStream(Stream<List<int>> stream) async* {
    final buffer = StringBuffer();
    await for (final chunk in stream) {
      buffer.write(utf8.decode(chunk));
      final content = buffer.toString();
      final parts = content.split('\n\n');
      buffer.clear();
      if (!content.endsWith('\n\n') && parts.isNotEmpty) {
        buffer.write(parts.removeLast());
      }
      for (final part in parts) {
        final event = _parseSsePart(part);
        if (event != null) yield event;
      }
    }
    if (buffer.isNotEmpty) {
      final event = _parseSsePart(buffer.toString());
      if (event != null) yield event;
    }
  }

  Uri _webSocketUri(String path, String token) {
    final base = Uri.parse(ApiConfig.baseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(
      scheme: scheme,
      path: path,
      queryParameters: {'token': token},
    );
  }

  CaptureStreamEvent? _parseSsePart(String part) {
    final lines = part.split('\n');
    String? eventName;
    String? dataLine;
    for (final line in lines) {
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLine = line.substring(5).trim();
      }
    }
    if (eventName == null || dataLine == null) return null;
    return CaptureStreamEvent(
      event: eventName,
      data: jsonDecode(dataLine) as Map<String, dynamic>,
    );
  }

  /// Execute a server-owned review/commit action. Never invent action IDs.
  Future<CaptureActionOutcome> executeAction({
    required String captureId,
    required String actionId,
    int proposalRevision = 0,
    String? idempotencyKey,
    Map<String, dynamic> input = const {},
    List<ProposalMutationOperation> operations = const [],
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/actions/$actionId',
      data: CaptureActionRequest(
        proposalRevision: proposalRevision,
        idempotencyKey: idempotencyKey,
        input: input,
        operations: operations,
      ).toJson(),
    );
    return CaptureActionOutcome.fromJson(response.data ?? const {});
  }

  /// Compatibility approve route — returns `capture_commit_receipt.v1`.
  Future<CaptureCommitReceipt> approve(
    String captureId, {
    String? title,
    String? summary,
    String? nodeType,
    int? proposalRevision,
    String? idempotencyKey,
  }) async {
    if (captureId == CaptureMockData.mockVoiceCaptureResponse().captureId) {
      return CaptureMockData.mockCommitReceipt();
    }
    // Revision zero means the proposal arrived through SSE before the client
    // fetched the authoritative terminal capture. The compatibility endpoint
    // is revision-agnostic and avoids a guaranteed stale-proposal 409.
    if (proposalRevision != null && proposalRevision > 0) {
      final outcome = await executeAction(
        captureId: captureId,
        actionId: 'capture.approve',
        proposalRevision: proposalRevision,
        idempotencyKey: idempotencyKey,
      );
      final receipt = outcome.receipt;
      if (receipt != null) return receipt;
    }
    final edits = <String, dynamic>{
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (summary != null && summary.trim().isNotEmpty)
        'summary': summary.trim(),
      if (nodeType != null && nodeType.trim().isNotEmpty)
        'node_type': nodeType.trim(),
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/approve',
      data: edits.isEmpty ? null : edits,
    );
    return CaptureCommitReceipt.fromJson(response.data!);
  }

  Future<void> dismiss(String captureId) async {
    if (captureId == CaptureMockData.mockVoiceCaptureResponse().captureId) {
      return;
    }
    await _dio.post<void>('/captures/$captureId/dismiss');
  }

  Future<CaptureResponse> confirmTime(
    String captureId, {
    required bool accepted,
    String? resolvedTime,
  }) async {
    final data = <String, dynamic>{'accepted': accepted};
    if (resolvedTime != null) {
      data['resolved_time'] = resolvedTime;
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/confirm-time',
      data: data,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> clarifyIntent(
    String captureId, {
    required String intent,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/clarify-intent',
      data: {'intent': intent},
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> followUpPendingCapture(
    String captureId, {
    required String message,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/follow-up',
      data: {'message': message},
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<CaptureResponse> confirmEntityEquivalence(
    String captureId, {
    bool? same,
    String? decision,
    String? targetEntityId,
  }) async {
    final data = buildEntityEquivalenceConfirmationPayload(
      same: same,
      decision: decision,
      targetEntityId: targetEntityId,
    );
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/confirm-entity-equivalence',
      data: data,
    );
    return CaptureResponse.fromJson(response.data!);
  }

  Future<List<CaptureExecutionRequest>> listExecutions(String captureId) async {
    final response = await _dio.get<List<dynamic>>(
      '/captures/$captureId/executions',
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map(
          (item) => CaptureExecutionRequest.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<CaptureExecutionTestResult> testExecution(String requestId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/executions/$requestId/test',
    );
    return CaptureExecutionTestResult.fromJson(response.data!);
  }

  Future<CaptureExecutionRequest> confirmExecution(String requestId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/executions/$requestId/confirm',
    );
    return CaptureExecutionRequest.fromJson(response.data!);
  }
}

Map<String, dynamic> buildEntityEquivalenceConfirmationPayload({
  bool? same,
  String? decision,
  String? targetEntityId,
}) {
  if (same == null && decision == null) {
    throw ArgumentError('Either same or decision must be provided.');
  }
  if (decision != null &&
      decision != 'ONE_PERSON' &&
      decision != 'MULTIPLE_PEOPLE') {
    throw ArgumentError.value(decision, 'decision');
  }

  final data = <String, dynamic>{};
  if (same != null) data['same'] = same;
  if (decision != null) data['decision'] = decision;
  if (targetEntityId != null) data['targetEntityId'] = targetEntityId;
  return data;
}
