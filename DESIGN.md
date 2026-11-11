# Forever One design system

Clean, neutral business software: light grey page, white bordered cards, one blue for action. Status colours mean status and nothing else. No beige, no brown, no gradients, no pill shapes.

- **Source of truth in code:** `lib/core/theme/app_colors.dart`, `app_theme.dart` and `lib/shared/widgets/`.
- **Visual reference:** the Claude Design canvas "Forever One Redesign" (design-system sheet, phone screens and web dashboard).

## Colour

`test/app_colors_contrast_test.dart` checks that every text pair reaches at least 4.5:1 (WCAG AA).

| Token | Hex | Use |
|---|---|---|
| `canvas` | #F5F6F8 | Page background |
| `surface` | #FFFFFF | Cards, headers, sidebar, fields |
| `surfaceAlt` | #F9FAFB | Table header row, hover |
| `fill` | #F2F4F7 | Neutral chip, selected segment, skeleton |
| `border` | #E4E7EC | Card borders and dividers (1px) |
| `fieldBorder` | #D0D5DD | Input and secondary-button borders |
| `textPrimary` | #101828 | Main text |
| `textSecondary` | #667085 | Secondary text, captions (4.97:1 on white) |
| `textLabel` | #344054 | Field labels, secondary-button text |
| `textMuted` | #98A2B3 | Placeholders and disabled text only |
| `primary` | #1D4ED8 | Buttons, active states, links, focus ring |
| `primarySoft` | #EFF4FF | Selected nav item, selected chip |
| `success` / `successText` / `successSoft` | #16A34A / #15803D / #F0FDF4 | Paid, in stock, positive |
| `warning` / `warningText` / `warningSoft` | #D97706 / #B45309 / #FFFBEB | Low stock, partially paid, to pay |
| `danger` / `dangerText` / `dangerSoft` | #DC2626 / #B91C1C / #FEF2F2 | Out of stock, overdue, errors |

The base status colours (#16A34A, #D97706) are for icons, dots and bars. Text uses the `*Text` shade, because the base colours reach only about 3.2:1 on white. Use `AppColors.textOn(color)` to get it. Old names such as `accent` and `black` still compile and resolve to the values above.

## Shape and spacing

| | |
|---|---|
| Radius | 12 cards · 10 inputs and buttons · 6 chips (`AppRadius`) |
| Spacing | 16 page padding · 12 between cards (`AppSpacing`) |
| Cards | White, 1px `border`, no shadow |

## Type: Inter

| Role | Style |
|---|---|
| Page title | 20 semi-bold (`AppTheme.pageTitle`) |
| Section title | 15 semi-bold (`AppTheme.sectionTitle`) |
| Body | 14 (`AppTheme.body`) |
| Caption | 12, secondary (`AppTheme.label`) |
| Field label | 13 medium, above the field (`AppTheme.fieldLabel`) |
| KPI figure | 22 semi-bold, tabular (`AppTheme.kpi`) |

All amounts use tabular figures. Money always goes through `formatDT()` in `core/utils/formatters.dart`: a thousands separator, two decimals and a non-breaking space, e.g. `4 005.00 DT`.

## Components

| Need | Use |
|---|---|
| A text field | `AppTextField` (label above, white, 48 high, `required: true` adds `*`) or `AppLabeledField` around any input |
| A form or detail section | `AppFormSection`: title and fields in ONE white card, never a card inside a card |
| Two short fields | A `Row` of two `Expanded` fields (Price / VAT, Lead time / Payment terms) |
| Primary action | `FilledButton`, blue, 48 high; disabled shows as #E4E7EC on #98A2B3 |
| Secondary action | `OutlinedButton`, white with a border |
| Form save | `AppBottomActionBar`, fixed at the bottom |
| A list of records | `AppDataTable`: header row, one-line rows of about 58px, sortable titles, extra columns from 600px, ⋮ menu |
| Sale or purchase lines | `AppLinesTable`: Product · Qty · Price · Total · delete |
| Status | `AppBadge` / `AppStatusChip`, radius 6, sentence case ("Partially paid") |
| A detail row | `AppInfoRow`: label left, value right, divider below |
| Loading · failed · empty | `AppSkeletonList` · `AppErrorState` (Retry) · `AppEmptyState` (with an action) |
| Snackbar | `AppSnack.success / error` |

## Navigation

| Window | Navigation |
|---|---|
| Phone (< 840px) | Bottom bar on the 5 main tabs (Home, Products, Sales, Customers, Copilot; a `StatefulShellRoute`, so each tab keeps its state). Menu button top-left opens the drawer with everything. |
| Web (≥ 840px) | Permanent white sidebar, 248 or 264 wide, collapsible to a 72px rail; no bottom bar. |

- **Header:** a white bar with a bottom border. Menu (or Back on pushed screens) on the left, title and subtitle, actions, and the notification bell with a red count on the right.
- **Forms and details:** pushed on the root navigator, full screen, with a Back arrow.
- **Notifications:** in-app only. `GET /notifications` supplies all active alerts grouped by type, and each opens its record.

## Accessibility

- **Targets:** 48×48 hit areas.
- **Icon buttons:** every one has a tooltip, which is also its screen-reader label.
- **Focus:** a keyboard focus ring (2px primary) via `AppPressable`.
- **Contrast:** text at 4.5:1 or better.
- **Motion:** respects reduced motion.
