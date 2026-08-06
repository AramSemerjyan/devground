import 'package:flutter/material.dart';
import '../../../../common/step_slider.dart';
import '../../../../../utils/app_colors.dart';
import '../../setting_option.dart';

class LocalAiContextLimit extends StatefulWidget {
  final Function(String?)? onLimitChanged;

  const LocalAiContextLimit({super.key, this.onLimitChanged});

  @override
  LocalAiContextLimitState createState() => LocalAiContextLimitState();
}

class LocalAiContextLimitState extends State<LocalAiContextLimit> {
  @override
  Widget build(BuildContext context) {
    return SettingOption(
      title: 'Local AI context limit',
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Text(
          //   "The local AI provider has a context limit of 4096 tokens. If the conversation exceeds this limit, the oldest messages will be removed.",
          //   style: TextStyle(color: AppColor.mainGreyLighter),
          // ),
          Text(
            "Defined how many messages the local AI provider can remember. If the conversation exceeds this limit, the oldest messages will be removed.",
            style: TextStyle(color: AppColor.mainGreyLighter),
          ),
          StepSlider(
            steps: List.generate(10, (index) => ((index + 1) * 10).toString()),
            onStepChanged: (value) {
              widget.onLimitChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
