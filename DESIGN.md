# Forever One design system

"Ledger": calm, data-dense business software. Light grey page, white bordered cards, an ink sidebar, one indigo for action. Status colours mean status and nothing else. Inspired by Mercury (dashboard), Stripe (invoices), Shopify (stock) and Attio (customers).

- **Source of truth in code:** `lib/core/theme/app_colors.dart`, `app_theme.dart` and `lib/shared/widgets/`.
- **Visual reference:** the Claude Design canvas "Forever One — Web Redesign" (Dashboard, Sales, Stock, Customers and Phone boards).
- **Plan and review:** `docs/plans/ledger-redesign-plan.md`.

## Colour

`test/app_colors_contrast_test.dart` checks that every text pair reaches at least 4.5:1 (WCAG AA).

| Token | Hex | Use |
|---|---|---|
| `canvas` | #F5F6F8 | Page background |
| `surface` | #FFFFFF | Cards, headers, sidebar, fields |
| `surfaceAlt` | #F9FAFB | Table header row, hover |
| `fill` | #F2F4F7 | Neutral chip, selected segment, skeleton |
| `border` | #E5E7EB | Card borders and dividers (1px) |
| `fieldBorder` | #D0D5DD | Input and secondary-button borders |
| `textPrimary` | #101828 | Main text |
| `textSecondary` | #5D6676 | Secondary text, captions |
| `textLabel` | #344054 | Field labels, secondary-button text |
| `textMuted` | #98A2B3 | Placeholders and disabled text only |
| `primary` | #4F46E5 | Buttons, active states, links, focus ring, chart line |
| `primarySoft` / `primaryText` | #EEF2FF / #3730A3 | Selected chip, active tab count |
| `sidebar` / `sidebarActive` / `sidebarText` | #0E1525 / #1E2840 / #B4BCCB | Ink sidebar and drawer |
| `rowSelected` | #F5F5FF | Table row whose side panel is open |
| `success` / `successText` / `successSoft` | #16A34A / #067647 / #ECFDF3 | Paid, in stock, positive |
| `warning` / `warningText` / `warningSoft` | #D97706 / #B54708 / #FFFAEB | Low stock, partially paid, to pay |
| `danger` / `dangerText` / `dangerSoft` | #DC2626 / #B42318 / #FEF3F2 | Out of stock, overdue, errors |
| `info` / `infoSoft` | #3538CD / #EEF4FF | Deliveries, informational |

The base status colours (#16A34A, #D97706) are for icons, dots and bars. Text uses the `*Text` shade, because the base colours reach only about 3.2:1 on white. Use `AppColors.textOn(color)` to get it. Old names such as `accent` and `black` still compile and resolve to the values above.

## Shape and spacing

| | |
|---|---|
| Radius | 12 cards · 10 inputs and buttons · 6 chips (`AppRadius`) |
| Spacing | 16 page padding · 12 between cards (`AppSpacing`) |
| Cards | White, 1px `border`, no shadow |

## Type: Plus Jakarta Sans headings, Inter body

| Role | Style |
|---|---|
| Page title | Plus Jakarta Sans 20, 28 on wide (`AppTheme.pageTitle`, `pageTitleWide`) |
| Hero figure | Plus Jakarta Sans 40, tabular (`AppTheme.hero`) |
| Section title | Plus Jakarta Sans 16 (`AppTheme.sectionTitle`) |
| Body | 14 (`AppTheme.body`) |
| Caption | 12, secondary (`AppTheme.label`) |
| Field label | 13 medium, above the field (`AppTheme.fieldLabel`) |
| KPI figure | Plus Jakarta Sans 24, tabular (`AppTheme.kpi`) |

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
| A list of records | `AppDataTable`: optional summary strip (`summary`), status tabs with counts (`tabs`, chips on phones), toolbar, rows of about 58px, sortable titles, pagination, and on wide a side panel (`isSelected` + `detailPanel`, the page owns the selection) |
| A record beside its list | `AppSidePanel` around the shared detail body (`CustomerDetailBody`, `SupplierDetailBody`, `ProductDetailBody`) or `AppDetailLoader` + `AppInvoicePanel` for sales and purchases; the phone detail page shows the same body |
| Sale or purchase lines | `AppLinesTable`: Product · Qty · Price · Total · delete |
| Status | `AppBadge`: rounded pill with a status dot, sentence case ("Partially paid") |
| A detail row | `AppInfoRow`: label left, value right, divider below |
| Loading · failed · empty | `AppSkeletonList` · `AppErrorState` (Retry) · `AppEmptyState` (with an action) |
| Snackbar | `AppSnack.success / error` |

## Navigation

| Window | Navigation |
|---|---|
| Phone (< 840px) | Bottom bar on the 5 main tabs (Home, Products, Sales, Customers, Copilot; a `StatefulShellRoute`, so each tab keeps its state). Menu button top-left opens the drawer with everything. |
| Web (≥ 840px) | Permanent ink sidebar, 248 or 264 wide, collapsible to a 72px rail; no bottom bar. Overview, then collapsible groups: Sales (Invoices, Customers) · Purchasing (Purchases, Suppliers) · Inventory (Products, Categories, Warehouses, Stock movements) · Intelligence (Insights, AI Copilot, Scanner) · Administration (Users, Audit log). The current page's group opens itself; open/closed groups are remembered. Profile, language and sign-out sit in the account block. |

- **Header:** a white bar with a bottom border. Menu (or Back on pushed screens) on the left, title and subtitle, actions, and the notification bell with a red count on the right.
- **Forms and details:** pushed on the root navigator, full screen, with a Back arrow.
- **Notifications:** in-app only. `GET /notifications` supplies all active alerts grouped by type, and each opens its record.

## Accessibility

- **Targets:** 48×48 hit areas.
- **Icon buttons:** every one has a tooltip, which is also its screen-reader label.
- **Focus:** a keyboard focus ring (2px primary) via `AppPressable`.
- **Contrast:** text at 4.5:1 or better.
- **Motion:** one rule set in `AppMotion` (`app_motion.dart`). Section switches fade and rise (180ms) in the shell; page sections and table rows stagger in once; the revenue line draws in, its last point pulses three times; bars and meters grow; side panels slide in. Everything shows its final state at once with OS reduced motion or the browser's `prefers-reduced-motion`.
