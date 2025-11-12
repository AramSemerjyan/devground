import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  final Widget right;
  final Widget left;

  const SplitView({super.key, required this.right, required this.left});

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
