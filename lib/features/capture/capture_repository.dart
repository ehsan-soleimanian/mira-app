import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/features/capture/capture_mock_data.dart';
import 'package:mira_app/models/api/capture_models.dart';

/// Capture create, SSE stream, approve/dismiss/confirm-time.
class CaptureRepository {
  CaptureRepository({required ApiClient apiClient}) : _dio = apiClient.dio;

  final Dio _dio;

  Future<CaptureResponse> createTextCapture(String text) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures',
      data: {'type': 'text', 'text': text, 'channel': 'mobile'},
    );
    return CaptureResponse.fromJson(response.data!);
  }

  /// Submit a URL (+ optional note) for Resource-style processing.
  Future<CaptureResponse> createLinkCapture({
    required String url,
    String? note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/link',
      data: {
        'url': url,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'channel': 'mobile',
      },
    );
    return CaptureResponse.fromJson(response.data!);
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
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'voice.m4a',
        ),
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
      if (audioPath != null)
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'voice.m4a',
        ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/voice',
      data: formData,
    );
    return CaptureResponse.fromJson(response.data!);
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
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/image',
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

    final buffer = StringBuffer();
    await for (final chunk in response.data!.stream) {
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

  Future<MemoryNodeResponse> approve(String captureId) async {
    if (captureId == CaptureMockData.mockVoiceCaptureResponse().captureId) {
      return MemoryNodeResponse(
        id: 'mock-memory-node',
        captureId: captureId,
        nodeType: 'Task',
        title: CaptureMockData.sampleTaskProposal()['title'] as String,
        summary: CaptureMockData.sampleTranscript,
      );
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/captures/$captureId/approve',
    );
    return MemoryNodeResponse.fromJson(response.data!);
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
}
