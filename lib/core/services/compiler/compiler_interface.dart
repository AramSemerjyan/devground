import 'package:dartpad_lite/core/services/compiler/default_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/json_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/py_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/shell_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/swift_compiler.dart';
import 'package:dartpad_lite/core/services/compiler/xml_compiler.dart';
import 'package:dartpad_lite/core/services/event_service/event_service.dart';

import '../../storage/supported_language.dart';
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

      if (language.supported == LanguageSupport.upcoming) {
        EventService.warning(
          msg: 'Upcoming',
          duration: const Duration(seconds: 2),
        );

        return;
      } else {
        EventService.error(
          msg: 'SDK path missing',
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    switch (language.key) {
      case SupportedLanguageType.dart:
        _selectedCompiler = DartCompiler(sdkPath!);
        break;
      case SupportedLanguageType.shell:
        _selectedCompiler = ShellCompiler(sdkPath!);
        break;
      case SupportedLanguageType.html:
        _selectedCompiler = HTMLCompiler();
        break;
      case SupportedLanguageType.js:
        _selectedCompiler = JsCompiler();
        break;
      case SupportedLanguageType.c:
        _selectedCompiler = CCompiler(sdkPath!);
        break;
      case SupportedLanguageType.cpp:
        _selectedCompiler = CPPCompiler(sdkPath!);
        break;
      case SupportedLanguageType.python:
        _selectedCompiler = PythonCompiler(sdkPath!);
        break;
      case SupportedLanguageType.swift:
        _selectedCompiler = SwiftCompiler(sdkPath!);
        break;
      case SupportedLanguageType.xml:
        _selectedCompiler = XMLCompiler();
        break;
      case SupportedLanguageType.json:
        _selectedCompiler = JSONCompiler();
        break;
      default:
        _selectedCompiler = DefaultCompiler(language: language);
    }
  }

  void resetCompiler() {
    _selectedCompiler = null;
  }
}
