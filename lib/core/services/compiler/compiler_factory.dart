import 'compiler_error.dart';
import 'compiler_interface.dart';
import 'default_compiler.dart';
import 'languages/json_compiler.dart';
import 'languages/py_compiler.dart';
import 'languages/shell_compiler.dart';
import 'languages/swift_compiler.dart';
import 'languages/xml_compiler.dart';
import '../../storage/supported_language.dart';
import 'languages/c_compiler.dart';
import 'languages/cpp_compiler.dart';
import 'languages/dart_compiler.dart';
import 'languages/html_compiler.dart';
import 'languages/js_compiler.dart';

class CompilerFactory {
  static Future<CompilerInterface> getCompiler(SupportedLanguage language) async {
    final sdkPath = language.sdkPath;

    if (sdkPath == null && language.needSDKPath) {
      if (language.supported == LanguageSupport.upcoming) {
        throw CompilerUpcomingSupport();
      } else {
        throw CompilerSDKPathMissing();
      }
    }

    switch (language.key) {
      case SupportedLanguageType.dart:
        return DartCompiler(language.sdkPath!);
      case SupportedLanguageType.shell:
        return ShellCompiler(language.sdkPath!);
      case SupportedLanguageType.html:
        return HTMLCompiler();
      case SupportedLanguageType.js:
        return JsCompiler();
      case SupportedLanguageType.c:
        return CCompiler(language.sdkPath!);
      case SupportedLanguageType.cpp:
        return CPPCompiler(language.sdkPath!);
      case SupportedLanguageType.python:
        return PythonCompiler(language.sdkPath!);
      case SupportedLanguageType.swift:
        return SwiftCompiler(language.sdkPath!);
      case SupportedLanguageType.xml:
        return XMLCompiler();
      case SupportedLanguageType.json:
        return JSONCompiler();
      default:
        return DefaultCompiler(language: language);
    }
  }
}