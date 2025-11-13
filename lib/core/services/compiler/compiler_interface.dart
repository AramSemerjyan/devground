import 'package:dartpad_lite/core/services/compiler/default_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/json_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/py_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/shell_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/swift_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/xml_compiler.dart';

import '../../../storage/supported_language.dart';
import 'c_compiler.dart';
import 'cpp_compiler.dart';
import 'dart_compiler.dart';
import 'html_compiler.dart';
import 'js_compiler.dart';

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
  final SupportedLanguage language;
  CompilerInterface? _selectedCompiler;

  Compiler({required this.language}) {
    _setUp();
  }

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

  void _setUp() {
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
      case SupportedLanguageType.c:
        _selectedCompiler = CCompiler(sdkPath!);
      case SupportedLanguageType.cpp:
        _selectedCompiler = CPPCompiler(sdkPath!);
      case SupportedLanguageType.python:
        _selectedCompiler = PythonCompiler(sdkPath!);
      case SupportedLanguageType.swift:
        _selectedCompiler = SwiftCompiler(sdkPath!);
      case SupportedLanguageType.xml:
        _selectedCompiler = XMLCompiler();
      case SupportedLanguageType.json:
        _selectedCompiler = JSONCompiler();
      default:
        _selectedCompiler = DefaultCompiler(language: language);
    }
  }

  void resetCompiler() {
    _selectedCompiler = null;
  }
}
