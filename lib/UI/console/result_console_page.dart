import 'dart:async';

import 'package:flutter/material.dart';

class ResultConsolePage extends StatelessWidget {
  final Stream<String> outputStream;

  const ResultConsolePage({super.key, required this.outputStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: outputStream,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: SelectableText(
            snapshot.data ?? '',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }
}
