import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Forever One'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your business operating system'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your management space'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'ForeverSoftware © 2026'**
  String get copyright;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {email}'**
  String welcome(String email);

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables;

  /// No description provided for @payables.
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get payables;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get lowStockAlerts;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @aiCopilot.
  ///
  /// In en, this message translates to:
  /// **'AI Copilot'**
  String get aiCopilot;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @generatePdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF report'**
  String get generatePdfReport;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @warehouses.
  ///
  /// In en, this message translates to:
  /// **'Warehouses'**
  String get warehouses;

  /// No description provided for @movements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @audit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get audit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @minThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min threshold'**
  String get minThreshold;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get creditLimit;

  /// No description provided for @leadTimeDays.
  ///
  /// In en, this message translates to:
  /// **'Lead time (days)'**
  String get leadTimeDays;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @newSupplier.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplier;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get newSale;

  /// No description provided for @newPurchase.
  ///
  /// In en, this message translates to:
  /// **'New purchase'**
  String get newPurchase;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get threshold;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'margin'**
  String get margin;

  /// No description provided for @creditLimitShort.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get creditLimitShort;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers'**
  String get noCustomers;

  /// No description provided for @noSuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers'**
  String get noSuppliers;

  /// No description provided for @noSales.
  ///
  /// In en, this message translates to:
  /// **'No sales'**
  String get noSales;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases'**
  String get noPurchases;

  /// No description provided for @noWarehouses.
  ///
  /// In en, this message translates to:
  /// **'No warehouses'**
  String get noWarehouses;

  /// No description provided for @tapPlusToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one'**
  String get tapPlusToAdd;

  /// No description provided for @tapPlusToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create one'**
  String get tapPlusToCreate;

  /// No description provided for @tapPlusToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record one'**
  String get tapPlusToRecord;

  /// No description provided for @addProductLine.
  ///
  /// In en, this message translates to:
  /// **'Add a product'**
  String get addProductLine;

  /// No description provided for @noLines.
  ///
  /// In en, this message translates to:
  /// **'No lines'**
  String get noLines;

  /// No description provided for @linesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}}'**
  String linesCount(int count);

  /// No description provided for @addAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product'**
  String get addAtLeastOneProduct;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCost;

  /// No description provided for @confirmSale.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale'**
  String get confirmSale;

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm purchase'**
  String get confirmPurchase;

  /// No description provided for @saleCreated.
  ///
  /// In en, this message translates to:
  /// **'Sale created · Total {total} DT'**
  String saleCreated(String total);

  /// No description provided for @purchaseRecorded.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded · Total {total} DT'**
  String purchaseRecorded(String total);

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @movementType.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementType;

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get stockOut;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// No description provided for @recordMovement.
  ///
  /// In en, this message translates to:
  /// **'Record movement'**
  String get recordMovement;

  /// No description provided for @stockMovement.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get stockMovement;

  /// No description provided for @movementRecorded.
  ///
  /// In en, this message translates to:
  /// **'Movement recorded · Current stock: {stock}'**
  String movementRecorded(int stock);

  /// No description provided for @currentStockAfter.
  ///
  /// In en, this message translates to:
  /// **'Current stock after movement: {stock}'**
  String currentStockAfter(int stock);

  /// No description provided for @paidInFull.
  ///
  /// In en, this message translates to:
  /// **'Fully paid'**
  String get paidInFull;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get balanceDue;

  /// No description provided for @alreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get alreadyPaid;

  /// No description provided for @remainingDue.
  ///
  /// In en, this message translates to:
  /// **'Remaining due'**
  String get remainingDue;

  /// No description provided for @percentSettled.
  ///
  /// In en, this message translates to:
  /// **'{percent} % settled'**
  String percentSettled(String percent);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record a payment'**
  String get recordPayment;

  /// No description provided for @payFullAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay full amount'**
  String get payFullAmount;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @recordThePayment.
  ///
  /// In en, this message translates to:
  /// **'Record the payment'**
  String get recordThePayment;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan a document'**
  String get scanDocument;

  /// No description provided for @photographInvoice.
  ///
  /// In en, this message translates to:
  /// **'Photograph an invoice'**
  String get photographInvoice;

  /// No description provided for @amountsExtractedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Amounts will be extracted automatically'**
  String get amountsExtractedAutomatically;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @analyzingDocument.
  ///
  /// In en, this message translates to:
  /// **'Analyzing document...'**
  String get analyzingDocument;

  /// No description provided for @extractionReliable.
  ///
  /// In en, this message translates to:
  /// **'Reliable extraction'**
  String get extractionReliable;

  /// No description provided for @verificationAdvised.
  ///
  /// In en, this message translates to:
  /// **'Verification advised'**
  String get verificationAdvised;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verificationRequired;

  /// No description provided for @extractionConfidence.
  ///
  /// In en, this message translates to:
  /// **'Extraction confidence: {confidence} %'**
  String extractionConfidence(int confidence);

  /// No description provided for @checkAndCorrect.
  ///
  /// In en, this message translates to:
  /// **'Check and correct if needed'**
  String get checkAndCorrect;

  /// No description provided for @validateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Validate and save'**
  String get validateAndSave;

  /// No description provided for @rawExtractedText.
  ///
  /// In en, this message translates to:
  /// **'Raw extracted text'**
  String get rawExtractedText;

  /// No description provided for @noTextDetected.
  ///
  /// In en, this message translates to:
  /// **'(no text detected)'**
  String get noTextDetected;

  /// No description provided for @documentValidated.
  ///
  /// In en, this message translates to:
  /// **'Document validated and saved'**
  String get documentValidated;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Business assistant'**
  String get aiAssistant;

  /// No description provided for @askYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Ask your business'**
  String get askYourBusiness;

  /// No description provided for @askQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about your sales, stock or customers'**
  String get askQuestionSubtitle;

  /// No description provided for @askYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your question...'**
  String get askYourQuestion;

  /// No description provided for @analyzingData.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your data...'**
  String get analyzingData;

  /// No description provided for @suggestStockRupture.
  ///
  /// In en, this message translates to:
  /// **'Which products risk running out?'**
  String get suggestStockRupture;

  /// No description provided for @suggestCustomerDebts.
  ///
  /// In en, this message translates to:
  /// **'Which customers owe me money?'**
  String get suggestCustomerDebts;

  /// No description provided for @suggestActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'Give me a summary of my activity'**
  String get suggestActivitySummary;

  /// No description provided for @insightsAndForecasts.
  ///
  /// In en, this message translates to:
  /// **'Insights & Forecasts'**
  String get insightsAndForecasts;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @dormant.
  ///
  /// In en, this message translates to:
  /// **'Dormant'**
  String get dormant;

  /// No description provided for @followUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get followUps;

  /// No description provided for @noStockData.
  ///
  /// In en, this message translates to:
  /// **'No stock data'**
  String get noStockData;

  /// No description provided for @addProductsForForecasts.
  ///
  /// In en, this message translates to:
  /// **'Add products to see forecasts'**
  String get addProductsForForecasts;

  /// No description provided for @daysOfCoverage.
  ///
  /// In en, this message translates to:
  /// **'{days} days of coverage · {rate}/day'**
  String daysOfCoverage(int days, String rate);

  /// No description provided for @noRecentSales.
  ///
  /// In en, this message translates to:
  /// **'No recent sales'**
  String get noRecentSales;

  /// No description provided for @orderUnits.
  ///
  /// In en, this message translates to:
  /// **'Order {units} units'**
  String orderUnits(int units);

  /// No description provided for @rupture.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get rupture;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noDormantProducts.
  ///
  /// In en, this message translates to:
  /// **'No dormant products'**
  String get noDormantProducts;

  /// No description provided for @allProductsSelling.
  ///
  /// In en, this message translates to:
  /// **'All your products are selling regularly'**
  String get allProductsSelling;

  /// No description provided for @neverSold.
  ///
  /// In en, this message translates to:
  /// **'Never sold'**
  String get neverSold;

  /// No description provided for @lastSaleDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Last sale {days} days ago'**
  String lastSaleDaysAgo(int days);

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers'**
  String get noCustomersYet;

  /// No description provided for @addCustomersForScores.
  ///
  /// In en, this message translates to:
  /// **'Add customers to see scores'**
  String get addCustomersForScores;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @logins.
  ///
  /// In en, this message translates to:
  /// **'Logins'**
  String get logins;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get connection;

  /// No description provided for @saleCreatedAction.
  ///
  /// In en, this message translates to:
  /// **'Sale created'**
  String get saleCreatedAction;

  /// No description provided for @purchaseRecordedAction.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded'**
  String get purchaseRecordedAction;

  /// No description provided for @paymentRecordedAction.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecordedAction;

  /// No description provided for @stockMovementAction.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get stockMovementAction;

  /// No description provided for @documentValidatedAction.
  ///
  /// In en, this message translates to:
  /// **'Document validated'**
  String get documentValidatedAction;

  /// No description provided for @aiQueryAction.
  ///
  /// In en, this message translates to:
  /// **'AI query'**
  String get aiQueryAction;

  /// No description provided for @reportGeneratedAction.
  ///
  /// In en, this message translates to:
  /// **'Report generated'**
  String get reportGeneratedAction;

  /// No description provided for @noActionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No actions recorded'**
  String get noActionsRecorded;

  /// No description provided for @noActionsOfThisType.
  ///
  /// In en, this message translates to:
  /// **'No actions of this type'**
  String get noActionsOfThisType;

  /// No description provided for @restrictedAccess.
  ///
  /// In en, this message translates to:
  /// **'Restricted access'**
  String get restrictedAccess;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @searchSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get searchSuppliers;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteConfirmTitle(String name);

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteConfirmMessage;

  /// No description provided for @productInUse.
  ///
  /// In en, this message translates to:
  /// **'This product cannot be deleted because it is used in sales, purchases or stock movements.'**
  String get productInUse;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get currentStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'in stock'**
  String get inStock;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get customerDetails;

  /// No description provided for @supplierDetails.
  ///
  /// In en, this message translates to:
  /// **'Supplier details'**
  String get supplierDetails;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit supplier'**
  String get editSupplier;

  /// No description provided for @customerInUse.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be deleted because they have sales history.'**
  String get customerInUse;

  /// No description provided for @supplierInUse.
  ///
  /// In en, this message translates to:
  /// **'This supplier cannot be deleted because they have purchase history.'**
  String get supplierInUse;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get customerDeleted;

  /// No description provided for @customerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated'**
  String get customerUpdated;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total purchases'**
  String get totalPurchases;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance'**
  String get outstandingBalance;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @lastOrder.
  ///
  /// In en, this message translates to:
  /// **'Last order'**
  String get lastOrder;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @creditUsage.
  ///
  /// In en, this message translates to:
  /// **'Credit usage'**
  String get creditUsage;

  /// No description provided for @creditLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Credit limit exceeded'**
  String get creditLimitExceeded;

  /// No description provided for @creditLimitNearlyReached.
  ///
  /// In en, this message translates to:
  /// **'Credit limit nearly reached'**
  String get creditLimitNearlyReached;

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get purchaseHistory;

  /// No description provided for @noPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get noPurchaseHistory;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callCustomer;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get sendEmail;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'unpaid'**
  String get unpaid;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get contactPerson;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get paymentTerms;

  /// No description provided for @paymentTermsCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentTermsCash;

  /// No description provided for @paymentTermsDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String paymentTermsDays(int days);

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account (RIB)'**
  String get bankAccount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @customerType.
  ///
  /// In en, this message translates to:
  /// **'Customer type'**
  String get customerType;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @supplierDeleted.
  ///
  /// In en, this message translates to:
  /// **'Supplier deleted'**
  String get supplierDeleted;

  /// No description provided for @supplierUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated'**
  String get supplierUpdated;

  /// No description provided for @amountOwed.
  ///
  /// In en, this message translates to:
  /// **'Amount owed'**
  String get amountOwed;

  /// No description provided for @leadTime.
  ///
  /// In en, this message translates to:
  /// **'Lead time'**
  String get leadTime;

  /// No description provided for @deliveryReliability.
  ///
  /// In en, this message translates to:
  /// **'Delivery reliability'**
  String get deliveryReliability;

  /// No description provided for @noDeliveryData.
  ///
  /// In en, this message translates to:
  /// **'No delivery data yet'**
  String get noDeliveryData;

  /// No description provided for @onTimeDeliveries.
  ///
  /// In en, this message translates to:
  /// **'{onTime} of {total} on time'**
  String onTimeDeliveries(int onTime, int total);

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @commercialInfo.
  ///
  /// In en, this message translates to:
  /// **'Commercial information'**
  String get commercialInfo;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get totalOrders;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance manager'**
  String get roleFinance;

  /// No description provided for @roleStock.
  ///
  /// In en, this message translates to:
  /// **'Stock manager'**
  String get roleStock;

  /// No description provided for @roleCommercial.
  ///
  /// In en, this message translates to:
  /// **'Sales rep'**
  String get roleCommercial;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @roleAuditor.
  ///
  /// In en, this message translates to:
  /// **'Auditor'**
  String get roleAuditor;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @intelligence.
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get intelligence;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again.'**
  String get logoutConfirmMessage;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @noComparison.
  ///
  /// In en, this message translates to:
  /// **'No comparison'**
  String get noComparison;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValue;

  /// No description provided for @salesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Sales this month'**
  String get salesThisMonth;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue (last 30 days)'**
  String get revenueTrend;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top products'**
  String get topProducts;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet'**
  String get noSalesYet;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @noAlerts.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your attention'**
  String get noAlerts;

  /// No description provided for @allGood.
  ///
  /// In en, this message translates to:
  /// **'Everything looks good'**
  String get allGood;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'{name} is out of stock'**
  String lowStockAlert(String name);

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'{name}: only {qty} left'**
  String lowStockWarning(String name, int qty);

  /// No description provided for @creditExceededAlert.
  ///
  /// In en, this message translates to:
  /// **'{name} is over their credit limit'**
  String creditExceededAlert(String name);

  /// No description provided for @overduePaymentAlert.
  ///
  /// In en, this message translates to:
  /// **'{name}: {days} days overdue'**
  String overduePaymentAlert(String name, int days);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivity;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @unitsSold.
  ///
  /// In en, this message translates to:
  /// **'{qty} sold'**
  String unitsSold(int qty);

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'Reference (SKU)'**
  String get sku;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryInUse.
  ///
  /// In en, this message translates to:
  /// **'This category cannot be deleted because products are using it.'**
  String get categoryInUse;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get noCategory;

  /// No description provided for @productCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products} =1{1 product} other{{count} products}}'**
  String productCount(int count);

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @vatRate.
  ///
  /// In en, this message translates to:
  /// **'VAT rate'**
  String get vatRate;

  /// No description provided for @maxThreshold.
  ///
  /// In en, this message translates to:
  /// **'Max threshold'**
  String get maxThreshold;

  /// No description provided for @shelfLocation.
  ///
  /// In en, this message translates to:
  /// **'Shelf location'**
  String get shelfLocation;

  /// No description provided for @defaultSupplier.
  ///
  /// In en, this message translates to:
  /// **'Default supplier'**
  String get defaultSupplier;

  /// No description provided for @saleUnit.
  ///
  /// In en, this message translates to:
  /// **'Sale unit'**
  String get saleUnit;

  /// No description provided for @purchaseUnit.
  ///
  /// In en, this message translates to:
  /// **'Purchase unit'**
  String get purchaseUnit;

  /// No description provided for @unitsPerPurchase.
  ///
  /// In en, this message translates to:
  /// **'Units per purchase unit'**
  String get unitsPerPurchase;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @productActive.
  ///
  /// In en, this message translates to:
  /// **'Product is active'**
  String get productActive;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInfo;

  /// No description provided for @pricingAndVat.
  ///
  /// In en, this message translates to:
  /// **'Pricing & VAT'**
  String get pricingAndVat;

  /// No description provided for @stockSettings.
  ///
  /// In en, this message translates to:
  /// **'Stock settings'**
  String get stockSettings;

  /// No description provided for @unitsAndPackaging.
  ///
  /// In en, this message translates to:
  /// **'Units & packaging'**
  String get unitsAndPackaging;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock history'**
  String get stockHistory;

  /// No description provided for @noStockHistory.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet'**
  String get noStockHistory;

  /// No description provided for @priceHt.
  ///
  /// In en, this message translates to:
  /// **'Price (excl. VAT)'**
  String get priceHt;

  /// No description provided for @priceTtc.
  ///
  /// In en, this message translates to:
  /// **'Price (incl. VAT)'**
  String get priceTtc;

  /// No description provided for @marginAmount.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get marginAmount;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @showInactive.
  ///
  /// In en, this message translates to:
  /// **'Show inactive'**
  String get showInactive;

  /// No description provided for @subtotalHt.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (excl. VAT)'**
  String get subtotalHt;

  /// No description provided for @totalVat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get totalVat;

  /// No description provided for @totalTtc.
  ///
  /// In en, this message translates to:
  /// **'Total (incl. VAT)'**
  String get totalTtc;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @expectedDate.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery'**
  String get expectedDate;

  /// No description provided for @receivedDate.
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get receivedDate;

  /// No description provided for @markAsReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark as received'**
  String get markAsReceived;

  /// No description provided for @purchaseReceived.
  ///
  /// In en, this message translates to:
  /// **'Purchase received'**
  String get purchaseReceived;

  /// No description provided for @alreadyReceived.
  ///
  /// In en, this message translates to:
  /// **'This purchase is already received'**
  String get alreadyReceived;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String dueIn(int days);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @pendingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pending delivery'**
  String get pendingDelivery;

  /// No description provided for @lineVat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get lineVat;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice details'**
  String get invoiceDetails;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @searchSales.
  ///
  /// In en, this message translates to:
  /// **'Search sales...'**
  String get searchSales;

  /// No description provided for @searchPurchases.
  ///
  /// In en, this message translates to:
  /// **'Search purchases...'**
  String get searchPurchases;

  /// No description provided for @editSale.
  ///
  /// In en, this message translates to:
  /// **'Edit sale'**
  String get editSale;

  /// No description provided for @editPurchase.
  ///
  /// In en, this message translates to:
  /// **'Edit purchase'**
  String get editPurchase;

  /// No description provided for @saleHasPayments.
  ///
  /// In en, this message translates to:
  /// **'This sale cannot be modified or deleted because payments have been recorded against it.'**
  String get saleHasPayments;

  /// No description provided for @purchaseHasPayments.
  ///
  /// In en, this message translates to:
  /// **'This purchase cannot be modified or deleted because payments have been recorded against it.'**
  String get purchaseHasPayments;

  /// No description provided for @saleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sale deleted'**
  String get saleDeleted;

  /// No description provided for @saleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sale updated'**
  String get saleUpdated;

  /// No description provided for @purchaseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase deleted'**
  String get purchaseDeleted;

  /// No description provided for @purchaseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Purchase updated'**
  String get purchaseUpdated;

  /// No description provided for @stockWillBeRestored.
  ///
  /// In en, this message translates to:
  /// **'The stock will be restored.'**
  String get stockWillBeRestored;

  /// No description provided for @searchWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Search warehouses...'**
  String get searchWarehouses;

  /// No description provided for @newWarehouse.
  ///
  /// In en, this message translates to:
  /// **'New warehouse'**
  String get newWarehouse;

  /// No description provided for @editWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Edit warehouse'**
  String get editWarehouse;

  /// No description provided for @warehouseInUse.
  ///
  /// In en, this message translates to:
  /// **'This warehouse cannot be deleted because it has stock movements.'**
  String get warehouseInUse;

  /// No description provided for @warehouseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Warehouse deleted'**
  String get warehouseDeleted;

  /// No description provided for @warehouseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Warehouse updated'**
  String get warehouseUpdated;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @totalUnits.
  ///
  /// In en, this message translates to:
  /// **'Units in stock'**
  String get totalUnits;

  /// No description provided for @distinctProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get distinctProducts;

  /// No description provided for @warehouseActive.
  ///
  /// In en, this message translates to:
  /// **'Warehouse is active'**
  String get warehouseActive;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get newUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get editUser;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get noUsers;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordReset;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get wrongPassword;

  /// No description provided for @emailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email is already used'**
  String get emailTaken;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @lastAdmin.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove the last administrator'**
  String get lastAdmin;

  /// No description provided for @cannotDeleteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account'**
  String get cannotDeleteSelf;

  /// No description provided for @userHasActivity.
  ///
  /// In en, this message translates to:
  /// **'This user cannot be deleted because they have activity in the system. Deactivate them instead.'**
  String get userHasActivity;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get userCreated;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get userUpdated;

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get userDeleted;

  /// No description provided for @userActive.
  ///
  /// In en, this message translates to:
  /// **'Account is active'**
  String get userActive;

  /// No description provided for @neverLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Never logged in'**
  String get neverLoggedIn;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login'**
  String get lastLogin;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get accountSecurity;

  /// No description provided for @accessRights.
  ///
  /// In en, this message translates to:
  /// **'Access rights'**
  String get accessRights;

  /// No description provided for @permissionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} permissions'**
  String permissionsCount(int count);

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact your administrator.'**
  String get accountDisabled;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do this'**
  String get forbidden;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signUp;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your company on Forever One'**
  String get signUpSubtitle;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get backToLogin;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @mainWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Main warehouse'**
  String get mainWarehouse;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Forever One'**
  String get accountCreated;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed, please try again'**
  String get registrationFailed;

  /// No description provided for @companyInfo.
  ///
  /// In en, this message translates to:
  /// **'Your company'**
  String get companyInfo;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @signUpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'You will be the administrator of this company'**
  String get signUpDisclaimer;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
