import 'package:dartpad_lite/UI/editor/editor/language_editor/ai_response_editor/ai_response_editor_controller.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';
import '../../../ai_helper/ui/response_parser/gpt_markdown.dart';

class AiResponseEditor extends StatefulWidget {
  final AIResponseEditorController controller;

  const AiResponseEditor({super.key, required this.controller});

  @override
  State<AiResponseEditor> createState() => _AiResponseEditorState();
}

class _AiResponseEditorState extends State<AiResponseEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.mainGreyDark,
      padding: EdgeInsets.all(16),
      height: double.infinity,
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.mainGrey,
        ),
        child: SingleChildScrollView(
          child: ValueListenableBuilder(
            valueListenable: widget.controller.onCodeSet,
            builder: (_, value, __) {
              return GptMarkdown(
                value ?? '',
                shouldShowCodeReplace: false,
                style: TextStyle(color: AppColor.mainGreyLighter),
              );
            },
          ),
        ),
      ),
    );
  }
}
