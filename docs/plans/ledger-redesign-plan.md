<!-- /autoplan restore point: "D:\\foreverone\\.gstack\\tmp\\autoplan\\ui-redesign-autoplan-restore-20261112-112036.md" -->
# Ledger web redesign — implementation plan

Branch `ui-redesign` (app `D:\foreverone`, backend `C:\xampp\htdocs\forever-one-backend`). Approved visual reference: Claude Design canvas "Forever One — Web Redesign" (https://claude.ai/artifact/DZsKcmYCz4u4ACyuQPYnUn): Dashboard, Sales, Stock, Customers and Phone boards. Applies to EVERY page. Do not commit until the user approves; never merge into `main`.

## Implementation plan

### Goal
Replace the current neutral grey/blue look with the approved "Ledger" direction on every screen, web and phone, without changing behaviour, permissions, routes, EN/FR texts or the backend contract.

### 1. Design tokens (`lib/core/theme/app_colors.dart`, `app_theme.dart`, `DESIGN.md`)
- `primary` #4F46E5, hover/pressed #4338CA, `primarySoft` #EEF2FF, `primaryBorder` #C7D2FE, `primaryText` #3730A3.
- Sidebar tokens: `sidebar` #0E1525, `sidebarHover` #1A2236, `sidebarActive` #1E2840, `sidebarText` #B4BCCB, `sidebarTextMuted` #8A94A7, `sidebarRule` #253049.
- Status shades from the canvas: success #067647 on #ECFDF3, warning #B54708 on #FFFAEB, danger #B42318 on #FEF3F2, info #3538CD on #EEF4FF. Base (dot/bar) colours stay #16A34A-style brights; text always uses the `*Text` shade.
- Text: primary #101828, secondary #475467, label #5D6676 (≥4.5:1 on white and on canvas #F5F6F8).
- Typography: headings (page title, section title, KPI and hero figures) in Plus Jakarta Sans 600/700 via google_fonts; body and all numbers in Inter with tabular figures. Page title 28 on wide, 20 on phone. Hero figure 40, KPI 24.
- Keep every existing token name compiling (aliases), update `test/app_colors_contrast_test.dart` and `DESIGN.md`.

### 2. Navigation (`core/router/app_destinations.dart`, `shared/widgets/app_shell.dart`, `app_drawer.dart`, `core/di/sidebar_provider.dart`)
- Add `NavGroup` to each destination: Overview (dashboard, top-level); Sales (Invoices = /sales, Customers); Purchasing (Purchases, Suppliers); Inventory (Products, Categories, Warehouses, Stock movements); Intelligence (Insights, AI Copilot, Scanner); Administration (Users, Audit log). Profile moves to the account block at the sidebar foot (avatar, name, role; tap opens /profile, menu has Sign out).
- Ink sidebar 248px on wide: collapsible groups with chevron rotation; the current page's group opens automatically; open/closed state persists per user in `sidebar_provider`; groups with no permitted item are hidden; count badges (Invoices, Purchases) stay.
- Phone drawer reuses the same grouped model and widgets (light or ink variant, same structure); the bottom tab bar keeps its five tabs.
- Wide top bar: breadcrumb (Group / Page), notification bell, "Ask AI" button (opens /ai). No global search box in this plan (no backend search endpoint).

### 3. Page frame and motion (`shared/widgets/`)
- Every page body in `AppContentFrame` max 1200 + 32px gutters on wide, 16 on phone; page header block = title, subtitle, actions (secondary + primary button).
- New `AppEntrance` widget: fade + 10px rise, staggered by index (60ms page sections, 40ms table rows, capped), runs once per mount. New `AppMeter` (animated horizontal bar) and helpers for chart animation.
- Section transitions (ENG-NAV-MOTION, accepted): sections are `NoTransitionPage`s and the phone tabs are a `StatefulShellRoute.indexedStack` (`core/router/app_router.dart:37,92`), so route-level transitions would not fire on tab switches. Instead `AppShell` wraps its body in one fade + 4px rise (180ms) keyed on the active destination route; `AppEntrance` staggers sections only on a page's first mount.
- Side panels slide in from the right (240ms). Sidebar items: hover colour + 2px shift. Buttons: press scale.
- Reduced motion: every animation reads one `AppMotion.enabled(context)` = `!MediaQuery.disableAnimationsOf(context)`, and on web also `prefers-reduced-motion` via `package:web` behind the existing conditional-import pattern (ENG-RM-WEB, accepted), and renders the final state instantly when disabled.

### 4. Dashboard (`features/dashboard/presentation/pages/dashboard_page.dart`)
- Greeting + date, actions "Monthly report" (existing PDF download) and "New sale".
- Revenue hero card: month-to-date revenue, growth pill vs the same range last month (existing `revenueThisMonth` / `revenueGrowthPercent`), fl_chart line for the selected period vs the previous period of the same length (dashed), area fill, line draws in, last point pulses, period switch 7D / 30D / 90D / 12M.
- Backend (CEO-TREND, accepted): extend the EXISTING `GET /dashboard` with optional `trend_days` (7|30|90|365, default 30, anything else → 30) returning `sales_trend` for that window plus `sales_trend_previous` for the preceding window of equal length (365 → monthly buckets). Same tenant scoping and auth; old clients unaffected. Period switch refetches only the trend; a failed refetch keeps the previous chart and shows an inline retry.
- Cash card (CEO-CASH, accepted): To collect (`receivables`) / To pay (`payables`) / Net position, animated meters — existing KPI fields only.
- KPI row (CEO-KPI, accepted): To collect (receivables, links to Sales › Unpaid), Overdue (count + sum of `overduePayment` alerts, links to Sales › Overdue), Low stock (`lowStockCount`, links to Products › Low stock), Sales this month (`salesCountThisMonth`). "Deliveries due" is dropped (not in the summary).
- Recent sales table + "Needs attention" (existing notifications/insights, one action per item).

### 5. List pages (`shared/widgets/app_data_table.dart` and every list page)
- `AppDataTable` gains: `tabs` (status tabs with counts, replacing the primary dropdown filter on wide and shown as chips on phone), optional `summary` strip (clickable stats that select a tab), `isSelected` + `detailPanel` (wide: side panel beside the table, row highlighted; phone: existing navigation), row stagger animation capped at 12 rows. The PAGE owns the selected id (ENG-TABLE-STATE, accepted): the table only lays out, and the page clears the selection when the row leaves the filtered set. Tabs, summary and panel are private widgets inside `app_data_table.dart`.
- Panels and detail pages share one body widget per entity (ENG-STRUCT, accepted: smaller arrangement): `CustomerDetailBody`, `SupplierDetailBody`, `ProductDetailBody` extracted from the existing detail pages, plus a new `SaleDetailBody`/`PurchaseDetailBody`. The page and the panel both render that body, so there is one way to show an entity.
- Latest-wins loads (ENG-LATEST, accepted): the dashboard trend notifier and the panel loaders tag each request with an increasing sequence number and ignore any response that isn't the latest. Existing search, period segmented control, pagination, hover, content-sized columns stay.
- Sales and Purchases (Stripe-like): summary strip (invoiced / paid / unpaid / overdue for the period), tabs All / Unpaid / Partially paid / Overdue / Paid (Purchases: All / To receive / To pay / Paid), Due column, invoice side panel (totals, lines, actions Record payment / Edit). Lines come from the existing `GET /sales/show` and `GET /purchases/show` (CEO-PANEL, accepted): loaded when a row is selected, skeleton while loading, inline error with retry, latest selection wins (a slow earlier response never overwrites a newer selection), cached per id until the list reloads.
- Products (Shopify-like): saved views All / Reorder soon / Low stock / Out of stock / Not selling; category chips with colour dots; product cell with tinted initials tile + SKU; stock as coloured text + animated level bar.
- Customers and Suppliers (Attio-like): initials avatars; side panel with balance, orders, credit-limit meter, purchases-per-month bars (from the existing detail data), recent activity, actions.
- Categories, Warehouses, Users: same table, tabs where a status exists.

### 6. Every other page
- Forms (product, category, warehouse, customer, supplier, user, sale, purchase, stock movement, payment, profile edit): new tokens and headings, 720px frame unchanged.
- Detail pages (customer, product, supplier) restyled with the panel components (shared with side panels).
- Insights, Audit log, Notifications, AI chat (primary colour instead of black), Scanner, Profile, Login, Signup, Splash: new tokens, frame, headings, entrance motion.

### 7. Phone
- Per the Phone board: header with menu / title + subtitle / search / bell; status chips; compact summary card; rows with 2-line names, amount + status right, ⋮; indigo FAB with pop-in, bottom padding so it never covers rows.

### 8. Verification
- `flutter analyze` clean; full `flutter test` green; new tests: grouped navigation (permission filtering, auto-open active group, persistence), table tabs and counts, side panel on wide vs navigation on phone, reduced-motion final state, contrast of new tokens.
- Rebuild web, deploy to `C:\xampp\htdocs\foreverone-app`, visual check of every page at 1440 and 390 (gstack /browse when signed in by the user).

### Not in scope
Global search, dark mode, new backend endpoints (the `trend_days` parameter extends an existing one), money-in/money-out cash flow, deliveries-due KPI, payment history in panels (not in any existing response) — cards without real data are omitted, never faked.

## Review record

### CEO review (/plan-ceo-review, run by hand: the /autoplan guard refused this resumed session with `competing_root`; every question auto-decided per the user's global rule "choose the recommended option")

**System audit.** Branch `ui-redesign`, 111 files changed vs `main`, no stash, no TODO/FIXME markers in `lib/`, no TODOS.md or CLAUDE.md in the repo. Recent work on this branch: table widget rewrite, 1200px frames, audit rows, report language. Prior review history on this plan: none. Retrospective: two earlier redesign passes (warm system, then neutral) were each replaced, so the token layer (`AppColors` aliases) must stay the single switch point.

**0A Premise.** Real problem: the user finds the current web UI generic and wants the approved Ledger look on every page; do-nothing cost is a product the owner will not demo. The plan attacks that directly (tokens + shell + every page), not a proxy.

**0B Existing code leverage.**
| Sub-problem | Reuse |
|---|---|
| Colours/type | `AppColors`/`AppTheme` token aliases — change values, keep names |
| Sidebar | `appDestinations` + `allows(user)` permission filter, `sidebar_provider`, `AppShellScope.sidebarVisible` |
| Frame | `AppContentFrame` (1248 cap) already on headers, detail pages, audit |
| Tables | `AppDataTable` (measured columns, toolbar, pagination, hover) — add tabs/summary/panel instead of a new widget |
| Charts | fl_chart already on the dashboard |
| Panel data | `customerDetailProvider` (customer + sales), `GET /sales/show`, `GET /purchases/show` |

Premise table:
| premise | claim | receipt | verdict |
|---|---|---|---|
| trend data | API returns 30 days only | backend `src/Repositories/DashboardRepository.php:132` (`INTERVAL 29 DAY`) | verified |
| cash in/out | not in summary; only receivables/payables | `lib/features/dashboard/domain/entities/dashboard_summary_entity.dart:6-7` | verified |
| overdue | sales have `dueDate`, overdue alerts exist | `sale_entity.dart:10`, `dashboard_summary_entity.dart:44` | verified |
| invoice lines | `GET /sales/show`, `/purchases/show` exist | backend `src/routes.php:65,69` | verified |
| customer bars | customer detail loads the customer's sales | `customer_provider.dart:103-106` | verified |
| fonts | google_fonts installed (Plus Jakarta Sans available) | `pubspec.yaml:32` | verified |
unverified=0

**0C Dream state.**
```
CURRENT                         THIS PLAN                              12-MONTH IDEAL
grey/blue, flat lists,   --->   Ledger tokens, grouped ink sidebar,  ---> same system + global search,
30-day chart, page-per-         Stripe/Shopify/Attio list patterns,       cash-flow (money in/out),
detail navigation               side panels, honest dashboard,            dark mode, saved custom views
                                motion with reduced-motion support
```

**0E Mode.** ~45 files will change [estimated: tokens 3, shell/nav 4, table 1, ~30 pages, tests ~6] → rule ">15 files → SCOPE REDUCTION" → auto-decided SCOPE REDUCTION (recommended). 0G minimum-scope candidates, each auto-decided **Keep** because the user explicitly said "the modifications will be applied to all pages": (1) restyle secondary pages — Keep; (2) side panels on wide — Keep; (3) phone pass — Keep; (4) motion — Keep (user asked for it). Net scope unchanged; three data-honesty corrections below.

**Decision ledger**
| ID and owner | Contract and evidence | Current | Proposed | Status | Exact approval and scope |
|---|---|---|---|---|---|
| CEO-MODE (Step 0) | >15 files | — | SCOPE REDUCTION | approved | auto-decided recommended; 4 cut candidates kept per user's "all pages" |
| CEO-TREND (S1/S4) | trend is 30 days only (`DashboardRepository.php:132`) | period switch on missing data | A) extend `/dashboard` with `trend_days` + previous window; B) 30-day only; C) client-side from sales list | approved A | auto-decided recommended (P1 completeness, P2 blast radius < 1 day, no new endpoint) |
| CEO-CASH (S4) | no money in/out fields | money in/out card | A) receivables/payables/net; B) new cash-flow query | approved A | auto-decided recommended (real data, zero backend) |
| CEO-KPI (S4) | no deliveries/unpaid counts in summary | 4 KPIs incl. deliveries due | A) receivables, overdue alerts, lowStockCount, salesCountThisMonth; B) load sales+purchases lists on dashboard | approved A | auto-decided recommended (no extra requests) |
| CEO-PANEL (S2/S4) | lines need `GET /sales/show` | lines unspecified | A) fetch on select, latest-wins, cache; B) panel without lines | approved A | auto-decided recommended |
Approval readiness: PASS (CEO-MODE, CEO-TREND, CEO-CASH, CEO-KPI, CEO-PANEL — all auto-decided under the user's global instruction).

**Section 1 Architecture.**
```
            ┌──────────── AppShell (sidebarVisible) ─────────────┐
 tokens ──▶ │ AppSidebar(groups from appDestinations+NavGroup)   │
 AppColors  │   └─ sidebar_provider (open groups, per user)      │
 AppTheme   │ AppTopBar(breadcrumb, bell, Ask AI)                │
            │ Page ─▶ AppContentFrame ─▶ AppEntrance(stagger)    │
            └─────────────────────────────────────────────────────┘
 Lists: AppDataTable(+tabs,+summary,+detailPanel) ─▶ SalePanel/CustomerPanel...
                         └─ detail providers ─▶ dio ─▶ /sales/show, /customers/{id}
 Dashboard: dashboardProvider ─▶ GET /dashboard?trend_days=N ─▶ DashboardRepository
```
Coupling: panels reuse detail providers (justified, single fetch path). New stateful objects: sidebar group state (open/closed per group, persisted), selected-row state per list (none → selected → none; deselect when the row leaves the filtered set). Rollback: branch not merged; revert = discard commits. Findings: 3 (trend, cash, KPI data gaps) — resolved above.

**Section 2 Error & rescue map.**
```
CODEPATH                     | WHAT CAN GO WRONG          | RESCUE / USER SEES
GET /dashboard?trend_days    | network/timeout/5xx        | keep previous chart, inline "Couldn't load — Retry"
                             | bad trend_days             | server clamps to 30
GET /sales/show (panel)      | 404 (deleted)              | panel shows "This invoice no longer exists", list reloads
                             | timeout/5xx                | panel error + Retry; table unaffected
customer detail (panel)      | error                      | same panel error pattern
sidebar_provider persistence | storage read fails         | default: active group open, others closed
google_fonts load            | offline                    | falls back to platform sans; layout unchanged
```
No catch-alls proposed; errors use the existing `errorText(code)` mapping. GAPS: 0 after CEO-PANEL.

**Section 3 Security.** One changed surface: `trend_days` query param — integer whitelist {7,30,90,365}, same tenant scoping and JWT as today; no new data exposed (same rows, longer window). Panels call existing authorized endpoints; permission filtering of sidebar groups reuses `allows(user)` (UI only — router guard unchanged). Likelihood/impact of new issues: Low/Low. No new dependencies or secrets.

**Section 4 Data flow & edge cases.**
```
period tap ─▶ trend_days ─▶ validate(whitelist) ─▶ SQL window ─▶ series[] ─▶ chart
  shadow: empty series → flat "No sales in this period" state; 1 point → dot only;
          previous window empty → dashed line hidden; error → keep old chart + retry
row select ─▶ id ─▶ /sales/show ─▶ panel   (latest-wins token; stale response dropped)
```
| INTERACTION | EDGE CASE | HANDLED? | HOW |
|---|---|---|---|
| period switch | rapid taps | yes | latest-wins request token |
| row select | select A then B fast | yes | latest-wins; A's response ignored |
| row select | selected row filtered out | yes | panel closes |
| tabs | 0 results | yes | table empty state "No results" |
| sidebar | user lacks every item of a group | yes | group hidden |
| sidebar | deep link into collapsed group | yes | active group auto-opens |
| motion | reduced motion | yes | final state instantly |

**Section 5 Code quality.** Extend `AppDataTable` rather than fork; one `AppEntrance`/`AppMeter` used everywhere (no per-page animation code); sidebar model lives in `app_destinations.dart` beside permissions. Risk: `AppDataTable` grows large — split tabs/summary/panel into private widgets in the same file. No findings beyond that note.

**Section 6 Tests.**
```
NEW THING                    | TEST TYPE | HAPPY                    | FAILURE                  | EDGE
grouped sidebar              | widget    | groups+items by role     | storage error → defaults | empty group hidden; deep link opens group
trend_days (backend)         | PHP       | 7/30/90/365 windows      | invalid → 30             | empty window
dashboard period switch      | widget    | refetch draws series     | error keeps old + retry  | rapid taps latest-wins
table tabs/summary           | widget    | counts + filtering       | —                        | 0 results
side panel (wide)            | widget    | select → panel → lines   | show error → retry       | stale response dropped; phone navigates
reduced motion               | widget    | disableAnimations → final state immediately
token contrast               | unit      | all text pairs ≥ 4.5:1
```
no_claim for widget tests: real browser rendering and fonts (test font) — covered by the post-build visual pass.

**Section 7 Performance.** 365-day trend = monthly buckets (12 rows); 90-day = 90 rows; index on `sales(tenant_id, created_at)` must exist — verify in eng review. Animations: one controller per widget, stagger capped (rows > 12 appear together) to avoid jank on 25-row pages.

**Section 8 Observability.** Client logs (existing `debugPrint` pattern) on trend/panel fetch failure with code; backend keeps existing request logging. No new dashboards needed (single-tenant SMB app).

**Section 9 Deployment.** Order: backend `trend_days` (backward compatible) → app build → copy to `C:\xampp\htdocs\foreverone-app`. Rollback: redeploy previous build folder; backend param is optional so no rollback needed there. No migrations.

**Section 10 Trajectory.** Reversibility 4/5 (tokens/aliases make the look swappable). Debt: AppDataTable size (noted). Fits Flutter/Riverpod conventions.

**Section 11 Design & UX.** First: page title + primary action; second: summary/hero; third: table/panel. States:
| FEATURE | LOADING | EMPTY | ERROR | SUCCESS | PARTIAL |
|---|---|---|---|---|---|
| dashboard hero | skeleton | "No sales in this period" | inline retry | chart | previous series missing → solid only |
| list + tabs | skeleton rows | "No results" / empty state | AppErrorState | table | — |
| side panel | skeleton | — | inline retry | details | lines failed → totals only + retry |
| sidebar | — | groups hidden | defaults | — | — |
```
Login ─▶ Overview ─▶ (sidebar group) ─▶ List ─▶ select row ─▶ Panel ─▶ Edit/Record payment ─▶ back to List
                        phone: drawer ─▶ List ─▶ row ─▶ Detail page
```
Accessibility: 44px targets, focus visible, aria labels on icon buttons, contrast test. Recommend /plan-design-review (next).

**NOT in scope:** global search; dark mode; money-in/out cash flow (no data); deliveries-due KPI (no data); payment history in panels (no data); saved custom views.
**What already exists:** see 0B table — all reused.
**Dream state delta:** delivers the full look and honest data on every page; leaves cash flow, search and dark mode for later.
**Failure modes registry:**
```
CODEPATH            | FAILURE         | RESCUED? | TEST? | USER SEES       | LOGGED?
trend refetch       | network         | Y        | Y     | old chart+retry | Y
panel /show         | 404/5xx         | Y        | Y     | panel message   | Y
sidebar persistence | read error      | Y        | Y     | default groups  | N (benign)
fonts               | offline         | Y        | N     | fallback font   | N
```
CRITICAL GAPS: 0.

REALITY: premise-table pass 6 claims verified, unverified=0 DashboardRepository.php:132
REALITY: already-done pass no prior Ledger work on main docs/plans/ledger-redesign-plan.md:1
REALITY: surface-check pass /dashboard, /sales/show, /purchases/show exist src/routes.php:65
REALITY: binding-decisions pass "never merge into main", "don't commit until approved" kept docs/plans/ledger-redesign-plan.md:3
REALITY: numbers pass 30-day window [measured: DashboardRepository.php:132]; ~45 files [estimated]
REALITY: deferred-asks pass no linked issue docs/plans/ledger-redesign-plan.md:1
REALITY: pr-count pass one branch, no PR until user approves docs/plans/ledger-redesign-plan.md:3

```
+====================================================================+
|            MEGA PLAN REVIEW — COMPLETION SUMMARY                   |
+====================================================================+
| Mode selected        | SCOPE REDUCTION (all cuts kept: user said all pages) |
| System Audit         | no TODOs; 2 prior redesigns replaced → keep token aliases |
| Step 0               | 3 data-honesty fixes + panel data source    |
| Section 1  (Arch)    | 3 issues found (resolved)                   |
| Section 2  (Errors)  | 6 error paths mapped, 0 GAPS                |
| Section 3  (Security)| 0 issues, 0 High                            |
| Section 4  (Data/UX) | 7 edge cases mapped, 0 unhandled            |
| Section 5  (Quality) | 1 note (table size)                         |
| Section 6  (Tests)   | Diagram produced, 0 gaps                    |
| Section 7  (Perf)    | 1 check for eng (sales index)               |
| Section 8  (Observ)  | 0 gaps                                      |
| Section 9  (Deploy)  | 0 risks                                     |
| Section 10 (Future)  | Reversibility: 4/5, debt items: 1           |
| Section 11 (Design)  | 0 issues; design review recommended         |
+--------------------------------------------------------------------+
| NOT in scope         | written (6 items)                           |
| What already exists  | written                                     |
| Dream state delta    | written                                     |
| Error/rescue registry| 6 rows, 0 CRITICAL GAPS                     |
| Failure modes        | 4 total, 0 CRITICAL GAPS                    |
| TODOS.md updates     | 0 items proposed                            |
| Scope proposals      | 0 proposed, 0 accepted (REDUCTION)          |
| CEO plan             | skipped by mode                             |
| Outside voice        | codex not installed; native fallback skipped (see report) |
| Lake Score           | 4/4 recommendations chose complete option   |
| Diagrams produced    | 6 (architecture, data flow, state, error, user flow, dream) |
| Stale diagrams found | 0                                           |
| Unresolved decisions | 0                                           |
| Reality rows         | 7/7 rows, 0 unverified                      |
+====================================================================+
```

### Eng review (plan-eng-review methodology, loaded from its installed files — not registered as a slash command in this session; every question auto-decided with the recommended option)

**Scope gate:** user-named target — reviewing `docs/plans/ledger-redesign-plan.md`.

**Scope Challenge.** ~45 changed files [estimated] and ~9 new widgets/classes (AppSidebar, AppTopBar, AppEntrance, AppMeter, AppMotion, Sale/Purchase detail bodies, trend state) → complexity gate trips.
- Feature cuts: none proposed (user: "applied to all pages"; CEO kept all).
- Structure (ENG-STRUCT): `Original arrangement` = separate Panel widgets per entity beside the existing detail pages (≈5 new panel classes, duplicated layout); `Smaller arrangement` = extract one DetailBody per entity used by both page and panel (3 extractions + 2 new bodies, no duplication). Pending remedies not decided here: none. **Auto-decided → Smaller arrangement** (recommended: removes red flag 6, "two ways to do one task").
- Scope record: feature answers: none cut; structure: B (smaller) auto-decided; accepted scope: plan as amended by CEO + ENG rows; pending remedies: none. Result: scope accepted as-is.
- Search: no new infra pattern; Flutter built-ins used (AnimatedSwitcher/TweenAnimationBuilder, `MediaQuery.disableAnimationsOf`) [Layer 1]. Search unavailable for web research — in-distribution knowledge only.

**Section 1 Architecture.** Two shapes for the new table/panel boundary: (A) table owns selection + fetch; (B) page owns selection, table only lays out, body widget owns rendering. Pick B: smaller public surface on the table (`isSelected`, `detailPanel`), one owner of selection state (red flag 5 avoided).
```
 AppShell ──AnimatedSwitcher(key: active route)──▶ section page
   │                                                   │
 AppSidebar ◀── appDestinations(+NavGroup, allows())   ├─ AppDataTable(tabs, summary, isSelected, detailPanel)
   │                                                   │        └─ detailPanel = XDetailBody(id)
 sidebar_provider (open groups)                        │                 └─ detail provider (seq-tagged) ─▶ /sales/show …
                                                       └─ dashboard: trend notifier (seq-tagged) ─▶ /dashboard?trend_days
```
Findings:
- [P1] (confidence 9/10) Section transitions can't use route pageBuilders: sections are `NoTransitionPage` and tabs use `indexedStack` — `app_router.dart:37,92`. → ENG-NAV-MOTION accepted (shell-level switcher).
- [P2] (8/10) Reduced motion on web isn't guaranteed through `MediaQuery` alone → ENG-RM-WEB accepted (read `prefers-reduced-motion` via package:web).
- Red flags screened: shallow module — none; information leakage — status colours stay in `AppColors.textOn`; hand-synced list — sidebar groups live in `appDestinations` only (phone `tabRoutes` is a different concept, kept); two ways — fixed by ENG-STRUCT.
Dispositions: ENG-NAV-MOTION accepted (auto), ENG-RM-WEB accepted (auto), ENG-STRUCT accepted (auto).

**Section 2 Code quality.** Shared code: detail bodies (callers: `customer_detail_page.dart`, `supplier_detail_page.dart`, `product_detail_page.dart` + the new panels — proposed callers, labelled). Estimated implementation lines: removed ~600 (page layouts moved), added ~650 (bodies + 2 new) → net ≈ +50, versus ≈ +900 for separate panels. Error handling: panel/trend errors use `errorText(code)`; no catch-alls. Diagrams in touched files: `app_router.dart:85` tree comment must be updated with the shell switcher. Finding [P2] (8/10): `AppDataTable` is ~760 lines; adding three features inline risks a god-widget → private widgets per feature (in plan). Dispositions: accepted as written.

**Section 3 Tests.** Framework: flutter_test + mocktail (`pubspec.yaml:38`); backend PHP scripts.
```
CODEPATH                         | TEST                                   | TYPE
appDestinations groups/allows    | role matrix → visible groups/items     | unit
AppSidebar                       | auto-open active group; toggle; persisted; hidden empty group | widget
AppShell switcher                | switches child; reduced motion → no animation frames | widget
AppMotion.enabled                | MediaQuery flag; web media query stub  | unit
dashboard trend notifier         | latest-wins with two Completers (both orders) | unit
DashboardRepository trend_days   | 7/30/90/365 windows; invalid → 30; previous window | PHP
AppDataTable tabs/summary        | counts, filter, summary selects tab, 0 results | widget
panel (wide) / navigation (phone)| select → body; A then B → B; 404 → message; filtered-out → closes | widget
token contrast                   | every text pair ≥ 4.5:1 (update existing test) | unit
```
REGRESSION RULE: existing 103 tests must stay green; tests asserting the old primary hex or flat sidebar are updated, not deleted. no_claim: real fonts/rendering (test font) — covered by the post-build visual pass. Test plan artifact: `~/.gstack/projects/ayadimohamed25-Forever_One/User-ui-redesign-eng-review-test-plan-20261112-112717.md`.

**Section 4 Performance.** Measured: 64 sales rows, dates 2026-09-12 → 2026-11-11 [measured: MySQL `forever_one`]; `EXPLAIN` of the 365-day trend = full scan of 64 rows using no composite index (`sales` has only `tenant_id`, `customer_id`, `warehouse_id`, PRIMARY) [measured]. Acceptable at this volume; composite `(tenant_id, created_at)` index goes to NOT in scope with its trigger. Animations: one controller per widget, stagger capped at 12 rows, no per-frame rebuilds of tables. Finding: none blocking.

**Outside voice:** Codex not installed → outside coverage unavailable; native fallback not run (stated, no credit).

**Eng decision ledger**
| ID and owner | Contract and evidence | Current | Proposed | Status | Exact approval and scope |
|---|---|---|---|---|---|
| ENG-STRUCT (Scope) | panels vs detail pages | separate panels | shared DetailBody per entity | approved | auto-decided recommended (smaller arrangement) |
| ENG-NAV-MOTION (S1) | `app_router.dart:37,92` | route transitions | shell-level AnimatedSwitcher | approved | auto-decided recommended |
| ENG-RM-WEB (S1) | web reduced motion | MediaQuery only | + `prefers-reduced-motion` via package:web | approved | auto-decided recommended |
| ENG-TABLE-STATE (S1) | selection owner | unspecified | page owns selection | approved | auto-decided recommended |
| ENG-LATEST (S1/S3) | rapid switches | unspecified | sequence-tagged requests + tests | approved | auto-decided recommended |
Approval readiness: PASS (ENG-STRUCT, ENG-NAV-MOTION, ENG-RM-WEB, ENG-TABLE-STATE, ENG-LATEST; CEO rows carried).

**NOT in scope (eng additions):** composite index `sales(tenant_id, created_at)` — add when sales exceed ~50k rows or the trend query passes 200 ms.
**What already exists:** see CEO 0B; plus `NoTransitionPage` sections and `indexedStack` tabs (kept), `errorText` mapping (reused).
**Failure modes (eng):**
```
CODEPATH        | FAILURE              | RESCUED? | TEST? | USER SEES        | LOGGED?
trend notifier  | stale response wins  | Y (seq)  | Y     | latest period    | n/a
panel loader    | stale response wins  | Y (seq)  | Y     | latest row       | n/a
shell switcher  | reduced motion       | Y        | Y     | instant switch   | n/a
```
Critical gaps: 0.
**Worktree parallelization:** sequential (tokens → shell → table → pages share files); no parallel lanes.

REALITY: premise-table pass 4 claims verified (transitions, index, volume, framework), unverified=0 core/router/app_router.dart:37
REALITY: already-done pass nothing on main implements Ledger docs/plans/ledger-redesign-plan.md:1
REALITY: surface-check pass /dashboard, /sales/show, /purchases/show routes exist src/routes.php:65
REALITY: binding-decisions pass CEO rows and "no merge/no commit" kept docs/plans/ledger-redesign-plan.md:3
REALITY: numbers pass 64 rows [measured: MySQL]; ~45 files, ~9 classes [estimated]
REALITY: deferred-asks pass no linked issue docs/plans/ledger-redesign-plan.md:1
REALITY: pr-count pass one branch, single PR after approval docs/plans/ledger-redesign-plan.md:3

## Implementation Tasks
Synthesized from the CEO and eng findings above. Sequential; checkbox as you ship.

- [x] **T1 (P1, human: ~3h / CC: ~15min)** — tokens — new colours/type + aliases, DESIGN.md, contrast test
  - Files: lib/core/theme/app_colors.dart, app_theme.dart, DESIGN.md, test/app_colors_contrast_test.dart
  - Verify: flutter test test/app_colors_contrast_test.dart
- [x] **T2 (P1, human: ~1d / CC: ~45min)** — navigation — NavGroup model, ink AppSidebar, account block, persisted groups, phone drawer, top bar
  - Files: core/router/app_destinations.dart, core/di/sidebar_provider.dart, shared/widgets/app_shell.dart, app_drawer.dart, app_page_header.dart
  - Verify: new sidebar widget tests (role matrix, auto-open, persistence)
- [x] **T3 (P1, human: ~4h / CC: ~20min)** — motion — AppMotion (+web media query), AppEntrance, AppMeter, shell switcher
  - Files: shared/widgets/app_motion.dart (new), app_shell.dart, core/router/app_router.dart (diagram comment)
  - Verify: reduced-motion widget test
- [x] **T4 (P1, human: ~1d / CC: ~45min)** — table — tabs, summary, isSelected/detailPanel, row stagger
  - Files: shared/widgets/app_data_table.dart, test/table_layout_test.dart
  - Verify: table widget tests
- [x] **T5 (P1, human: ~1d / CC: ~40min)** — detail bodies + panels — extract Customer/Supplier/Product bodies, new Sale/Purchase bodies, latest-wins loaders
  - Files: features/*/presentation/pages/*detail_page.dart, new *_detail_body.dart, sales/purchases datasources (show)
  - Verify: panel tests (A→B, 404, filtered-out)
- [x] **T6 (P1, human: ~1d / CC: ~40min)** — dashboard — hero, period switch, cash card, KPIs, recent sales, needs attention; backend trend_days
  - Files: dashboard_page.dart, dashboard providers/datasource, backend DashboardRepository.php + controller
  - Verify: trend latest-wins test + PHP trend test
- [x] **T7 (P1, human: ~2d / CC: ~1h)** — list pages — Sales, Purchases, Products, Customers, Suppliers, Categories, Warehouses, Users per boards
  - Verify: flutter test; visual pass
- [x] **T8 (P1, human: ~1d / CC: ~40min)** — remaining pages — forms, insights, audit, notifications, AI chat, scanner, profile, login, signup, splash
  - Verify: forms_render_test + visual pass
- [ ] **T9 (P1, human: ~2h / CC: ~15min)** — verify & deploy — analyze, full tests, web build, deploy, check at 1440 and 390
  - Verify: flutter analyze; flutter test; manual/browse pass

```
+====================================================================+
|            ENG REVIEW — COMPLETION SUMMARY                         |
+====================================================================+
| Scope Challenge      | scope accepted as-is; smaller arrangement   |
| Section 1 (Arch)     | 2 findings (P1 transitions, P2 web RM), resolved |
| Section 2 (Quality)  | 1 finding (table size), resolved            |
| Section 3 (Tests)    | diagram produced, 0 gaps; test plan written |
| Section 4 (Perf)     | 0 blocking; index deferred with trigger     |
| Outside voice        | codex not installed — unavailable           |
| Failure modes        | 3 total, 0 critical gaps                    |
| Unresolved decisions | 0                                           |
| Reality rows         | 7/7, 0 unverified                           |
+====================================================================+
```

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 1 | CLEAR | mode: SCOPE_REDUCTION, 0 critical gaps |
| Outside Review | codex (not installed) | Independent 2nd opinion | 0 | unavailable | Codex CLI not installed; no completed external review |
| Eng Review | plan-eng-review (manual, autoplan guard fallback) | Architecture & tests (required) | 1 | CLEAR | 5 issues, 0 critical gaps |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | skipped | visuals approved directly by the user on the Claude Design canvas |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | skipped | not a developer-facing product (term match on "API" only) |

- **OUTSIDE COVERAGE:** codex — CEO and Eng phases unavailable (CLI not installed); no completed external review; native fallback not run.
- **VERDICT:** CEO + ENG CLEARED — ready to implement

NO UNRESOLVED DECISIONS
