import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeField extends StatefulWidget {
  final String name;
  final String codes;
  final void Function(String code)? onCodeReplaceTap;

  const CodeField({
    super.key,
    required this.name,
    required this.codes,
    this.onCodeReplaceTap,
  });

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.mainGreyDarker,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text(
                  widget.name,
                  style: TextStyle(color: AppColor.white),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Copy',
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.codes));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              Tooltip(
                message: 'Replace editor code',
                child: InkWell(
                  onTap: () {
                    widget.onCodeReplaceTap?.call(widget.codes);
                  },
                  child: const Icon(
                    Icons.move_up_sharp,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.codes,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
