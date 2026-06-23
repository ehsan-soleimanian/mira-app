import 'package:dio/dio.dart';
import 'package:mira_app/features/auth/utils/auth_errors.dart';

/// User-facing Persian messages for voice capture / STT failures.
String formatVoiceCaptureError(Object error) {
  final raw = formatAuthError(error).toLowerCase();

  if (raw.contains('empty transcript') ||
      raw.contains('voice capture produced')) {
    return 'صدات را نشنیدم. دوباره واضح‌تر صحبت کن.';
  }
  if (raw.contains('no audio data') || raw.contains('microphone permission')) {
    return 'دسترسی میکروفون را بده و دوباره ضبط کن.';
  }
  if (raw.contains('stt') ||
      raw.contains('503') ||
      raw.contains('provider error')) {
    return 'مشکل در تبدیل صدا به متن. دوباره امتحان کن.';
  }
  if (error is DioException &&
      (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout)) {
    return 'اتصال قطع شد. دوباره امتحان کن.';
  }
  if (raw.contains('capture type disabled') || raw.contains('capture_voice')) {
    return 'ضبط صدا در حال حاضر غیرفعال است.';
  }
  if (raw.contains('capture_image')) {
    return 'ارسال عکس در حال حاضر غیرفعال است.';
  }
  if (raw.contains('capture_link')) {
    return 'ارسال لینک در حال حاضر غیرفعال است.';
  }
  if (raw.contains('413') || raw.contains('exceeds maximum')) {
    return 'فایل صوتی خیلی بزرگ است. ضبط کوتاه‌تری بزن.';
  }

  final detail = formatAuthError(error);
  if (detail.length > 120) {
    return 'خطا در پردازش صدا. دوباره امتحان کن.';
  }
  return detail;
}

/// User-facing Persian messages for text / media / link capture failures.
String formatCaptureError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final detail = _captureDetail(error.response?.data);
    final raw = (detail ?? '').toLowerCase();

    if (raw.contains('capture_image')) {
      return 'ارسال عکس در حال حاضر غیرفعال است.';
    }
    if (raw.contains('capture_link')) {
      return 'ارسال لینک در حال حاضر غیرفعال است.';
    }
    if (raw.contains('capture_voice')) {
      return 'ضبط صدا در حال حاضر غیرفعال است.';
    }
    if (status == 413 || raw.contains('exceeds maximum')) {
      return 'فایل خیلی بزرگ است (حداکثر ۱۰ مگابایت).';
    }
    if (status == 422 && detail != null) {
      return detail.length > 120 ? 'این نوع ورودی غیرفعال است.' : detail;
    }
    if (status == 401) return 'نشست منقضی شده. دوباره وارد شو.';
    if (status == 503 || raw.contains('provider error')) {
      return 'سرویس هوش مصنوعی در دسترس نیست. بعداً امتحان کن.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'اتصال قطع شد. دوباره امتحان کن.';
    }
    if (detail != null && detail.length <= 120) return detail;
  }
  return 'خطا در ثبت ورودی. دوباره امتحان کن.';
}

String? _captureDetail(Object? data) {
  if (data is Map && data['detail'] is String) {
    return data['detail'] as String;
  }
  return null;
}
