import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/models/api/storage_models.dart';

import '../theme/rd_colors.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// Storage — a pushed screen showing how much of the account's quota is used,
/// broken down by category. Usage loads from `settingsRepository`
/// (`GET /storage/usage`); until it arrives — or if the backend is unreachable —
/// a representative sample is shown so the screen never renders empty. Styled to
/// match the Account cluster (`rd_settings.dart`): rounded cards, Dosis /
/// Vazirmatn, and dark-aware from the start via `context.rd`.
///
/// Layout: a headline of **used of quota** in human units, a **segmented bar**
/// split by category (a distinct colour per type), then a **per-category list**
/// (icon + label + item count + human size), and finally a "free up space"
/// action that clears archived captures best-effort.
class RdStorageScreen extends StatefulWidget {
  const RdStorageScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdStorageScreen> createState() => _RdStorageScreenState();
}

class _RdStorageScreenState extends State<RdStorageScreen> {
  /// Live usage from the backend; null until the first load. Falls back to the
  /// zeroed baseline below when unreachable, so the layout is always populated.
  StorageUsage? _usage;
  bool _loaded = false;
  bool _clearing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final usage = await AppScope.servicesOf(context)
          .settingsRepository
          .fetchStorageUsage();
      if (mounted) setState(() => _usage = usage);
    } catch (_) {
      // Backend unreachable — keep the zeroed baseline; never show fake usage.
    }
  }

  /// The usage to render — live once loaded, a zeroed baseline until then.
  StorageUsage get _source => _usage ?? _empty;

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          // Fixed dark pill in both themes — its text is white, so it must not
          // flip to the near-white dark-mode ink.
          backgroundColor: RdColors.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: Colors.white),
          ),
        ),
      );
  }

  /// "Free up space": permanently deletes archived captures. Loads the archived
  /// items (`?includeArchived`, flagged in metadata), bulk-deletes them via
  /// `/library/items/bulk-actions`, then refreshes the usage bar and reports how
  /// much was reclaimed.
  Future<void> _clearArchived() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      final repo = AppScope.servicesOf(context).libraryRepository;
      final items = await repo.list(includeArchived: true);
      final archived = items
          .where((i) => (i.metadata['archived'] as bool?) ?? false)
          .toList();
      if (archived.isEmpty) {
        if (mounted) {
          setState(() => _clearing = false);
          _toast('No archived items to clear');
        }
        return;
      }
      final bytes = archived.fold<int>(0, (sum, i) => sum + (i.sizeBytes ?? 0));
      await repo.bulkAction(archived.map((i) => i.id).toList(), 'delete');
      await _load(); // pull the new usage so the bar/breakdown update
      if (mounted) {
        setState(() => _clearing = false);
        final freed = bytes > 0 ? ' · ${_bytesHuman(bytes)} freed' : '';
        _toast(
            'Cleared ${archived.length} archived item${archived.length == 1 ? '' : 's'}$freed');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _clearing = false);
        _toast('Couldn’t clear archived items');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final usage = _source;
    return Scaffold(
      backgroundColor: rd.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _back(),
              _heading(),
              if (_usage == null) const _LoadingHint(),
              _SummaryCard(usage: usage),
              _sectionLabel('Breakdown'),
              _breakdown(usage),
              _sectionLabel('Manage'),
              _manage(),
              const _StorageFoot('Mira keeps only what you approve.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _back() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 20, 0),
      child: GestureDetector(
        onTap: widget.onBack,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RdIcon(RdIcons.chevronLeft, size: 20, color: rd.navy, strokeWidth: 2),
              const SizedBox(width: 3),
              Text('Account',
                  style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.navy)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage',
              style: GoogleFonts.dosis(
                  fontSize: 30, fontWeight: FontWeight.w700, color: rd.ink)),
          const SizedBox(height: 4),
          Text(
            'What Mira is holding, and how much room is left.',
            style:
                GoogleFonts.vazirmatn(fontSize: 14, height: 1.5, color: rd.muted),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 10),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: rd.faint),
      ),
    );
  }

  Widget _breakdown(StorageUsage usage) {
    final rd = context.rd;
    // Only categories that actually hold something get a row — but the six are
    // always sent, so this collapses empty buckets rather than the whole list.
    final rows = usage.categories.where((c) => c.count > 0 || c.bytes > 0).toList();
    final shown = rows.isEmpty ? usage.categories : rows;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rd.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 62),
                  child: Divider(height: 1, thickness: 1, color: rd.line),
                ),
              _CategoryRow(category: shown[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _manage() {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rd.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _ManageRow(
              icon: RdIcons.archive,
              title: 'Clear archived',
              sub: 'Remove captures you have archived',
              busy: _clearing,
              onTap: _clearArchived,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 62),
              child: Divider(height: 1, thickness: 1, color: rd.line),
            ),
            _ManageRow(
              icon: RdIcons.link,
              title: 'Offload originals to cloud',
              sub: 'Keep full-quality copies in a connected service',
              onTap: () => widget.go('connectedapps'),
            ),
          ],
        ),
      ),
    );
  }

  /// Zeroed baseline — shown until the real figures load, or if they can't, so
  /// the layout is populated without ever presenting fabricated usage. Mirrors
  /// the endpoint's shape: six categories, always present, all empty.
  static StorageUsage get _empty => const StorageUsage(
        usedBytes: 0,
        quotaBytes: 0,
        categories: [
          StorageCategory(type: 'photos', count: 0, bytes: 0),
          StorageCategory(type: 'voice', count: 0, bytes: 0),
          StorageCategory(type: 'screenshots', count: 0, bytes: 0),
          StorageCategory(type: 'notes', count: 0, bytes: 0),
          StorageCategory(type: 'links', count: 0, bytes: 0),
          StorageCategory(type: 'other', count: 0, bytes: 0),
        ],
      );
}

/// The summary card: the used-of-quota headline plus the segmented usage bar.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.usage});

  final StorageUsage usage;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final hasQuota = usage.quotaBytes > 0;
    final pct = (usage.fraction * 100).round();
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _bytesHuman(usage.usedBytes),
                style: GoogleFonts.dosis(
                    fontSize: 30, fontWeight: FontWeight.w700, color: rd.ink),
              ),
              const SizedBox(width: 8),
              if (hasQuota)
                Text(
                  'of ${_bytesHuman(usage.quotaBytes)}',
                  style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.muted),
                ),
              const Spacer(),
              if (hasQuota)
                Text('$pct%',
                    style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rd.muted)),
            ],
          ),
          const SizedBox(height: 14),
          _SegmentedBar(usage: usage),
          const SizedBox(height: 14),
          _Legend(usage: usage),
        ],
      ),
    );
  }
}

/// A single rounded track split into a coloured segment per category, sized by
/// each category's share of the quota (or of the used total when there is no
/// quota). A trailing "free" segment fills the remaining room.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.usage});

  final StorageUsage usage;

  @override
  Widget build(BuildContext context) {
    // Track (the empty remainder) has no palette token: keep the exact light
    // literal, darken for dark mode — same treatment as the Account storage bar.
    final trackBg =
        _isDark(context) ? const Color(0xFF2A2B33) : const Color(0xFFE7E7E1);
    // Denominator: the quota when present, else the used total so segments still
    // fill the bar proportionally.
    final total =
        usage.quotaBytes > 0 ? usage.quotaBytes : (usage.usedBytes == 0 ? 1 : usage.usedBytes);
    final segments = usage.categories.where((c) => c.bytes > 0).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (final c in segments)
              Expanded(
                flex: (c.bytes / total * 10000).round().clamp(1, 1000000),
                child: Container(color: _categoryColor(context, c.type)),
              ),
            // The unused remainder — flexes to whatever space is left.
            Expanded(
              flex: () {
                final usedShare = segments.fold<int>(
                    0, (sum, c) => sum + (c.bytes / total * 10000).round());
                final free = 10000 - usedShare;
                return free <= 0 ? 1 : free;
              }(),
              child: Container(color: trackBg),
            ),
          ],
        ),
      ),
    );
  }
}

/// The colour swatches under the bar, one per non-empty category, so the
/// segments can be read without tapping into the list.
class _Legend extends StatelessWidget {
  const _Legend({required this.usage});

  final StorageUsage usage;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final items = usage.categories.where((c) => c.bytes > 0).toList();
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final c in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _categoryColor(context, c.type)),
              ),
              const SizedBox(width: 6),
              Text(
                _categoryLabel(c.type),
                style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted),
              ),
            ],
          ),
      ],
    );
  }
}

/// One breakdown row: a tinted category tile, the label + item count, and the
/// human-readable size on the right.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final StorageCategory category;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final color = _categoryColor(context, category.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              // A translucent wash of the category colour so the glyph reads
              // against the card in both themes.
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: RdIcon(_categoryIcon(category.type),
                  size: 18, color: color, strokeWidth: 1.9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabel(category.type),
                  style: GoogleFonts.vazirmatn(
                      fontSize: 15, fontWeight: FontWeight.w500, color: rd.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  _countLabel(category.count),
                  style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _bytesHuman(category.bytes),
            style: GoogleFonts.vazirmatn(
                fontSize: 14, fontWeight: FontWeight.w600, color: rd.ink),
          ),
        ],
      ),
    );
  }
}

/// A tappable management row (Clear archived / Optimise). Shows a small spinner
/// in place of the chevron while [busy].
class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.busy = false,
  });

  final String icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: busy ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Center(
                child: RdIcon(icon, size: 19, color: rd.peri, strokeWidth: 1.8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: rd.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style:
                        GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (busy)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: rd.faint),
              )
            else
              RdIcon('<path d="m9 6 6 6-6 6"/>',
                  size: 18, color: rd.faint, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

/// A brief "loading" line shown above the summary while live figures load; the
/// sample renders underneath so the screen is never blank.
class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Row(
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child:
                CircularProgressIndicator(strokeWidth: 1.8, color: rd.faint),
          ),
          const SizedBox(width: 8),
          Text('Updating usage…',
              style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.faint)),
        ],
      ),
    );
  }
}

class _StorageFoot extends StatelessWidget {
  const _StorageFoot(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Center(
        child: Text(text,
            style:
                GoogleFonts.vazirmatn(fontSize: 12, color: context.rd.faint)),
      ),
    );
  }
}

// ══ category helpers ═══════════════════════════════════════════════════════

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Human label for a category type (e.g. `screenshots` → "Screenshots").
String _categoryLabel(String type) {
  switch (type) {
    case 'photos':
      return 'Photos';
    case 'voice':
      return 'Voice';
    case 'screenshots':
      return 'Screenshots';
    case 'notes':
      return 'Notes';
    case 'links':
      return 'Links';
    default:
      return 'Other';
  }
}

/// The line icon (from [RdIcons], or an inline body) for a category type.
String _categoryIcon(String type) {
  switch (type) {
    case 'photos':
      return RdIcons.photo;
    case 'voice':
      return RdIcons.micSimple;
    case 'screenshots':
      // A framed screen glyph, distinct from the photo icon.
      return '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 3v18M4 8h4"/>';
    case 'notes':
      return '<rect x="4" y="3" width="16" height="18" rx="2.5"/><path d="M8 8h8M8 12h8M8 16h5"/>';
    case 'links':
      return RdIcons.linkChain;
    default:
      return RdIcons.folder;
  }
}

/// A distinct, fixed colour per category — used for both the bar segment and the
/// tinted row tile. These are brand-adjacent accents, kept constant across
/// themes so the segments stay identifiable (the row tile tints them down).
Color _categoryColor(BuildContext context, String type) {
  switch (type) {
    case 'photos':
      return const Color(0xFF5B8DEF); // blue
    case 'voice':
      return const Color(0xFFE86868); // coral
    case 'screenshots':
      return const Color(0xFF7E8BC9); // periwinkle
    case 'notes':
      return const Color(0xFFF0B545); // amber
    case 'links':
      return const Color(0xFF37B6A0); // teal
    default:
      return const Color(0xFF9AA0AC); // slate grey
  }
}

/// "128 items" / "1 item" / "Empty".
String _countLabel(int count) {
  if (count <= 0) return 'Empty';
  if (count == 1) return '1 item';
  return '$count items';
}

/// Human-readable byte size: bytes → KB → MB → GB, with one decimal above the
/// KB threshold and no trailing ".0". e.g. 6912 → "6.8 KB", 5368709120 → "5 GB".
String _bytesHuman(int bytes) {
  if (bytes <= 0) return '0 KB';
  const kb = 1024.0;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes < mb) {
    return '${_trim(bytes / kb)} KB';
  }
  if (bytes < gb) {
    return '${_trim(bytes / mb)} MB';
  }
  return '${_trim(bytes / gb)} GB';
}

/// Formats a size figure with at most one decimal, dropping a trailing ".0".
String _trim(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.toStringAsFixed(0);
  return rounded.toStringAsFixed(1);
}
