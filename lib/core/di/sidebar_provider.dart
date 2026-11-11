import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether the desktop sidebar is collapsed to an icon rail. A user choice,
/// remembered across launches; never changed by window width.
class SidebarCollapsedNotifier extends StateNotifier<bool> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'sidebar_collapsed';

  SidebarCollapsedNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = (await _storage.read(key: _key)) == 'true';
    } catch (_) {
      // Storage unavailable (tests, some web contexts): stay expanded.
    }
  }

  Future<void> toggle() async {
    state = !state;
    try {
      await _storage.write(key: _key, value: '$state');
    } catch (_) {
      // Still toggles for this session.
    }
  }
}

final sidebarCollapsedProvider =
    StateNotifierProvider<SidebarCollapsedNotifier, bool>(
        (ref) => SidebarCollapsedNotifier());
