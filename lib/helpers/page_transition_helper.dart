import 'package:flutter/material.dart';

/// 平滑的页面过渡动画
/// 新页面从右侧滑入，背景页面向左移动并降低亮度
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String? routeName;

  SlidePageRoute({
    required this.page,
    this.routeName,
  }) : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 350),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 使用丝滑的easeOutCubic曲线
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 新页面从右侧滑入
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}

/// 使用平滑过渡动画跳转页面
Future<T?> navigateWithSlideTransition<T>(
  BuildContext context,
  Widget page, {
  String? routeName,
}) {
  return Navigator.of(context).push<T>(
    SlidePageRoute<T>(
      page: page,
      routeName: routeName,
    ),
  );
}
