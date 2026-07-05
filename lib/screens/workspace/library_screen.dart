import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/screens/workspace/note_editor_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  final _assistant = TextEditingController();
  var _items = const <LibraryItem>[];
  var _loading = true;
  String? _answer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    _assistant.dispose();
    super.dispose();
  }

  Future<void> _load([String? query]) async {
    setState(() => _loading = true);
    try {
      final repo = AppScope.servicesOf(context).libraryRepository;
      final items = await repo.list(query: query);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ask() async {
    final prompt = _assistant.text.trim();
    if (prompt.isEmpty) return;
    final repo = AppScope.servicesOf(context).assistantRepository;
    final response = await repo.run(prompt);
    if (!mounted) return;
    setState(() {
      _answer = response.answer;
      _items = response.citations;
    });
  }

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (!mounted) return;
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    await AppScope.servicesOf(
      context,
    ).libraryRepository.uploadBytes(bytes: bytes, filename: file.name);
    if (mounted) unawaited(_load());
  }

  Future<void> _createNote() async {
    await Navigator.of(context).pushMira((_) => const NoteEditorScreen());
    if (mounted) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _load(_search.text),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Library',
                  style: AppTypography.dosis(size: 28, weight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Upload',
                onPressed: _upload,
                icon: const Icon(Icons.upload_file_rounded),
              ),
              IconButton(
                tooltip: 'New note',
                onPressed: _createNote,
                icon: const Icon(Icons.note_add_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: _load,
            decoration: InputDecoration(
              hintText: 'Search by meaning, source, title or text',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: () => _load(_search.text),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE7E7EF)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _assistant,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ask Mira across your library',
              prefixIcon: const Icon(Icons.auto_awesome_rounded),
              suffixIcon: IconButton(
                tooltip: 'Ask',
                onPressed: _ask,
                icon: const Icon(Icons.send_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F8FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_answer != null) ...[
            const SizedBox(height: 12),
            _WorkspaceCard(
              child: Text(
                _answer!,
                style: AppTypography.dosis(
                  size: 15,
                ).copyWith(color: AppColors.textSecondary, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_items.isEmpty)
            _WorkspaceCard(
              child: Text(
                'No library items yet. Capture, upload, or write a note to start.',
                style: AppTypography.dosis(
                  size: 16,
                ).copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            for (final item in _items) _LibraryItemTile(item: item),
        ],
      ),
    );
  }
}

class _LibraryItemTile extends StatelessWidget {
  const _LibraryItemTile({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _WorkspaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(item.type), color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.dosis(
                      size: 17,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary.isNotEmpty
                        ? item.summary
                        : item.contentText ?? item.source,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.dosis(
                      size: 13,
                    ).copyWith(color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'file':
        return Icons.insert_drive_file_outlined;
      case 'task':
        return Icons.check_circle_outline_rounded;
      case 'connector':
        return Icons.extension_rounded;
      default:
        return Icons.notes_rounded;
    }
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7EF)),
      ),
      child: child,
    );
  }
}
