import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../l10n/app_localizations.dart';
import 'app_page_header.dart';

/// The bell at the top-right of main screens, with a red count of active
/// alerts. Opens the Notifications screen.
class AppNotificationBell extends ConsumerWidget {
  const AppNotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final count = ref.watch(notificationProvider.select((s) => s.count));
    final label = count > 0
        ? '${l10n.notifications}, ${l10n.alertsBanner(count)}'
        : l10n.notifications;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: Icons.notifications_none_outlined,
          tooltip: label,
          onTap: () => openNotifications(context),
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 4,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: AppTheme.font(
                      size: 11, weight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
