/// How [CaptureWorkflowScreen] should open when launched from Home bubbles.
enum CaptureWorkflowInitialAction {
  /// Show camera / gallery / file / link attach menu.
  attachMenu,

  /// Open the camera picker immediately.
  camera,

  /// Open link URL sheet immediately.
  link,

  /// Pick from gallery immediately.
  gallery,

  /// Pick a generic file immediately.
  file,
}
