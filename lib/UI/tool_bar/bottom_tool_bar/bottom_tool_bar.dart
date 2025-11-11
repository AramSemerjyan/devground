import 'dart:async';

import 'package:dartpad_lite/UI/tool_bar/bottom_tool_bar/bottom_tool_bar_vm.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../command_palette/command_palette.dart';

class BottomToolBar extends StatefulWidget {
  final LanguageRepoInterface languageRepo;

  const BottomToolBar({super.key, required this.languageRepo});

  @override
  State<BottomToolBar> createState() => _BottomToolBarState();
}

class _BottomToolBarState extends State<BottomToolBar> {
  late final BottomToolBarVMInterface _vm = BottomToolBarVM(
    widget.languageRepo,
  );
  Timer? _timer;

  void _setUpTimer(Duration duration) {
    _timer?.cancel();
    _timer = null;

    _timer = Timer(duration, () {
      EventService.instance.onEvent.add(Event(type: EventType.idle));

      _timer = null;
    });
  }

  Widget _buildLanguageSelection() {
    return FutureBuilder(
      future: _vm.getSupportedLanguages(),
      builder: (c, f) {
        final data = f.data;

        if (data == null) return Container();

        return ValueListenableBuilder(
          valueListenable: _vm.selectedLanguage,
          builder: (_, value, __) {
            return InkWell(
              onTap: () {
                print('on language select');

                CommandPalette.showOption<SupportedLanguage>(
                  context: context,
                  items: data.values.toList(),
                  itemBuilder: (context, item) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  onSelected: (item) {
                    debugPrint('Selected: $item');
                    _vm.selectLanguage(language: item);
                  },
                  hintText: 'Select a language…',
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value?.name ?? '',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: EventService.instance.onEvent.stream,
      builder: (c, s) {
        final data = s.data;

        if (data == null) {
          return Container(
            height: 20,
            width: double.infinity,
            color: AppColor.mainGrey,
          );
        }

        final duration = data.duration;
        if (duration != null) {
          _setUpTimer(duration);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          height: 20,
          width: double.infinity,
          color: data.type.color,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  curve: Curves.linear,
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.normal,
                  ),
                  duration: const Duration(milliseconds: 100),
                  child: Text(data.title ?? ''),
                ),
              ),
              const Spacer(),
              _buildLanguageSelection(),
            ],
          ),
        );
      },
    );
  }
}
