import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/local_storage.dart';
import 'route_paths.dart';

/// Route guard for authentication and authorization
class RouteGuard {
  final LocalStorage localStorage;

  RouteGuard(this.localStorage);

  /// Check if user is authenticated
  bool isAuthenticated() {
    // TODO: Implement proper authentication check
    // For now, check if login credentials exist
    final username = localStorage.getString('username');
    final password = localStorage.getString('password');
    return username != null && password != null;
  }

  /// Check if first time setup is complete
  bool isFirstTimeComplete() {
    return !localStorage.isFirstTime();
  }

  /// Redirect for authentication guard
  String? authGuard(BuildContext context, GoRouterState state) {
    final isAuth = isAuthenticated();
    final isLoginRoute = state.uri.path == RoutePaths.login;

    // If not authenticated and not on login page, redirect to login
    if (!isAuth && !isLoginRoute) {
      return RoutePaths.login;
    }

    // If authenticated and on login page, redirect to home
    if (isAuth && isLoginRoute) {
      return RoutePaths.home;
    }

    return null;
  }

  /// Redirect for first time setup guard
  String? firstTimeGuard(BuildContext context, GoRouterState state) {
    final isComplete = isFirstTimeComplete();
    final isFirstTimeRoute = state.uri.path == RoutePaths.firstTime;

    // If first time not complete and not on first time page, redirect
    if (!isComplete && !isFirstTimeRoute) {
      return RoutePaths.firstTime;
    }

    // If first time complete and on first time page, redirect to home
    if (isComplete && isFirstTimeRoute) {
      return RoutePaths.home;
    }

    return null;
  }

  /// Combined redirect guard
  String? combinedGuard(BuildContext context, GoRouterState state) {
    // Check first time setup first
    final firstTimeRedirect = firstTimeGuard(context, state);
    if (firstTimeRedirect != null) {
      return firstTimeRedirect;
    }

    // Then check authentication (optional for now)
    // Uncomment when authentication is implemented
    // final authRedirect = authGuard(context, state);
    // if (authRedirect != null) {
    //   return authRedirect;
    // }

    return null;
  }
}
