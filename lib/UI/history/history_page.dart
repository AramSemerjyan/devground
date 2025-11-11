import 'dart:io';

import 'package:dartpad_lite/UI/history/history_page_vm.dart';
import 'package:dartpad_lite/services/import_file/import_file_service.dart';
import 'package:dartpad_lite/services/save_file/file_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';

class HistoryPage extends StatefulWidget {
  final FileServiceInterface fileService;
  final ImportFileServiceInterface importFileService;

  const HistoryPage({
    super.key,
    required this.fileService,
    required this.importFileService,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryPageVMInterface _vm = HistoryPageVM(
    widget.fileService,
    widget.importFileService,
  );

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
          builder: (_, files, __) {
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: AppColor.error,
                          ),
                          onPressed: () {
                            _vm.deleteFile(file: file);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.folder,
                            color: AppColor.mainGreyLighter,
                          ),
                          onPressed: () {
                            _vm.onReveal(file: file);
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      await _vm.onSelect(file: file);
                      if (context.mounted) Navigator.of(context).pop();
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
