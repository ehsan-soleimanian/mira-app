/// UI phases for the home capture experience (voice + bubble menu).
enum CaptureUiPhase {
  idle,
  bubbleMenu,
  recording,
  uploading,
  processing,

  /// Voice long-press: proposal ready — show Save / cancel on recording route.
  approving,
}
