import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Matches backend `_MAX_MEDIA_BYTES` (10 MB).
const int captureMediaMaxBytes = 10_000_000;

/// User-selected media bytes ready for multipart upload.
class PickedCaptureMedia {
  const PickedCaptureMedia({
    required this.bytes,
    required this.filename,
    this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String? mimeType;
}

/// Port for camera, gallery, and file selection (Adapter pattern).
abstract class CaptureMediaPickerPort {
  Future<PickedCaptureMedia?> pickCameraImage();
  Future<PickedCaptureMedia?> pickGalleryImage();
  Future<PickedCaptureMedia?> pickFile();
}

/// Device picker using [ImagePicker] and [FilePicker].
class DeviceCaptureMediaPicker implements CaptureMediaPickerPort {
  DeviceCaptureMediaPicker({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<PickedCaptureMedia?> pickCameraImage() =>
      _pickImage(ImageSource.camera, fallbackName: 'mira-camera.jpg');

  @override
  Future<PickedCaptureMedia?> pickGalleryImage() =>
      _pickImage(ImageSource.gallery, fallbackName: 'mira-picture.jpg');

  @override
  Future<PickedCaptureMedia?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    final name = (file.name.trim().isEmpty) ? 'mira-file' : file.name.trim();
    return PickedCaptureMedia(
      bytes: bytes,
      filename: name,
      mimeType: _normalizeMime(file.extension, name),
    );
  }

  Future<PickedCaptureMedia?> _pickImage(
    ImageSource source, {
    required String fallbackName,
  }) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 4096,
      maxHeight: 4096,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) return null;
    final name = _basename(picked.name, fallbackName);
    return PickedCaptureMedia(
      bytes: bytes,
      filename: name,
      mimeType: _normalizeMime(_extension(name), name),
    );
  }

  String _basename(String? path, String fallback) {
    if (path == null || path.trim().isEmpty) return fallback;
    final parts = path.replaceAll('\\', '/').split('/');
    final last = parts.last.trim();
    return last.isEmpty ? fallback : last;
  }

  String? _extension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot <= 0 || dot == filename.length - 1) return null;
    return filename.substring(dot + 1);
  }

  String? _normalizeMime(String? extension, String filename) {
    final ext = (extension ?? _extension(filename) ?? '').toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'pdf' => 'application/pdf',
      'txt' => 'text/plain',
      'md' => 'text/markdown',
      'json' => 'application/json',
      'csv' => 'text/csv',
      _ => null,
    };
  }
}

CaptureMediaPickerPort createCaptureMediaPicker() => DeviceCaptureMediaPicker();
