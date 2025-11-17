import FlutterMacOS

class LlamaStreamHandler: NSObject, FlutterStreamHandler {
    private var streamTask: Task<Void, Never>?
    private var eventSink: FlutterEventSink?
    private var tokenStream: AsyncThrowingStream<String, Error>?

    init(stream: AsyncThrowingStream<String, Error>) {
        self.tokenStream = stream
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events

        streamTask = Task {
            guard let tokenStream else { return }
            do {
                for try await token in tokenStream {
                    events(token) // send each token to Flutter
                }
                events("__done__")
            } catch {
                events(FlutterError(code: "STREAM_ERROR", message: error.localizedDescription, details: nil))
            }
        }

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        streamTask?.cancel()
        streamTask = nil
        eventSink = nil
        return nil
    }
}

