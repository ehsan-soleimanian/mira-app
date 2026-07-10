import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/models/api/collection_models.dart';

import '../theme/rd_theme.dart';
import 'rd_icon.dart';

/// The user's pick from the "add to collection" sheet: an existing collection,
/// or a request to create a new one named [name]. Shared by the Library
/// multi-select flow and the Memory detail action menu.
class RdColChoice {
  const RdColChoice.existing(this.collection) : name = null;
  const RdColChoice.create(this.name) : collection = null;

  final MemoryCollection? collection;
  final String? name;
}

/// Bottom sheet that lists the user's collections and offers to create a new
/// one, returning a [RdColChoice] via `Navigator.pop`.
class RdCollectionPickerSheet extends StatefulWidget {
  const RdCollectionPickerSheet({super.key, required this.collections});

  final List<MemoryCollection> collections;

  @override
  State<RdCollectionPickerSheet> createState() =>
      _RdCollectionPickerSheetState();
}

class _RdCollectionPickerSheetState extends State<RdCollectionPickerSheet> {
  final TextEditingController _newCtl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _newCtl.dispose();
    super.dispose();
  }

  void _submitNew() {
    final name = _newCtl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(RdColChoice.create(name));
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final mq = MediaQuery.of(context);
    // Clear the Android nav bar when the keyboard isn't already covering it.
    final navGap = (mq.viewPadding.bottom - mq.viewInsets.bottom).clamp(0.0, 64.0);
    return Container(
      decoration: BoxDecoration(
        color: rd.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: mq.viewInsets.bottom + 24 + navGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: rd.line,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add to collection',
            style: GoogleFonts.dosis(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: rd.ink,
            ),
          ),
          const SizedBox(height: 12),
          if (_creating)
            _newRow()
          else ...[
            if (widget.collections.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final c in widget.collections) _row(c)],
                  ),
                ),
              ),
            _createRow(),
          ],
        ],
      ),
    );
  }

  Widget _row(MemoryCollection c) {
    final rd = context.rd;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(RdColChoice.existing(c)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          children: [
            const RdIcon(RdIcons.folder, size: 18, stroke: '#14328C', strokeWidth: 1.8),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
            ),
            Text(
              '${c.itemCount}',
              style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRow() {
    final rd = context.rd;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _creating = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Text(
              '+',
              style: GoogleFonts.dosis(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: rd.peri,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'New collection',
              style: GoogleFonts.vazirmatn(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: rd.peri,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newRow() {
    final rd = context.rd;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: rd.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rd.line, width: 1),
            ),
            child: Center(
              child: TextField(
                controller: _newCtl,
                autofocus: true,
                cursorColor: rd.navy,
                style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Collection name',
                  hintStyle:
                      GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
                ),
                onSubmitted: (_) => _submitNew(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _submitNew,
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF14328C),
            ),
            child: const Center(
              child: RdIcon(
                RdIcons.checkThick,
                size: 18,
                stroke: '#FFFFFF',
                strokeWidth: 2.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
