import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'app_motion.dart';
import 'app_pressable.dart';
import 'app_shell.dart';

/// One column of an [AppDataTable].
///
/// Column order on every list: name first, then information columns, then
/// amounts, then Status, then the ⋮ menu.
class AppTableColumn<T> {
  final String label;

  /// The FIRST column (the name) is flexible and takes all remaining width.
  /// Other columns are sized to their content: give [measure] (the text the
  /// cell shows) and the table measures the widest value. Without [measure],
  /// [width] is used as a fixed width.
  final double? width;

  /// Upper bound for a measured column (long values are ellipsized).
  final double maxWidth;

  /// Right-aligned (amounts, quantities).
  final bool numeric;

  /// The cell is a status chip (measured with chip padding).
  final bool chip;

  /// Only shown when the table is at least this wide (0 = always).
  /// Phones get the essential columns; tablets and the web get the rest.
  final double showFrom;

  final Widget Function(T row) cell;

  /// The text a cell shows, used to size the column to its content.
  final String Function(T row)? measure;

  /// Tapping the title sorts by this value; null = not sortable.
  final Comparable<Object?> Function(T row)? sortValue;

  /// Kept for older call sites: ignored, the first column always flexes.
  final int flex;

  const AppTableColumn({
    required this.label,
    required this.cell,
    this.width,
    this.maxWidth = 180,
    this.numeric = false,
    this.chip = false,
    this.showFrom = 0,
    this.measure,
    this.sortValue,
    this.flex = 1,
  });
}

/// A filter shown in the table toolbar (status, period…).
class AppTableFilter<T> {
  final String label;
  final List<AppFilterOption<T>> options;
  const AppTableFilter({required this.label, required this.options});
}

class AppFilterOption<T> {
  final String label;

  /// Null = "All" (keeps every row).
  final bool Function(T row)? test;
  const AppFilterOption(this.label, [this.test]);
}

/// One figure of the summary strip above a table (Invoiced, Paid, Unpaid…).
/// Tapping it selects tab [tab] when given.
class AppTableStat {
  final String label;
  final String value;
  final Color? color;
  final int? tab;
  const AppTableStat(
      {required this.label, required this.value, this.color, this.tab});
}

/// Width of the table currently laid out, readable by cells:
/// `AppTableWidth.of(context) >= 760` tells a cell whether a column with
/// `showFrom: 760` is visible (e.g. don't repeat the date under the name when
/// the Date column shows it).
class AppTableWidth extends InheritedWidget {
  final double width;
  const AppTableWidth({super.key, required this.width, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppTableWidth>()?.width ??
      MediaQuery.sizeOf(context).width;

  @override
  bool updateShouldNotify(AppTableWidth old) => old.width != width;
}

/// The shared list table.
///
/// - One white bordered container: header row of column titles, then compact
///   rows (58px; a long name wraps onto 2 lines before being cut).
/// - The name column takes all remaining width; other columns are as wide as
///   their content; the status chip sits right before the ⋮ menu.
/// - Tap a title to sort; tap anywhere on a row to open it; hover highlights.
/// - Wide screens (≥ 840px): content max 1200px centred, a toolbar (search,
///   filters, result count, add button) and pagination (25 per page).
/// - Phones: simple scrolling, with bottom room for the floating add button.
class AppDataTable<T> extends StatefulWidget {
  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final void Function(T row)? onRowTap;
  final Widget Function(T row)? rowMenu;

  final int? initialSortColumn;
  final bool initialAscending;

  /// Widgets shown above the table inside the same scroll view (filters).
  final List<Widget> header;

  /// Extra bottom padding on phones (room for the floating add button).
  final double bottomPadding;

  /// Toolbar (wide screens): search over this text, these filters, and an
  /// add button.
  final String Function(T row)? searchText;
  final String? searchHint;
  final List<AppTableFilter<T>> filters;
  final VoidCallback? onAdd;
  final String? addLabel;

  /// Rows per page on wide screens.
  final int pageSize;

  /// Status tabs with counts ("All 57 · Unpaid 11 · …"): underline tabs at
  /// the top of the table on wide screens, chips above the list on phones.
  /// They filter on every screen size.
  final AppTableFilter<T>? tabs;

  /// Figures shown above the table; tapping one selects its tab.
  final List<AppTableStat> summary;

  /// Wide screens: the selected row is highlighted and [detailPanel] is shown
  /// beside the table. The PAGE owns the selection; the table only lays it
  /// out. Phones ignore both and keep navigating to the detail page.
  final bool Function(T row)? isSelected;
  final Widget? detailPanel;

  /// Called when the selected row is no longer in the filtered rows (a tab or
  /// search hid it), so the page can close its panel.
  final VoidCallback? onSelectionHidden;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.rowMenu,
    this.initialSortColumn,
    this.initialAscending = true,
    this.header = const [],
    this.bottomPadding = 112,
    this.searchText,
    this.searchHint,
    this.filters = const [],
    this.onAdd,
    this.addLabel,
    this.pageSize = 25,
    this.tabs,
    this.summary = const [],
    this.isSelected,
    this.detailPanel,
    this.onSelectionHidden,
  });

  /// Width of the side panel on wide screens.
  static const double panelWidth = 380;

  /// Where the toolbar, pagination and 1200px cap kick in.
  static const double wideFrom = 840;
  static const double maxContentWidth = 1200;

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumn;
  bool _ascending = true;
  String _query = '';
  late List<int> _filterChoice;
  int _page = 0;
  int _tab = 0;
  final _scroll = ScrollController();

  void _selectTab(int i) => setState(() {
        _tab = i;
        _page = 0;
      });

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// A new page starts at its first row, not where the pager was.
  void _goToPage(int page) {
    setState(() => _page = page);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  static const double _menuWidth = 40;
  static const double _hPad = 14;
  static const double _gap = 12;

  @override
  void initState() {
    super.initState();
    _sortColumn = widget.initialSortColumn;
    _ascending = widget.initialAscending;
    _filterChoice = List.filled(widget.filters.length, 0);
  }

  @override
  void didUpdateWidget(covariant AppDataTable<T> old) {
    super.didUpdateWidget(old);
    if (old.filters.length != widget.filters.length) {
      _filterChoice = List.filled(widget.filters.length, 0);
    }
  }

  /// Rows matching the search and toolbar filters, before the tab: the base
  /// for the tab counts.
  Iterable<T> _searched(bool wide) {
    Iterable<T> rows = widget.rows;
    if (wide && _query.trim().isNotEmpty && widget.searchText != null) {
      final q = _query.trim().toLowerCase();
      rows = rows.where((r) => widget.searchText!(r).toLowerCase().contains(q));
    }
    return rows;
  }

  List<T> _visibleRows(bool wide) {
    Iterable<T> rows = _searched(wide);
    final tabs = widget.tabs;
    if (tabs != null && _tab < tabs.options.length) {
      final test = tabs.options[_tab].test;
      if (test != null) rows = rows.where(test);
    }
    if (wide) {
      for (var i = 0; i < widget.filters.length; i++) {
        final test = widget.filters[i].options[_filterChoice[i]].test;
        if (test != null) rows = rows.where(test);
      }
    }
    final list = rows.toList();
    final col = _sortColumn;
    if (col != null && col < widget.columns.length) {
      final key = widget.columns[col].sortValue;
      if (key != null) {
        list.sort((a, b) {
          final r = Comparable.compare(key(a), key(b));
          return _ascending ? r : -r;
        });
      }
    }
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

  // ── Content-sized columns ──

  double _textWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  /// Width of every non-first column: the widest of its header and its values.
  Map<int, double> _columnWidths(List<int> visible, List<T> rows) {
    final head = AppTheme.font(size: 12, weight: FontWeight.w500);
    final value = AppTheme.font(
      size: 14,
      weight: FontWeight.w600,
      tabularFigures: true,
    );
    final chip = AppTheme.font(size: 12, weight: FontWeight.w500);
    final widths = <int, double>{};
    for (final i in visible.skip(1)) {
      final c = widget.columns[i];
      if (c.measure == null) {
        widths[i] = c.width ?? 80;
        continue;
      }
      var w = _textWidth(c.label, head) + (c.sortValue != null ? 18 : 0);
      for (final r in rows) {
        final t = c.measure!(r);
        final tw = c.chip ? _textWidth(t, chip) + 30 : _textWidth(t, value);
        if (tw > w) w = tw;
      }
      widths[i] = (w + 2).clamp(32, c.maxWidth).toDouble();
    }
    return widths;
  }

  Widget _cell(AppTableColumn<T> c, Widget child, double? width) {
    final aligned = Align(
      alignment: c.numeric ? Alignment.centerRight : Alignment.centerLeft,
      child: child,
    );
    return width == null
        ? Expanded(child: aligned)
        : SizedBox(width: width, child: aligned);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, box) {
        // Wide follows the shell (sidebar shown = toolbar, no FAB), so the add
        // action is never missing; outside a shell (tests) the width decides.
        final wide =
            AppShellScope.maybeOf(context)?.sidebarVisible ??
            box.maxWidth >= AppDataTable.wideFrom;
        final pad = wide ? 24.0 : AppSpacing.page;
        final frameWidth = (box.maxWidth - 2 * pad)
            .clamp(0, AppDataTable.maxContentWidth)
            .toDouble();
        final sidePad = (box.maxWidth - frameWidth) / 2;
        // On wide screens an open detail panel takes its share of the frame.
        final panelOpen = wide && widget.detailPanel != null;
        final contentWidth = panelOpen
            ? (frameWidth - AppDataTable.panelWidth - 20).clamp(0, frameWidth).toDouble()
            : frameWidth;

        final visible = [
          for (var i = 0; i < widget.columns.length; i++)
            if (contentWidth >= widget.columns[i].showFrom) i,
        ];
        final all = _visibleRows(wide);
        final pageCount = wide ? ((all.length - 1) ~/ widget.pageSize) + 1 : 1;
        final page = _page.clamp(0, pageCount - 1);
        final rows = wide
            ? all.skip(page * widget.pageSize).take(widget.pageSize).toList()
            : all;
        final widths = _columnWidths(visible, rows.isEmpty ? all : rows);
        final hasMenu = widget.rowMenu != null;
        final isSelected = widget.isSelected;
        if (panelOpen &&
            isSelected != null &&
            widget.onSelectionHidden != null &&
            !all.any(isSelected)) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => widget.onSelectionHidden?.call());
        }
        final tabs = widget.tabs;
        final searched = tabs == null ? const [] : _searched(wide).toList();
        final tabCounts = [
          if (tabs != null)
            for (final o in tabs.options)
              o.test == null
                  ? searched.length
                  : searched.where((r) => o.test!(r as T)).length,
        ];
        final tabsOnTop = wide && tabs != null;

        Widget rowCells(Widget Function(int i) cellOf) => Row(
          children: [
            for (final i in visible) ...[
              if (i != visible.first) const SizedBox(width: _gap),
              _cell(
                widget.columns[i],
                cellOf(i),
                i == visible.first ? null : widths[i],
              ),
            ],
            if (hasMenu) const SizedBox(width: 4),
          ],
        );

        Widget headerRow() => Container(
          height: 40,
          padding: EdgeInsets.only(
            left: _hPad,
            right: hasMenu ? _menuWidth : _hPad,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: const Border.fromBorderSide(
                BorderSide(color: AppColors.border)),
            borderRadius: tabsOnTop
                ? null
                : const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card),
                  ),
          ),
          child: rowCells(
            (i) => _HeaderLabel(
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
        );

        Widget row(T item, bool last, int index) {
          final selected =
              panelOpen && isSelected != null && isSelected(item);
          final content = Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: EdgeInsets.only(left: _hPad, right: hasMenu ? 0 : _hPad),
            child: Row(
              children: [
                Expanded(child: rowCells((i) => widget.columns[i].cell(item))),
                if (hasMenu)
                  SizedBox(width: _menuWidth, child: widget.rowMenu!(item)),
              ],
            ),
          );
          final cell = Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.rowSelected : AppColors.surface,
              border: const Border(
                left: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
              borderRadius: last && !wide
                  ? const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadius.card),
                    )
                  : null,
            ),
            clipBehavior: last && !wide ? Clip.antiAlias : Clip.none,
            child: widget.onRowTap == null
                ? content
                : AppPressable(
                    onTap: () => widget.onRowTap!(item),
                    borderRadius: BorderRadius.zero,
                    selected: selected,
                    hoverColor: AppColors.surfaceAlt,
                    child: content,
                  ),
          );
          return AppEntrance(
            index: index,
            stagger: AppMotion.stagger,
            offset: 6,
            child: cell,
          );
        }

        final showToolbar =
            wide &&
            (widget.searchText != null ||
                widget.filters.isNotEmpty ||
                widget.onAdd != null);

        final items = <Widget>[
          ...widget.header,
          if (widget.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SummaryStrip(
                stats: widget.summary,
                compact: !wide,
                onTab: tabs == null ? null : _selectTab,
              ),
            ),
          if (showToolbar)
            _Toolbar(
              searchHint: widget.searchText == null ? null : widget.searchHint,
              onSearch: (v) => setState(() {
                _query = v;
                _page = 0;
              }),
              filters: widget.filters,
              choices: _filterChoice,
              onFilter: (f, o) => setState(() {
                _filterChoice[f] = o;
                _page = 0;
              }),
              countText: l10n.tableResults(all.length),
              onAdd: widget.onAdd,
              addLabel: widget.addLabel,
            ),
          if (tabs != null && !wide)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TabChips(
                labels: [for (final o in tabs.options) o.label],
                counts: tabCounts,
                selected: _tab,
                onSelect: _selectTab,
              ),
            ),
          if (tabsOnTop)
            _TabStrip(
              labels: [for (final o in tabs.options) o.label],
              counts: tabCounts,
              selected: _tab,
              onSelect: _selectTab,
            ),
          headerRow(),
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  left: BorderSide(color: AppColors.border),
                  right: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              alignment: Alignment.center,
              child: Text(l10n.tableResults(0), style: AppTheme.label),
            ),
          for (var i = 0; i < rows.length; i++)
            row(rows[i], i == rows.length - 1, i),
          if (wide)
            _Pagination(
              from: all.isEmpty ? 0 : page * widget.pageSize + 1,
              to: page * widget.pageSize + rows.length,
              total: all.length,
              onPrevious: page > 0
                  ? () => _goToPage(page - 1)
                  : null,
              onNext: page < pageCount - 1
                  ? () => _goToPage(page + 1)
                  : null,
            ),
        ];

        final list = AppTableWidth(
          width: contentWidth,
          child: ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              sidePad,
              AppSpacing.gap,
              panelOpen ? 10 : sidePad,
              wide ? 32 : widget.bottomPadding,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        );
        if (!panelOpen) return list;
        // Table and panel side by side inside the 1200px frame; each scrolls
        // on its own so the panel stays in view while the list moves.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: list),
            Padding(
              padding: EdgeInsets.fromLTRB(10, AppSpacing.gap, sidePad, 24),
              child: SizedBox(
                width: AppDataTable.panelWidth,
                child: _PanelEntrance(child: widget.detailPanel!),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Slides the detail panel in from the right when it first appears.
class _PanelEntrance extends StatelessWidget {
  final Widget child;
  const _PanelEntrance({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.medium),
      curve: AppMotion.curve,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
            offset: Offset(24 * (1 - t), 0), child: child),
      ),
    );
  }
}

/// Figures above the table in one bordered card; tapping one selects its tab.
class _SummaryStrip extends StatelessWidget {
  final List<AppTableStat> stats;
  final bool compact;
  final ValueChanged<int>? onTab;

  const _SummaryStrip(
      {required this.stats, required this.compact, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.border),
              Expanded(
                child: AppPressable(
                  onTap: stats[i].tab == null || onTab == null
                      ? null
                      : () => onTab!(stats[i].tab!),
                  borderRadius: BorderRadius.zero,
                  hoverColor: AppColors.surfaceAlt,
                  semanticLabel: '${stats[i].label} ${stats[i].value}',
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: compact ? 12 : 20,
                        vertical: compact ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                                size: compact ? 12 : 13,
                                weight: FontWeight.w500,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(stats[i].value,
                              style: AppTheme.heading(
                                  size: compact ? 16 : 22,
                                  tabularFigures: true,
                                  color: stats[i].color ??
                                      AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wide screens: underline tabs with counts at the top of the table card.
class _TabStrip extends StatelessWidget {
  final List<String> labels;
  final List<int> counts;
  final int selected;
  final ValueChanged<int> onSelect;

  const _TabStrip({
    required this.labels,
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Semantics(
                selected: i == selected,
                button: true,
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.fast),
                    height: 46,
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: i == selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(children: [
                      Text(labels[i],
                          style: AppTheme.font(
                            size: 14,
                            weight: i == selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          )),
                      const SizedBox(width: 8),
                      _Count(counts[i], selected: i == selected),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Phones: the same tabs as a row of chips above the list.
class _TabChips extends StatelessWidget {
  final List<String> labels;
  final List<int> counts;
  final int selected;
  final ValueChanged<int> onSelect;

  const _TabChips({
    required this.labels,
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selected;
          return AppPressable(
            onTap: () => onSelect(i),
            selected: on,
            semanticLabel: '${labels[i]} ${counts[i]}',
            borderRadius: BorderRadius.circular(999),
            color: on ? AppColors.primarySoft : AppColors.surface,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: on ? AppColors.primaryBorder : AppColors.fieldBorder),
              ),
              alignment: Alignment.center,
              child: Text('${labels[i]} ${counts[i]}',
                  style: AppTheme.font(
                    size: 13,
                    weight: FontWeight.w500,
                    color: on ? AppColors.primaryText : AppColors.textLabel,
                  )),
            ),
          );
        },
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final int value;
  final bool selected;
  const _Count(this.value, {required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$value',
          style: AppTheme.font(
            size: 12,
            weight: FontWeight.w500,
            tabularFigures: true,
            color: selected ? AppColors.primaryText : AppColors.textLabel,
          )),
    );
  }
}

class _Toolbar<T> extends StatelessWidget {
  final String? searchHint;
  final ValueChanged<String> onSearch;
  final List<AppTableFilter<T>> filters;
  final List<int> choices;
  final void Function(int filter, int option) onFilter;
  final String countText;
  final VoidCallback? onAdd;
  final String? addLabel;

  const _Toolbar({
    required this.searchHint,
    required this.onSearch,
    required this.filters,
    required this.choices,
    required this.onFilter,
    required this.countText,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (searchHint != null)
            SizedBox(
              width: 280,
              height: 40,
              child: TextField(
                onChanged: onSearch,
                style: AppTheme.font(size: 14),
                decoration: InputDecoration(
                  hintText: searchHint,
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 40,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  prefixIcon: const Icon(Icons.search, size: 18),
                ),
              ),
            ),
          for (var i = 0; i < filters.length; i++)
            Container(
              height: 40,
              padding: const EdgeInsets.only(left: 12, right: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: choices[i] == 0
                      ? AppColors.fieldBorder
                      : AppColors.primary,
                ),
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: choices[i],
                  isDense: true,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  icon: const Icon(Icons.expand_more, size: 18),
                  style: AppTheme.font(
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.textLabel,
                  ),
                  items: [
                    for (var o = 0; o < filters[i].options.length; o++)
                      DropdownMenuItem(
                        value: o,
                        child: Text(
                          o == 0
                              ? '${filters[i].label}: ${filters[i].options[o].label}'
                              : filters[i].options[o].label,
                        ),
                      ),
                  ],
                  onChanged: (o) => onFilter(i, o ?? 0),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(countText, style: AppTheme.label),
          ),
          if (onAdd != null && addLabel != null)
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(addLabel!),
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
            ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int from;
  final int to;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Pagination({
    required this.from,
    required this.to,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.card),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.tableRange(from, to, total),
            style: AppTheme.font(
              size: 13,
              color: AppColors.textSecondary,
              tabularFigures: true,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
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

/// A table cell's text with an optional small grey line under it (category
/// under a product, date under a customer). The main line may wrap onto
/// [maxLines] lines before being cut.
class AppCellText extends StatelessWidget {
  final String text;
  final String? sub;
  final bool strong;
  final Color? color;
  final bool numeric;
  final int maxLines;

  /// Optional widget before the sub line (a category colour dot).
  final Widget? subLeading;

  const AppCellText(
    this.text, {
    super.key,
    this.sub,
    this.strong = false,
    this.color,
    this.numeric = false,
    this.maxLines = 1,
    this.subLeading,
  });

  @override
  Widget build(BuildContext context) {
    final main = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: numeric ? TextAlign.right : TextAlign.left,
      style: AppTheme.font(
        size: 14,
        weight: strong ? FontWeight.w500 : FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        tabularFigures: numeric,
        height: 1.3,
      ),
    );
    if (sub == null || sub!.isEmpty) return main;
    final subText = Text(
      sub!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.font(size: 12, color: AppColors.textSecondary),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: numeric
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        main,
        const SizedBox(height: 2),
        subLeading == null
            ? subText
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  subLeading!,
                  const SizedBox(width: 6),
                  Flexible(child: subText),
                ],
              ),
      ],
    );
  }
}

/// Small round colour swatch (a category's colour).
class AppColorDot extends StatelessWidget {
  final Color color;
  final double size;
  const AppColorDot(this.color, {super.key, this.size = 8});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Initials avatar before a person's or company's name.
class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  const AppAvatar(this.name, {super.key, this.size = 32});

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppColors.primarySoft,
      shape: BoxShape.circle,
    ),
    child: Text(
      initialsOf(name),
      style: AppTheme.font(
        size: size * 0.38,
        weight: FontWeight.w600,
        color: AppColors.primary,
      ),
    ),
  );
}
