import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../providers/warehouse_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage> {
  String? _subtitle(WarehouseListState state, AppLocalizations l10n) {
    if (state.warehouses.isEmpty) return null;
    final value =
    state.warehouses.fold<double>(0, (sum, w) => sum + w.stockValue);
    return '${state.warehouses.length} · ${value.toStringAsFixed(0)} DT ${l10n.stockValue.toLowerCase()}';
  }
  final searchController = TextEditingController();
  bool searchVisible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(warehouseListProvider.notifier).load());
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

  Future<void> _openForm({WarehouseEntity? existing}) async {
    final l10n = AppLocalizations.of(context)!;

    final codeController = TextEditingController(text: existing?.code ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final locationController =
    TextEditingController(text: existing?.location ?? '');
    final addressController =
    TextEditingController(text: existing?.address ?? '');
    final managerController =
    TextEditingController(text: existing?.managerName ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    var isActive = existing?.isActive ?? true;

    final input = await showDialog<WarehouseInput>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:
          Text(existing == null ? l10n.newWarehouse : l10n.editWarehouse),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: codeController,
                          decoration: InputDecoration(labelText: l10n.code),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: nameController,
                          autofocus: existing == null,
                          decoration: InputDecoration(labelText: l10n.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: l10n.location,
                      prefixIcon: const Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.address),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: managerController,
                    decoration: InputDecoration(
                      labelText: l10n.manager,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.notes),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isActive,
                    title: Text(l10n.warehouseActive,
                        style: const TextStyle(fontSize: 13.5)),
                    onChanged: (v) => setState(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                String? orNull(TextEditingController c) =>
                    c.text.trim().isEmpty ? null : c.text.trim();

                Navigator.of(context).pop(WarehouseInput(
                  code: orNull(codeController),
                  name: nameController.text.trim(),
                  location: orNull(locationController),
                  address: orNull(addressController),
                  managerName: orNull(managerController),
                  phone: orNull(phoneController),
                  isActive: isActive,
                  notes: orNull(notesController),
                ));
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (input == null) return;

    if (existing == null) {
      await ref.read(warehouseListProvider.notifier).add(input);
    } else {
      await ref.read(warehouseListProvider.notifier).update(existing.id, input);
      if (mounted) _showSnack(l10n.warehouseUpdated);
    }
  }

  Future<void> _delete(WarehouseEntity w, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle(w.name)),
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

    final error = await ref.read(warehouseListProvider.notifier).remove(w.id);
    if (!mounted) return;

    if (error == null) {
      _showSnack(l10n.warehouseDeleted);
    } else if (error == 'WAREHOUSE_IN_USE') {
      _showSnack(l10n.warehouseInUse, isError: true);
    } else {
      _showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseListProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(warehouseListProvider, (previous, next) {
      if (next.error != null) _showSnack(next.error!, isError: true);
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/warehouses'),
      appBar: searchVisible
          ? AppSearchHeader(
        controller: searchController,
        hint: l10n.searchWarehouses,
        onChanged: (v) =>
            ref.read(warehouseListProvider.notifier).search(v),
        onClose: () {
          setState(() => searchVisible = false);
          searchController.clear();
          ref.read(warehouseListProvider.notifier).clearSearch();
        },
      )
          : AppPageHeader(
        title: l10n.warehouses,
        subtitle: _subtitle(state, l10n),
        icon: Icons.warehouse_rounded,
        color: AppColors.stock,
        actions: [
          AppHeaderAction(
            icon: Icons.search_rounded,
            tooltip: l10n.search,
            onTap: () => setState(() => searchVisible = true),
          ),
          AppHeaderAction(
            icon: Icons.refresh_rounded,
            tooltip: l10n.refresh,
            onTap: () => ref.read(warehouseListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.warehouses.isEmpty
          ? AppEmptyState(
        icon: state.hasSearched
            ? Icons.search_off
            : Icons.warehouse_outlined,
        title:
        state.hasSearched ? l10n.noResults : l10n.noWarehouses,
        subtitle: state.hasSearched
            ? l10n.tryDifferentSearch
            : l10n.tapPlusToAdd,
        color: AppColors.stock,
      )
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(warehouseListProvider.notifier).load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: state.warehouses.length,
          itemBuilder: (context, index) {
            final w = state.warehouses[index];

            return Opacity(
              opacity: w.isActive ? 1 : 0.55,
              child: AppCard(
                onTap: () => _openForm(existing: w),
                padding: const EdgeInsets.fromLTRB(14, 14, 4, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppIconBadge(
                            icon: Icons.warehouse_outlined,
                            color: AppColors.stock),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(w.name,
                                        style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: AppColors
                                                .textPrimary),
                                        overflow:
                                        TextOverflow.ellipsis),
                                  ),
                                  if (!w.isActive) ...[
                                    const SizedBox(width: 6),
                                    AppStatusChip(
                                        label: l10n.inactive,
                                        color:
                                        AppColors.textSecondary),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppMetaRow(items: [
                                if (w.code != null)
                                  (icon: Icons.tag, text: w.code!),
                                if (w.location != null)
                                  (
                                  icon: Icons.place_outlined,
                                  text: w.location!
                                  ),
                                if (w.managerName != null)
                                  (
                                  icon: Icons.person_outline,
                                  text: w.managerName!
                                  ),
                              ]),
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
                              _openForm(existing: w);
                            } else if (value == 'delete') {
                              _delete(w, l10n);
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
                          Expanded(
                            child: _stat(l10n.totalUnits,
                                '${w.totalUnits}', AppColors.stock),
                          ),
                          Expanded(
                            child: _stat(
                                l10n.distinctProducts,
                                '${w.productCount}',
                                AppColors.primary),
                          ),
                          Expanded(
                            child: _stat(
                                l10n.stockValue,
                                '${w.stockValue.toStringAsFixed(0)} DT',
                                AppColors.sales),
                          ),
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
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.warehouse),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 1),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}