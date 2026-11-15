import 'package:web/web.dart' as web;

/// Web: the browser's `prefers-reduced-motion: reduce` setting. Read on each
/// call so a change in the OS setting applies without a reload.
bool platformPrefersReducedMotion() {
  try {
    return web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  } catch (_) {
    // matchMedia unavailable (very old browser): animate normally.
    return false;
  }
}
