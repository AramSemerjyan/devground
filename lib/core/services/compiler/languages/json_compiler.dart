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

    // Fix missing colons after keys (e.g., "key" { or "key" [)
    json = _fixMissingColons(json);

    // Fix misplaced closing braces (e.g., },\n}\n"key": where the first } should be removed)
    json = _fixMisplacedBrackets(json);

    // Fix missing opening brackets BEFORE fixing quotes
    json = _fixMissingOpeningBrackets(json);

    // Fix unquoted keys (including numeric keys, UUIDs, and keys with spaces)
    // First pass: keys with spaces (must be done before single-word keys)
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*(?:\s+[a-zA-Z0-9_$\-]+)+)\s*:',
        multiLine: true,
      ),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Second pass: single-word keys
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:',
        multiLine: true,
      ),
      (match) => '${match.group(1)}"${match.group(2)}":',
    );

    // Fix unquoted string values (including Unicode/Cyrillic characters and complex strings)
    // Match any unquoted value that's not a structural character or already quoted
    // This handles simple values and complex strings with special characters
    json = json.replaceAllMapped(RegExp(r':\s*([^,}\]"[{]+?)(\s*[,}\]])'), (
      match,
    ) {
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

      // Don't quote if it's already quoted
      if (value.startsWith('"') && value.endsWith('"')) {
        return ': $value${match.group(2)}';
      }

      // Quote the value (including Unicode characters and special chars)
      // Escape any existing quotes in the value
      final escapedValue = value.replaceAll('"', '\\"');
      return ': "$escapedValue"${match.group(2)}';
    });

    // Fix unquoted values inside arrays (after [ or , but not after :)
    // Need to run this multiple times to catch all array values
    for (int i = 0; i < 3; i++) {
      json = json.replaceAllMapped(
        RegExp(r'([\[,])\s*\n?\s*([a-zA-Z_0-9\-]+)\s*([,\]])', multiLine: true),
        (match) {
          final value = match.group(2)!.trim();

          // Skip empty values
          if (value.isEmpty) {
            return '${match.group(1)}${match.group(3)}';
          }

          // Don't quote reserved words or numbers
          if (value == 'true' ||
              value == 'false' ||
              value == 'null' ||
              RegExp(r'^-?\d+\.?\d*$').hasMatch(value)) {
            return '${match.group(1)} $value${match.group(3)}';
          }

          // Don't quote if it's already quoted
          if (value.startsWith('"') && value.endsWith('"')) {
            return '${match.group(1)} $value${match.group(3)}';
          }

          // Quote the value
          return '${match.group(1)} "$value"${match.group(3)}';
        },
      );
    }

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

    // Fix: "value" "key": pattern on same line (missing comma after quoted string value)
    json = json.replaceAllMapped(
      RegExp(r'("[^"]*")\s+("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)}, ${match.group(2)}',
    );

    // Fix: "value"\n"key": pattern (missing comma after quoted string value)
    json = json.replaceAllMapped(
      RegExp(r'("[^"]*")\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: number "key": pattern on same line (missing comma after number)
    json = json.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\s+("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)}, ${match.group(2)}',
    );

    // Fix: number\n"key": pattern (missing comma after number)
    json = json.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: boolean/null "key": pattern on same line (missing comma after boolean or null)
    json = json.replaceAllMapped(
      RegExp(r'\b(true|false|null)\s+("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)}, ${match.group(2)}',
    );

    // Fix: boolean/null\n"key": pattern (missing comma after boolean or null)
    json = json.replaceAllMapped(
      RegExp(r'\b(true|false|null)\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: } "key": pattern on same line (missing comma after closing brace)
    json = json.replaceAllMapped(
      RegExp(r'(})\s+("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)}, ${match.group(2)}',
    );

    // Fix: }\n"key": pattern (missing comma after closing brace)
    json = json.replaceAllMapped(
      RegExp(r'(})\s*\n\s*("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)},\n        ${match.group(2)}',
    );

    // Fix: ] "key": pattern on same line (missing comma after closing bracket)
    json = json.replaceAllMapped(
      RegExp(r'(\])\s+("[^"]+"\s*:)', multiLine: true),
      (match) => '${match.group(1)}, ${match.group(2)}',
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
    // Fix keys missing closing quote followed by a quoted value
    // Pattern: "key "value" (missing closing quote and colon after key)
    json = json.replaceAllMapped(
      RegExp(r'"([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s+"([^"]+)"', multiLine: true),
      (match) => '"${match.group(1)}": "${match.group(2)}"',
    );

    // Fix keys followed by value with missing colon and opening quote
    // Pattern: "key" value" (missing : and opening ") followed by comma, brace, bracket, or newline
    json = json.replaceAllMapped(
      RegExp(r'"([^"]+)"\s+([a-zA-Z_0-9\-]+)"([,}\]\n])', multiLine: true),
      (match) => '"${match.group(1)}": "${match.group(2)}"${match.group(3)}',
    );

    // Fix keys with opening quote but missing closing quote before structural characters
    // Pattern: "identifier { or "identifier [ (missing closing quote and possibly colon)
    json = json.replaceAllMapped(
      RegExp(r'"([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s+([{\[])', multiLine: true),
      (match) => '"${match.group(1)}": ${match.group(2)}',
    );

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

    // Fix unclosed string values (missing closing quote before comma, brace, or bracket)
    // Pattern: : "value, or : "value} or : "value]
    // This must be done carefully to avoid matching already-valid strings
    json = json.replaceAllMapped(
      RegExp(r':\s*"([^"\n]*?)([,}\]\n])', multiLine: true),
      (match) {
        final value = match.group(1)!;
        final terminator = match.group(2)!;

        // Check if the value looks incomplete (doesn't already end with a quote)
        // If there's no closing quote before the terminator, add it
        if (!value.endsWith('"')) {
          return ': "$value"$terminator';
        }

        // Already has closing quote, keep as is
        return match.group(0)!;
      },
    );

    // Fix missing opening quote before string values
    // Pattern: : value" where value should be quoted (not a number, boolean, or null)
    json = json.replaceAllMapped(
      RegExp(r':\s*([a-zA-Z_\-][a-zA-Z0-9_\-]*)"([,}\]\n])', multiLine: true),
      (match) {
        final value = match.group(1)!;
        final terminator = match.group(2)!;

        // Don't add quote if it's a reserved word
        if (value == 'true' || value == 'false' || value == 'null') {
          return ': $value$terminator';
        }

        // Add opening quote
        return ': "$value"$terminator';
      },
    );

    return json;
  }

  /// Fix missing colons after keys (e.g., "key" { or "key" [)
  String _fixMissingColons(String json) {
    // Fix quoted keys missing colons before opening brace or bracket
    // Pattern: "key" { or "key" [
    json = json.replaceAllMapped(
      RegExp(r'"([^"]+)"\s+([{\[])', multiLine: true),
      (match) => '"${match.group(1)}": ${match.group(2)}',
    );

    // Fix unquoted keys missing colons before opening brace or bracket
    // Pattern: key { or key [
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\[\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s+([{\[])',
        multiLine: true,
      ),
      (match) => '${match.group(1)}${match.group(2)}: ${match.group(3)}',
    );

    // Fix quoted keys missing colons before primitive values
    // Pattern: "key" value (where value is number, string, boolean, null, or starts with ")
    // But NOT when the string is followed by a colon (that means it's another key)
    json = json.replaceAllMapped(
      RegExp(
        r'"([^"]+)"\s+((?:true|false|null|-?\d+\.?\d*|"[^"]*"))(?!\s*:)',
        multiLine: true,
      ),
      (match) => '"${match.group(1)}": ${match.group(2)}',
    );

    // Fix unquoted keys missing colons before primitive values
    // This must be more careful to avoid matching already-valid JSON
    json = json.replaceAllMapped(
      RegExp(
        r'([{,\n]\s*)([a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s+((?:true|false|null|-?\d+\.?\d*|"[^"]*"))(?!\s*:)',
        multiLine: true,
      ),
      (match) => '${match.group(1)}${match.group(2)}: ${match.group(3)}',
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

    // Fix missing opening brace in arrays: [..., \n "key": value...]
    // This handles cases where array items are objects but missing opening brace
    json = json.replaceAllMapped(
      RegExp(
        r'(\[)\s*\n\s+("[^"]+"|[a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:',
        multiLine: true,
      ),
      (match) {
        // Add opening brace after the array opening bracket
        return '${match.group(1)}\n    {\n      ${match.group(2)}:';
      },
    );

    // Fix missing opening brace after comma in arrays: [item, \n "key": value...]
    json = json.replaceAllMapped(
      RegExp(
        r'(,)\s*\n\s+("[^"]+"|[a-zA-Z_$0-9][a-zA-Z0-9_$\-]*)\s*:',
        multiLine: true,
      ),
      (match) {
        // Check if we're inside an array by looking at the context
        // If the comma is followed by a key-value pattern, it's likely a missing brace
        final beforeComma = json.substring(0, json.indexOf(match.group(0)!));

        // Count brackets to see if we're in an array context
        int bracketDepth = 0;
        int braceDepth = 0;
        bool inString = false;

        for (int i = beforeComma.length - 1; i >= 0; i--) {
          final char = beforeComma[i];
          if (char == '"' && (i == 0 || beforeComma[i - 1] != '\\')) {
            inString = !inString;
          }
          if (!inString) {
            if (char == ']') bracketDepth++;
            if (char == '[') {
              bracketDepth--;
              if (bracketDepth < 0) {
                // We're inside an array
                return '${match.group(1)}\n    {\n      ${match.group(2)}:';
              }
            }
            if (char == '}') braceDepth++;
            if (char == '{') {
              braceDepth--;
              if (braceDepth < 0) {
                // We're inside an object, not an array
                break;
              }
            }
          }
        }

        // Default: keep original
        return match.group(0)!;
      },
    );

    return json;
  }

  /// Fix missing closing brackets and braces
  String _fixMissingBrackets(String json) {
    // First, fix cases where we have closing bracket without opening bracket
    // Pattern: "key": { ... }] should be "key": [{ ... }]
    json = _fixMissingOpeningBracketsBeforeClosing(json);

    // Then, try to add missing opening brackets
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

    // If we have more closing than opening, we need to add opening brackets
    // But since we're at the end, we can only add closing brackets
    if (openBraces < 0 || openBrackets < 0) {
      // This means we have extra closing brackets - JSON is still malformed
      // But we'll try to fix by balancing at the end
      openBraces = openBraces.abs();
      openBrackets = openBrackets.abs();
    }

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

  /// Fix missing opening bracket before closing bracket
  /// Pattern: "key": { ... }] should be "key": [{ ... }]
  String _fixMissingOpeningBracketsBeforeClosing(String json) {
    final lines = json.split('\n');
    final List<String> result = [];

    int bracketDepth = 0;
    int braceDepth = 0;
    bool inString = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      String processedLine = line;

      // Track bracket/brace depth to detect mismatches
      for (int j = 0; j < line.length; j++) {
        final char = line[j];

        if (char == '"' && (j == 0 || line[j - 1] != '\\')) {
          inString = !inString;
        }

        if (!inString) {
          if (char == '[') bracketDepth++;
          if (char == '{') braceDepth++;
          if (char == '}') braceDepth--;
          if (char == ']') {
            bracketDepth--;

            // If bracket depth goes negative, we have a closing bracket without opening
            if (bracketDepth < 0) {
              // Look back to find where to insert the opening bracket
              // Find the line with "key": { pattern
              for (int k = result.length - 1; k >= 0; k--) {
                final prevLine = result[k];
                // Look for pattern: "key": { or "key":\s*{
                if (RegExp(r':\s*\{').hasMatch(prevLine) &&
                    !RegExp(r':\s*\[').hasMatch(prevLine)) {
                  // Insert [ after the colon
                  result[k] = prevLine.replaceFirstMapped(
                    RegExp(r'(:\s*)(\{)'),
                    (match) => '${match.group(1)}[${match.group(2)}',
                  );
                  bracketDepth = 0; // Reset since we fixed it
                  break;
                }
              }
            }
          }
        }
      }

      result.add(processedLine);
    }

    return result.join('\n');
  }
}
