import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side "Mira Plus" membership flag.
///
/// There is no billing backend yet (no Stripe keys), so this is the single
/// source of truth the Account plan row and the Paywall share — mirroring the
/// design's `localStorage("mira-plus")`. The paywall's Subscribe / Cancel flip
/// it; it persists across launches via shared_preferences. Swap this for a real
/// entitlement lookup once billing exists.
class Membership {
  Membership._();

  static final ValueNotifier<bool> isPlus = ValueNotifier<bool>(false);
  static const _key = 'mira_plus';
  static bool _loaded = false;

  /// Loads the persisted flag once. Safe to call from multiple screens.
  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      isPlus.value = prefs.getBool(_key) ?? false;
    } catch (_) {
      // Prefs unavailable (e.g. web preview) — default to Free.
    }
  }

  /// Sets and persists the membership flag; notifies listeners immediately.
  static Future<void> setPlus(bool value) async {
    isPlus.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {
      // Best-effort — the in-memory flag already updated the UI.
    }
  }
}
