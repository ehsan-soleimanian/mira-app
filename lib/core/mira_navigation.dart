import 'package:flutter/material.dart';

/// Fast fade — feels like the same surface, not a new app screen.
Route<T> miraRoute<T>(WidgetBuilder builder) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: const Duration(milliseconds: 120),
    reverseTransitionDuration: const Duration(milliseconds: 100),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

extension MiraNavigator on NavigatorState {
  Future<T?> pushMira<T extends Object?>(WidgetBuilder builder) =>
      push<T>(miraRoute<T>(builder));
}

/// Global Material page transitions (Android back gesture, etc.).
class MiraPageTransitionsBuilder extends PageTransitionsBuilder {
  const MiraPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(opacity: curved, child: child);
  }
}
