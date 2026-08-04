import 'package:mira_app/models/api/capture_models.dart';

/// Capture entry modes passed into the shared capture flow.
enum RdCaptureMode { voice, meeting, photo, file, screenshot, link, type }

extension RdCaptureModeContract on RdCaptureMode {
  String get canonicalInputKind => switch (this) {
    RdCaptureMode.voice => 'voice',
    RdCaptureMode.meeting => 'live_meeting',
    RdCaptureMode.photo => 'camera_scan',
    RdCaptureMode.file => 'file',
    RdCaptureMode.screenshot => 'image',
    RdCaptureMode.link => 'link',
    RdCaptureMode.type => 'text',
  };
}

class RdCaptureModeArg {
  const RdCaptureModeArg(this.mode, {this.initialText});

  final RdCaptureMode mode;
  final String? initialText;
}

/// Entry used by share sheets, connectors, deep links, and bundles. Contextual
/// inputs bypass the transport picker and join the same processing/review flow.
class RdCanonicalCaptureArg {
  const RdCanonicalCaptureArg(this.input);

  final CaptureInput input;
}
