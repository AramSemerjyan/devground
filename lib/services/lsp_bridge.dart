import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/settings_manager.dart';

class LspBridge {
  final int port;
  Process? _analysisProc;
  HttpServer? _httpServer;

  LspBridge(this.port);

  /// Start analysis server and ws bridge
  Future<void> start() async {
    _analysisProc = await SettingsManager.startAnalysisServer();
    // Listen to analysis stdout; forward messages to connected websocket clients.
    _analysisProc!.stdout.listen((data) {
      // data are bytes that contain framed LSP messages; we forward raw bytes as text frames
      final text = utf8.decode(data);
      _broadcastToClients(text);
    });

    _analysisProc!.stderr.transform(utf8.decoder).listen((s) {
      print('[analysis stderr] $s');
    });

    // Start local HTTP server for upgrading to WebSocket
    _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _httpServer!.listen((HttpRequest req) async {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        final ws = await WebSocketTransformer.upgrade(req);
        _handleWebSocket(ws);
      } else {
        req.response
          ..statusCode = HttpStatus.badRequest
          ..write('This endpoint only accepts WebSocket connections')
          ..close();
      }
    });
  }

  final List<WebSocket> _clients = [];

  void _handleWebSocket(WebSocket ws) {
    _clients.add(ws);

    // messages from WebSocket (client / Monaco) -> forward to analysis server stdin
    ws.listen(
      (dynamic msg) {
        // `msg` is a string containing framed LSP JSON (with Content-Length headers)
        if (_analysisProc == null) return;
        // write exact bytes to analysis server stdin
        _analysisProc!.stdin.add(utf8.encode(msg));
        // ensure newline flush
        _analysisProc!.stdin.add(const Utf8Encoder().convert(''));
      },
      onDone: () {
        _clients.remove(ws);
      },
      onError: (e) {
        _clients.remove(ws);
      },
    );
  }

  void _broadcastToClients(String text) {
    for (final c in List<WebSocket>.from(_clients)) {
      if (c.readyState == WebSocket.open) {
        c.add(text);
      } else {
        _clients.remove(c);
      }
    }
  }

  Future<void> stop() async {
    await _httpServer?.close(force: true);
    _httpServer = null;
    _analysisProc?.kill();
    _analysisProc = null;
  }
}
