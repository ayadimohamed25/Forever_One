<!-- /autoplan restore point: "D:\\foreverone\\.gstack\\tmp\\autoplan\\main-autoplan-restore-20261111-113929.md" -->
# ForeverOne — UI Fix Plan

_Drafted 2026-11-11 on `main` (7539520 + uncommitted AI-chat/l10n work)._
_Design sources: UI/UX Pro Max skill (Flutter stack, UX guidelines, design-system search) + the existing warm design system (`lib/core/theme/`)._

> **Status: REVIEWED, waiting for owner approval at the gate (bottom of the file).**
> The reviews ran by hand in autoplan order (CEO → Design → DX → Eng) with auto-decisions. The guarded `/autoplan` pipeline refused to run in this session: a compacted conversation counts as two roots in its journal (`competing_root`). Its documented fallback is to run each review by hand. The design review ran on Fable 5.2, at the owner's request.

---

## Implementation plan

### Goal
Fix the real UI defects found in a code audit of all 33 screens without changing the brand direction (warm cream canvas, dark ink, terracotta accent, Plus Jakarta Sans). Make the app readable (WCAG AA), navigable (no page pile-up), usable on desktop/web widths, and consistent (every screen on the shared design system).

### Audit findings (evidence)

| # | Severity | Problem | Evidence |
|---|----------|---------|----------|
| F1 | **High** | **Text contrast fails WCAG AA.** `textSecondary` #8C8378 is 3.73:1 on white and 3.23:1 on canvas. `textMuted` #B8AFA3 is 2.17:1 on white and 1.88:1 on canvas. The terracotta `accent` is 3.77:1 on canvas. Labels, subtitles, hints, drawer section labels and metadata all use these colours. | `core/theme/app_colors.dart`; contrast computed with the WCAG formula |
| F2 | **High** | **Drawer navigation stacks pages.** `context.push(route)` for top-level destinations means each drawer tap adds a page to the history. Back walks through every screen visited, and the browser history grows on web. | `shared/widgets/app_drawer.dart:68` |
| F3 | **High** | **No adaptive layout.** The app ships for web, Windows, macOS and Linux, but only 3 files read the screen width and only one uses `maxWidth`. On a 1440px window, lists, forms and full-width 56px buttons stretch edge to edge, and the sidebar is always a hidden drawer. | grep of `LayoutBuilder` / `MediaQuery` / `maxWidth` |
| F4 | **High** | **No auth guard in the router.** There is no `redirect`, so `/dashboard`, `/users` and the other routes open without a session on web (deep link or refresh). After logout, Back can return to protected screens. | `core/router/app_router.dart` (only `initialLocation: '/login'`) |
| F5 | Medium | **Screens off the design system.** `supplier_detail_page` has 15 raw `fontSize` values and 7 raw `Colors.green` / `Colors.orange`. `scan_page` (10), `payment_page` (9), `signup_page` (7) and `users_page` (5) also use raw font sizes. Seven other screens have stray `Colors.*` values. | grep counts per file |
| F6 | Medium | **Icon buttons lack labels.** Only 2 of 17 `IconButton`s have a `tooltip`, and there are 0 `Semantics` wrappers. Screen readers announce "button", and desktop users get no hover hint. | grep |
| F7 | Medium | **No visible keyboard focus.** The theme sets `highlightColor: transparent`, and the custom `InkWell` items (drawer, cards, row menus) have no focus ring. Keyboard and Tab users on web/desktop can't see where they are. | `core/theme/app_theme.dart`, `app_drawer.dart` |
| F8 | Low | **Loading is a bare spinner.** All 26 loading states are a centred `CircularProgressIndicator`, with no skeletons, so lists jump when data arrives. | grep |
| F9 | Low | **Misleading names.** `*_form_dialog.dart` files actually push full-page forms (the commit "full-page forms" kept the old names). New contributors will look for dialogs that don't exist. | `features/*/presentation/widgets/*_form_dialog.dart` |
| F10 | Low | **Category colours as raw hex** in the domain entity and form, not as theme tokens. | `stock/domain/entities/category_entity.dart`, `category_form_page.dart` |
| F11 | Low | **SnackBars built inline in 18 files** with no shared success/error helper, so styles and durations drift. | grep |
| F12 | **High** | **No session restore** _(found in the CEO review)_. The signed-in user exists only in memory (`AuthState.user`). After a web refresh or app restart, the token is still in secure storage but `user` is null, so every `can()` check fails and the sidebar shows only Dashboard and Profile. | `features/auth/presentation/providers/auth_provider.dart:20-38`, `app_drawer.dart:132` |
| F13 | **High** | **Logout leaves the user in memory** _(CEO review)_. `logout()` deletes the token but never resets `authNotifierProvider`, so a guard that checks `user != null` would let Back return to protected screens. | `auth_repository_impl.dart:32-33`, `app_drawer.dart:122-123` |
| F14 | Medium | **No 401 handling** _(CEO review)_. An expired token makes every screen show API errors instead of returning to login. | `core/network/auth_interceptor.dart` (only `onRequest`) |

`flutter analyze`: no issues. Localization: no hardcoded user-facing strings were found, so this area is already good.

### Changes

**Step 1: Accessible colour tokens (F1)** in `core/theme/app_colors.dart`, `app_theme.dart` and `app_widgets.dart`

Same hues, lightness only. Values from the design review, with contrast computed by the WCAG formula:

| Token | Old | New | On white | On canvas | Worst soft surface |
|---|---|---|---|---|---|
| `textSecondary` | #8C8378 | **#6B6258** | 5.98 | 5.18 | 4.70 on `border` |
| `textMuted` (disabled or decorative only) | #B8AFA3 | **#8C8378** | 3.73 | 3.23 | 3.10 on `fill` |
| `accentText` (new: accent used as text) | — | **#A8432D** | 5.99 | 5.19 | 4.89 on `accentSoft` |
| `accentStrong` (new: fill under white text) | — | **#B54932** | white on it 5.30 | — | — |
| `success` | #3F7D4E | **#356E45** | 6.06 | 5.25 | 5.18 on `successSoft` |
| `warning` | #A16207 | **#925807** | 5.80 | 5.02 | 5.12 on `warningSoft` |

`accent` #C8553D stays for fills, icons and the focus ring. `danger` already passes.

**Where they're used:**
- Point these at `accentText`: `badgeColors().fg` (`app_widgets.dart:11-24`), the chip `secondaryLabelStyle` (`app_theme.dart:225`) and the 31 `color: AppColors.accent` text sites.
- Input hints (`app_theme.dart:195`) and drawer section labels carry information, so they move to `textSecondary`.
- The dashboard revenue card (`dashboard_page.dart:76,85`) gets an `accentStrong` fill with solid white labels. Today it's white on #C8553D (4.35), and the 78% white label is 3.27.
- Never put `textSecondary` on ink (2.68).

**Test:** a unit test asserts every text/surface pair above stays at 4.5 or more, so contrast can't regress.

**Step 2: Navigation, session and auth guard (F2, F4, F12, F13, F14)** in `core/router/app_router.dart`, `auth_provider.dart`, `auth_interceptor.dart` and `app_drawer.dart`
- Drawer destinations use `context.go(route)` instead of `push`. Detail and form pages keep using `push`.
- **Session restore:** add `AuthNotifier.restore()`. With a stored `auth_token`, it calls the existing `GET /profile` (`UserRepository.getProfile`, which already returns a `UserEntity` with `permissions`) and sets `user`. On a 401 it deletes the token and signs the user out. On a network error or timeout (10s) it keeps the token and shows the login screen with a "Couldn't reach the server" message and Retry. `AuthState` gains a `status`: `unknown`, `authenticated` or `unauthenticated`. The app shows a small branded loading screen while the status is `unknown`.
- **Logout:** add `AuthNotifier.logout()`, which deletes the token and resets the state to `unauthenticated`. The drawer calls this instead of the repository directly.
- **401 handling:** `AuthInterceptor.onError` on 401 deletes the token and calls a callback that sets the auth state to `unauthenticated`, so the redirect sends the user to `/login`. It is skipped for `/auth/login` and `/auth/register` themselves.
- **Router as a provider:** `appRouter` becomes `routerProvider` (`Provider<GoRouter>`) with `refreshListenable` bound to the auth status. `redirect` works like this:
  - status `unknown` → stay put (the loading screen shows)
  - unauthenticated, on any route except `/login` and `/signup` → `/login?from=<route>`
  - authenticated, on `/login` or `/signup` → `from`, or `/dashboard`
  - authenticated but missing that route's permission → `/dashboard`
- **One route→permission map** (`core/router/route_permissions.dart`) drives both the redirect and the menu items (`/products`→`view_products` … `/audit`→`view_audit`), so the sidebar and the guard can't disagree.
- **Android Back** on a top-level page other than Dashboard goes to `/dashboard`. Back on Dashboard exits the app, as before.

**Step 3: Adaptive shell (F3)** in a new `shared/widgets/app_shell.dart` and `app_router.dart`
- Wrap the authenticated routes in a GoRouter `ShellRoute` with one `AppShell` widget.
- Extract the drawer's items, section labels and permission checks into `AppNavList`, so the drawer and the sidebar share one source of truth.

**Breakpoints** (using `LayoutBuilder`):

| Width | Navigation |
|---|---|
| < 840px | The current modal drawer plus page header (unchanged on mobile), built from `AppNavList` with 48-high items. |
| 840–1199px | A permanent **labelled** sidebar, 248 wide. Not an icon-only rail: 13 icons in 3 groups is too many for a rail. |
| ≥ 1200px | The same sidebar, 264 wide. |

A user toggle collapses the sidebar to a 72-wide rail (icons with tooltips, sections become dividers). The choice is saved.

**Sidebar spec** (from the design review):
- **Surface:** canvas, with a 1px `border` on the right edge, no shadow and no rounded corner.
- **Items:** 44 high, radius 12, 12px horizontal inset, 20px icon, 12px gap, 14/500 label on one line with ellipsis.
- **Selected:** white fill with `cardShadow`, weight 600, `textPrimary` label and an `accent` icon. Today `fill` on canvas is 1.04:1, so the selection is nearly invisible (`app_drawer.dart:62`).
- **Hover:** `fill`.
- **Section labels:** 11/600, tracking 0.8, `textSecondary`, 20px above and 6px below.
- **Layout:** identity block on top; language and logout pinned to the bottom.

**Content widths** (centred): lists 880, detail pages and AI chat 760, forms 720. The dashboard is 1200 wide on a 12-column grid: revenue card 6 columns, three stat cards 2 each, then chart 8 and alerts 4. AI bubbles cap at 560 instead of 80% of the window (`ai_chat_page.dart:191`).

**FAB:** at 840px and above, each list page's FAB (9 of them) becomes a primary button in the page header. Below 840, it stays a FAB.

**Buttons:**
- The theme `minimumSize` changes from `Size(double.infinity, 56)` to `Size(88, 48)`.
- `AppBottomActionBar` forces 56px high: full width below 840, right-aligned with max 320 at 840 and above.
- Wrap these explicitly to keep them full width: login, signup, `dashboard_page.dart:887`, `stock_movement_page.dart:261`, `profile_edit_page.dart:131`, and the two "add line" outlined buttons.
- Keep the login loading placeholder (`login_page.dart:167`) at 56 so the layout doesn't jump. Dialog actions need no change.

**Plumbing:** remove the per-page `drawer:` (13 pages) and the `currentRoute` prop. The shell reads the location from `GoRouterState`.

**Pushed pages:** detail and form pages opened with `Navigator.push` (14 files) go on the **root** navigator, using `Navigator.of(context, rootNavigator: true)` in the renamed `open*Form` helpers. So forms are full-screen with their own back bar on mobile. On desktop, the sidebar stays only for `go` routes, which is consistent with "a form is a focused task".

**Step 4: Bring outlier screens onto the system (F5, F10)**
- `supplier_detail_page.dart`: replace the raw `TextStyle` / `fontSize` values with `AppTheme.*` styles, and `Colors.green` / `orange` with `AppColors.success` / `warning`. Rebuild the stat tiles and info rows with `AppCard`, `AppInfoRow`, `AppTrailingStat` and `AppStatusChip`.
- `scan_page`, `payment_page`, `signup_page`, `users_page`: same treatment.
- The 7 stray `Colors.*` files go to tokens.
- Category colours: a named swatch list in `AppColors.categorySwatches`. The entity stores the index or hex, and the form picks from the swatches.

**Step 5: Accessibility pass (F6, F7)**
- Add a `tooltip` to every `IconButton` and `AppIconButton` (also used as the semantic label), with l10n keys in EN and FR.
- **Focus ring, implemented once in a new `AppPressable`:**
  - 2px `accent`, 2px gap, radius of the widget plus 4.
  - Shown for keyboard only (`FocusHighlightMode.traditional`), with a 120ms fade and none under reduced motion.
  - Drawn as a foreground decoration outside the clip, because `AppCard` clips (`app_widgets.dart:139`).
  - Contrast: 3.77 on canvas, 4.35 on white, 3.62 on `fill`. All pass 3:1.
  - The theme `focusColor` becomes transparent so there's no double indicator. The focused input border goes from 1.5 to 2.
- **Keyboard reach:** the 5 `GestureDetector` controls can't take focus (`app_widgets.dart:640`, `app_drawer.dart:377`, `dashboard_page.dart:524` and others). Convert them to `AppPressable`.
- **Targets of at least 48×48** (the Android 48dp rule is stricter than 44):
  - `AppIconButton` 40 → 48 hit area (`app_page_header.dart:116-118`)
  - language chips (about 28 high, `app_drawer.dart:381`)
  - the shrink-wrapped dashboard `TextButton` (`dashboard_page.dart:867`)

**Step 6: States and polish (F8, F9, F11, plus the design review's error and empty states)**
- **`AppErrorState` (new, high priority):** icon, title, a one-line cause and a Retry `FilledButton`. Use it on every list page and the dashboard.
  - Today a failed dashboard load spins forever (`dashboard_page.dart:798` with `dashboard_provider.dart:29`), with a hardcoded English message.
  - A failed customers load shows "No customers, tap + to add" (`customers_page.dart:283-294`).
  - Providers must expose an error separately from empty data.
- **`AppEmptyState` gets an action:** optional `actionLabel` / `onAction`, and the icon becomes `iconMuted`. The copy stops saying "tap +", since the FAB becomes a header button on desktop.
- **`AppSkeletonList`:**
  - white card rows mirroring the real row: 40 tile, 60% and 35% lines, trailing stub
  - blocks pulse #F0E9E0 ↔ #E2D9CD over 1.2s (static under reduced motion), 6 rows
  - shown only after 200ms, so fast loads don't flash, with one "Loading" semantics label
  - the spinner stays for in-button and pagination loading
- **README run steps** (Flutter version, backend base URL, `flutter run -d chrome`).
- **`DESIGN.md`** at the repo root records the tokens, breakpoints, sidebar spec, focus ring and component list, so later screens stay consistent.
- Rename `*_form_dialog.dart` to `*_form_route.dart` and `show*FormDialog` to `open*Form`.
- `AppSnack.success / error(context, msg)` in `shared/widgets`, replacing the inline SnackBars.

### Verification
- `flutter analyze` clean, and `flutter test` green, with new tests for:
  - token contrast ratios (Step 1)
  - the router redirect: logged out goes to `/login`, logged in on `/login` goes to `/dashboard`, a non-admin on `/users` goes to `/dashboard`, `unknown` status means no redirect (no loop)
  - session: restore success; restore on 401 deletes the token; restore on network error keeps it; logout resets the state; an interceptor 401 signs the user out
  - the shell: sidebar visible at 1000px wide, drawer at 400px (widget test with `tester.view.physicalSize`); the rail toggle
  - states: the dashboard and one list page show `AppErrorState` on a failed load, and Retry reloads
- Manual QA with `flutter run -d chrome` at 375, 768, 1024 and 1440px: navigate through all drawer items and check Back, keyboard Tab through the dashboard, and log out then press Back.
- Run `/design-review` (gstack) on the running web build after the changes.

### NOT in scope
- Changing the brand palette or font. The audit only fixes contrast; a full rebrand would be a user decision.
- Dark mode. It's worth doing next, and Step 1's token cleanup prepares for it, but it doubles the visual QA.
- New features from the two shared claude.ai conversations. Those still need their text pasted in.
- Backend or API changes.

### Order and effort
Steps 1 and 2 first (small, highest impact), then 3 (the largest), then 4, 5 and 6.

| Step | Files touched | Effort |
|---|---|---|
| 1 | 3 + about 10 accent-text sites + test | ~45 min |
| 2 | 6 (router, new permission map, auth provider, interceptor, drawer, main) + tests | ~2.5 h |
| 3 | about 25 (shell, nav list, 13 pages drop `drawer:`, 9 FABs, button ripple) | ~4 h |
| 4 | ~12 | ~2 h |
| 5 | ~15 + l10n | ~2 h |
| 6 | about 25 + `DESIGN.md` | ~2.5 h |

Total about 14h for a human team; about 2–3h with CC + gstack. One PR, in commit order 1 → 6.

---

## Review record

<!-- AUTONOMOUS DECISION LOG -->
## Decision Audit Trail

Pre-review decisions made while drafting (classified with the autoplan principles). The full autoplan run will add its own rows.

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|----------------|-----------|-----------|----------|
| 1 | Draft | Keep the warm palette and only darken text tokens | Mechanical | P4 DRY / user direction | The palette was a deliberate recent commit ("Warm design system"). UI/UX Pro Max suggested navy and blue, but replacing the brand is the user's call. | Adopt Pro Max's navy/blue palette |
| 2 | Draft | Fix the auth guard as part of the UI plan | Taste | P2 Boil lakes | The router is already being edited for the shell and drawer navigation, so the guard is in the blast radius and under 1 day of work. It's also a security gap. | Leave for a separate ticket |
| 3 | Draft | One `ShellRoute` + `AppShell` with a shared `AppNavList` | Mechanical | P4 DRY, P5 Explicit | One nav source for the drawer and sidebar. Removes per-page drawer plumbing. | A separate sidebar widget per breakpoint |
| 4 | Draft | Breakpoints at 840 and 1200 | Mechanical | P3 Pragmatic | These match the Material 3 window size classes (medium/expanded). | Custom breakpoints |
| 5 | Draft | Defer dark mode | Taste | P6 Bias to action | Doubles the visual QA. Step 1 makes it cheap later. | Include dark mode now |
| 6 | Draft | Rename `*_form_dialog` files | Taste | P5 Explicit | Cheap (about 8 imports), and the names currently mislead. | Leave the names |
| 7 | CEO | Review mode: HOLD SCOPE | Mechanical | P1 + P2 | This is a fix/refactor plan. About 40 files change because every page drops its own `drawer:`, which is mechanical, not new capability. Scope reduction would cut F3 (desktop layout), which is half the visible value. | SCOPE REDUCTION, EXPANSION |
| 8 | CEO | Add session restore, logout reset and 401 handling to Step 2 | Mechanical | P1 Completeness | Without them the guard breaks web refresh (F12) or leaks protected screens after logout (F13). That would be a guard that ships broken. Same files, under 1 day. | Guard only on `/users` and `/audit` |
| 9 | CEO | Guard every route through one route→permission map | Mechanical | P4 DRY | The sidebar already checks 12 permissions (`app_drawer.dart:132-205`). A second hand-kept list in the router would drift. | Gate only `/users` and `/audit` |
| 10 | CEO | Use `GET /profile` for session restore, no new endpoint | Taste | P4 DRY, P6 | `UserRepository.getProfile` already returns a `UserEntity`. **Unverified:** that the backend includes `permissions` in `/profile`. If it doesn't, the backend needs a 1-line change. Verify first. | New `/auth/me` endpoint |
| 11 | CEO | Keep dark mode and the features from the shared conversations out | Mechanical | P6 | Already recorded in NOT in scope. The conversations still can't be read. | — |
| 12 | Design | Adopt the reviewer's token table (`accentStrong`, retuned `success` / `warning`, hints on `textSecondary`) | Mechanical | P1 + P5 | Badge pairs (3.55–4.34) and white on accent (4.35) still fail after the draft Step 1. Lightness only, so the brand holds. | Draft Step 1 as written |
| 13 | Design | Labelled sidebar from 840, not an icon rail | Mechanical | P5 Explicit | 13 destinations in 3 groups is too many for a rail. | Rail at 840–1199 |
| 14 | Design | Rail collapse as a saved user toggle | **Taste** | P1 vs P6 | Nice for power users, but it adds about 1 file and a preference. You could drop it and lose nothing essential. | No collapse |
| 15 | Design | Tap targets 48×48 | Mechanical | P1 | Android 48dp is stricter than 44, and the app ships on Android. | 44×44 |
| 16 | Design | Buttons min 88×48, action bar 56, explicit full-width wraps at 7 sites | Mechanical | P5 | Avoids layout jumps (`login_page.dart:167`) and keeps form CTAs full width on mobile. | Drop to 64×48 everywhere |
| 17 | Design | Add `AppErrorState` + an empty-state action to Step 6 | Mechanical | P1 Completeness | A failed load currently spins forever or lies ("No customers"). This is a correctness bug in the UI. | Skeletons only |
| 18 | Design | FAB → header button at ≥ 840 | **Taste** | P5 | A FAB floating 1000px from the content reads poorly on desktop, but this changes 9 pages. | Keep FAB everywhere |
| 19 | Design | Per-type content widths (880/760/720, dashboard 12-column grid at 1200) | Mechanical | P1 | A single 1200 cap is a stretched phone layout. | One 1200 cap |
| 20 | Design | Add `DESIGN.md` | Mechanical | P4 DRY | One written source for tokens and specs. Cheap. | None |
| 21 | DX | Run the DX phase, but scope it to contributor experience | Mechanical | rule | The scope check matched "shell" (app shell) and "API" (backend). That's a false positive for a developer product, but the rule says not to negate it. So it reviews the experience of the next developer touching this code. | Skip the phase |
| 22 | Eng | Forms and details push on the **root** navigator | Mechanical | P5 Explicit | Avoids pushing inside the shell's nested navigator, where Back and the sidebar would behave inconsistently between mobile and desktop. One change point: the `open*Form` helpers. | Shell navigator |
| 23 | Eng | `AuthState.status` enum instead of nullable-user checks | Mechanical | P5 | A tri-state (`unknown`) is the only way to avoid a redirect loop during restore. | `user == null` checks |
| 24 | Eng | The interceptor talks to auth through an injected callback | Mechanical | P3 | `ApiClient` is built in `apiClientProvider` with no `ref`, so pass `onUnauthorized` at construction and avoid a provider cycle. | Global singleton |
| 25 | Eng | One PR, 6 commits in step order | Mechanical | P6 | No ship policy file; each commit compiles and passes tests on its own. | Split PRs |

---

## CEO review (Phase 1)

**Mode:** HOLD SCOPE. Codex isn't installed, so there's no outside voice, and the consensus columns are N/A.

### 0A. Premise challenge
The real problem is that the app looks finished on a phone screenshot but fails three groups of real users:
- people reading small grey text (most labels fail AA)
- people on desktop or web (stretched layout, a lost session on refresh)
- anyone pressing Back (a pile of screens, and protected screens after logout)

The plan targets those directly, not a proxy. Doing nothing means desktop users see a broken-looking app, a web refresh empties the menu, and contrast stays below the legal accessibility bar in the EU (EAA, in force since June 2025), which matters for a B2B product sold to companies.

| Premise | Claim | Receipt | Verdict |
|---|---|---|---|
| P1 | Secondary text fails AA | `app_colors.dart:22-24` + WCAG formula: 3.73 / 3.23 / 2.17 / 1.88 | verified |
| P2 | The drawer stacks pages | `app_drawer.dart:68` `context.push(route)` | verified |
| P3 | No adaptive layout | grep: 3 files use width, 1 `maxWidth` (`ai_chat_page.dart:191`) | verified |
| P4 | No route guard | `app_router.dart:18-19`, no `redirect` | verified |
| P5 | The user isn't restored on restart | `auth_provider.dart:27-28` initial `AuthState()`, no read of the token outside the interceptor | verified |
| P6 | `/profile` returns permissions | `user_model.dart:17` parses `permissions`, but the backend response hasn't been checked | **unverified** |
| P7 | The app ships on desktop/web | `web/`, `windows/`, `macos/`, `linux/` folders exist | verified |

`unverified=1`

### 0B. Existing code leverage
| Sub-problem | Reuse |
|---|---|
| Contrast | `AppColors` tokens. Change the values only; all 33 screens inherit them. |
| Sidebar | `AppDrawer`'s `_navItem`, `_sectionLabel` and permission checks get extracted into `AppNavList`. No rebuild. |
| Session restore | `UserRepository.getProfile` → `UserEntity` |
| Outlier screens | `AppCard`, `AppInfoRow`, `AppTrailingStat`, `AppStatusChip`, `AppEmptyState` (already in `app_widgets.dart`) |
| Routing | go_router 14 `ShellRoute` and `redirect`, both already a dependency |

### 0C. Dream state
```
CURRENT                         THIS PLAN                          12-MONTH IDEAL
phone-first UI, grey text,  ->  AA contrast, guarded routes,   ->  one adaptive app: phone, tablet,
lost session on refresh,        restored sessions, sidebar on      desktop; dark mode; keyboard-first
stacked navigation              desktop, consistent screens        power-user flows; skeleton loads
```
This plan moves straight toward the ideal and leaves dark mode cheap, because the token cleanup comes first.

### Review sections (1–10, condensed to findings)
1. **Architecture:** the router has to become a Riverpod provider to read auth. That's a small, known go_router pattern. **Finding** (accepted, decision 8).
2. **Error and rescue map:** see the registry below.
3. **Security:** the client-side guard is UX, not security. The backend must still enforce permissions per endpoint (assumed, outside this plan). The token stays in `flutter_secure_storage`; on web that's localStorage-backed, which is an existing risk and not made worse here.
4. **Data flow:** login or restore → `AuthState(status, user)` → router refresh → redirect → shell → nav list. It's a single source.
5. **Edge cases:** double-tapping a drawer item (`go` is idempotent, fixed); refresh on `/users` without permission (redirect after restore, covered); a slow `/profile` (loading screen; it needs a 10s timeout, then the error state on the login screen).
6. **Tests:** see the Eng phase.
7. **Performance:** no concern. One extra `/profile` call at startup.
8. **Observability:** log restore failures and 401 redirects with `debugPrint` in debug builds. There's no analytics stack yet.
9. **Deploy and rollback:** one PR, with no backend change unless P6 fails.
10. **Long-term:** the route→permission map becomes the single place to add a screen.

### Error & Rescue registry
| Error | Trigger | Handler | User sees | Test |
|---|---|---|---|---|
| Restore fails (network) | Startup without connectivity | `restore()` catches → unauthenticated, but keeps the token | Login screen with a "Couldn't reach server" banner and Retry | unit: restore network failure |
| Restore fails (401) | Expired token | Delete the token → unauthenticated | Login screen | unit |
| 401 mid-session | Token revoked | Interceptor `onError` → logout callback | Redirect to `/login?from=…`, then back to the same screen after login | unit: interceptor |
| Missing permission | Deep link to `/users` as an employee | redirect → `/dashboard` | Dashboard | router test |
| `/profile` lacks permissions | Backend shape | `permissions` defaults to `[]` | Empty menu (the bug stays) | **Verify P6 before building** |

### Failure modes
| Mode | Severity | Mitigation |
|---|---|---|
| A redirect loop (`/login` ↔ `/dashboard`) when status flips | Critical | `unknown` → no redirect; router tests for each status |
| Restore treats a network error as logged out and deletes a good token | High | Only delete the token on 401, never on a network error |
| Shell plus `Navigator.push` forms render inside the shell on mobile | Medium | Covered in the Eng phase |

### NOT in scope (CEO)
Dark mode, a rebrand, the features from the shared conversations, backend permission enforcement (assumed to exist).

### Completion summary
HOLD SCOPE. 3 premises added (F12–F14), 1 unverified (P6). Step 2 grew from about 1h to about 2.5h. No scope cuts.

REALITY: premise-table finding unverified=1 (P6 /profile permissions) lib/features/auth/data/models/user_model.dart:17
REALITY: already-done pass no commits on origin/main touching lib/core or lib/shared since 2026-11-10; head is 7539520 lib/core/router/app_router.dart:18-19
REALITY: surface-check finding GET /profile exists lib/features/users/data/datasources/user_remote_datasource.dart:35; /auth/me does not exist and isn't used
REALITY: binding-decisions pass gstack-decision-search returned none; the warm palette is the user's direction (commit 3d4e203)
REALITY: numbers pass contrast ratios measured with the WCAG formula; effort estimated lib/core/theme/app_colors.dart:22-24
REALITY: deferred-asks pass no linked issue lib/core/router/app_router.dart:18
REALITY: pr-count pass no ship-policy.json → 1 PR (docs/plans/ui-fixes-plan.md:1)

<!-- autoplan-accepted:ceo -->
- Step 2 includes session restore via `GET /profile`. Delete the token only on 401, keep it on network error or timeout. Tests: restore success, 401, network error.
- `AuthNotifier.logout()` resets the state; the drawer uses it. Test: logout resets.
- `AuthInterceptor.onError` 401 signs the user out, except on `/auth/login` and `/auth/register`. Test: interceptor 401.
- Every route is guarded by one route→permission map shared with the nav list. Test: non-permitted deep link → `/dashboard`.
- Verify that `/profile` returns `permissions` before building (P6).
<!-- /autoplan-accepted:ceo -->

---

## Design review (Phase 2), run on Fable 5.2

**Reviewer:** a Fable 5.2 subagent applying the `/plan-design-review` methodology plus UI/UX Pro Max data. It read the plan, the theme, the shared widgets and 4 sample screens, and edited no files. Outside voice: none (Codex isn't installed).

| Dimension | Now | Draft plan | Amended plan |
|---|---|---|---|
| 1 Information architecture | 5 | 6 | 8 |
| 2 Interaction states | 3 | 4 | 8 |
| 3 Journey | 4 | 6 | 7 |
| 4 AI slop / specificity | 6 | 6 | 7 |
| 5 Design system | 6 | 7 | 9 |
| 6 Responsive / accessibility | 2 | 6 | 8 |
| 7 Unresolved decisions | — | 2 of 10 settled | 10 of 10 |

**Litmus:**
- Brand unmistakable: yes.
- One visual anchor: yes (the terracotta revenue card).
- Scannable by headings: yes.
- Cards necessary: **no**. Every row is a card. Accepted for now: changing it is a restyle, not a fix.
- Premium without shadows: yes.

**Issues raised, all decided** (decisions 12–20):
1. Failed loads have no error state.
2. Badge pairs fail AA.
3. White on accent fails.
4. The selected nav item is invisible (1.04:1).
5. The 840–1199 sidebar is undefined.
6. The button change needs a list of affected sites.
7. Touch targets and keyboard reach.
8. A width cap is not a desktop layout.
9. The empty state has no action.
10. The skeleton is unspecified.

All were folded into Steps 1, 3, 5 and 6.

**Flagged, not changed:** the methodology lists cream plus terracotta as one of three stock "AI-looking" palettes. The reviewer judged that the ink buttons and the sans typeface keep it distinct. The brand stays as you chose it.

<!-- autoplan-accepted:design -->
- Token table in Step 1, enforced by a contrast unit test (all text pairs ≥ 4.5).
- Labelled sidebar from 840 per the sidebar spec. The collapse toggle is a taste item (decision 14).
- 48×48 targets, an `AppPressable` focus ring per spec, `GestureDetector`s converted.
- Button min 88×48, action bar 56, 7 explicit full-width sites, login placeholder kept at 56.
- `AppErrorState` on every list page and the dashboard. Test: failed load shows error and Retry reloads.
- `AppEmptyState` action, skeleton spec, per-type content widths, FAB → header button at ≥ 840 (taste, decision 18), `DESIGN.md`.
<!-- /autoplan-accepted:design -->

---

## DX review (Phase 2.5)

**Scope note:** ForeverOne is an end-user ERP, not a developer tool. The scope check fired on "shell" and "API" (decision 21). So this phase reviews the **next developer's experience** of adding or changing a screen after this plan lands.

| Dimension | Score now → after | Note |
|---|---|---|
| 1 Getting started | 5 → 6 | `README.md` is the Flutter template. Add run steps and the backend URL in `DESIGN.md` or README (cheap, accepted). |
| 2 Adding a screen | 3 → 8 | Today: a route, a page with `drawer:` + `currentRoute`, and a hand-added drawer item with its permission. After: a route plus one row in `route_permissions.dart`. |
| 3 Discoverability | 4 → 7 | `DESIGN.md` + the `app_widgets.dart` catalogue. Misleading `*_form_dialog` names fixed. |
| 4 Error messages | 5 → 6 | The redirect logs reasons with `debugPrint` in debug. |
| 5 Consistency | 5 → 8 | Tokens enforced by test; outlier screens migrated. |
| 6 Testing | 3 → 6 | 4 test files today. The plan adds router, session, shell and state tests. |
| 7 Docs | 2 → 6 | `DESIGN.md`. |
| 8 Upgrade path | 6 → 7 | go_router 14 `ShellRoute` / `redirect` are stable APIs. |

**Developer journey ("add a Reports screen"):** add the route under the `ShellRoute` → add `'/reports': 'view_reports'` to the map → the page uses `AppPageHeader` plus `AppErrorState` / `AppSkeletonList` → done. The nav item and guard follow automatically.

**TTHW (time to a working new screen):** today about 20 min, with 3 files and an easy-to-miss permission mismatch. Target about 8 min, with 2 files.

**Empathy:** a new contributor today copies a page, forgets the drawer item or the permission, and ships a screen that some roles can open but never see in the menu.

**DX checklist:** route map, `DESIGN.md`, README run steps, debug logs in the redirect.

<!-- autoplan-accepted:dx -->
- Add README run steps (flutter version, backend base URL, `flutter run -d chrome`) alongside `DESIGN.md`.
- `route_permissions.dart` is the single place to register a screen's permission.
<!-- /autoplan-accepted:dx -->

---

## Eng review (Phase 3), run last on the amended plan

### Scope challenge
| Claim | Receipt | Verdict |
|---|---|---|
| The router is a global, not a provider | `lib/core/router/app_router.dart:18` `final appRouter = GoRouter(` | verified, so it must become `routerProvider` |
| `main.dart` wires `routerConfig: appRouter` | `lib/main.dart:22` | verified, so it switches to `ref.watch(routerProvider)` |
| `ApiClient` is built without `ref` | `lib/features/auth/presentation/providers/auth_provider.dart:9` | verified (decision 24) |
| Forms are pushed with `MaterialPageRoute` | 14 files, e.g. `lib/features/stock/presentation/pages/categories_page.dart:46` | verified (decision 22) |
| 13 pages pass `drawer:` | grep, e.g. `lib/features/customers/presentation/pages/customers_page.dart:256` | verified |
| Profile returns `UserEntity` | `lib/features/users/data/repositories/user_repository_impl.dart:67-69` | verified; backend permissions unverified (P6) |

8+ files and 3 new classes (`AppShell`, `AppNavList`, `AppPressable`) plus 2 new state widgets: this passes the complexity check. Each one replaces scattered code; none is speculative.

### Architecture
```
 main.dart ── ProviderScope
    │
    ▼
 MyApp ── ref.watch(routerProvider) ──► GoRouter
                                          │ refreshListenable = authStatusListenable
                                          │ redirect(state):
                                          │   unknown            -> null (LoadingScreen)
                                          │   unauth & !public   -> /login?from=
                                          │   auth & public      -> from ?? /dashboard
                                          │   auth & !can(perm)  -> /dashboard
                                          │        ▲ routePermissions map
                                          ▼
     /login  /signup          ShellRoute(builder: AppShell)
                                 │  LayoutBuilder
                                 ├─ <840 : Scaffold(drawer: Drawer(AppNavList))
                                 └─ ≥840 : Row[Sidebar(AppNavList, 248|264|72), content(maxWidth)]
                                 │
                                 └─ /dashboard /products … /profile  (pages: no drawer)
                                        │ open*Form → Navigator(root).push(FormPage)

 AuthNotifier(status,user) ◄── restore()/login()/logout()
        ▲                            │ GET /profile
        └── onUnauthorized ◄── AuthInterceptor.onError(401) ◄── Dio(ApiClient)
```

### Code path → test map
| Code path | Test |
|---|---|
| `AuthNotifier.restore` (ok, 401, network) | `test/auth_notifier_test.dart`, 3 cases with a mocktail repo |
| `AuthNotifier.logout` | same file |
| `AuthInterceptor.onError` 401 / skip login | `test/auth_interceptor_test.dart` |
| `redirect` × 4 statuses + permission | `test/router_redirect_test.dart`: pure function `computeRedirect(status, user, location)`, extracted for testability |
| `AppShell` breakpoints + rail toggle | `test/app_shell_test.dart`, widget tests at 400, 1000 and 1300 width |
| Token contrast | `test/app_colors_contrast_test.dart` |
| `AppErrorState` Retry | `test/dashboard_error_test.dart` |

The test plan is also written to `~/.gstack/projects/ayadimohamed25-Forever_One/main-ui-fixes-test-plan.md`.

### Failure modes registry
| Failure | Likelihood | Impact | Critical gap? | Mitigation |
|---|---|---|---|---|
| Redirect loop on a status flip | Med | App unusable | **yes**, until tested | `unknown` → null + `computeRedirect` unit tests |
| `/profile` without `permissions` | Med | Empty menu after refresh | **yes**, until verified | Verify P6 first. Fallback: re-login on restart (status quo) |
| Token deleted on a flaky network | Low | Surprise logout | no | Delete only on 401 |
| Root-navigator push breaks `context.pop` in forms | Low | Back broken in forms | no | Forms already use `Navigator.pop`; covered by manual QA |
| `GoRouterState` location vs nested detail routes | Low | Wrong selected item | no | Match on the first path segment |
| Button ripple causes layout regressions | Med | Visual | no | The list of 7 explicit sites + manual QA at 4 widths |

### NOT in scope (Eng)
Backend changes (unless P6 fails), migrating `Navigator.push` detail pages to go_router routes, state-management refactors beyond `AuthState`.

### What already exists
`AppDrawer` permission logic, `AppEmptyState`, `AppCard`, `AppInfoRow`, the `UserRepository.getProfile` call, go_router 14, mocktail (already in dependencies) for tests.

### Completion summary
The architecture is sound. 2 critical gaps, both turned into tasks: the redirect-loop tests, and verifying P6. 4 eng decisions (22–25). Effort is about 14h for a human team, about 2–3h with CC + gstack.

REALITY: premise-table pass unverified=1 (P6) lib/features/users/data/repositories/user_repository_impl.dart:67-69
REALITY: already-done pass no overlapping commits on origin/main lib/core/router/app_router.dart:18
REALITY: surface-check pass go_router 14 has ShellRoute and redirect; GET /profile exists lib/features/users/data/datasources/user_remote_datasource.dart:35
REALITY: binding-decisions pass none recorded; the user's palette is kept lib/core/theme/app_colors.dart:1-10
REALITY: numbers pass file counts measured by grep; effort estimated lib/features/customers/presentation/pages/customers_page.dart:256
REALITY: deferred-asks pass no linked issue lib/main.dart:22
REALITY: pr-count pass 1 PR, 6 commits lib/main.dart:1

<!-- autoplan-accepted:eng -->
- `routerProvider` + a pure `computeRedirect` with unit tests for all statuses (no loop).
- `AuthState.status` enum; the interceptor gets an injected `onUnauthorized`.
- `open*Form` helpers push on the root navigator.
- Tests listed in the code path → test map. Test plan file at `~/.gstack/projects/ayadimohamed25-Forever_One/main-ui-fixes-test-plan.md`.
<!-- /autoplan-accepted:eng -->

---

## /autoplan Review Complete: approval gate

**URGENT, outside this plan:** none found. (The client-side guard isn't security. The backend must enforce permissions per endpoint; that's assumed, not verified.)

**Plan summary:** fix contrast, navigation, the session/auth guard, the desktop layout, consistency, accessibility and load states in one PR of 6 commits. The warm brand is kept.

**Decisions:** 25 total. 21 mechanical (auto-decided), 4 taste (decisions 2, 10, 14, 18), 0 user challenges.

**Review scores:**

| Phase | Result | Outside voice |
|---|---|---|
| CEO | HOLD SCOPE, reality 7/7 complete, unverified=1 | Codex unavailable |
| Design (Fable 5.2) | 2/10 → 7/10 overall, all 7 dimensions at least 7 after fixes | Codex unavailable |
| DX | Contributor TTHW 20 → 8 min | Codex unavailable |
| Eng | 2 critical gaps → tasks | Codex unavailable |

**Cross-phase themes:**
- The session/permission single source came up in CEO, DX and Eng.
- Error/empty states came up in CEO (error map) and Design.

**Taste decisions for you to confirm** (each defaults to its recommendation):
- **d1** (decision 2): the auth guard ships in this UI PR. Recommended: yes.
- **d2** (decision 10): session restore via the existing `/profile` call, after checking it returns `permissions`. Recommended: yes.
- **d3** (decision 14): the collapsible sidebar rail toggle. Recommended: keep. Alternative: drop it and save about 30 min.
- **d4** (decision 18): the FAB becomes a header button on desktop. Recommended: yes.

**p1:** A) approve as-is  B) approve with the recommended taste choices (**recommended**)  C) ask questions  D) revise  E) reject

Reply `rec` to take every recommendation, or for example `d3: drop`.
