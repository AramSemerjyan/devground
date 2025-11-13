import 'dart:async';

import 'package:dartpad_lite/UI/app/app_pages.dart';
import 'package:flutter/material.dart';

import '../../core/services/monaco_bridge_service/monaco_bridge_service.dart';

class AppRouteObserver extends NavigatorObserver {
  final MonacoWebBridgeServiceInterface monacoWebBridgeService;
  final List<Route<dynamic>> _routeStack = [];
  final StreamController<AppPages> _onRouteChange = StreamController();

  Stream<AppPages> get routeUpdated => _onRouteChange.stream;

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
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) _routeStack.remove(oldRoute);
    if (newRoute != null) _routeStack.add(newRoute);

    _onRouteChange.sink.add(AppPages.fromString(newRoute?.settings.name ?? ''));

    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
