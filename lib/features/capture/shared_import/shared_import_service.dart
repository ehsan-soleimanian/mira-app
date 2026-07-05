import 'dart:async';
import 'package:flutter/services.dart';

enum SharedImportType { image, text, file }

class SharedImportItem {
  const SharedImportItem._({
    required this.type,
    this.bytes,
    this.filename,
    this.mimeType,
    this.text,
  });

  factory SharedImportItem.image({
    required Uint8List bytes,
    required String filename,
    String? mimeType,
  }) {
    return SharedImportItem._(
      type: SharedImportType.image,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  factory SharedImportItem.file({
    required Uint8List bytes,
    required String filename,
    String? mimeType,
  }) {
    return SharedImportItem._(
      type: SharedImportType.file,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  factory SharedImportItem.text(String text) {
    return SharedImportItem._(type: SharedImportType.text, text: text);
  }

  factory SharedImportItem.fromMap(Map<Object?, Object?> map) {
    final type = map['type']?.toString();
    if (type == 'image' || type == 'file') {
      final rawBytes = map['bytes'];
      final bytes = rawBytes is Uint8List
          ? rawBytes
          : Uint8List.fromList((rawBytes as List<Object?>).cast<int>());
      if (type == 'file') {
        return SharedImportItem.file(
          bytes: bytes,
          filename: map['filename']?.toString() ?? 'mira-shared-file',
          mimeType: map['mimeType']?.toString(),
        );
      }
      return SharedImportItem.image(
        bytes: bytes,
        filename: map['filename']?.toString() ?? 'mira-shared-image.jpg',
        mimeType: map['mimeType']?.toString(),
      );
    }
    return SharedImportItem.text(map['text']?.toString() ?? '');
  }

  final SharedImportType type;
  final Uint8List? bytes;
  final String? filename;
  final String? mimeType;
  final String? text;

  bool get isValid {
    return switch (type) {
      SharedImportType.image => bytes != null && bytes!.isNotEmpty,
      SharedImportType.file => bytes != null && bytes!.isNotEmpty,
      SharedImportType.text => text != null && text!.trim().isNotEmpty,
    };
  }
}

class SharedImportService {
  SharedImportService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('mira/shared_import');

  final MethodChannel _channel;
  final _controller = StreamController<SharedImportItem>.broadcast();
  var _listening = false;

  Stream<SharedImportItem> get stream => _controller.stream;

  Future<void> start() async {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    final Map<Object?, Object?>? initial;
    try {
      initial = await _channel.invokeMapMethod<Object?, Object?>(
        'getInitialSharedItem',
      );
    } on MissingPluginException {
      return;
    }
    final item = _itemFromMap(initial);
    if (item != null) _controller.add(item);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method != 'sharedItem') return null;
    final args = call.arguments;
    if (args is Map<Object?, Object?>) {
      final item = _itemFromMap(args);
      if (item != null) _controller.add(item);
    }
    return null;
  }

  SharedImportItem? _itemFromMap(Map<Object?, Object?>? map) {
    if (map == null) return null;
    final item = SharedImportItem.fromMap(map);
    return item.isValid ? item : null;
  }

  void dispose() {
    _controller.close();
  }
}
