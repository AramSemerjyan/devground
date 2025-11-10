import 'dart:io';

import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../settings_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _flutterPathController = TextEditingController();
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = await SettingsManager.getFlutterPath();
    _flutterPathController.text = path ?? '';
  }

  Future<void> _save() async {
    final path = _flutterPathController.text.trim();
    if (path.isEmpty) {
      setState(() => _statusMessage = 'Path cannot be empty.');
      return;
    }

    final flutterBin = File('$path/bin/flutter');
    if (!await flutterBin.exists()) {
      setState(() => _statusMessage = 'Invalid Flutter SDK path.');
      return;
    }

    await SettingsManager.setFlutterPath(path);
    setState(() => _statusMessage = '✅ Saved successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColor.mainGrey),
      backgroundColor: AppColor.mainGreyDarker,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flutter SDK Path:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.mainGreyLighter,
              ),
            ),
            TextField(
              controller: _flutterPathController,
              enabled: false,
              style: TextStyle(
                color: AppColor.mainGreyLighter.withValues(alpha: 0.3),
              ),
              decoration: InputDecoration(
                hintText: '/Users/your_username/flutter',
                hintStyle: TextStyle(
                  color: AppColor.mainGreyLighter.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String? selectedDirectory = await FilePicker.platform
                    .getDirectoryPath();
                if (selectedDirectory != null) {
                  setState(() {
                    _flutterPathController.text = selectedDirectory;
                    _save();
                    StatusEvent.instance.onEvent.add(
                      Event.success(title: 'Ready'),
                    );
                  });
                }
              },
              child: const Text('Browse...'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(color: AppColor.mainGreyLighter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
