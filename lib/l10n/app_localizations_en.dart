// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Forever One';

  @override
  String get appTagline => 'Your business operating system';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Access your management space';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get logout => 'Logout';

  @override
  String get copyright => 'ForeverSoftware © 2026';

  @override
  String get dashboard => 'Dashboard';

  @override
  String welcome(String email) {
    return 'Welcome, $email';
  }

  @override
  String get revenue => 'Revenue';

  @override
  String get receivables => 'Receivables';

  @override
  String get payables => 'Payables';

  @override
  String get lowStockAlerts => 'Low stock alerts';

  @override
  String get management => 'Management';

  @override
  String get aiCopilot => 'AI Copilot';

  @override
  String get insights => 'Insights';

  @override
  String get generatePdfReport => 'Generate PDF report';

  @override
  String get products => 'Products';

  @override
  String get warehouses => 'Warehouses';

  @override
  String get movements => 'Movements';

  @override
  String get customers => 'Customers';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get sales => 'Sales';

  @override
  String get purchases => 'Purchases';

  @override
  String get scanner => 'Scanner';

  @override
  String get audit => 'Audit';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get price => 'Price';

  @override
  String get cost => 'Cost';

  @override
  String get minThreshold => 'Min threshold';

  @override
  String get unit => 'Unit';

  @override
  String get quantity => 'Quantity';

  @override
  String get qty => 'Qty';

  @override
  String get note => 'Note';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get creditLimit => 'Credit limit';

  @override
  String get leadTimeDays => 'Lead time (days)';

  @override
  String get location => 'Location';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get total => 'Total';

  @override
  String get status => 'Status';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get refresh => 'Refresh';

  @override
  String get delete => 'Delete';

  @override
  String get newProduct => 'New product';

  @override
  String get newCustomer => 'New customer';

  @override
  String get newSupplier => 'New supplier';

  @override
  String get newSale => 'New sale';

  @override
  String get newPurchase => 'New purchase';

  @override
  String get product => 'Product';

  @override
  String get customer => 'Customer';

  @override
  String get supplier => 'Supplier';

  @override
  String get warehouse => 'Warehouse';

  @override
  String get threshold => 'Threshold';

  @override
  String get margin => 'margin';

  @override
  String get creditLimitShort => 'Limit';

  @override
  String get noProducts => 'No products';

  @override
  String get noCustomers => 'No customers';

  @override
  String get noSuppliers => 'No suppliers';

  @override
  String get noSales => 'No sales';

  @override
  String get noPurchases => 'No purchases';

  @override
  String get noWarehouses => 'No warehouses';

  @override
  String get tapPlusToAdd => 'Tap + to add one';

  @override
  String get tapPlusToCreate => 'Tap + to create one';

  @override
  String get tapPlusToRecord => 'Tap + to record one';

  @override
  String get addProductLine => 'Add a product';

  @override
  String get noLines => 'No lines';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String get addAtLeastOneProduct => 'Add at least one product';

  @override
  String get unitCost => 'Unit cost';

  @override
  String get confirmSale => 'Confirm sale';

  @override
  String get confirmPurchase => 'Confirm purchase';

  @override
  String saleCreated(String total) {
    return 'Sale created · Total $total DT';
  }

  @override
  String purchaseRecorded(String total) {
    return 'Purchase recorded · Total $total DT';
  }

  @override
  String get confirmed => 'Confirmed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get draft => 'Draft';

  @override
  String get received => 'Received';

  @override
  String get payment => 'Payment';

  @override
  String get movementType => 'Movement type';

  @override
  String get stockIn => 'In';

  @override
  String get stockOut => 'Out';

  @override
  String get transfer => 'Transfer';

  @override
  String get correction => 'Correction';

  @override
  String get recordMovement => 'Record movement';

  @override
  String get stockMovement => 'Stock movement';

  @override
  String movementRecorded(int stock) {
    return 'Movement recorded · Current stock: $stock';
  }

  @override
  String currentStockAfter(int stock) {
    return 'Current stock after movement: $stock';
  }

  @override
  String get paidInFull => 'Fully paid';

  @override
  String get balanceDue => 'Balance due';

  @override
  String get alreadyPaid => 'Already paid';

  @override
  String get remainingDue => 'Remaining due';

  @override
  String percentSettled(String percent) {
    return '$percent % settled';
  }

  @override
  String get recordPayment => 'Record a payment';

  @override
  String get payFullAmount => 'Pay full amount';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cash => 'Cash';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get check => 'Check';

  @override
  String get recordThePayment => 'Record the payment';

  @override
  String get scanDocument => 'Scan a document';

  @override
  String get photographInvoice => 'Photograph an invoice';

  @override
  String get amountsExtractedAutomatically =>
      'Amounts will be extracted automatically';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get analyzingDocument => 'Analyzing document...';

  @override
  String get extractionReliable => 'Reliable extraction';

  @override
  String get verificationAdvised => 'Verification advised';

  @override
  String get verificationRequired => 'Verification required';

  @override
  String extractionConfidence(int confidence) {
    return 'Extraction confidence: $confidence %';
  }

  @override
  String get checkAndCorrect => 'Check and correct if needed';

  @override
  String get validateAndSave => 'Validate and save';

  @override
  String get rawExtractedText => 'Raw extracted text';

  @override
  String get noTextDetected => '(no text detected)';

  @override
  String get documentValidated => 'Document validated and saved';

  @override
  String get aiAssistant => 'Business assistant';

  @override
  String get askYourBusiness => 'Ask your business';

  @override
  String get askQuestionSubtitle =>
      'Ask a question about your sales, stock or customers';

  @override
  String get askYourQuestion => 'Ask your question...';

  @override
  String get analyzingData => 'Analyzing your data...';

  @override
  String get suggestStockRupture => 'Which products risk running out?';

  @override
  String get suggestCustomerDebts => 'Which customers owe me money?';

  @override
  String get suggestActivitySummary => 'Give me a summary of my activity';

  @override
  String get insightsAndForecasts => 'Insights & Forecasts';

  @override
  String get stock => 'Stock';

  @override
  String get dormant => 'Dormant';

  @override
  String get followUps => 'Follow-ups';

  @override
  String get noStockData => 'No stock data';

  @override
  String get addProductsForForecasts => 'Add products to see forecasts';

  @override
  String daysOfCoverage(int days, String rate) {
    return '$days days of coverage · $rate/day';
  }

  @override
  String get noRecentSales => 'No recent sales';

  @override
  String orderUnits(int units) {
    return 'Order $units units';
  }

  @override
  String get rupture => 'Out of stock';

  @override
  String get soon => 'Soon';

  @override
  String get ok => 'OK';

  @override
  String get noDormantProducts => 'No dormant products';

  @override
  String get allProductsSelling => 'All your products are selling regularly';

  @override
  String get neverSold => 'Never sold';

  @override
  String lastSaleDaysAgo(int days) {
    return 'Last sale $days days ago';
  }

  @override
  String get noCustomersYet => 'No customers';

  @override
  String get addCustomersForScores => 'Add customers to see scores';

  @override
  String get auditLog => 'Audit log';

  @override
  String get all => 'All';

  @override
  String get payments => 'Payments';

  @override
  String get documents => 'Documents';

  @override
  String get logins => 'Logins';

  @override
  String get reports => 'Reports';

  @override
  String get ai => 'AI';

  @override
  String get connection => 'Login';

  @override
  String get saleCreatedAction => 'Sale created';

  @override
  String get purchaseRecordedAction => 'Purchase recorded';

  @override
  String get paymentRecordedAction => 'Payment recorded';

  @override
  String get stockMovementAction => 'Stock movement';

  @override
  String get documentValidatedAction => 'Document validated';

  @override
  String get aiQueryAction => 'AI query';

  @override
  String get reportGeneratedAction => 'Report generated';

  @override
  String get noActionsRecorded => 'No actions recorded';

  @override
  String get noActionsOfThisType => 'No actions of this type';

  @override
  String get restrictedAccess => 'Restricted access';

  @override
  String get system => 'system';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get days => 'days';
}
