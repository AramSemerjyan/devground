import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../utils/app_colors.dart';
import '../../setting_option.dart';

class ApiKeyOption extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSave;

  const ApiKeyOption({super.key, required this.controller, this.onSave});

  @override
  State<ApiKeyOption> createState() => _ApiKeyOptionState();
}

class _ApiKeyOptionState extends State<ApiKeyOption> {
  final ValueNotifier<bool> _saveEnabled = ValueNotifier(false);
  final ValueNotifier<bool> _showApiKey = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SettingOption(
      title: 'Gemini API key',
      height: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder(
            valueListenable: _showApiKey,
            builder: (_, show, __) {
              return TextField(
                controller: widget.controller,
                obscureText: !show,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2A2D2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFF454545)),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          show ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => _showApiKey.value = !_showApiKey.value,
                      ),
                      IconButton(
                        icon: const Icon(Icons.paste, color: Colors.white54),
                        onPressed: () async {
                          final paste = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          if (paste?.text != null) {
                            widget.controller.text = paste!.text!;
                          }
                        },
                      ),
                      if (widget.controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () => widget.controller.clear(),
                        ),
                    ],
                  ),
                ),
                onChanged: (v) {
                  _saveEnabled.value = v.isNotEmpty;
                },
              );
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder(
            valueListenable: _saveEnabled,
            builder: (_, enabled, __) {
              return Opacity(
                opacity: enabled ? 1 : 0.5,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!enabled) return;
                    widget.onSave?.call(widget.controller.text);
                  },
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
