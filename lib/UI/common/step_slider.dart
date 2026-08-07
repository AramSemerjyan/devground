import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class StepSlider extends StatefulWidget {
  final List<String> steps;
  final int initialValue;
  final Function(String)? onStepChanged;

  const StepSlider({
    super.key,
    required this.steps,
    this.initialValue = 0,
    this.onStepChanged,
  });

  @override
  State<StepSlider> createState() => _StepSliderState();
}

class _StepSliderState extends State<StepSlider> {
  List<String> get _steps => widget.steps;
  late double _currentValue =
      (widget.initialValue / 10 - 1).toDouble();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Slider(
            value: _currentValue,
            min: 0,
            max: (_steps.length - 1).toDouble(),
            divisions: _steps.length - 1,
            activeColor: AppColor.selected,
            inactiveColor: AppColor.mainGreyLighter,
            thumbColor: Colors.white,
            onChanged: (double value) {
              setState(() {
                _currentValue = value;
                widget.onStepChanged?.call(_steps[_currentValue.toInt()]);
              });
            },
          ),
        ),

        // Bottom Labels Layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _steps.map((label) {
              int index = _steps.indexOf(label);
              bool isSelected = index == _currentValue.toInt();

              return Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColor.white : AppColor.mainGreyLighter,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
