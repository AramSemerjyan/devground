import 'package:dartpad_lite/UI/app/app_page_vm.dart';
import 'package:dartpad_lite/UI/app/route_observer.dart';
import 'package:dartpad_lite/UI/editor/editor_page.dart';
import 'package:dartpad_lite/UI/history/history_page.dart';
import 'package:dartpad_lite/UI/settings/settings_page.dart';
import 'package:dartpad_lite/UI/tool_bar/side_tool_bar.dart';
import 'package:flutter/material.dart';

import '../tool_bar/bottom_tool_bar/bottom_tool_bar.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _observer = AppRouteObserver();
  late final _vm = AppPageVM();

  @override
  void initState() {
    super.initState();

    _vm.setUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Side bar
                SideToolBar(navigatorKey: _navigatorKey),

                Container(
                  width: 1,
                  height: double.infinity,
                  color: Color(0xff2b2b2b),
                ),

                Expanded(
                  child: Navigator(
                    key: _navigatorKey,
                    observers: [_observer],
                    initialRoute: 'editor',
                    onGenerateRoute: (RouteSettings settings) {
                      WidgetBuilder builder;
                      switch (settings.name) {
                        case 'editor':
                          builder = (context) => EditorPage(
                            compiler: _vm.compiler,
                            saveFileService: _vm.fileService,
                          );
                          break;
                        case 'settings':
                          builder = (context) =>
                              SettingsPage(languageRepo: _vm.languageRepo);
                          break;
                        case 'history':
                          builder = (context) =>
                              HistoryPage(fileService: _vm.fileService);
                        default:
                          builder = (context) => EditorPage(
                            compiler: _vm.compiler,
                            saveFileService: _vm.fileService,
                          );
                      }
                      return MaterialPageRoute(
                        builder: builder,
                        settings: settings,
                      );
                    },
                  ),
                ),
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
      ),
    );
  }
}
