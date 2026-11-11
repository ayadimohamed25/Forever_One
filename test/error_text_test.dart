import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/core/errors/error_text.dart';
import 'package:foreverone/l10n/app_localizations.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations fr;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    fr = await AppLocalizations.delegate.load(const Locale('fr'));
  });

  test('API and data-layer codes become sentences in the app language', () {
    expect(errorText('INVALID_CREDENTIALS', en), en.errInvalidCredentials);
    expect(errorText('INVALID_CREDENTIALS', fr), fr.errInvalidCredentials);
    expect(errorText('REPORT_FAILED', en), en.reportFailed);
    expect(errorText('REPORT_FAILED', fr), isNot(en.reportFailed));
    expect(errorText('NETWORK_ERROR', en), en.errNetwork);
    expect(errorText('SAVE_FAILED', fr), fr.errSaveFailed);
  });

  test('raw server text or unknown codes never reach the user', () {
    expect(errorText('Impossible de générer le rapport', en), en.errGeneric);
    expect(errorText('SQLSTATE[HY000] something', en), en.errGeneric);
    expect(errorText(null, fr), fr.errGeneric);
  });

  test('every code the backend returns has a translation', () {
    const backendCodes = [
      'ACCOUNT_DISABLED', 'AUTH_REQUIRED', 'CANNOT_DELETE_SELF', 'CATEGORY_IN_USE',
      'CUSTOMER_IN_USE', 'DELETE_FAILED', 'EMAIL_TAKEN', 'FIELD_REQUIRED',
      'FORBIDDEN', 'INVALID_CREDENTIALS', 'INVALID_EMAIL', 'INVALID_PAYMENT_TARGET',
      'INVALID_ROLE', 'LAST_ADMIN', 'LINES_REQUIRED', 'MISSING_FIELDS',
      'NAME_REQUIRED', 'NOT_FOUND', 'NO_IMAGE', 'PASSWORD_TOO_SHORT',
      'PRODUCT_IN_USE', 'PURCHASE_ALREADY_RECEIVED', 'PURCHASE_HAS_PAYMENTS',
      'REGISTRATION_FAILED', 'ROUTE_NOT_FOUND', 'SALE_HAS_PAYMENTS', 'SAVE_FAILED',
      'SESSION_EXPIRED', 'SUPPLIER_IN_USE', 'UPLOAD_FAILED', 'USER_HAS_ACTIVITY',
      'WAREHOUSE_IN_USE', 'WRONG_PASSWORD',
    ];
    for (final code in backendCodes) {
      expect(errorText(code, en), isNot(en.errGeneric), reason: code);
    }
  });
}
