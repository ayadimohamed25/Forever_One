import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'app_notification_bell.dart';
import 'app_pressable.dart';
import 'app_shell.dart';

/// Page header: a white bar with a bottom border. Menu button on the LEFT
/// (phones), title and optional grey subtitle, actions, and on main screens
/// the notification bell at the far right. Detail pages get a back arrow.
/// [icon] and [color] are accepted for compatibility but not drawn.
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> actions;
  final bool showMenuButton;

  /// The notification bell; on by default for main (menu) screens.
  final bool? showBell;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.actions = const [],
    this.showMenuButton = true,
    this.showBell,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shell = AppShellScope.maybeOf(context);
    // A main screen opened on top of another (Categories from Products)
    // shows Back instead of the menu, so the user can return.
    final pushed = ModalRoute.of(context)?.canPop ?? false;
    final menu = showMenuButton && !pushed;
    // With the permanent sidebar on screen there is nothing to open.
    final hideMenu = menu && (shell?.sidebarVisible ?? false);

    final bell = showBell ?? showMenuButton;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 63,
        child: Padding(
          padding: EdgeInsets.only(left: hideMenu ? 24 : 8, right: 8),
          child: Row(
            children: [
              if (hideMenu)
                const SizedBox.shrink()
              else if (menu)
                AppMenuButton(tooltip: l10n.openMenu)
              else
                AppIconButton(
                  icon: Icons.arrow_back,
                  tooltip: l10n.back,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              if (!hideMenu) const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: AppTheme.pageTitle,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: AppTheme.font(
                          size: 12,
                          height: 1.25,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...actions,
              if (bell) const AppNotificationBell(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "add" action of a list page as a floating button, on phones only.
/// From 840px the same action moves into the header ([AppHeaderAddButton]),
/// next to the content instead of floating far away in the window corner.
class AppAddFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AppAddFab({super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    if (AppShellScope.maybeOf(context)?.sidebarVisible ?? false) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.black,
      icon: const Icon(Icons.add),
      label: Text(label),
    );
  }
}

/// The "add" action in the page header, from 840px (see [AppAddFab]).
class AppHeaderAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AppHeaderAddButton(
      {super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    if (!(AppShellScope.maybeOf(context)?.sidebarVisible ?? false)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: AppTheme.font(size: 14, weight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Opens the navigation drawer of the surrounding [AppShell] (phones).
class AppMenuButton extends StatelessWidget {
  final String tooltip;
  const AppMenuButton({super.key, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.menu,
      tooltip: tooltip,
      onTap: () {
        final shell = AppShellScope.maybeOf(context);
        if (shell != null) {
          shell.openNavigation();
        } else {
          Scaffold.maybeOf(context)?.openDrawer();
        }
      },
    );
  }
}

/// A bare outline icon button — no chip, no fill. 48×48 hit area, a tooltip
/// that doubles as the screen-reader label, and a keyboard focus ring.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = AppPressable(
      onTap: onTap,
      semanticLabel: tooltip,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icon, size: 24, color: color ?? AppColors.icon),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Header action button.
class AppHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;

  const AppHeaderAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: AppIconButton(
        icon: icon,
        onTap: onTap,
        tooltip: tooltip,
        color: color == AppColors.accent ? AppColors.accent : null,
      ),
    );
  }
}

/// Search field that replaces the header while searching.
class AppSearchHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const AppSearchHeader({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 63,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.fieldBorder),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search,
                          size: 18, color: AppColors.iconMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: onChanged,
                          style: AppTheme.font(size: 14),
                          decoration: InputDecoration(
                            hintText: hint,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: AppTheme.font(
                                size: 14, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AppIconButton(
                icon: Icons.close,
                tooltip: AppLocalizations.of(context)!.close,
                onTap: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}