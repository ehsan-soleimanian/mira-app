import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let deviceContextChannel = FlutterMethodChannel(
      name: "mira/device_context",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    deviceContextChannel.setMethodCallHandler { call, result in
      if call.method == "getTimezone" {
        result(TimeZone.current.identifier)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
