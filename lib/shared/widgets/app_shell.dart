import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_destinations.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_drawer.dart';

/// Window-size breakpoints (Material 3 window classes).
class AppBreakpoints {
  AppBreakpoints._();

  /// From here the sidebar is permanent instead of a modal drawer.
  static const double sidebar = 840;

  /// From here the sidebar is a little wider.
  static const double wide = 1200;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= sidebar;
}

/// Max content widths by page type, so text lines and rows stay readable on
/// wide windows instead of stretching edge to edge.
class AppContentWidth {
  AppContentWidth._();
  static const double list = 880;
  static const double detail = 760;
  static const double form = 720;
  static const double dashboard = 1200;
}

/// Lets pages inside the shell open the navigation and know whether the
/// sidebar is visible (pages hide their menu button when it is).
class AppShellScope extends InheritedWidget {
  final bool sidebarVisible;
  final VoidCallback openNavigation;

  const AppShellScope({
    super.key,
    required this.sidebarVisible,
    required this.openNavigation,
    required super.child,
  });

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope old) =>
      old.sidebarVisible != sidebarVisible;
}

/// The frame around every signed-in screen.
///
///   width < 840   Scaffold(drawer: AppDrawer) + page   (phones, unchanged)
///   width ≥ 840   Row[ AppSidebar(248 | 264 | 72 rail), page ]
///
/// Pages keep their own Scaffold and header; they no longer build a drawer.
class AppShell extends ConsumerStatefulWidget {
  final String location;
  final Widget child;

  const AppShell({super.key, required this.location, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// The user's home: Dashboard for most roles, else their first allowed screen.
  String get _home => homeFor(ref.read(authNotifierProvider).user);

  bool get _onHome {
    final current = destinationFor(widget.location)?.route;
    return current == null || current == _home;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final sidebarVisible = width >= AppBreakpoints.sidebar;

      final page = AppShellScope(
        sidebarVisible: sidebarVisible,
        openNavigation: () => _scaffoldKey.currentState?.openDrawer(),
        child: widget.child,
      );

      final body = sidebarVisible
          ? Row(
              children: [
                AppSidebar(
                  location: widget.location,
                  width: width >= AppBreakpoints.wide ? 264 : 248,
                ),
                Expanded(child: page),
              ],
            )
          : page;

      // Android Back on a top-level screen other than home goes home
      // instead of closing the app.
      return PopScope(
        canPop: _onHome,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final drawerOpen = _scaffoldKey.currentState?.isDrawerOpen ?? false;
          if (drawerOpen) {
            _scaffoldKey.currentState?.closeDrawer();
            return;
          }
          context.go(_home);
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.canvas,
          drawer:
              sidebarVisible ? null : AppDrawer(location: widget.location),
          body: body,
        ),
      );
    });
  }
}

/// Centres a page body and caps its width (see [AppContentWidth]).
class AppContentFrame extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const AppContentFrame({
    super.key,
    required this.maxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
