import 'package:dartpad_lite/UI/settings/options/language/language_setting_option.dart';
import 'package:dartpad_lite/UI/settings/options/setting_section.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/storage/language_repo.dart';
import 'options/ai_section/ai_setting_section.dart';

class SettingsPage extends StatefulWidget {
  final LanguageRepoInterface languageRepo;

  const SettingsPage({super.key, required this.languageRepo});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainGreyDark,
      appBar: AppBar(
        backgroundColor: AppColor.mainGrey,
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColor.mainGreyLighter),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingSection(
              title: 'General',
              children: [
                LanguageSettingOption(languageRepo: widget.languageRepo),
              ],
            ),
            AISettingSection(),
          ],
        ),
      ),
    );
  }
}
