# Forever One — Google Stitch prompts

Two Stitch projects: an **App** project for the mobile prompts (M1–M7) and a **Web** project for the desktop prompts (W1–W7). Send the prompts of each project in order, in the same chat, so the style carries over.

Owner's requirements (phone AND web): bottom bar plus a ☰ menu on the left on phone, left sidebar on web, notification bell, alerts at the top of the dashboard, structured tables, categories reachable from the dashboard, no internal IDs or codes under the items, empty login.

---

## M1 — Mobile · main prompt: app, design system, login, home

```
Design the phone app of "Forever One", a professional ERP for small Tunisian businesses (wholesale grocery, cafés, restaurants). Demo company: "Épicerie El Baraka" in Sfax. It manages sales invoices, purchases, stock, customers, suppliers and payments, with AI insights. Currency is Tunisian dinar written "1 942.72 DT"; dates dd/MM/yyyy; UI in English, product and company names in French.

STYLE: serious, modern business software in the spirit of the Stripe, Odoo and Zoho mobile apps. Not a lifestyle or consumer app: no illustrations, no decorative gradients, no emoji. Propose a professional palette for business software: a deep blue or neutral primary colour, NOT purple or violet (the owner rejected violet), dark navy for the side menu, clean neutral backgrounds. Status colours: success green, warning amber, danger red, each as dark text on a soft background, used for status pills and figures. Clear typographic hierarchy with large, tabular figures for money. Comfortable touch targets. You decide the spacing, card style and visual details: aim for something more polished than a standard admin template.

DATA RULES: never show internal IDs, database codes or product codes under list items. Lists show names, dates, amounts and statuses only.

NAVIGATION on every main screen (Home, Sales, Stock, Customers, More):
- Bottom bar with 5 tabs: Home, Sales, Stock, Customers, More.
- A ☰ menu button at the top LEFT. It opens a dark navy side drawer: the user on top ("Mohamed Trabelsi", "Administrator · Épicerie El Baraka"), then the full navigation: Overview · Sales (Invoices, Customers) · Purchasing (Purchases, Suppliers) · Inventory (Products, Categories, Warehouses, Stock movements) · Intelligence (Insights, AI Copilot, Scanner) · Administration (Users, Audit log); at the bottom Language EN/FR and Logout. Show the drawer open as an extra screen.
- A notification bell with a red count "13" at the top right.

SCREEN 1 — Login: app logo and name "Forever One", title "Login", subtitle "Access your management space", Email and Password fields left EMPTY (no pre-filled values, password show/hide), "Sign in" button, "No account yet? Create an account", EN/FR switch, footer "ForeverSoftware © 2026".

SCREEN 2 — Home (dashboard), top to bottom:
1. Alert strip at the very top: "13 alerts · 8 overdue payments · 1 out of stock · 3 low stock — See all".
2. ☰ button, date "Wednesday 18 November 2026", greeting "Good morning, Mohamed"; AI assistant button and bell on the right.
3. Revenue card: "Revenue this month" 1 942.72 DT, "+13.0%" badge, "vs last month (1 719.90 DT)", line chart of this period vs previous period, period switch 7D / 30D / 90D / 12M.
4. Main action "New sale" within thumb reach, plus Scan and a "More" menu (Download PDF report, New purchase, Add product, Categories).
5. Four figures: Cash position +454.99 DT (net, positive, green) · Overdue 555.77 DT (8 overdue invoices) · Stock value 4 580.30 DT · To reorder 4 (low or out of stock). Stock value and To reorder lead to Products and Categories.
6. "Needs attention": Semoule fine 5 kg — 0 left · minimum 15; Concentré de tomate 800 g — 7 left · minimum 20; Restaurant Le Golfe — 33 days overdue · 131.38 DT.
7. "Recent activity": Café Majestic · Sale · 17/11/2026 · +75.92 DT; Société Tunisienne de Café · Purchase · −444.77 DT.
```

---

## M2 — Mobile · list screens

```
Same phone app, same bottom bar, ☰ menu and bell. Design the list screens. Each has a title with a count ("Sales — 65 sales"), a search field directly under the title, a few summary figures, status filters with counts, a sort option, and a list of rows. No column headers and no codes under the names. The main "add" action stays reachable without covering the last row. You decide the row and card styling.

1. Sales: figures Invoiced 7 247.04 DT, Paid 5 186.70 DT, To collect 2 060.34 DT, Overdue 555.77 DT. Filters All 65 · Unpaid 22 · Partially paid 3 · Overdue 8 · Paid 43. Rows grouped by Today, Yesterday, This week, This month, October 2026. Each row: customer initials, customer name, date, amount and status pill. Examples: Café Majestic 75.92 DT Unpaid · Restaurant Le Golfe 117.81 DT Partially paid · Hôtel Les Oliviers 169.81 DT Unpaid. Action "New sale".
2. Stock (Products): search finds names, product codes and barcodes, but codes are not displayed in the list. Category filters (All categories, Boissons, Emballage, Épicerie sèche, Hygiène, Produits frais); figures Products 17, Stock value 4 580.30 DT, Low stock 3, Out of stock 1. Row: product name, category and price under it ("Épicerie sèche · 5.83 DT"), stock on the right as "7 left" with a small level indicator (ok / low / out). Semoule fine 5 kg is "Out of stock". Action "Product".
3. Customers: rows with initials, name, phone, balance and status (Unpaid, Up to date, Over limit); a settled customer shows "—" instead of 0.00 DT. Figures: Customers 7, Outstanding balance 2 060.34 DT, Over limit 0 (zero is neutral, never red).
4. More tab: account card (Mohamed Trabelsi, Administrator · Épicerie El Baraka), then grouped entries: Purchasing (Purchases "2 to receive", Suppliers) · Inventory (Categories, Warehouses, Stock movements) · Intelligence (Insights "3 new", AI Copilot, Scanner) · Administration (Users, Audit log) · Settings (Language EN/FR, Logout).
```

---

## M3 — Mobile · detail pages

```
Same phone app. Detail screens open full screen with a back arrow. Invoice numbers appear only here (invoice detail and payment), never in lists.

1. Invoice FAC-2026-0064 (the number is the screen title): customer Snack Chez Ali, status Unpaid, "Issued 11/11/2026 · Due 26/11/2026", total 202.45 DT, paid vs remaining progress (Paid 0.00 DT, Balance 202.45 DT), totals (Subtotal excl. VAT 174.30, VAT 28.15, Total incl. VAT 202.45, Paid 0.00, Balance 202.45 DT), lines "Savon liquide 5 L × 2 — 42.00 DT", "Sacs kraft 1 kg (x100) × 3 — 49.50 DT", "Thé vert Sultan 250 g × 12 — 82.80 DT". Actions within thumb reach: "Record a payment" (main) and "Edit".
2. Customer Café Majestic: initials, name, "Last order: 18 days ago"; quick actions Call, Message, Email, Edit; Outstanding balance 479.02 DT, Orders 9; credit usage 479.02 / 6 000.00 DT; purchases per month over 6 months; recent invoices with dates, amounts and status.
3. Payment: title "Payment", subtitle "Restaurant Le Golfe · FAC-2026-0057"; balance due 131.38 DT, 0 % settled, Total 131.38 DT, Already paid 0.00 DT, Remaining due 131.38 DT; Amount field, "Pay full amount", method Cash / Bank transfer / Check, "Record the payment".
4. Notifications: groups Out of stock (Semoule fine 5 kg — 0 left · minimum 15), Low stock (Concentré de tomate 800 g — 7 left · minimum 20; Yaourt nature (pack 8); Eau minérale Safia 1.5 L (pack 6)), Overdue customer payments (Restaurant Le Golfe — 33 days overdue — 131.38 DT; Supérette Ennour — 23 days overdue — 105.91 DT). Amounts on the right for payments only.
```

---

## M4 — Mobile · forms

```
Same phone app. Forms open as a full-screen sheet with a close (×) button; the save action is always reachable at the bottom.

1. New sale: customer picker showing the chosen customer (Restaurant El Medina, "Owes 1 240.00 DT · limit 5 000.00", Change); items with quantity steppers ("Huile d'olive extra 1 L — 18.90 · 46 in stock", "Pâtes spaghetti 500 g — only 7 in stock" as a warning); "Add product" and "Scan barcode"; payment Cash / Card / Transfer / Later; total "556.45 DT · 79 items · VAT included"; "Create invoice".
2. Product form in sections: General info (Name, Product code, Barcode, Category, Default supplier, Description, Active) · Pricing and VAT (Price excl. VAT, Cost, VAT rate 7 / 13 / 19 %) · Units and packaging (Sale unit, Purchase unit, Units per purchase) · Stock settings (Minimum, Maximum, Shelf location) · Notes.
3. Customer form: General info (Type Company / Individual, Name, Contact, Phone, Email, Address, Tax ID) · Commercial info (Credit limit, Payment terms in days) · Notes.
4. Stock movement: choose the type (In, Out, Transfer, Correction), then Product, Warehouse, Quantity, Note (optional), "Record movement".
```

---

## M5 — Mobile · AI and insights

```
Same phone app; these screens open from More or the ☰ drawer, with a back arrow.

1. Insights: tabs Stock, Dormant, Follow-ups. Stock: products with days of coverage and daily sales ("3 days of coverage · 2.14/day"), stock vs minimum, suggested quantity to order ("+78"), status Out of stock / Low stock / OK (Semoule fine 5 kg 0 / 15 +54; Concentré de tomate 800 g 7 / 20 +78). Dormant: products with no sale in 30+ days (Thon à l'huile d'olive 160 g, Papier essuie-tout (pack 6), Barquettes aluminium (x50)). Follow-ups: customers to chase, with a short reason and one action each.
2. AI Copilot: empty state "Ask your business — Ask a question about your sales, stock or customers", suggestions "Which products risk running out?", "Which customers owe me money?", "Give me a summary of my activity"; then a conversation with a short answer and a small table of figures; question field and send button.
3. Scanner: "Photograph an invoice — Amounts will be extracted automatically", Camera and Gallery (equal importance), then a review of the extracted supplier, date, lines and total with "Confirm" and "Retake".
```

---

## M6 — Mobile · profile, audit log, sign up

```
Same phone app.
1. Profile: Mohamed Trabelsi, admin@elbaraka.tn, Administrator; Email, Phone 74 401 220, Company Épicerie El Baraka, Access rights "23 permissions"; Change password; Logout.
2. Audit log: "25 entries", filters (All, Sales, Purchases, Payments, Products, Stock, Customers, Suppliers, Users, AI, Documents, Logins, Reports); entries with action ("Sale created", "Signed in", "Report generated", "Customer updated", "Purchase received", "Stock movement"), user email, date and time, and one detail ("75.92 DT", "Director report", "Out · × 1", "Restaurant Le Golfe"). No IDs.
3. Sign up: same look as the login, all fields empty: Company name, Full name, Email, Password, "Create account".
```

---

## M7 — Mobile · final check

```
Review every screen of this project against these rules and fix any screen that breaks one: bottom bar with Home, Sales, Stock, Customers, More plus a ☰ menu at the top left on every main screen; notification bell with a count; alert strip at the top of Home; structured lists; Categories reachable from Home; no internal IDs, product codes or invoice numbers under list items; empty login; no purple or violet; consistent colours, type and status pills everywhere.
```

---

## W1 — Desktop web · main prompt: app, design system, login, dashboard

```
Design "Forever One", a professional ERP web app for small Tunisian businesses (wholesale grocery, cafés, restaurants). Demo company: "Épicerie El Baraka" in Sfax. It manages sales invoices, purchases, stock, customers, suppliers and payments, with AI insights. Currency is Tunisian dinar written "1 942.72 DT"; dates dd/MM/yyyy; UI in English, product and company names in French.

STYLE: serious, modern business software in the spirit of Stripe Dashboard, Odoo 17 and Zoho Books. Calm and data-dense. Not a lifestyle or consumer app: no illustrations, no decorative gradients, no emoji. Propose a professional palette for business software: a deep blue or neutral primary colour, NOT purple or violet (the owner rejected violet), dark navy sidebar, clean neutral backgrounds. Status colours: success green, warning amber, danger red, each as dark text on a soft background, used for status pills and figures. Money in tabular figures, right-aligned in tables. You decide the spacing, card style and visual details: aim for something more polished than a standard admin template.

DATA RULES: never show internal IDs, database codes or product codes under items or in list columns.

LAYOUT on every signed-in page:
- Dark navy left sidebar: "Forever One / Épicerie El Baraka" on top; Overview; collapsible groups Sales (Invoices, Customers) · Purchasing (Purchases, Suppliers) · Inventory (Products, Categories, Warehouses, Stock movements) · Intelligence (Insights, AI Copilot, Scanner) · Administration (Users, Audit log); at the bottom language EN/FR, the user "Mohamed Trabelsi · Administrator" and logout. The sidebar can collapse to icons.
- Top bar: page title and short subtitle; "Ask AI" and a notification bell with a red count "13".

SCREEN 1 — Login (no sidebar): app logo and name "Forever One", title "Login", subtitle "Access your management space", Email and Password fields left EMPTY (no pre-filled values, password show/hide), "Sign in", "No account yet? Create an account", EN/FR switch, footer "ForeverSoftware © 2026".

SCREEN 2 — Dashboard ("Overview"), in this order:
1. Alert strip at the very top: "13 alerts · 8 overdue payments · 1 out of stock · 3 low stock — See all".
2. Date "Wednesday 18 November 2026" and greeting "Good morning, Mohamed".
3. Actions together on one line: New sale (main), New purchase, Add product, Scan, and Download PDF report at the end.
4. Revenue: "Revenue this month" 1 942.72 DT, "+13.0%", "vs last month (1 719.90 DT)", line chart this period vs previous period, period switch 7D / 30D / 90D / 12M.
5. Cash position: To collect 2 060.34 DT, To pay 1 605.35 DT, Net position +454.99 DT (positive, green). Owe you the most: Hôtel Les Oliviers 561.88 DT, Supérette Ennour 555.14 DT, Restaurant Le Golfe 397.94 DT. Suppliers to pay first: Emballages du Sud 399.84 DT (bill of 09/11/2026), Société Tunisienne de Café 444.77 DT (bill of 13/11/2026).
6. Key figures: Stock value 4 580.30 DT · Overdue 8 invoices, 555.77 DT · To reorder 4 (low or out of stock) · Sales this month 16, 1 942.72 DT. Stock value and To reorder lead to Products and Categories.
7. Recent activity (Café Majestic, Sale, 17/11/2026 08:00, +75.92 DT; Restaurant Le Golfe +117.81 DT; Société Tunisienne de Café, Purchase, −444.77 DT), Needs attention (Semoule fine 5 kg — 0 left · minimum 15; Concentré de tomate 800 g — 7 left · minimum 20; Restaurant Le Golfe — 33 days overdue · 131.38 DT) and Top products (Huile d'olive extra vierge 5 L 890.00 DT; Semoule fine 5 kg 883.20 DT; Café moulu Bondin 500 g 625.00 DT).
```

---

## W2 — Desktop web · list screens (tables)

```
Same web app. Design the list pages as structured, sortable data tables. Each page has a title with a count, a few summary figures, a search field, filters, status tabs with counts, the page's main action, a row menu, and pagination ("1–25 of 65"). Selecting a row opens a detail panel beside the table (show one example). No product codes, invoice numbers or IDs in the table columns or under the names. You decide the visual style of the table, tabs and figures.

1. Invoices (Sales): figures Invoiced 7 247.04 DT, Paid 5 186.70 DT, To collect 2 060.34 DT, Overdue 555.77 DT. Tabs All 65 · Unpaid 22 · Partially paid 3 · Overdue 8 · Paid 43. Date filter (All time / This month / Last 30 days). Action "New sale". Columns: Customer, Date, Balance, Total incl. VAT, Status. Rows: Café Majestic 17/11/2026, 75.92 / 75.92 DT, Unpaid · Restaurant Le Golfe 16/11/2026, 70.69 / 117.81 DT, Partially paid · Supérette Ennour 12/11/2026, — / 140.09 DT, Paid. Detail panel (invoice FAC-2026-0065, Café Majestic): status, issued 17/11/2026, due 17/12/2026, Subtotal excl. VAT 70.95, VAT 4.97, Total 75.92, Paid 0.00, Balance 75.92 DT; lines Semoule fine 5 kg × 3 = 41.40 DT, Yaourt nature (pack 8) × 4 = 20.80 DT, Lait demi-écrémé 1 L × 5 = 8.75 DT; actions Record a payment, Edit.
2. Products: category filter (All categories, Boissons, Emballage, Épicerie sèche, Hygiène, Produits frais); figures Products 17, Stock value 4 580.30 DT, Low stock 3, Out of stock 1; tabs All · Low stock · Out of stock · Inactive; search finds names, product codes and barcodes, but codes are not shown in the table. Columns: Product (with its category), Supplier, Stock (highlighted when low or out), VAT, Margin, Price incl. VAT. Rows: Concentré de tomate 800 g, SOTUPRODIS Sfax, 7, 19 %, 31 %, 5.83 DT · Café moulu Bondin 500 g, Société Tunisienne de Café, 108, 13 %, 34 %, 14.12 DT · Semoule fine 5 kg, 0. Action "Product".
3. Customers: figures Customers 7, Outstanding balance 2 060.34 DT, Over limit 0 (zero is neutral, never red); tabs All 7 · Unpaid 6 · Over limit 0 · Up to date 1; columns Customer (with phone), Email, Orders, Balance ("—" when settled), Status. Rows: Café Majestic, 74 225 880, 7 orders, 270.75 DT · Hôtel Les Oliviers 561.88 DT · Mongi Sassi, Up to date, —.
4. Purchases: figures Purchased 7 807.11 DT, To pay 1 605.35 DT, Pending delivery 1; tabs All 11 · Pending delivery 1 · To pay 3 · Paid 8; columns Supplier, Date, Balance, Total, Status (To pay, Paid, Late delivery, Pending delivery). Action "New purchase".
5. Suppliers: figures Suppliers 4, Amount owed 1 605.35 DT; tabs All · To pay · Settled; columns Supplier (with contact person), Phone, Orders, Amount owed ("—" when settled), Status. Rows: SOTUPRODIS Sfax (Anis Mahjoub) 760.74 DT, Société Tunisienne de Café 444.77 DT, Emballages du Sud 399.84 DT, Délice Danone Distribution, Settled.
6. Categories (colour, name, description, number of products: Boissons 4, Épicerie sèche 7…), Warehouses (Dépôt Principal, Sfax, manager Sonia Ben Amor, 17 products, 4 542.30 DT, Active · Dépôt Sakiet Ezzit), Users (name and email, last login or "—", role Administrator / Stock manager / Sales rep, Active).
```

---

## W3 — Desktop web · detail pages

```
Same web app. Detail pages, which also open as a panel beside their table. Product codes appear only on the product detail; invoice numbers only on invoice detail and payment screens.

1. Customer Café Majestic: "Last order: 18 days ago"; actions Edit, Call, Send email; Outstanding balance 479.02 DT, Orders 9; credit usage 479.02 / 6 000.00 DT; purchases per month over 6 months; purchase history (39.87 DT 29/10/2026 Unpaid, 77.85 DT 23/10/2026 Paid, 64.14 DT 21/10/2026 Unpaid), each opening its invoice.
2. Supplier SOTUPRODIS Sfax: contact Anis Mahjoub, phone 74 612 330, payment terms, delivery lead time; amount owed 760.74 DT; purchase history with Late delivery / To pay / Paid; actions Edit, Call, Email.
3. Product Concentré de tomate 800 g: product code PRD-009 and barcode (shown here only), category Épicerie sèche, default supplier SOTUPRODIS Sfax, shelf location, description; Stock 7 (minimum 20, low), Price incl. VAT 5.83 DT, Margin 31 %; stock history per warehouse; actions Edit, Record movement.
4. Payment: title "Payment", subtitle "Restaurant Le Golfe · FAC-2026-0057"; balance due 131.38 DT, 0 % settled, Total 131.38 DT, Already paid 0.00 DT, Remaining due 131.38 DT; Amount, "Pay full amount", method Cash / Bank transfer / Check, "Record the payment".
5. Notifications: groups Out of stock (1), Low stock (3), Overdue customer payments (8), each item with its detail ("0 left · minimum 15", "33 days overdue") and the amount for payments only (Restaurant Le Golfe 131.38 DT, Supérette Ennour 105.91 DT).
```

---

## W4 — Desktop web · forms

```
Same web app. Forms in clear sections with labels, required fields marked and a visible save area.

1. New sale: invoice details (Customer, Warehouse, Reference optional); add products (Product with stock shown, Quantity) and the added lines with quantities and remove; totals Subtotal excl. VAT, VAT, Total incl. VAT; "Confirm sale" (disabled until valid). Lines: Huile d'olive extra vierge 5 L × 2, Pâtes spaghetti 500 g × 7 with a "only 7 in stock" warning.
2. New purchase: Supplier, Warehouse, Expected date, Reference; lines with quantity and unit cost; totals; "Confirm purchase".
3. Product form: General info (Name, Product code, Barcode, Category, Default supplier, Description, Active) · Pricing and VAT (Price excl. VAT, Cost, VAT rate 7 / 13 / 19 %) · Units and packaging (Sale unit, Purchase unit, Units per purchase) · Stock settings (Minimum, Maximum, Shelf location) · Notes.
4. Customer form: General info (Type Company / Individual, Name, Contact, Phone, Email, Address, Tax ID) · Commercial info (Credit limit, Payment terms in days) · Notes.
5. Stock movement: type In / Out / Transfer / Correction, then Product, Warehouse, Quantity, Note (optional), "Record movement".
6. Smaller forms: Category (Name, Description, Colour), Warehouse (Code, Name, Location, Address, Manager, Phone, Active, Notes), Supplier (Name, Contact person, Phone, Email, Address, Tax ID, Payment terms, Lead time in days, Bank account / IBAN, Notes), User (Full name, Email, Phone, Role, Password, Active).
```

---

## W5 — Desktop web · AI and insights

```
Same web app, Intelligence group.

1. Insights & Forecasts ("1 out of stock"): tabs Stock, Dormant, Follow-ups. Stock = table of products with days of coverage and daily sales, Stock, Minimum, To order, Status (Semoule fine 5 kg 0 / 15 / +54 Out of stock; Concentré de tomate 800 g 7 / 20 / +78 Low stock; Savon liquide 5 L 16 / 8 / — OK). Dormant: products with no sale in 30+ days (Thon à l'huile d'olive 160 g, Papier essuie-tout (pack 6), Barquettes aluminium (x50)) with the last sale date. Follow-ups: customers to chase with a short reason and one action each.
2. AI Copilot: empty state "Ask your business — Ask a question about your sales, stock or customers" with suggestions ("Which products risk running out?", "Which customers owe me money?", "Give me a summary of my activity"), and a conversation where the answer has a short summary and a small table of figures; question field with send.
3. Scanner: "Photograph an invoice — Amounts will be extracted automatically", Camera and Gallery (equal importance), then a review of the extracted supplier, date, lines and total with Confirm and Retake.
```

---

## W6 — Desktop web · profile, audit log, sign up

```
Same web app.
1. My profile: Mohamed Trabelsi, admin@elbaraka.tn, Administrator; Email, Phone 74 401 220, Company Épicerie El Baraka, Access rights "23 permissions"; Change password; Edit profile.
2. Audit log: "25 entries"; filters All, Sales, Purchases, Payments, Products, Stock, Customers, Suppliers, Users, AI, Documents, Logins, Reports; entries with action ("Sale created", "Signed in", "Report generated", "Customer updated", "Purchase received", "Stock movement"), user email, date and time, and details aligned in one place ("75.92 DT", "Director report", "Out · × 1", "Restaurant Le Golfe"). No IDs.
3. Sign up (same look as the login, all fields empty): Company name, Full name, Email, Password, "Create account".
```

---

## W7 — Desktop web · final check

```
Review every screen of this project against these rules and fix any screen that breaks one: dark left sidebar with the full navigation; notification bell with a count on every page; alert strip at the top of the dashboard; structured, sortable tables; Categories reachable from the dashboard; no internal IDs, product codes or invoice numbers in table columns or under item names; empty login; no purple or violet; consistent colours, type and status pills everywhere.
```
