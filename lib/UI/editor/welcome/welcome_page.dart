import 'dart:io';

import 'package:dartpad_lite/UI/editor/welcome/welcome_page_vm.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/services/import_file/import_file_service.dart';
import '../../../core/services/save_file/file_service.dart';

class WelcomePage extends StatefulWidget {
  final LanguageRepoInterface languageRepo;
  final ImportFileServiceInterface importFileService;
  final FileServiceInterface fileService;

  const WelcomePage({
    super.key,
    required this.fileService,
    required this.importFileService,
    required this.languageRepo,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final _vm = WelcomePageVM(
    widget.fileService,
    widget.importFileService,
    widget.languageRepo,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainGreyDark,
      body: Row(
        children: [
          // Left Section: Start Actions
          Container(
            width: 320,
            color: AppColor.mainGrey,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _sectionTitle('Start'),
                _actionTile(
                  Icons.note_add_outlined,
                  'New File',
                  enabled: true,
                  onTap: _vm.onNewFile,
                ),
                _actionTile(Icons.folder_open_outlined, 'Open Folder'),
                _actionTile(Icons.cloud_download_outlined, 'Clone Repository'),
                const SizedBox(height: 32),
                _sectionTitle('Help'),
                _actionTile(Icons.book_outlined, 'Documentation'),
                _actionTile(
                  Icons.play_circle_outline,
                  'Interactive Playground',
                ),
                _actionTile(Icons.forum_outlined, 'Community'),
              ],
            ),
          ),

          // Right Section: Recent Projects
          Expanded(
            child: Container(
              color: AppColor.mainGreyDark,
              padding: const EdgeInsets.only(
                top: 40,
                right: 40,
                left: 40,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Recent'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder(
                      future: _vm.getHistory(),
                      builder: (_, future) {
                        final files = future.data ?? [];

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: files.map(_recentTile).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'VS Code–style Welcome Page (Created by Me)',
                      style: TextStyle(
                        color: AppColor.mainGreyLighter,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String label, {
    enabled = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentTile(File file) {
    final name = file.uri.pathSegments.last;
    final path = file.path;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          _vm.onSelect(file: file);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                path,
                style: TextStyle(color: AppColor.mainGreyLighter, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
