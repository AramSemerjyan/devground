import 'package:dartpad_lite/services/monaco_bridge_service/monaco_bridge_service.dart';
import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  String? currentRoute;

  AppRouteObserver({required this.monacoWebBridgeService});

  @override
  void didPush(Route route, Route? previousRoute) async {
    currentRoute = route.settings.name;
    await monacoWebBridgeService.dropFocus();

    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }
}
