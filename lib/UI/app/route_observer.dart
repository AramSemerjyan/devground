import 'package:flutter/material.dart';

import '../../core/services/monaco_bridge_service/monaco_bridge_service.dart';

class AppRouteObserver extends NavigatorObserver {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  final List<Route<dynamic>> _routeStack = [];

  AppRouteObserver({required this.monacoWebBridgeService});

  String? get currentRoute =>
      _routeStack.isNotEmpty ? _routeStack.last.settings.name : null;

  bool containsRoute(String routeName) {
    return _routeStack.any((route) => route.settings.name == routeName);
  }

  @override
  void didPush(Route route, Route? previousRoute) async {
    _routeStack.add(route);
    await monacoWebBridgeService.dropFocus();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _routeStack.remove(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _routeStack.remove(route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) _routeStack.remove(oldRoute);
    if (newRoute != null) _routeStack.add(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
