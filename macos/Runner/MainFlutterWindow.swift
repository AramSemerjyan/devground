import Cocoa
import FlutterMacOS
import Darwin
import desktop_multi_window

private var llamaChannel: FlutterMethodChannel?
private var llamaEventChannel: FlutterEventChannel?
private var currentStreamHandler: LlamaStreamHandler?

class MainFlutterWindow: NSWindow {
    
  override func awakeFromNib() {
      let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
      
      FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
          RegisterGeneratedPlugins(registry: controller)
      }
      
      SystemInfo.setUpChannel(binnaryMessagner: flutterViewController.engine.binaryMessenger)
      
      // Method channel to initiate generation
      llamaChannel = FlutterMethodChannel(
          name: "llama.method",
          binaryMessenger: flutterViewController.engine.binaryMessenger
      )

      llamaChannel?.setMethodCallHandler(handleMethodCall)

      // Event channel for streaming tokens
      llamaEventChannel = FlutterEventChannel(
          name: "llama.stream",
          binaryMessenger: flutterViewController.engine.binaryMessenger
      )

    super.awakeFromNib()
  }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startGeneration":
            startGeneration(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startGeneration(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let messages = args["messages"] as? [[String: String]],
              let modelPath = args["modelPath"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        DispatchQueue.global().async {
            let modelUrl = URL(fileURLWithPath: modelPath)

            guard FileManager.default.fileExists(atPath: modelUrl.path) else {
                result(FlutterError(
                    code: "NO_MODEL",
                    message: "Model file does not exist at path: \(modelUrl.path)",
                    details: nil
                ))
                return
            }

            let llamaService = LlamaService(
                modelUrl: modelUrl,
                config: .init(batchSize: 256, maxTokenCount: 4096, useGPU: true)
            )

            Task {
                do {
                    let chatMsgs = messages.map {
                        LlamaChatMessage(
                            role: LlamaChatMessage.Role(rawValue: $0["role"]!)!,
                            content: $0["content"]!
                        )
                    }

                    let stream = try await llamaService.streamCompletion(
                        of: chatMsgs,
                        samplingConfig: .init(temperature: 0.8, seed: 42)
                    )

                    let handler = LlamaStreamHandler(stream: stream)
                    currentStreamHandler = handler
                    llamaEventChannel?.setStreamHandler(handler)

                    result(nil) // OK

                } catch {
                    result(FlutterError(
                        code: "GEN_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }
    }
}
