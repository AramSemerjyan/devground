import 'dart:async';

import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

class BottomToolBar extends StatefulWidget {
  const BottomToolBar({super.key});

  @override
  State<BottomToolBar> createState() => _BottomToolBarState();
}

class _BottomToolBarState extends State<BottomToolBar> {
  Timer? _timer;

  void _setUpTimer(Duration duration) {
    _timer?.cancel();
    _timer = null;

    _timer = Timer(duration, () {
      StatusEvent.instance.onEvent.add(Event(type: EventType.idle));

      _timer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: StatusEvent.instance.onEvent.stream,
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
              AnimatedDefaultTextStyle(
                curve: Curves.linear,
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.normal,
                ),
                duration: const Duration(milliseconds: 100),
                child: Text(data.title ?? ''),
              ),
              // Text(data.title ?? '', style: TextStyle(color: Colors.white54)),
              const Spacer(),
              InkWell(
                onTap: () {
                  print('on language select');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'dart',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
