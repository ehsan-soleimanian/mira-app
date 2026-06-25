import 'package:dio/dio.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';

/// User-facing messages for voice capture / STT failures (Persian UI).
String formatVoiceCaptureError(Object error) {
  final raw = formatAuthError(error).toLowerCase();

  if (raw.contains('empty transcript') ||
      raw.contains('voice capture produced')) {
    return 'چیزی نشنیدم. یک‌بار دیگر بلندتر بگو.';
  }
  if (raw.contains('no audio data') || raw.contains('microphone permission')) {
    return 'دسترسی میکروفون را بدهید و دوباره ضبط کنید.';
  }
  if (raw.contains('stt') ||
      raw.contains('503') ||
      raw.contains('provider error')) {
    return 'تبدیل گفتار به متن در دسترس نیست. کمی بعد دوباره تلاش کنید.';
  }
  if (error is DioException &&
      (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout)) {
    return 'اتصال قطع شد. دوباره تلاش کنید.';
  }
  if (raw.contains('capture type disabled') || raw.contains('capture_voice')) {
    return 'ضبط صوتی فعلاً غیرفعال است.';
  }
  if (raw.contains('capture_image')) {
    return 'ضبط تصویر فعلاً غیرفعال است.';
  }
  if (raw.contains('capture_link')) {
    return 'ضبط لینک فعلاً غیرفعال است.';
  }
  if (raw.contains('413') || raw.contains('exceeds maximum')) {
    return 'ضبط خیلی طولانی است. یک قطعه کوتاه‌تر بزنید.';
  }

  final detail = formatAuthError(error);
  if (detail.length > 120) {
    return 'پردازش صدا انجام نشد. دوباره تلاش کنید.';
  }
  return detail;
}

/// User-facing messages for text / media / link capture failures.
String formatCaptureError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final detail = _captureDetail(error.response?.data);
    final raw = (detail ?? '').toLowerCase();

    if (raw.contains('capture_image')) {
      return 'Image capture is currently disabled.';
    }
    if (raw.contains('capture_link')) {
      return 'Link capture is currently disabled.';
    }
    if (raw.contains('capture_voice')) {
      return 'Voice capture is currently disabled.';
    }
    if (status == 413 || raw.contains('exceeds maximum')) {
      return 'File is too large (max 10 MB).';
    }
    if (status == 422 && detail != null) {
      return detail.length > 120 ? 'This input type is disabled.' : detail;
    }
    if (status == 401) return 'Session expired. Please sign in again.';
    if (status == 503 || raw.contains('provider error')) {
      return 'AI service is unavailable. Try again later.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection lost. Try again.';
    }
    if (detail != null && detail.length <= 120) return detail;
  }
  return 'Could not save your input. Try again.';
}

String? _captureDetail(Object? data) {
  if (data is Map && data['detail'] is String) {
    return data['detail'] as String;
  }
  return null;
}
