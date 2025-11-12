import 'package:dartpad_lite/services/compiler/dart_compiler.dart';
import 'package:dartpad_lite/services/compiler/html_compiler.dart';
import 'package:dartpad_lite/services/compiler/js_compiler.dart';
import 'package:dartpad_lite/services/compiler/shell_compiler.dart';
import 'package:dartpad_lite/storage/supported_language.dart';

class CompilerResult {
  final bool hasError;
  final Object? error;
  final dynamic data;

  CompilerResult({this.hasError = false, this.data, this.error});
}

abstract class CompilerInterface {
  Future<CompilerResult> runCode(String code);
  Future<CompilerResult> formatCode(String code);
}

class Compiler implements CompilerInterface {
  CompilerInterface? _selectedCompiler;

  @override
  Future<CompilerResult> formatCode(String code) {
    if (_selectedCompiler == null) {
      throw Exception('Compiler not selected');
    }

    return _selectedCompiler!.formatCode(code);
  }

  @override
  Future<CompilerResult> runCode(String code) {
    if (_selectedCompiler == null) {
      throw Exception('Compiler not selected');
    }

    return _selectedCompiler!.runCode(code);
  }

  void setCompilerForLanguage({required SupportedLanguage language}) {
    final sdkPath = language.sdkPath;

    if (sdkPath == null && language.needSDKPath) {
      _selectedCompiler = null;
      throw Exception('SDK path missing');
    }

    switch (language.key) {
      case SupportedLanguageType.dart:
        _selectedCompiler = DartCompiler(sdkPath!);
        break;
      case SupportedLanguageType.shell:
        _selectedCompiler = ShellCompiler(sdkPath!);
      case SupportedLanguageType.html:
        _selectedCompiler = HTMLCompiler();
      case SupportedLanguageType.js:
        _selectedCompiler = JsCompiler();
      default:
        _selectedCompiler = null;
    }
  }

  void resetCompiler() {
    _selectedCompiler = null;
  }
}
