import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../storage/supported_language.dart';

class LspBridge {
  final SupportedLanguage language;

  final int port;
  Process? _analysisProc;
  HttpServer? _httpServer;

  LspBridge(this.port, this.language);

  /// Start analysis server and ws bridge
  Future<void> start() async {
    if (language.key != SupportedLanguageKey.dart) {
      return;
    }

    _analysisProc = await startAnalysisServer();
    // Listen to analysis stdout; forward messages to connected websocket clients.
    _analysisProc!.stdout.listen((data) {
      // data are bytes that contain framed LSP messages; we forward raw bytes as text frames
      final text = utf8.decode(data);
      _broadcastToClients(text);
    });

    _analysisProc!.stderr.transform(utf8.decoder).listen((s) {});

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

  Future<Process> startAnalysisServer() async {
    final flutterPath = language.sdkPath;
    final dartExec = flutterPath != null && flutterPath.isNotEmpty
        ? '$flutterPath/bin/dart'
        : 'dart';

    // analysis server snapshot location (Flutter-provided Dart SDK)
    final snapshot = flutterPath != null
        ? '$flutterPath/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot'
        : null; // adjust if not using flutterPath

    if (snapshot == null) {
      throw Exception(
        'Cannot locate analysis_server.dart.snapshot. Set Flutter path in settings.',
      );
    }

    final args = [
      snapshot,
      '--lsp',
      '--client-id', 'dartpad_lite', // optional
      '--client-version', '0.1.0',
    ];

    final proc = await Process.start(
      dartExec,
      args,
      mode: ProcessStartMode.detachedWithStdio,
    );

    return proc;
  }
}
