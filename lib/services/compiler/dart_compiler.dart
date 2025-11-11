import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DartCompiler implements CompilerInterface {
  final String flutterPath;
  final uuid = const Uuid();

  DartCompiler(this.flutterPath);

  @override
  Future<CompilerResult> formatCode(String code) async {
    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_fmt_$id.dart');
    // final flutterPath = await SettingsManager.getFlutterPath();
    final dartExecutable = flutterPath.isNotEmpty
        ? '$flutterPath/bin/dart'
        : 'dart';
    await file.writeAsString(code);
    // run dart format -n does not write; run 'dart format' overwrites, but we want formatted output
    // Simplest: run `dart format <file>` then read file back.
    final proc = await Process.start(dartExecutable, ['format', file.path]);
    final exitCode = await proc.exitCode;
    if (exitCode == 0) {
      final formatted = await file.readAsString();
      return CompilerResult(data: formatted);
    } else {
      return CompilerResult(hasError: true, data: exitCode);
    }
  }

  @override
  Future<CompilerResult> runCode(String code) async {
    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_$id.dart');
    await file.writeAsString(code);
    // Try to compile to an exe to capture compile errors.
    final compiledPath = '${tmpDir.path}/snippet_$id.bin';

    // Run: dart compile exe <file> -o <compiledPath>
    // final flutterPath = await SettingsManager.getFlutterPath();
    final dartExecutable = flutterPath.isNotEmpty
        ? '$flutterPath/bin/dart'
        : 'dart'; // fallback to default if not set

    final compileProc = await Process.start(dartExecutable, [
      'compile',
      'exe',
      file.path,
      '-o',
      compiledPath,
    ]);
    // collect output
    final compileStdout = StringBuffer();
    final compileStderr = StringBuffer();
    compileProc.stdout
        .transform(utf8.decoder)
        .listen((d) => compileStdout.write(d));
    compileProc.stderr
        .transform(utf8.decoder)
        .listen((d) => compileStderr.write(d));
    final exitCode = await compileProc.exitCode;

    if (exitCode != 0) {
      if (compileStderr.isNotEmpty) {
        return CompilerResult(
          hasError: true,
          data: _extractDartError(compileStderr.toString()),
        );
      }
    }

    // run the compiled binary
    try {
      final runProc = await Process.start(compiledPath, []);
      final runProcStdout = StringBuffer();
      final runProcStderr = StringBuffer();

      runProc.stdout
          .transform(utf8.decoder)
          .listen((d) => runProcStdout.write(d));
      runProc.stderr
          .transform(utf8.decoder)
          .listen((d) => runProcStderr.write(d));
      final rc = await runProc.exitCode;

      if (rc != 0) {
        return CompilerResult(hasError: true, data: runProcStderr.toString());
      } else {
        return CompilerResult(data: runProcStdout.toString());
      }
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }

  String _extractDartError(String stderr) {
    // Find the start: first colon after the temp file path
    final startIndex = stderr.indexOf(
      '.dart:',
    ); // e.g. ../../../snippet_*.dart:2:27:
    if (startIndex == -1) return stderr.trim();

    // Find the end: before "Error: AOT compilation failed"
    final endIndex = stderr.indexOf('Error: AOT compilation failed');
    if (endIndex == -1) return stderr.substring(startIndex).trim();

    // Extract substring
    final slice = stderr.substring(startIndex, endIndex).trim();

    // Remove the file path at the start (optional)
    final firstColon = slice.indexOf('Error:');
    if (firstColon != -1) {
      return slice.substring(firstColon).trim();
    }

    return slice;
  }
}
