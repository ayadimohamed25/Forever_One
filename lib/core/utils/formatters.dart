// Shared display formats, so money and dates look identical on every screen.

String _two(int n) => n.toString().padLeft(2, '0');

/// 53.55 DT — always two decimals.
String formatDT(double amount) => '${amount.toStringAsFixed(2)} DT';

/// +53.55 DT for money coming in, −53.55 DT for money going out.
String formatSignedDT(double amount, {required bool incoming}) =>
    '${incoming ? '+' : '−'}${amount.toStringAsFixed(2)} DT';

/// 17/09/2026
String formatDate(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year}';

/// 17/09/2026 · 14:05
String formatDateTime(DateTime date) =>
    '${formatDate(date)} · ${_two(date.hour)}:${_two(date.minute)}';