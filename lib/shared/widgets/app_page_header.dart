import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Page header: leading control, title, optional gray subtitle, actions.
/// [icon] and [color] are accepted for compatibility but not drawn.
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> actions;
  final bool showMenuButton;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.actions = const [],
    this.showMenuButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 76,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (showMenuButton)
                Builder(
                  builder: (context) => AppIconButton(
                    icon: Icons.menu,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              else
                AppIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              const SizedBox(width: 8),
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
                      style: AppTheme.font(
                        size: 20,
                        weight: FontWeight.w600,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: AppTheme.font(
                          size: 13,
                          height: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// A bare outline icon button — no chip, no fill.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 24, color: color ?? AppColors.icon),
        ),
      ),
    );
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
      child: Tooltip(
        message: tooltip ?? '',
        child: AppIconButton(
          icon: icon,
          onTap: onTap,
          color: color == AppColors.accent ? AppColors.accent : null,
        ),
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
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 76,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search,
                          size: 20, color: AppColors.iconMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: onChanged,
                          style: AppTheme.font(size: 15),
                          decoration: InputDecoration(
                            hintText: hint,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: AppTheme.font(
                                size: 15, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AppIconButton(icon: Icons.close, onTap: onClose),
            ],
          ),
        ),
      ),
    );
  }
}