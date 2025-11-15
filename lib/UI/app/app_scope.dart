import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:flutter/material.dart';

import 'app_page_vm.dart';
import 'app_route_observer.dart';

class AppPageScope extends InheritedWidget {
  final AppPageVM vm;
  final AppRouteObserver observer;
  final PagesServiceInterface pagesService;
  final GlobalKey<NavigatorState> navigatorKey;

  const AppPageScope({
    required this.vm,
    required this.navigatorKey,
    required this.observer,
    required this.pagesService,
    required super.child,
    super.key,
  });

  static AppPageScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppPageScope>();
    assert(scope != null, 'No AppPageScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppPageScope oldWidget) =>
      vm != oldWidget.vm || navigatorKey != oldWidget.navigatorKey;
}
