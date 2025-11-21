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
  static Future<CompilerInterface> getCompiler(
    SupportedLanguage language,
  ) async {
    final sdkPath = language.sdkPath;

    if (sdkPath == null && language.needSDKPath) {
      if (language.supported == LanguageSupport.upcoming) {
        throw CompilerUpcomingSupport();
      } else {
        throw CompilerSDKPathMissing();
      }
    }

    switch (language.key) {
      case SupportedLanguageKey.dart:
        return DartCompiler(language.sdkPath!);
      case SupportedLanguageKey.shell:
        return ShellCompiler(language.sdkPath!);
      case SupportedLanguageKey.html:
        return HTMLCompiler();
      case SupportedLanguageKey.js:
        return JsCompiler();
      case SupportedLanguageKey.c:
        return CCompiler(language.sdkPath!);
      case SupportedLanguageKey.cpp:
        return CPPCompiler(language.sdkPath!);
      case SupportedLanguageKey.python:
        return PythonCompiler(language.sdkPath!);
      case SupportedLanguageKey.swift:
        return SwiftCompiler(language.sdkPath!);
      case SupportedLanguageKey.xml:
        return XMLCompiler();
      case SupportedLanguageKey.json:
        return JSONCompiler();
      default:
        return DefaultCompiler(language: language);
    }
  }
}
