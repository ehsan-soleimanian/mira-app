import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/screens/workspace/canvas_workspace_screen.dart';
import 'package:mira_app/screens/workspace/note_editor_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  final _assistant = TextEditingController();
  var _items = const <LibraryItem>[];
  var _sources = const <ImportSourceDto>[];
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
      final results = await Future.wait([
        repo.list(query: query),
        repo.importSources(),
      ]);
      if (!mounted) return;
      setState(() {
        _items = results[0] as List<LibraryItem>;
        _sources = results[1] as List<ImportSourceDto>;
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

  Future<void> _uploadForSource(ImportSourceDto source) async {
    final extensions = source.extensions
        .where((value) => value.startsWith('.'))
        .map((value) => value.substring(1))
        .toList();
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: extensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: extensions.isEmpty ? null : extensions,
    );
    if (!mounted) return;
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;
    await AppScope.servicesOf(
      context,
    ).libraryRepository.uploadBytes(bytes: bytes, filename: file.name);
    if (mounted) unawaited(_load());
  }

  Future<void> _pasteLink(ImportSourceDto source) async {
    final controller = TextEditingController();
    final url = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ImportTextSheet(
        title: 'Paste ${source.name} link',
        hint: 'https://...',
        controller: controller,
      ),
    );
    controller.dispose();
    if (url == null || url.trim().isEmpty || !mounted) return;
    await AppScope.servicesOf(
      context,
    ).libraryRepository.importLink(url: url.trim(), sourceId: source.id);
    if (mounted) unawaited(_load());
  }

  Future<void> _pasteText(ImportSourceDto source) async {
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ImportTextSheet(
        title: 'Paste ${source.name}',
        hint: source.description,
        controller: controller,
        minLines: 6,
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty || !mounted) return;
    await AppScope.servicesOf(
      context,
    ).libraryRepository.importText(text: text.trim(), sourceId: source.id);
    if (mounted) unawaited(_load());
  }

  void _openImportHub() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ImportHubSheet(
        sources: _sources,
        onSelect: (source) {
          Navigator.of(context).pop();
          _handleImportSource(source);
        },
      ),
    );
  }

  void _handleImportSource(ImportSourceDto source) {
    if (source.action == 'paste_link') {
      unawaited(_pasteLink(source));
    } else if (source.action == 'upload_or_paste_text' ||
        source.action == 'create_note') {
      unawaited(_pasteText(source));
    } else if (source.action == 'share_or_upload_export') {
      _showImportGuide(source);
    } else if (source.action == 'connect_provider') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${source.name} sync lives in Connectors.')),
      );
    } else {
      unawaited(_uploadForSource(source));
    }
  }

  void _showImportGuide(ImportSourceDto source) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ImportGuideSheet(
        source: source,
        onUpload: () {
          Navigator.of(context).pop();
          unawaited(_uploadForSource(source));
        },
        onPaste: () {
          Navigator.of(context).pop();
          unawaited(_pasteText(source));
        },
      ),
    );
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
                tooltip: 'Add anything',
                onPressed: _openImportHub,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
              IconButton(
                tooltip: 'New note',
                onPressed: _createNote,
                icon: const Icon(Icons.note_add_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AddAnythingBand(onTap: _openImportHub, sourceCount: _sources.length),
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
            for (final item in _items)
              _LibraryItemTile(
                item: item,
                onTap: () => Navigator.of(
                  context,
                ).pushMira((_) => LibraryItemDetailScreen(item: item)),
              ),
        ],
      ),
    );
  }
}

class _LibraryItemTile extends StatelessWidget {
  const _LibraryItemTile({required this.item, required this.onTap});

  final LibraryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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

class _AddAnythingBand extends StatelessWidget {
  const _AddAnythingBand({required this.onTap, required this.sourceCount});

  final VoidCallback onTap;
  final int sourceCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.all_inbox_rounded, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add anything',
                      style: AppTypography.dosis(
                        size: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$sourceCount import sources: files, links, notes, media, exports.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 13,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportHubSheet extends StatelessWidget {
  const _ImportHubSheet({required this.sources, required this.onSelect});

  final List<ImportSourceDto> sources;
  final ValueChanged<ImportSourceDto> onSelect;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ImportSourceDto>>{};
    for (final source in sources) {
      grouped.putIfAbsent(source.category, () => []).add(source);
    }
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        maxChildSize: 0.94,
        minChildSize: 0.45,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              'Works with everything',
              style: AppTypography.dosis(size: 26, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Import files, links, media, notes, and exports into Library. Connectors stay separate for real provider sync.',
              style: AppTypography.dosis(
                size: 14,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 18),
            for (final entry in grouped.entries) ...[
              Text(
                entry.key,
                style: AppTypography.dosis(
                  size: 13,
                  weight: FontWeight.w700,
                ).copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final source in entry.value)
                    _ImportSourceChip(
                      source: source,
                      onTap: () => onSelect(source),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImportSourceChip extends StatelessWidget {
  const _ImportSourceChip({required this.source, required this.onTap});

  final ImportSourceDto source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 154,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_sourceIcon(source), size: 20, color: AppColors.accent),
                const SizedBox(height: 8),
                Text(
                  source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.dosis(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  _actionLabel(source),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.dosis(
                    size: 12,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _sourceIcon(ImportSourceDto source) {
    if (source.isConnector) return Icons.sync_rounded;
    if (source.isLink) return Icons.link_rounded;
    if (source.isText) return Icons.notes_rounded;
    if (source.isGuide) return Icons.ios_share_rounded;
    if (source.category == 'Media' || source.category == 'Video') {
      return Icons.perm_media_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _actionLabel(ImportSourceDto source) {
    switch (source.action) {
      case 'paste_link':
        return 'Paste link';
      case 'upload_or_paste_text':
        return 'Paste or upload';
      case 'share_or_upload_export':
        return 'Share/export';
      case 'connect_provider':
        return 'Connector';
      case 'create_note':
        return 'Write note';
      default:
        return 'Upload';
    }
  }
}

class _ImportTextSheet extends StatelessWidget {
  const _ImportTextSheet({
    required this.title,
    required this.hint,
    required this.controller,
    this.minLines = 1,
  });

  final String title;
  final String hint;
  final TextEditingController controller;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.dosis(size: 22, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: minLines,
              maxLines: minLines == 1 ? 1 : 10,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(controller.text),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportGuideSheet extends StatelessWidget {
  const _ImportGuideSheet({
    required this.source,
    required this.onUpload,
    required this.onPaste,
  });

  final ImportSourceDto source;
  final VoidCallback onUpload;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.name,
              style: AppTypography.dosis(size: 24, weight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              source.description,
              style: AppTypography.dosis(
                size: 15,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload export file'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onPaste,
              icon: const Icon(Icons.notes_rounded),
              label: const Text('Paste exported text'),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryItemDetailScreen extends StatefulWidget {
  const LibraryItemDetailScreen({super.key, required this.item});

  final LibraryItem item;

  @override
  State<LibraryItemDetailScreen> createState() =>
      _LibraryItemDetailScreenState();
}

class _LibraryItemDetailScreenState extends State<LibraryItemDetailScreen> {
  late LibraryItem _item;
  var _chunks = const <LibraryChunk>[];
  String? _assistantAnswer;
  String? _publishUrl;
  String? _detailError;
  var _busy = false;
  var _loadingChunks = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    unawaited(_loadChunks());
  }

  Future<void> _loadChunks() async {
    setState(() => _loadingChunks = true);
    try {
      final chunks = await AppScope.servicesOf(
        context,
      ).libraryRepository.chunks(_item.id);
      if (!mounted) return;
      setState(() {
        _chunks = chunks;
        _detailError = null;
        _loadingChunks = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detailError = 'Could not load transcript chunks.';
        _loadingChunks = false;
      });
    }
  }

  Future<void> _summarize() async {
    setState(() => _busy = true);
    final response = await AppScope.servicesOf(
      context,
    ).assistantRepository.run('Summarize ${_item.title}', action: 'summarize');
    if (!mounted) return;
    setState(() {
      _assistantAnswer = response.answer;
      _busy = false;
    });
  }

  Future<void> _publish() async {
    setState(() => _busy = true);
    final link = await AppScope.servicesOf(
      context,
    ).publishRepository.create(targetType: 'item', targetId: _item.id);
    if (!mounted) return;
    setState(() {
      _publishUrl = link.url;
      _busy = false;
    });
  }

  Future<void> _retryExtraction() async {
    setState(() {
      _busy = true;
      _detailError = null;
    });
    try {
      final updated = await AppScope.servicesOf(
        context,
      ).libraryRepository.retryExtraction(_item.id);
      if (!mounted) return;
      setState(() {
        _item = updated;
        _chunks = const [];
      });
      await _loadChunks();
    } catch (error) {
      if (!mounted) return;
      setState(() => _detailError = 'Could not retry extraction.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSource() async {
    final sourceUrl = _item.sourceUrl;
    if (sourceUrl == null) return;
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _WorkspaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.thumbnailUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.thumbnailUrl!,
                      height: 176,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        alignment: Alignment.center,
                        color: const Color(0xFFEAF0FF),
                        child: const Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppColors.accent,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(label: item.source),
                    _MetaPill(label: item.extractionStatus),
                    if (item.mimeType != null) _MetaPill(label: item.mimeType!),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.summary.isEmpty ? 'No summary yet.' : item.summary,
                  style: AppTypography.dosis(size: 15, height: 1.35),
                ),
              ],
            ),
          ),
          if (item.isMedia) ...[
            const SizedBox(height: 12),
            _MediaStatusPanel(
              status: item.extractionStatus,
              onRetry: _busy ? null : _retryExtraction,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _summarize,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Summarize'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _publish,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Publish'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).pushMira((_) => const CanvasWorkspaceScreen()),
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('Open in canvas'),
              ),
              if (item.sourceUrl != null)
                OutlinedButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Source'),
                ),
              if (item.isMedia)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _retryExtraction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry extraction'),
                ),
            ],
          ),
          if (_detailError != null) ...[
            const SizedBox(height: 12),
            _WorkspaceCard(
              child: Text(
                _detailError!,
                style: AppTypography.dosis(
                  size: 14,
                ).copyWith(color: Colors.red.shade700),
              ),
            ),
          ],
          if (_assistantAnswer != null) ...[
            const SizedBox(height: 12),
            _WorkspaceCard(child: Text(_assistantAnswer!)),
          ],
          if (_publishUrl != null) ...[
            const SizedBox(height: 12),
            _WorkspaceCard(child: Text('Private link: $_publishUrl')),
          ],
          const SizedBox(height: 16),
          if (item.isMedia) ...[
            Text(
              'Transcript timeline',
              style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _TranscriptTimeline(
              chunks: _chunks,
              loading: _loadingChunks,
              status: item.extractionStatus,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Preview',
            style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _WorkspaceCard(
            child: Text(
              item.contentText?.trim().isNotEmpty == true
                  ? item.contentText!
                  : 'No extracted preview yet. ${item.extractionStatus}',
              style: AppTypography.dosis(
                size: 14,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaStatusPanel extends StatelessWidget {
  const _MediaStatusPanel({required this.status, required this.onRetry});

  final String status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final active = {
      'queued',
      'extracting_metadata',
      'downloading',
      'transcribing',
    }.contains(status);
    final needsUpload = status == 'needs_upload' || status == 'blocked_auth';
    return _WorkspaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                needsUpload
                    ? Icons.upload_file_rounded
                    : Icons.graphic_eq_rounded,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusTitle(status),
                  style: AppTypography.dosis(size: 16, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
          const SizedBox(height: 10),
          Text(
            _statusBody(status),
            style: AppTypography.dosis(
              size: 14,
            ).copyWith(color: AppColors.textSecondary, height: 1.3),
          ),
          if (needsUpload || status == 'failed') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusTitle(String status) => switch (status) {
    'queued' => 'Queued for media extraction',
    'extracting_metadata' => 'Reading media metadata',
    'downloading' => 'Preparing temporary media',
    'transcribing' => 'Transcribing media',
    'ready' => 'Transcript ready',
    'metadata_ready' => 'Metadata ready',
    'needs_upload' => 'Upload needed',
    'blocked_auth' => 'Source is private or blocked',
    'failed' => 'Extraction failed',
    _ => status,
  };

  static String _statusBody(String status) => switch (status) {
    'queued' =>
      'Mira will extract metadata, captions, transcript chunks, and timestamps in the media worker.',
    'extracting_metadata' =>
      'Mira is checking title, duration, thumbnail, captions, and public transcript availability.',
    'downloading' =>
      'External media is temporary during processing. Uploaded originals remain stored securely.',
    'transcribing' =>
      'The admin-selected media transcription route is converting audio into searchable text.',
    'ready' =>
      'This item can now be searched, cited by the assistant, and placed on Canvas.',
    'metadata_ready' => 'Mira has useful metadata, but no full transcript yet.',
    'needs_upload' =>
      'The public source did not expose usable media or captions. Upload the file or paste a transcript from Add anything.',
    'blocked_auth' =>
      'Mira does not bypass private sources or login walls. Export/upload the media or transcript manually.',
    'failed' =>
      'The worker could not finish extraction. You can retry after checking the source or upload.',
    _ => 'Mira is tracking extraction state for this item.',
  };
}

class _TranscriptTimeline extends StatelessWidget {
  const _TranscriptTimeline({
    required this.chunks,
    required this.loading,
    required this.status,
  });

  final List<LibraryChunk> chunks;
  final bool loading;
  final String status;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _WorkspaceCard(child: LinearProgressIndicator(minHeight: 3));
    }
    if (chunks.isEmpty) {
      return _WorkspaceCard(
        child: Text(
          status == 'ready'
              ? 'No timestamp chunks were returned for this item.'
              : 'Transcript chunks will appear here after extraction.',
          style: AppTypography.dosis(
            size: 14,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        for (final chunk in chunks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _WorkspaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 58,
                    child: Text(
                      chunk.locator ?? '#${chunk.chunkIndex + 1}',
                      style: AppTypography.dosis(
                        size: 12,
                        weight: FontWeight.w700,
                      ).copyWith(color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chunk.text,
                      style: AppTypography.dosis(
                        size: 14,
                      ).copyWith(color: AppColors.textSecondary, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.dosis(
          size: 12,
          weight: FontWeight.w700,
        ).copyWith(color: AppColors.accent),
      ),
    );
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
