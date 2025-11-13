import 'dart:io';

import 'package:dartpad_lite/UI/app/app_page_vm.dart';
import 'package:dartpad_lite/UI/app/app_pages.dart';
import 'package:dartpad_lite/UI/app/app_route_observer.dart';
import 'package:dartpad_lite/UI/app/app_scope.dart';
import 'package:dartpad_lite/UI/command_palette/command_palette.dart';
import 'package:dartpad_lite/UI/editor/editor_page.dart';
import 'package:dartpad_lite/UI/history/history_page.dart';
import 'package:dartpad_lite/UI/settings/settings_page.dart';
import 'package:dartpad_lite/UI/tool_bar/side_bar/side_tool_bar.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../core/services/event_service.dart';
import '../tool_bar/bottom_tool_bar/bottom_tool_bar.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _observer = AppRouteObserver(
    monacoWebBridgeService: _vm.monacoWebBridgeService,
  );
  late final _vm = AppPageVM();

  @override
  void initState() {
    super.initState();

    _vm.setUp();
    WidgetsBinding.instance.addObserver(this);

    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) {
          if (_observer.currentRoute != AppPages.editor.value) {
            _navigatorKey.currentState?.pushReplacementNamed(
              AppPages.editor.value,
            );
          }
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        EventService.event(type: EventType.monacoDropFocus);
        break;
      default:
    }
  }

  Widget _buildMain() {
    return Navigator(
      key: _navigatorKey,
      observers: [_observer],
      initialRoute: AppPages.editor.value,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'Editor':
            builder = (context) => EditorPage(
              fileService: _vm.fileService,
              importFileService: _vm.importFileService,
              languageRepo: _vm.languageRepo,
            );
            break;
          case 'Settings':
            builder = (context) => SettingsPage(languageRepo: _vm.languageRepo);
            break;
          case 'History':
            builder = (context) => HistoryPage(
              fileService: _vm.fileService,
              importFileService: _vm.importFileService,
            );
          default:
            builder = (context) => Container();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScope(
      vm: _vm,
      navigatorKey: _navigatorKey,
      observer: _observer,
      child: Scaffold(
        backgroundColor: AppColor.mainGrey,
        body: DropTarget(
          onDragEntered: (_) => CommandPalette.showFileImport(context),
          onDragExited: (details) => CommandPalette.hide(),
          onDragDone: (details) {
            CommandPalette.hide();

            for (final file in details.files) {
              if (file.path.isNotEmpty) {
                _vm.importFileService.importFile(file: File(file.path));
              }
            }
          },
          child: ValueListenableBuilder(
            valueListenable: _vm.inProgress,
            builder: (_, value, __) {
              if (value) {
                return Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SideToolBar(navigatorKey: _navigatorKey),
                        Container(
                          width: 1,
                          height: double.infinity,
                          color: Color(0xff2b2b2b),
                        ),
                        Expanded(child: _buildMain()),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Color(0xff2b2b2b),
                  ),
                  BottomToolBar(languageRepo: _vm.languageRepo),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
