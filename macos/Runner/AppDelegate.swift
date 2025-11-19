import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
    
    override func application(
        _ sender: NSApplication,
        openFile filename: String
    ) -> Bool {
        // Send the file path to Flutter via MethodChannel
        if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "file_open_channel",
                binaryMessenger: controller.engine.binaryMessenger
            )
            channel.invokeMethod("file_open", arguments: filename)
        }

        return true
    }
}
