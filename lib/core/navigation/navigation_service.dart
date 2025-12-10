import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A service class that provides methods for navigating between screens in the app.
class NavigationService {
  /// Pops the top-most screen from the navigation stack and returns an optional response.
  static void pop([dynamic response]) {
    Modular.to.pop(response);
  }

  /// Pushes a new named route onto the navigation stack and returns a future that completes with a result value.
  static Future<T?> pushNamed<T extends Object>({
    required BuildContext context,
    dynamic arguments,
    required String route,
  }) async {
    final response = await Modular.to.pushNamed<T>(
      route,
      arguments: arguments,
    );

    return response;
  }

  /// Navigates to a new named route and optionally passes arguments to the new route.
  static void navigate<T extends Object>({
    required BuildContext context,
    dynamic arguments,
    required String route,
  }) {
    Modular.to.navigate(
      route,
      arguments: arguments,
    );
  }

  /// Replaces the current route with a new named route and returns a future that completes with a result value.
  static Future<T?> pushReplacementNamed<T extends Object>({
    required BuildContext context,
    dynamic arguments,
    required String route,
  }) async {
    final response = await Modular.to.pushReplacementNamed(
      route,
      arguments: arguments,
    );

    return response as T?;
  }

  /// Pops all routes until the named route is at the top of the stack.
  static void popUntil({
    required String route,
  }) async {
    Modular.to.popUntil(ModalRoute.withName(route));
  }
}
