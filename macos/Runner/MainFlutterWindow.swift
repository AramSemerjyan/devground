import Cocoa
import FlutterMacOS
//import multi_window_macos
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
//    MultiWindowMacosPlugin.registerGeneratedPlugins = RegisterGeneratedPlugins
      
//      let flutterViewController = MultiWindowViewController()
      let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
      
      FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
          RegisterGeneratedPlugins(registry: controller)
      }

    super.awakeFromNib()
  }
}
