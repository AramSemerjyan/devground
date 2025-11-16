import 'package:flutter/material.dart';

import '../../../../command_palette/command_palette.dart';
import '../../setting_option.dart';
import '../ai_setting_vm.dart';

class AITypeSelectorOption extends StatelessWidget {
  final AISettings settings;
  final Function(AIType)? onTypeSelect;

  const AITypeSelectorOption({
    super.key,
    required this.settings,
    this.onTypeSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SettingOption(
      height: 100,
      title: 'AI Type',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          CommandPalette.showOption<AIType>(
            context: context,
            items: AIType.values,
            itemBuilder: (context, item) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.name,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            onSelected: (item) {
              onTypeSelect?.call(item);
            },
            hintText: 'Choose language…',
          );
        },
        child: Row(
          children: [
            Text(
              settings.type.value,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
