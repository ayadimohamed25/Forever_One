# Stitch design → Flutter: points to fix during implementation

Small inconsistencies in the Stitch mobile designs ("Forever One Mobile") that are NOT regenerated. When the design is implemented in Flutter, apply one rule everywhere instead of copying the screen. Data on every screen comes from the API, never from the mock-ups.

## Status colours: one set everywhere
- Unpaid / Partially paid / Low stock / To pay: amber (warning).
- Paid / In stock / Up to date: green (success).
- Overdue / Out of stock / Late delivery: red (danger).
- Neutral information (Delivered, Received): grey.
- Seen wrong in Stitch:
  - "Unpaid" and "Partially paid" pills grey-blue on **Customer details** and **Invoice FAC-2026-0065**; "Partially paid" grey-blue on **Sales** (the other Sales pills are amber).
  - "Low stock" pills and the "Low stock" summary card grey-blue on **Stock** and **Insights** (amber on Home and Notifications).
  - "Paid" pill grey on **Home** recent activity (green elsewhere).
  - Late delivery dot amber on **Notifications** (rule: red).

## Top bar: two kinds only
- Main screens (Home, Sales, Stock, Customers, More): ☰ menu on the left, title, notification bell with count on the right.
- Detail screens (invoice, customer, payment, notifications, forms): back arrow (or × for forms opened as a sheet) and the title only. No account button, print or share icons. Exception: My profile keeps its edit (pencil) icon, as in the app.
- Seen wrong in Stitch: account button at the top right of **Notifications**, and next to the bell on all five main screens.
- Decision (2026-11-18): no account button anywhere. The user is shown in the drawer, on More and in the Home greeting.

## Titles and labels
- Sentence case everywhere: "Scan a document", not "Scan A Document" as on **Scanner** and **Scanner review**.
- Same for "My profile" (Stitch: "My Profile"), "Audit log" (Stitch: "Audit Log"), "New product" (Stitch: "New Product") and "Customer details" (Stitch: "Customer Details").
- One wording per action: Invoice says "Record a payment", Payment says "Record the payment". Use the app's label on both.
- Add buttons: "New sale", "New product", but Customers shows "Customer". Use the app's labels ("New …") consistently.

## Bottom bar
- Home tab icon: a house, the same on every screen (Stitch: grid on Home, shop on the other four).

## Fonts
- One font family for figures: Home shows amounts in a monospaced font, every other screen in the regular font. Use the regular font with tabular figures everywhere.

## Logo
- One logo everywhere: Login/Home/Sales show the blocks logo, Sign up shows a "1" logo.

## Sign up
- The grey band at the top behind the back arrow must go: same plain background as Login.
- Stitch's placeholders use the demo names ("e.g. Épicerie El Baraka", "e.g. Mohamed Trabelsi"). Keep the app's own neutral placeholders; a new company must not see the demo shop's names.

## Data shown in the mock-ups
- Some mock-up figures disagree with the database (Home: Café Majestic 75.92 DT shown "Paid", purchase dated 17/11 instead of 13/11; Sales: two dates). Ignore them: the app shows live data from the API.

## Other
- Stock: the floating "New product" button must not cover the last row (the app keeps a bottom gap).

## Screens added 2026-11-22 (kept as generated, fix in Flutter)
- **Product details** (Concentré de tomate 800 g):
  - Title reads "Product Details": use sentence case, "Product details".
  - "Out" rows in Stock history use an up-right arrow; use the app's out icon (the same one as the Stock movement screen) so In and Out read clearly.
- **Warehouses**: the "Active" pills are blue; Active is green (success), like Users.
- **Supplier details** (SOTUPRODIS Sfax):
  - Title reads "Supplier Details": use sentence case, "Supplier details".
  - "Paid" pills in Purchase history use a brighter green than the rest of the app; use the standard success pill.
- **Users**: "Active" pills have green text on a blue tint; use the standard green success pill.
- **Suppliers**: the amounts owed in the rows are amber; the app shows them in the normal text colour (only the "To pay" pill and the summary figure are amber).
- **New purchase**: title reads "New Purchase": use sentence case, "New purchase".
- All new list screens reached from More (Categories, Purchases, Suppliers, Warehouses, Users): back arrow and title only, no account button, no company name label under the top bar.
- Purchase status "Pending delivery" is blue (info); "Late delivery" is red; "To pay" amber; "Paid" green.
