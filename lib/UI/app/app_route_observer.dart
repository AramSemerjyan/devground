import 'dart:async';

import 'package:dartpad_lite/UI/app/app_pages.dart';
import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routeStack = [];
  final StreamController<AppPages> _onRouteChange = StreamController();

  Stream<AppPages> get routeUpdated => _onRouteChange.stream;

  String? get currentRoute =>
      _routeStack.isNotEmpty ? _routeStack.last.settings.name : null;

  bool containsRoute(String routeName) {
    return _routeStack.any((route) => route.settings.name == routeName);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _onRouteChange.sink.add(
      AppPages.fromString(previousRoute?.settings.name ?? ''),
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) async {
    _routeStack.add(route);
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
