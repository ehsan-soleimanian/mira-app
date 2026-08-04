/// Canonical transport kinds accepted by `capture_input.v1`.
///
/// Only [direct] kinds need a button in Mira. Contextual kinds arrive through
/// sharing, connectors, deep links, or bundles and must enter the same review
/// experience without forcing the user to classify them first.
class CaptureInputKindDefinition {
  const CaptureInputKindDefinition(this.kind, {required this.direct});

  final String kind;
  final bool direct;
}

const captureInputCatalog = <CaptureInputKindDefinition>[
  CaptureInputKindDefinition('text', direct: true),
  CaptureInputKindDefinition('voice', direct: true),
  CaptureInputKindDefinition('image', direct: true),
  CaptureInputKindDefinition('camera_scan', direct: true),
  CaptureInputKindDefinition('file', direct: true),
  CaptureInputKindDefinition('link', direct: true),
  CaptureInputKindDefinition('message', direct: false),
  CaptureInputKindDefinition('calendar', direct: false),
  CaptureInputKindDefinition('contact', direct: false),
  CaptureInputKindDefinition('live_meeting', direct: true),
  CaptureInputKindDefinition('integration_event', direct: false),
  CaptureInputKindDefinition('bundle', direct: false),
];

const canonicalCaptureInputKinds = <String>{
  'text',
  'voice',
  'image',
  'camera_scan',
  'file',
  'link',
  'message',
  'calendar',
  'contact',
  'live_meeting',
  'integration_event',
  'bundle',
};

CaptureInputKindDefinition captureInputDefinition(String? rawKind) {
  final normalized = rawKind?.trim().toLowerCase() ?? '';
  return captureInputCatalog.firstWhere(
    (definition) => definition.kind == normalized,
    orElse: () => captureInputCatalog.first,
  );
}
