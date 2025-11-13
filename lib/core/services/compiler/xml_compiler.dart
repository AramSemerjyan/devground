import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import 'compiler_interface.dart';

class XMLCompiler implements CompilerInterface {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      final document = XmlDocument.parse(code);
      return CompilerResult(
        data: document.toXmlString(pretty: true, indent: '\t'),
      );
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }

  @override
  Future<CompilerResult> runCode(String code) async {
    try {
      // Create a temporary HTML file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_xml_$id.xml');
      await file.writeAsString(code);

      // Load the temporary file into WebView
      final uri = Uri.file(file.path).path;

      return CompilerResult(data: uri);
    } catch (e) {
      return CompilerResult(hasError: true, error: e);
    }
  }
}
