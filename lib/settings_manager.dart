import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const _flutterPathKey = 'flutter_sdk_path';

  static Future<String?> getFlutterPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_flutterPathKey);
  }

  static Future<void> setFlutterPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_flutterPathKey, path);
  }

  /// Starts analysis server in LSP mode and returns the Process.
  /// `flutterPath` is path to the Flutter SDK (or null to use system dart).
  static Future<Process> startAnalysisServer() async {
    final flutterPath = await getFlutterPath();
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

    // OPTIONAL: listen to stderr for logs
    proc.stderr.transform(utf8.decoder).listen((s) {
      print('[analysis_server stderr] $s');
    });

    return proc;
  }
}
