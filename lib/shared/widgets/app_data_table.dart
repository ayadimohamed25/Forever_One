import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'app_pressable.dart';

/// One column of an [AppDataTable].
class AppTableColumn<T> {
  final String label;

  /// Relative width among flexible columns (ignored when [width] is set).
  final int flex;

  /// Fixed width in logical pixels.
  final double? width;

  /// Right-aligned (amounts, quantities).
  final bool numeric;

  /// Only shown when the table is at least this wide (0 = always).
  /// Phones get the essential columns; tablets and the web get the rest.
  final double showFrom;

  final Widget Function(T row) cell;

  /// Tapping the title sorts by this value; null = not sortable.
  final Comparable<Object?> Function(T row)? sortValue;

  const AppTableColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.width,
    this.numeric = false,
    this.showFrom = 0,
    this.sortValue,
  });
}

/// The shared list table: one white bordered container, a header row of
/// column titles, then compact one-line rows (about 58px) separated by thin
/// dividers. Tap a title to sort, tap a row to open it; the ⋮ menu stays for
/// edit/delete. Long text is ellipsized, never wrapped. Scrolls itself, so it
/// can be the child of a RefreshIndicator.
class AppDataTable<T> extends StatefulWidget {
  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final void Function(T row)? onRowTap;
  final Widget Function(T row)? rowMenu;

  /// Initially sorted column (index into [columns]) and direction.
  final int? initialSortColumn;
  final bool initialAscending;

  /// Widgets shown above the table inside the same scroll view (filters).
  final List<Widget> header;

  /// Extra bottom padding (so a floating button doesn't cover the last row).
  final double bottomPadding;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.rowMenu,
    this.initialSortColumn,
    this.initialAscending = true,
    this.header = const [],
    this.bottomPadding = 88,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumn;
  bool _ascending = true;

  static const double _menuWidth = 40;
  static const double _hPad = 14;

  @override
  void initState() {
    super.initState();
    _sortColumn = widget.initialSortColumn;
    _ascending = widget.initialAscending;
  }

  List<T> _sorted() {
    final col = _sortColumn;
    if (col == null || col >= widget.columns.length) return widget.rows;
    final key = widget.columns[col].sortValue;
    if (key == null) return widget.rows;
    final list = [...widget.rows];
    list.sort((a, b) {
      final r = Comparable.compare(key(a), key(b));
      return _ascending ? r : -r;
    });
    return list;
  }

  void _toggleSort(int index) {
    setState(() {
      if (_sortColumn == index) {
        _ascending = !_ascending;
      } else {
        _sortColumn = index;
        _ascending = true;
      }
    });
  }

  Widget _cell(AppTableColumn<T> c, Widget child) {
    final aligned = Align(
      alignment: c.numeric ? Alignment.centerRight : Alignment.centerLeft,
      child: child,
    );
    return c.width != null
        ? SizedBox(width: c.width, child: aligned)
        : Expanded(flex: c.flex, child: aligned);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final visible = [
        for (var i = 0; i < widget.columns.length; i++)
          if (box.maxWidth >= widget.columns[i].showFrom) i,
      ];
      final rows = _sorted();
      final hasMenu = widget.rowMenu != null;

      Widget headerRow() => Container(
            height: 40,
            padding: EdgeInsets.only(left: _hPad, right: hasMenu ? 4 : _hPad),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border(
                top: BorderSide(color: AppColors.border),
                left: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
            ),
            child: Row(
              children: [
                for (final i in visible) ...[
                  if (i != visible.first) const SizedBox(width: 12),
                  _cell(
                    widget.columns[i],
                    _HeaderLabel(
                      label: widget.columns[i].label,
                      sortable: widget.columns[i].sortValue != null,
                      active: _sortColumn == i,
                      ascending: _ascending,
                      numeric: widget.columns[i].numeric,
                      onTap: widget.columns[i].sortValue == null
                          ? null
                          : () => _toggleSort(i),
                    ),
                  ),
                ],
                if (hasMenu) const SizedBox(width: _menuWidth),
              ],
            ),
          );

      Widget row(T item, bool last) {
        final content = Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: EdgeInsets.only(left: _hPad, right: hasMenu ? 4 : _hPad),
          child: Row(
            children: [
              for (final i in visible) ...[
                if (i != visible.first) const SizedBox(width: 12),
                _cell(widget.columns[i], widget.columns[i].cell(item)),
              ],
              if (hasMenu)
                SizedBox(width: _menuWidth, child: widget.rowMenu!(item)),
            ],
          ),
        );
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              left: const BorderSide(color: AppColors.border),
              right: const BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
            borderRadius: last
                ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card))
                : null,
          ),
          clipBehavior: last ? Clip.antiAlias : Clip.none,
          child: widget.onRowTap == null
              ? content
              : AppPressable(
                  onTap: () => widget.onRowTap!(item),
                  borderRadius: BorderRadius.zero,
                  hoverColor: AppColors.surfaceAlt,
                  child: content,
                ),
        );
      }

      final pad = box.maxWidth >= 840 ? 24.0 : AppSpacing.page;
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(pad, AppSpacing.gap, pad, widget.bottomPadding),
        itemCount: widget.header.length + 1 + rows.length,
        itemBuilder: (context, index) {
          if (index < widget.header.length) return widget.header[index];
          final i = index - widget.header.length;
          if (i == 0) return headerRow();
          return row(rows[i - 1], i == rows.length);
        },
      );
    });
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  final bool sortable;
  final bool active;
  final bool ascending;
  final bool numeric;
  final VoidCallback? onTap;

  const _HeaderLabel({
    required this.label,
    required this.sortable,
    required this.active,
    required this.ascending,
    required this.numeric,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.font(
          size: 12,
          weight: FontWeight.w500,
          color: active ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
    final arrow = Icon(
      active
          ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
          : Icons.unfold_more,
      size: 14,
      color: active ? AppColors.textPrimary : AppColors.textMuted,
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: numeric
          ? [if (sortable) arrow, if (sortable) const SizedBox(width: 2), text]
          : [text, if (sortable) const SizedBox(width: 2), if (sortable) arrow],
    );
    if (!sortable) return content;
    return Semantics(
      button: true,
      label: label,
      sortKey: null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      ),
    );
  }
}

/// A table cell's text: one line, ellipsized, with an optional small grey
/// line under it (category under a product, date under a customer).
class AppCellText extends StatelessWidget {
  final String text;
  final String? sub;
  final bool strong;
  final Color? color;
  final bool numeric;

  const AppCellText(
    this.text, {
    super.key,
    this.sub,
    this.strong = false,
    this.color,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    final main = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: numeric ? TextAlign.right : TextAlign.left,
      style: AppTheme.font(
        size: 14,
        weight: strong ? FontWeight.w500 : FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        tabularFigures: numeric,
      ),
    );
    if (sub == null || sub!.isEmpty) return main;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          numeric ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        main,
        const SizedBox(height: 2),
        Text(
          sub!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.font(size: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
