import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_destinations.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import 'app_shell.dart';

/// The five main tabs (Home, Sales, Stock, Customers, More) as a bottom
/// navigation bar on phones. Each tab is a StatefulShellRoute branch,
/// so it keeps its state when you switch away and back. Tabs the user has no
/// permission for are left out. From 840px the sidebar does this job, so
/// the bar is hidden.
class AppTabsScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppTabsScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authNotifierProvider.select((s) => s.user));
    final sidebar = AppShellScope.maybeOf(context)?.sidebarVisible ??
        AppBreakpoints.isWide(context);

    // (branch index, icon, selected icon, label) for each permitted tab.
    final tabs = <(int, IconData, IconData, String)>[];
    const icons = [
      (Icons.home_outlined, Icons.home),
      (Icons.receipt_long_outlined, Icons.receipt_long),
      (Icons.inventory_2_outlined, Icons.inventory_2),
      (Icons.people_outline, Icons.people),
      (Icons.grid_view_outlined, Icons.grid_view_rounded),
    ];
    final labels = [
      l10n.tabHome,
      l10n.sales,
      l10n.tabStock,
      l10n.customers,
      l10n.moreShort,
    ];
    for (var i = 0; i < tabRoutes.length; i++) {
      // More has no destination entry: every signed-in user has it.
      final d = destinationFor(tabRoutes[i]);
      if (tabRoutes[i] == moreRoute || (d != null && d.allows(user))) {
        tabs.add((i, icons[i].$1, icons[i].$2, labels[i]));
      }
    }

    final current = tabs.indexWhere((t) => t.$1 == navigationShell.currentIndex);
    final showBar = !sidebar && tabs.length >= 2 && current >= 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: AppTabRootScope(active: showBar, child: navigationShell),
      bottomNavigationBar: showBar
          ? DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NavigationBar(
                selectedIndex: current,
                onDestinationSelected: (i) {
                  final branch = tabs[i].$1;
                  // Tapping the current tab again returns it to its root.
                  navigationShell.goBranch(
                    branch,
                    initialLocation: branch == navigationShell.currentIndex,
                  );
                },
                destinations: [
                  for (final t in tabs)
                    NavigationDestination(
                      icon: Icon(t.$2),
                      selectedIcon: Icon(t.$3),
                      label: t.$4,
                      tooltip: t.$4,
                    ),
                ],
              ),
            )
          : null,
    );
  }
}
