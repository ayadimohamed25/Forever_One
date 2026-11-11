import '../../../../core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/user_provider.dart';
import '../widgets/user_form_route.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../../shared/widgets/app_data_table.dart';
import '../../../../core/errors/error_text.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userListProvider.notifier).load());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnack.show(context, message, error: isError);
  }

  /// Turns a backend error code into a message the user understands.

  Future<void> _create(AppLocalizations l10n) async {
    final input = await openUserForm(context);
    if (input == null) return;

    final error = await ref.read(userListProvider.notifier).add(input);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.userCreated);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  Future<void> _edit(UserEntity u, AppLocalizations l10n) async {
    final input = await openUserForm(context, existing: u);
    if (input == null) return;

    final error = await ref.read(userListProvider.notifier).update(u.id, input);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.userUpdated);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  Future<void> _resetPassword(UserEntity u, AppLocalizations l10n) async {
    final passwordController = TextEditingController();
    var obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.resetPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(u.email,
                  style: AppTheme.font(size: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              AppLabeledField(label: l10n.newPassword, child: TextField(
                controller: passwordController,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: obscure ? l10n.showPassword : l10n.hidePassword,
                    icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (passwordController.text.length < 8) return;
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final error = await ref
        .read(userListProvider.notifier)
        .resetPassword(u.id, passwordController.text);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.passwordReset);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  Future<void> _delete(UserEntity u, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(u.displayName)),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await ref.read(userListProvider.notifier).remove(u.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.userDeleted);
    } else {
      _showSnack(errorText(error, l10n), isError: true);
    }
  }

  List<AppTableColumn<UserEntity>> _columns(AppLocalizations l10n) => [
        AppTableColumn(
          label: l10n.user,
          flex: 4,
          sortValue: (u) => u.displayName.toLowerCase(),
          cell: (u) => Opacity(
            opacity: u.isActive ? 1 : 0.55,
            child: AppCellText(u.displayName, strong: true, sub: u.email),
          ),
        ),
        AppTableColumn(
          label: l10n.lastLogin,
          width: 112,
          showFrom: 760,
          sortValue: (u) => u.lastLoginAt ?? DateTime(1970),
          cell: (u) => AppCellText(
              u.lastLoginAt == null
                  ? l10n.neverLoggedIn
                  : formatDate(u.lastLoginAt!),
              color: AppColors.textSecondary),
        ),
        AppTableColumn(
          label: l10n.role,
          width: 112,
          sortValue: (u) => roleLabel(u.role, l10n),
          cell: (u) => AppBadge(label: roleLabel(u.role, l10n), tone: roleTone(u.role)),
        ),
        AppTableColumn(
          label: l10n.status,
          width: 84,
          showFrom: 520,
          sortValue: (u) => u.isActive ? 0 : 1,
          cell: (u) => u.isActive
              ? AppBadge(label: l10n.active, tone: BadgeTone.success)
              : AppBadge(label: l10n.inactive, tone: BadgeTone.neutral),
        ),
      ];

  Widget _rowMenu(UserEntity u, AppLocalizations l10n) => AppRowMenu(actions: [
        AppMenuAction(
            label: l10n.edit, icon: Icons.edit_outlined, onTap: () => _edit(u, l10n)),
        AppMenuAction(
            label: l10n.resetPassword,
            icon: Icons.key_outlined,
            onTap: () => _resetPassword(u, l10n)),
        AppMenuAction(
            label: l10n.delete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () => _delete(u, l10n)),
      ]);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(userListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(errorText(next.error!, l10n), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchUsers,
        onChanged: (v) => ref.read(userListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(userListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.users,
        subtitle: state.users.isEmpty
            ? null
            : '${state.users.length} · ${state.users.where((u) => u.isActive).length} ${l10n.active.toLowerCase()}',
        icon: Icons.group_rounded,
        color: AppColors.primary,
        actions: [
          AppHeaderAction(
            icon: Icons.search_rounded,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: l10n.refresh,
            onTap: () => ref.read(userListProvider.notifier).load(),
          ),
          AppHeaderAddButton(onPressed: () => _create(l10n), label: l10n.user),
        ],
      ),
      body: state.isLoading
          ? AppSkeletonList(semanticLabel: l10n.loading)
          : state.error != null && state.users.isEmpty
          ? AppErrorState(
              title: l10n.loadFailedTitle,
              message: l10n.serverUnreachable,
              retryLabel: l10n.retry,
              onRetry: () => ref.read(userListProvider.notifier).load(),
            )
          : state.users.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.group_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noUsers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : '',
          actionLabel: state.hasSearched ? null : l10n.user,
          onAction: () => _create(l10n),
        color: AppColors.primary,
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(userListProvider.notifier).load(),
        child: AppDataTable<UserEntity>(
          columns: _columns(l10n),
          rows: state.users,
          initialSortColumn: 0,
          onRowTap: (u) => _edit(u, l10n),
          rowMenu: (u) => _rowMenu(u, l10n),
        ),
      ),
      floatingActionButton: AppAddFab(onPressed: () => _create(l10n), label: l10n.user),
    );
  }
}