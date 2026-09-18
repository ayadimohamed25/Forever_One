import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/user_provider.dart';
import '../widgets/user_form_dialog.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  /// Turns a backend error code into a message the user understands.
  String _translateError(String code, AppLocalizations l10n) {
    switch (code) {
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      case 'INVALID_EMAIL':
        return l10n.invalidEmail;
      case 'PASSWORD_TOO_SHORT':
        return l10n.passwordTooShort;
      case 'LAST_ADMIN':
        return l10n.lastAdmin;
      case 'CANNOT_DELETE_SELF':
        return l10n.cannotDeleteSelf;
      case 'USER_HAS_ACTIVITY':
        return l10n.userHasActivity;
      case 'FORBIDDEN':
        return l10n.forbidden;
      default:
        return code;
    }
  }

  Future<void> _create(AppLocalizations l10n) async {
    final input = await showUserFormDialog(context);
    if (input == null) return;

    final error = await ref.read(userListProvider.notifier).add(input);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.userCreated);
    } else {
      _showSnack(_translateError(error, l10n), isError: true);
    }
  }

  Future<void> _edit(UserEntity u, AppLocalizations l10n) async {
    final input = await showUserFormDialog(context, existing: u);
    if (input == null) return;

    final error = await ref.read(userListProvider.notifier).update(u.id, input);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.userUpdated);
    } else {
      _showSnack(_translateError(error, l10n), isError: true);
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
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
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
      _showSnack(_translateError(error, l10n), isError: true);
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
      _showSnack(_translateError(error, l10n), isError: true);
    }
  }

  String _lastLoginLabel(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.neverLoggedIn;
    return '${l10n.lastLogin}: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(userListProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(_translateError(next.error!, l10n), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/users'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: searchVisible
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchUsers,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (v) => ref.read(userListProvider.notifier).search(v),
        )
            : Text(l10n.users),
        actions: [
          IconButton(
            icon: Icon(searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => searchVisible = !searchVisible);
              if (!searchVisible) {
                searchController.clear();
                ref.read(userListProvider.notifier).clearSearch();
              }
            },
          ),
          if (!searchVisible)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(userListProvider.notifier).load(),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.users.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.group_outlined,
        title: state.hasSearched ? l10n.noResults : l10n.noUsers,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
        color: AppColors.primary,
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(userListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final u = state.users[index];
            final color = roleColor(u.role);

            return Opacity(
              opacity: u.isActive ? 1 : 0.55,
              child: AppCard(
                onTap: () => _edit(u, l10n),
                padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppInitialsBadge(
                            name: u.displayName, color: color),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(u.displayName,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(u.email,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color:
                                      AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              size: 19,
                              color: AppColors.textSecondary),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _edit(u, l10n);
                            } else if (value == 'password') {
                              _resetPassword(u, l10n);
                            } else if (value == 'delete') {
                              _delete(u, l10n);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                const Icon(Icons.edit_outlined,
                                    size: 18),
                                const SizedBox(width: 10),
                                Text(l10n.edit),
                              ]),
                            ),
                            PopupMenuItem(
                              value: 'password',
                              child: Row(children: [
                                const Icon(Icons.key_outlined,
                                    size: 18),
                                const SizedBox(width: 10),
                                Text(l10n.resetPassword),
                              ]),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                const Icon(Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.danger),
                                const SizedBox(width: 10),
                                Text(l10n.delete,
                                    style: const TextStyle(
                                        color: AppColors.danger)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              gradient:
                              AppColors.tintGradient(color),
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                  color: color.withValues(
                                      alpha: 0.22)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(roleIcon(u.role),
                                    size: 12, color: color),
                                const SizedBox(width: 5),
                                Text(roleLabel(u.role, l10n),
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: color)),
                              ],
                            ),
                          ),
                          if (!u.isActive) ...[
                            const SizedBox(width: 6),
                            AppStatusChip(
                                label: l10n.inactive,
                                color: AppColors.textSecondary),
                          ],
                          const Spacer(),
                          Text(_lastLoginLabel(u.lastLoginAt, l10n),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.user),
      ),
    );
  }
}