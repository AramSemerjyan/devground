import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class XMLCompiler extends Compiler {
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      final document = XmlDocument.parse(code);
      return CompilerResult.message(
        data: document.toXmlString(pretty: true, indent: '\t'),
      );
    } catch (e) {
      return CompilerResult.error(error: e);
    }
  }

  @override
  Future<void> runCode(String code) async {
    try {
      // Create a temporary HTML file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_xml_$id.xml');
      await file.writeAsString(code);

      // Load the temporary file into WebView
      final uri = Uri.file(file.path).path;

      resultStream.sink.add(CompilerResult.done(data: uri));
      return;
    } catch (e) {
      resultStream.sink.add(CompilerResult.error(error: e));
      return;
    }
  }
}
