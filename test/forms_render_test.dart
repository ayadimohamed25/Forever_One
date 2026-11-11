import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/customers/presentation/pages/customer_form_page.dart';
import 'package:foreverone/features/finance/presentation/pages/payment_page.dart';
import 'package:foreverone/features/purchases/presentation/pages/create_purchase_page.dart';
import 'package:foreverone/features/sales/presentation/pages/create_sale_page.dart';
import 'package:foreverone/features/stock/presentation/pages/category_form_page.dart';
import 'package:foreverone/features/stock/presentation/pages/product_form_page.dart';
import 'package:foreverone/features/stock/presentation/pages/stock_movement_page.dart';
import 'package:foreverone/features/stock/presentation/pages/warehouse_form_page.dart';
import 'package:foreverone/features/suppliers/presentation/pages/supplier_form_page.dart';
import 'package:foreverone/features/users/presentation/pages/user_form_page.dart';
import 'package:foreverone/l10n/app_localizations.dart';
import 'package:foreverone/shared/widgets/app_widgets.dart';

/// Every New/Edit form must render on a wide (web) window: no layout
/// exception, the first field visible and reachable, and the fixed bottom
/// bar no taller than a bar (it once covered the whole page).
void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  final forms = <String, Widget>{
    'product': const ProductFormPage(),
    'category': const CategoryFormPage(),
    'warehouse': const WarehouseFormPage(),
    'customer': const CustomerFormPage(),
    'supplier': const SupplierFormPage(),
    'user': const UserFormPage(),
    'sale': const CreateSalePage(),
    'purchase': const CreatePurchasePage(),
    'stock movement': const StockMovementPage(),
    'payment': const PaymentPage(saleId: 's1', title: 'Payment'),
  };

  for (final width in [1280.0, 412.0]) {
    for (final entry in forms.entries) {
      testWidgets('${entry.key} form renders at ${width.toInt()}px',
          (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: entry.value,
          ),
        ));
        // Let initial loads fail fast (no network in tests) and settle.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);

        final bar = find.byType(AppBottomActionBar);
        if (bar.evaluate().isNotEmpty) {
          expect(tester.getSize(bar).height, lessThan(120),
              reason: 'the Save bar must stay a bar');
        }

        // Something to fill in is on screen and reachable.
        final inputs = find.byWidgetPredicate((w) =>
            w is TextField || w is DropdownButtonFormField || w is EditableText);
        if (entry.key != 'payment') {
          expect(inputs.hitTestable(), findsWidgets,
              reason: 'the form body must be visible');
        }
      });
    }
  }
}
