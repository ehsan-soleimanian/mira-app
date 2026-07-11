/// Capture entry modes from design2 `CaptureSheet` — passed into
/// [RdCaptureFlow] via `go('captureflow', arg: RdCaptureModeArg(...))`.
enum RdCaptureMode { voice, photo, screenshot, link, type }

class RdCaptureModeArg {
  const RdCaptureModeArg(this.mode);

  final RdCaptureMode mode;
}
