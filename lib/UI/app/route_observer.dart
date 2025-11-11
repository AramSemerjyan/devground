import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  String? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }
}
