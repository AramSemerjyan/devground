import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class SettingOption extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? height;

  const SettingOption({
    super.key,
    required this.child,
    this.title,
    this.height,
  });

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.mainGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3C3C3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title ?? ''),
          Expanded(child: child),
        ],
      ),
    );
  }
}
