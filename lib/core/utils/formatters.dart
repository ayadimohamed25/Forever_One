// Shared display formats, so money and dates look identical on every screen.

String _two(int n) => n.toString().padLeft(2, '0');

/// Non-breaking space: groups digits and keeps "DT" on the same line.
const _nbsp = ' ';

/// 4 005.00 — thousands separated by a space, always two decimals.
String formatAmount(double amount) {
  final negative = amount < 0;
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(_nbsp);
    grouped.write(whole[i]);
  }
  return '${negative ? '−' : ''}$grouped.${parts[1]}';
}

/// 4 005.00 DT — the one money format used everywhere.
String formatDT(double amount) => '${formatAmount(amount)}${_nbsp}DT';

/// +53.55 DT for money coming in, −53.55 DT for money going out.
String formatSignedDT(double amount, {required bool incoming}) =>
    '${incoming ? '+' : '−'}${formatAmount(amount.abs())}${_nbsp}DT';

/// 17/09/2026
String formatDate(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year}';

/// 17/09/2026 · 14:05
String formatDateTime(DateTime date) =>
    '${formatDate(date)} · ${_two(date.hour)}:${_two(date.minute)}';
