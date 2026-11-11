import '../../l10n/app_localizations.dart';

/// Turns an error CODE (from the API or a repository) into a sentence in the
/// app's language. The API and the data layer never produce user-facing text:
/// they return codes like `INVALID_CREDENTIALS` or `SAVE_FAILED`, and every
/// screen shows `errorText(code, l10n)`.
///
/// Unknown codes (or anything that is not a code) fall back to a generic
/// message, so raw server text never reaches the user.
String errorText(String? code, AppLocalizations l10n) {
  switch (code) {
    // Network and session
    case 'NETWORK_ERROR':
      return l10n.errNetwork;
    case 'SESSION_EXPIRED':
    case 'AUTH_REQUIRED':
      return l10n.errSessionExpired;
    case 'FORBIDDEN':
      return l10n.forbidden;
    // Sign-in and accounts
    case 'INVALID_CREDENTIALS':
      return l10n.errInvalidCredentials;
    case 'LOGIN_FAILED':
      return l10n.errLoginFailed;
    case 'ACCOUNT_DISABLED':
      return l10n.accountDisabled;
    case 'REGISTRATION_FAILED':
      return l10n.registrationFailed;
    case 'EMAIL_TAKEN':
      return l10n.emailTaken;
    case 'INVALID_EMAIL':
      return l10n.invalidEmail;
    case 'PASSWORD_TOO_SHORT':
      return l10n.passwordTooShort;
    case 'WRONG_PASSWORD':
      return l10n.wrongPassword;
    case 'INVALID_ROLE':
      return l10n.errInvalidRole;
    case 'LAST_ADMIN':
      return l10n.lastAdmin;
    case 'CANNOT_DELETE_SELF':
      return l10n.cannotDeleteSelf;
    case 'USER_HAS_ACTIVITY':
      return l10n.userHasActivity;
    // Data
    case 'LOAD_FAILED':
      return l10n.errLoadFailed;
    case 'SAVE_FAILED':
      return l10n.errSaveFailed;
    case 'DELETE_FAILED':
      return l10n.errDeleteFailed;
    case 'NOT_FOUND':
    case 'ROUTE_NOT_FOUND':
      return l10n.errNotFound;
    case 'MISSING_FIELDS':
    case 'FIELD_REQUIRED':
      return l10n.errMissingFields;
    case 'NAME_REQUIRED':
      return l10n.errNameRequired;
    case 'LINES_REQUIRED':
      return l10n.errLinesRequired;
    case 'INVALID_PAYMENT_TARGET':
      return l10n.errInvalidPaymentTarget;
    case 'CATEGORY_IN_USE':
      return l10n.categoryInUse;
    case 'CUSTOMER_IN_USE':
      return l10n.customerInUse;
    case 'PRODUCT_IN_USE':
      return l10n.productInUse;
    case 'SUPPLIER_IN_USE':
      return l10n.supplierInUse;
    case 'WAREHOUSE_IN_USE':
      return l10n.warehouseInUse;
    case 'SALE_HAS_PAYMENTS':
      return l10n.saleHasPayments;
    case 'PURCHASE_HAS_PAYMENTS':
      return l10n.purchaseHasPayments;
    case 'PURCHASE_ALREADY_RECEIVED':
      return l10n.purchaseAlreadyReceived;
    case 'NO_IMAGE':
      return l10n.errNoImage;
    case 'UPLOAD_FAILED':
      return l10n.errUploadFailed;
    case 'REPORT_FAILED':
      return l10n.reportFailed;
    default:
      return l10n.errGeneric;
  }
}
