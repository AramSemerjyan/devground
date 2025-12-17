import 'dart:convert';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class JSONCompiler extends Compiler {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    String? fixedCode;
    try {
      // First, try to fix common JSON issues
      fixedCode = _fixInvalidJson(code);

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
      CompilerResult.error(
        compilerError: CompilerNotSupported('Code execution'),
      ),
    );
  }

  /// Fix common JSON issues like unquoted keys and values
  String _fixInvalidJson(String json) {
    // Remove comments (single line and multi-line)
    json = json.replaceAll(RegExp(r'//.*?$', multiLine: true), '');
    json = json.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    // Add basic formatting if JSON is on a single line (makes other fixes work)
    json = _addBasicFormatting(json);

    // Fix incomplete quoted strings (missing opening or closing quotes)
    json = _fixIncompleteQuotes(json);

    // Fix misplaced closing braces (e.g., },\n}\n"key": where the first } should be removed)
    json = _fixMisplacedBrackets(json);

    // Fix missing opening brackets BEFORE fixing quotes
    json = _fixMissingOpeningBrackets(json);

    // Fix unquoted keys (including numeric keys and UUIDs): match any unquoted identifier before colon
    // Pattern: after {, [, comma, or newline followed by whitespace, capture identifier, then colon
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:',
        multiLine: true,
      ),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Fix unquoted string values (including Unicode/Cyrillic characters)
    // This includes UUIDs, identifiers like "brand-block-xyz", "field_metrics_bb", etc.
    // Don't match structural characters like { } [ ]
    json = json.replaceAllMapped(
      RegExp(r':\s*([^\s,}\]":[{]+(?:\s+[^\s,}\]":[{]+)*)(\s*[,}\]])'),
      (match) {
        final value = match.group(1)!.trim();

        // Skip empty values
        if (value.isEmpty) {
          return ':${match.group(2)}';
        }

        // Don't quote reserved words or numbers
        if (value == 'true' ||
            value == 'false' ||
            value == 'null' ||
            RegExp(r'^-?\d+\.?\d*$').hasMatch(value)) {
          return ': $value${match.group(2)}';
        }

        // Don't quote if it's already part of a quoted string
        if (value.startsWith('"') || value.endsWith('"')) {
          return ': $value${match.group(2)}';
        }

        // Quote the value (including Unicode characters)
        return ': "$value"${match.group(2)}';
      },
    );

    // Fix missing commas between properties
    json = _fixMissingCommas(json);

    // Fix trailing commas
    json = json.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

    // Fix missing closing brackets/braces
    json = _fixMissingBrackets(json);

    return json;
  }

  /// Add basic formatting to single-line JSON to enable other fixes
  String _addBasicFormatting(String json) {
    // Check if JSON is mostly on one line (few newlines)
    final newlineCount = '\n'.allMatches(json).length;
    final jsonLength = json.length;

    // If there are already plenty of newlines, skip this step
    if (jsonLength < 500 || newlineCount > jsonLength / 100) {
      return json;
    }

    // Add line breaks after structural characters (but not within strings)
    bool inString = false;
    bool escapeNext = false;
    final buffer = StringBuffer();

    for (int i = 0; i < json.length; i++) {
      final char = json[i];

      if (escapeNext) {
        buffer.write(char);
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        buffer.write(char);
        escapeNext = true;
        continue;
      }

      if (char == '"') {
        buffer.write(char);
        inString = !inString;
        continue;
      }

      if (!inString) {
        // Add newline after opening braces/brackets
        if (char == '{' || char == '[') {
          buffer.write(char);
          if (i + 1 < json.length && json[i + 1] != '\n') {
            buffer.write('\n');
          }
          continue;
        }

        // Add newline before closing braces/brackets
        if (char == '}' || char == ']') {
          if (buffer.isNotEmpty &&
              buffer.toString()[buffer.length - 1] != '\n') {
            buffer.write('\n');
          }
          buffer.write(char);
          continue;
        }

        // Add newline after commas
        if (char == ',') {
          buffer.write(char);
          if (i + 1 < json.length && json[i + 1] != '\n') {
            buffer.write('\n');
          }
          continue;
        }
      }

      buffer.write(char);
    }

    return buffer.toString();
  }

  /// Fix missing commas between key-value pairs
  String _fixMissingCommas(String json) {
    // Pattern: value (number, string, boolean, null, }, ]) followed by newline and a key
    // without a comma between them

    // Fix: "value"\n"key": pattern (missing comma after quoted string value)
    json = json.replaceAllMapped(
      RegExp(r'("[^"]*")\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: number\n"key": pattern (missing comma after number)
    json = json.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: boolean/null\n"key": pattern (missing comma after boolean or null)
    json = json.replaceAllMapped(
      RegExp(r'\b(true|false|null)\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: }\n"key": pattern (missing comma after closing brace)
    json = json.replaceAllMapped(
      RegExp(r'(})\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: ]\n"key": pattern (missing comma after closing bracket)
    json = json.replaceAllMapped(
      RegExp(r'(\])\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    return json;
  }

  /// Fix incomplete quoted strings (e.g., "key: or key":)
  String _fixIncompleteQuotes(String json) {
    // Fix keys with opening quote but missing closing quote before colon
    // Pattern: "identifier: (missing closing quote)
    json = json.replaceAllMapped(
      RegExp(r'"([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:', multiLine: true),
      (match) => '"${match.group(1)}":',
    );

    // Fix keys with closing quote but missing opening quote
    // Pattern: identifier": (missing opening quote)
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)":',
        multiLine: true,
      ),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    return json;
  }

  /// Fix misplaced closing brackets (e.g., },\n}\n"key": pattern)
  String _fixMisplacedBrackets(String json) {
    // Pattern: closing brace with comma, followed by closing brace on next line,
    // followed by a key-value pair (indicating the first brace was misplaced)
    json = json.replaceAllMapped(
      RegExp(
        r'},\s*\n\s*}\s*\n\s*("[^"]+"|[a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:',
        multiLine: true,
      ),
      (match) {
        // Remove the first closing brace and comma, keep the second one
        return '},\n        ${match.group(1)}:';
      },
    );

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
