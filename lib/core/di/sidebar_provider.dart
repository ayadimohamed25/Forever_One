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

/// Which sidebar groups the user opened or closed, remembered across
/// launches. A group the user never touched follows the current page: the
/// page's own group is open, the others closed (see [isOpen]).
class NavGroupsNotifier extends StateNotifier<Map<String, bool>> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'sidebar_groups';

  NavGroupsNotifier() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return;
      state = {
        for (final part in raw.split(','))
          if (part.contains('='))
            part.split('=')[0]: part.split('=')[1] == '1',
      };
    } catch (_) {
      // Storage unavailable (tests, some web contexts): defaults apply.
    }
  }

  /// Open when the user opened it, or when it holds the current page and the
  /// user hasn't closed it.
  bool isOpen(String group, {required bool active}) => state[group] ?? active;

  Future<void> toggle(String group, {required bool active}) async {
    state = {...state, group: !isOpen(group, active: active)};
    try {
      await _storage.write(
        key: _key,
        value: state.entries.map((e) => '${e.key}=${e.value ? 1 : 0}').join(','),
      );
    } catch (_) {
      // Still toggles for this session.
    }
  }
}

final navGroupsProvider =
    StateNotifierProvider<NavGroupsNotifier, Map<String, bool>>(
        (ref) => NavGroupsNotifier());
