import 'dart:async';

import 'package:dartpad_lite/UI/common/Animations%20/ai_mode_animation.dart';
import 'package:dartpad_lite/UI/common/system_info/system_info_view.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ai_state.dart';
import 'package:dartpad_lite/UI/editor/ai_helper/ui/think_animation_view.dart';
import 'package:dartpad_lite/UI/tool_bar/bottom_tool_bar/tool_bar_container.dart';
import 'package:dartpad_lite/UI/tool_bar/bottom_tool_bar/tool_bar_vm.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/services/event_service/event_service.dart';
import '../../../core/storage/language_repo.dart';
import '../../../core/storage/supported_language.dart';
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
  final ValueNotifier<Event?> _onEvent = ValueNotifier(null);
  final ValueNotifier<bool> _aiMode = ValueNotifier(false);
  final ValueNotifier<AIState> _aiState = ValueNotifier(AIState.idle);

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    EventService.instance.stream.where((e) => e.status != null).listen((event) {
      _onEvent.value = event;
    });

    EventService.instance.stream
        .where((e) => e.type == EventType.aiModeChanged)
        .listen((event) {
          _aiMode.value = event.data;
        });

    EventService.instance.stream
        .where((e) => e.type == EventType.aiStateChanged)
        .listen((event) {
          _aiState.value = event.data;
        });
  }

  void _setUpTimer(Duration duration) {
    _timer?.cancel();
    _timer = null;

    _timer = Timer(duration, () {
      _onEvent.value = Event(status: StatusEvent.idle());

      _timer?.cancel();
      _timer = null;
    });
  }

  Widget _buildLanguageSelection() {
    return FutureBuilder(
      future: _vm.getSupportedLanguages(),
      builder: (c, f) {
        final data = f.data;

        if (data == null) return Container();

        return Tooltip(
          message: 'Change language',
          child: ValueListenableBuilder(
            valueListenable: _vm.selectedLanguage,
            builder: (_, value, __) {
              return InkWell(
                onTap: () {
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
                      _vm.selectLanguage(language: item);
                    },
                    hintText: 'Select a language…',
                  );
                },
                child: Row(
                  spacing: 5,
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
          ),
        );
      },
    );
  }

  Widget _buildAI() {
    return ValueListenableBuilder(
      valueListenable: _aiState,
      builder: (_, state, __) {
        final Widget stateWidget;

        switch (state) {
          case AIState.thinking:
            stateWidget = ThinkingText(
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            );
          default:
            stateWidget = Text(
              'AI Boost',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            );
        }

        return Tooltip(
          message: _vm.aiProviderInfo.name,
          child: Row(
            spacing: 10,
            children: [
              SystemInfoView(),
              const SizedBox(width: 5),
              stateWidget,
              AIModeAnimation(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _onEvent,
      builder: (_, event, __) {
        final data = event;

        if (data == null) {
          return Container(
            height: 20,
            width: double.infinity,
            color: AppColor.mainGrey,
          );
        }

        return ValueListenableBuilder(
          valueListenable: _aiMode,
          builder: (_, aiMode, __) {
            final status = data.status;

            Color color = (aiMode ? AppColor.aiBlue : AppColor.mainGrey);

            if (status != null && status.type != StatusType.idle) {
              color = status.type.color;
            }

            final duration = data.status!.duration;
            if (duration != null) {
              _setUpTimer(duration);
            }

            return ToolBarContainer(
              pulsing: aiMode,
              mainColor: AppColor.mainGrey,
              pulsingStart: AppColor.aiBlue,
              pulsingEnd: AppColor.blue,
              overrideColor: color,
              overrideDuration: status?.duration,
              child: Row(
                spacing: 15,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.linear,
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.normal,
                      ),
                      duration: const Duration(milliseconds: 100),
                      child: Text(data.status?.msg ?? ''),
                    ),
                  ),
                  const Spacer(),
                  if (aiMode) _buildAI(),
                  _buildLanguageSelection(),
                  const SizedBox(width: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
