import 'package:dartpad_lite/UI/settings/options/compiler/language_setting_option_vm.dart';
import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/UI/settings/widget/path_selector.dart';
import 'package:dartpad_lite/core/storage/compiler_repo.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/supported_language.dart';
import '../../../command_palette/command_palette.dart';

class LanguageSettingOption extends StatefulWidget {
  final CompilerRepoInterface languageRepo;
  const LanguageSettingOption({super.key, required this.languageRepo});

  @override
  State<LanguageSettingOption> createState() => _LanguageSettingOptionState();
}

class _LanguageSettingOptionState extends State<LanguageSettingOption> {
  late final LanguageSettingOptionVMInterface _vm = LanguageSettingOptionVM(
    widget.languageRepo,
  );

  void _selectDirectory(String? path) async {
    if (path != null) {
      await _vm.setSDKPath(sdkPath: path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.selectedLanguage,
      builder: (_, selectedLanguage, __) {
        return SettingOption(
          title: 'Language',
          height: selectedLanguage?.needSDKPath ?? false ? 200 : 100,
          child: FutureBuilder(
            future: _vm.getSupportedLanguages(),
            builder: (c, f) {
              final data = f.data;
              if (data == null) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Language Picker
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      CommandPalette.showOption<SupportedLanguage>(
                        context: context,
                        items: data.values.toList(),
                        itemBuilder: (context, item) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        onSelected: (item) {
                          _vm.selectedLanguage.value = item;
                        },
                        hintText: 'Choose language…',
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          selectedLanguage?.name ?? 'Select language…',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.expand_more, color: Colors.white54),
                      ],
                    ),
                  ),

                  // Browse button
                  if (selectedLanguage?.needSDKPath ?? false) ...[
                    PathSelector(
                      path:
                          selectedLanguage?.sdkPath ??
                          selectedLanguage?.path.hint,
                      label: "Select SDK Folder",
                      onPathSelect: _selectDirectory,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}
