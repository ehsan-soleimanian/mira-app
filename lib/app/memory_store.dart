import 'package:flutter/foundation.dart';

import 'package:mira_app/features/workspace/library_repository.dart';
import 'package:mira_app/models/api/workspace_models.dart';

/// Shared client-side cache and source of truth for the user's library
/// memories, held once on [MiraServices] and reachable from every redesign
/// screen through `AppScope`.
///
/// The point is coherence: an edit made on one screen (e.g. Memory detail)
/// reflects on the others (e.g. Library) without a re-fetch. Screens read from
/// [getAll] / [get] and listen for changes ([ChangeNotifier] via
/// `notifyListeners`); writes are optimistic and local ([applyLocalEdit] /
/// [removeLocal]) — the network round-trip stays each screen's responsibility,
/// this only keeps the in-memory copy consistent so views stay in sync.
class MemoryStore extends ChangeNotifier {
  MemoryStore(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  /// Cached items keyed by [LibraryItem.id].
  final Map<String, LibraryItem> _byId = {};

  bool _loaded = false;

  /// Whether [load] has successfully populated the cache at least once this
  /// session. Screens use this to decide between the live set and their sample
  /// fallback.
  bool get loaded => _loaded;

  /// Loads every library item once and caches it by id. A second call is a
  /// no-op unless [force] is set (e.g. an explicit pull-to-refresh).
  ///
  /// Best-effort: a failed fetch leaves the cache untouched and [loaded] false,
  /// so a later call retries rather than stranding the store in a bad state.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final items = await _libraryRepository.list();
      _byId
        ..clear()
        ..addEntries(items.map((item) => MapEntry(item.id, item)));
      _loaded = true;
      notifyListeners();
    } catch (_) {
      // Backend unreachable — leave the cache as-is; a later load() retries.
    }
  }

  /// Every cached memory, newest-first by creation time.
  List<LibraryItem> getAll() {
    final items = _byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// The cached memory for [id], or null when it isn't loaded.
  LibraryItem? get(String id) => _byId[id];

  /// Optimistically patches a cached memory's [title] and/or [summary] in place
  /// so listening screens reflect an edit immediately. No-op when [id] isn't
  /// cached. Local-only — persistence stays with the caller.
  void applyLocalEdit(String id, {String? title, String? summary}) {
    final existing = _byId[id];
    if (existing == null) return;
    _byId[id] = existing.copyWith(title: title, summary: summary);
    notifyListeners();
  }

  /// Removes a cached memory (delete / archive) so it drops from every listener.
  /// No-op when [id] isn't cached. Local-only — persistence stays with the
  /// caller.
  void removeLocal(String id) {
    if (_byId.remove(id) != null) notifyListeners();
  }

  /// Inserts or replaces one library item after a successful create/import so
  /// Library (and other listeners) reflect it without a full reload.
  void upsertLocal(LibraryItem item) {
    _byId[item.id] = item;
    _loaded = true;
    notifyListeners();
  }
}
