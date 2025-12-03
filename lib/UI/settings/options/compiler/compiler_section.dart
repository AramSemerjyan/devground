import 'package:dartpad_lite/UI/settings/options/compiler/compiler_sound_option.dart';
import 'package:dartpad_lite/UI/settings/options/compiler/language_setting_option.dart';
import 'package:dartpad_lite/core/storage/compiler_sound_repo.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/compiler_repo.dart';
import '../setting_section.dart';

class CompilerSection extends StatelessWidget {
  final CompilerRepoInterface languageRepo;

  const CompilerSection({super.key, required this.languageRepo});

  @override
  Widget build(BuildContext context) {
    return SettingSection(
      title: 'Compiler',
      children: [
        LanguageSettingOption(languageRepo: languageRepo),
        CompilerSoundOption(repo: languageRepo),
      ],
    );
  }
}
