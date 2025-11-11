import 'dart:io';

import 'package:dartpad_lite/UI/history/history_page_vm.dart';
import 'package:dartpad_lite/services/save_file/save_file_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';

class HistoryPage extends StatefulWidget {
  final FileServiceInterface fileService;
  const HistoryPage({super.key, required this.fileService});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryPageVMInterface _vm = HistoryPageVM(widget.fileService);

  @override
  void initState() {
    super.initState();

    _vm.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColor.mainGrey),
      backgroundColor: AppColor.mainGreyDarker,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<List<File>>(
          valueListenable: _vm.onFilesUpdate,
          builder: (_, value, __) {
            final files = value;

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.uri.pathSegments.last;
                final filePath = file.path;
                final modified = DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).format(file.lastModifiedSync());

                return Card(
                  color: AppColor.mainGrey,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      fileName,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filePath,
                          style: TextStyle(color: AppColor.mainGreyLighter),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last saved: $modified',
                          style: TextStyle(
                            color: AppColor.mainGreyLighter,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: AppColor.error,
                      ),
                      onPressed: () {
                        _vm.deleteFile(file: file);
                      },
                    ),
                    onTap: () {
                      // Optional: open file in Monaco editor
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
