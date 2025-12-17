import 'package:dartpad_lite/UI/editor/editor/language_editor/language_editor_factory.dart';
import 'package:dartpad_lite/UI/editor/result_page/side_by_side/side_by_side_view_vm.dart';
import 'package:dartpad_lite/core/storage/supported_language.dart';
import 'package:flutter/material.dart';

class SideToSideView extends StatefulWidget {
  final SupportedLanguage language;

  const SideToSideView({super.key, required this.language});

  @override
  State<SideToSideView> createState() => _SideToSideViewState();
}

class _SideToSideViewState extends State<SideToSideView> {
  late final SideBySideViewVMInterface _vm = SideBySideViewVM(widget.language);

  Widget _buildLoader() {
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.settingUp,
      builder: (_, value, _) {
        if (value) {
          return _buildLoader();
        }

        return LanguageEditorFactory.buildLanguageEditor(
          language: widget.language,
          controller: _vm.controller,
        );
      },
    );
  }
}
