import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/features/capture/media/capture_media_picker.dart';
import 'package:mira_app/features/capture/shared_import/shared_import_service.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class SharedImportReviewScreen extends StatefulWidget {
  const SharedImportReviewScreen({super.key, required this.item});

  final SharedImportItem item;

  @override
  State<SharedImportReviewScreen> createState() =>
      _SharedImportReviewScreenState();
}

class _SharedImportReviewScreenState extends State<SharedImportReviewScreen> {
  final _captionController = TextEditingController();
  var _busy = false;
  String? _status;
  LibraryItem? _created;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == SharedImportType.text) {
      _captionController.text = widget.item.text?.trim() ?? '';
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _status = l10n.sharedImportImportingStatus;
    });

    try {
      final repo = AppScope.servicesOf(context).libraryRepository;
      final created = switch (widget.item.type) {
        SharedImportType.image || SharedImportType.file =>
          await repo.uploadBytes(
            bytes: widget.item.bytes!,
            filename: widget.item.filename ?? 'mira-shared-file',
            mimeType: widget.item.mimeType,
          ),
        SharedImportType.text => await _createTextOrLink(),
      };
      if (!mounted) return;
      setState(() {
        _created = created;
        _status = 'Imported into Library. You can search, ask, add to canvas, or publish it.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = l10n.sharedImportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<LibraryItem> _createTextOrLink() {
    final text = _captionController.text.trim();
    final repo = AppScope.servicesOf(context).libraryRepository;
    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return repo.importLink(url: text);
    }
    return repo.importText(text: text, sourceId: _textSourceId(text));
  }

  String _textSourceId(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('whatsapp') || lower.contains(' - ')) {
      return 'whatsapp_export';
    }
    return 'shared_text';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isImage = widget.item.type == SharedImportType.image;
    final isFile = widget.item.type == SharedImportType.file;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.sharedImportAppBarTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              isImage
                  ? l10n.sharedImportImageTitle
                  : isFile
                  ? widget.item.filename ?? 'Import shared file'
                  : l10n.sharedImportTextTitle,
              style: AppTypography.dosis(size: 24, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isImage || isFile
                  ? 'Mira stores this in Library, extracts what it can, and makes it available for search, assistant answers, canvas, and publish.'
                  : l10n.sharedImportTextBody,
              style: AppTypography.dosis(
                size: 15,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            if (isImage) _ImagePreview(item: widget.item),
            if (isFile) _FilePreview(item: widget.item),
            if (!isImage && !isFile) _TextPreview(text: widget.item.text ?? ''),
            const SizedBox(height: 16),
            if (!isFile)
              TextField(
                controller: _captionController,
                minLines: isImage ? 2 : 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: isImage
                      ? l10n.sharedImportImageHint
                      : l10n.sharedImportTextHint,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _busy ? l10n.sharedImportImporting : l10n.sharedImportSave,
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(
                _status!,
                style: AppTypography.dosis(
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (_created != null) ...[
              const SizedBox(height: 12),
              _ImportedItemSummary(item: _created!),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.item});

  final SharedImportItem item;

  @override
  Widget build(BuildContext context) {
    final bytes = item.bytes!;
    final tooLarge = bytes.length > captureMediaMaxBytes * 5;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tooLarge
                  ? AppLocalizations.of(context)!.sharedImportOversize
                  : item.filename ?? 'Shared file',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.dosis(
                size: 15,
                color: tooLarge ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.item});

  final SharedImportItem item;

  @override
  Widget build(BuildContext context) {
    final bytes = item.bytes!;
    final tooLarge = bytes.length > captureMediaMaxBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.memory(
              bytes,
              fit: BoxFit.cover,
              height: 260,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                tooLarge
                    ? AppLocalizations.of(context)!.sharedImportOversize
                    : item.filename ??
                          AppLocalizations.of(
                            context,
                          )!.sharedImportFallbackFileName,
                style: AppTypography.dosis(
                  size: 13,
                  color: tooLarge ? Colors.red : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPreview extends StatelessWidget {
  const _TextPreview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.dosis(size: 15, height: 1.35),
      ),
    );
  }
}

class _ImportedItemSummary extends StatelessWidget {
  const _ImportedItemSummary({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '${item.title}\n${item.source} · ${item.extractionStatus}',
        style: AppTypography.dosis(
          size: 14,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
    );
  }
}
