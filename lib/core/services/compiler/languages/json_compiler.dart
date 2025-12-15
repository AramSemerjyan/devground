import 'dart:convert';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class JSONCompiler extends Compiler {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      // First, try to fix common JSON issues
      final fixedCode = _fixInvalidJson(code);

      final jsonObject = jsonDecode(fixedCode);
      const encoder = JsonEncoder.withIndent('  '); // 2 spaces
      return CompilerResult.message(
        data: encoder.convert(jsonObject),
        message: 'JSON formatted successfully',
      );
    } catch (e, s) {
      return CompilerResult.error(error: e, stackTrace: s);
    }
  }

  @override
  Future<void> runCode(String code) async {
    // This compiler does not execute code; just report as not supported for run
    resultStream.sink.add(
      CompilerResult.error(compilerError: CompilerNotSupported('Code execution')),
    );
  }

  /// Fix common JSON issues like unquoted keys and values
  String _fixInvalidJson(String json) {
    // Remove comments (single line and multi-line)
    json = json.replaceAll(RegExp(r'//.*?$', multiLine: true), '');
    json = json.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Fix missing opening brackets BEFORE fixing quotes
    json = _fixMissingOpeningBrackets(json);

    // Fix unquoted keys (including numeric keys): match any unquoted identifier before colon
    // Pattern: after {, [, comma, or newline followed by whitespace, capture identifier, then colon
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$]*)\s*:',
        multiLine: true,
      ),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Fix unquoted string values (but not numbers, booleans, or null)
    // Pattern: colon followed by unquoted word that's not true/false/null/number
    json = json.replaceAllMapped(
      RegExp(r':\s*([a-zA-Z_][a-zA-Z0-9_\s]*?)(\s*[,}\]])'),
      (match) {
        final value = match.group(1)!.trim();

        // Don't quote reserved words or numbers
        if (value == 'true' ||
            value == 'false' ||
            value == 'null' ||
            RegExp(r'^-?\d+\.?\d*$').hasMatch(value)) {
          return ':${match.group(1)}${match.group(2)}';
        }

        // Quote the value
        return ': "$value"${match.group(2)}';
      },
    );

    // Fix trailing commas
    json = json.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

    // Fix missing closing brackets/braces
    json = _fixMissingBrackets(json);

    return json;
  }

  /// Fix missing opening brackets after colons (e.g., "key": value instead of "key": {value})
  String _fixMissingOpeningBrackets(String json) {
    // Pattern: colon followed by newline/whitespace and then a key (not a value)
    // This indicates missing opening brace for nested object
    json = json.replaceAllMapped(
      RegExp(r':\s*\n\s+(["\w]+)\s*:', multiLine: true),
      (match) {
        // Check if this looks like a nested object definition
        return ': {\n    ${match.group(1)}:';
      },
    );

    return json;
  }

  /// Fix missing closing brackets and braces
  String _fixMissingBrackets(String json) {
    // First, try to add missing opening brackets
    json = _fixMissingOpeningBrackets(json);

    int openBraces = 0;
    int openBrackets = 0;
    bool inString = false;
    bool escapeNext = false;

    // Count unmatched brackets/braces while respecting strings
    for (int i = 0; i < json.length; i++) {
      final char = json[i];

      if (escapeNext) {
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        escapeNext = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == '{') {
          openBraces++;
        } else if (char == '}') {
          openBraces--;
        } else if (char == '[') {
          openBrackets++;
        } else if (char == ']') {
          openBrackets--;
        }
      }
    }

    // Add missing closing characters at the end
    final buffer = StringBuffer(json.trimRight());

    // Add missing closing brackets first (for arrays)
    for (int i = 0; i < openBrackets; i++) {
      buffer.write('\n]');
    }

    // Add missing closing braces (for objects)
    for (int i = 0; i < openBraces; i++) {
      buffer.write('\n}');
    }

    return buffer.toString();
  }
}
