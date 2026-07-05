import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/capture/media/capture_media_picker.dart';
import 'package:mira_app/features/capture/shared_import/shared_import_service.dart';
import 'package:mira_app/features/capture/utils/capture_errors.dart';
import 'package:mira_app/features/capture/widgets/approval_sheet.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';
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
  CaptureRepository? _captures;
  var _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == SharedImportType.text) {
      _captionController.text = widget.item.text?.trim() ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captures ??= AppScope.servicesOf(context).captureRepository;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = _captures;
    if (repo == null || _busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _status = l10n.sharedImportImportingStatus;
    });

    try {
      final created = switch (widget.item.type) {
        SharedImportType.image => await _createImage(repo),
        SharedImportType.text => await repo.createTextCapture(
          _captionController.text.trim(),
        ),
      };
      await _consumeStream(repo, created);
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = formatCaptureError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<CaptureResponse> _createImage(CaptureRepository repo) {
    final caption = _captionController.text.trim();
    return repo.createImageCapture(
      bytes: widget.item.bytes!,
      filename: widget.item.filename ?? 'mira-shared-image.jpg',
      caption: caption.isEmpty ? null : caption,
    );
  }

  Future<void> _consumeStream(
    CaptureRepository repo,
    CaptureResponse created,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await for (final event in repo.streamCapture(created.captureId)) {
      if (!mounted) return;
      switch (event.event) {
        case 'status':
          setState(() => _status = l10n.sharedImportReadingStatus);
        case 'proposal':
          await _showApproval(repo, created.captureId, event.data);
          return;
        case 'question_answer':
          setState(() {
            _status =
                event.data['answer']?.toString() ??
                l10n.sharedImportAnswerReceived;
          });
          return;
        case 'error':
          setState(() {
            _status =
                event.data['detail']?.toString() ?? l10n.sharedImportFailed;
          });
          return;
        case 'done':
          break;
      }
    }

    if (!mounted) return;
    if (created.state == 'awaiting_approval' && created.proposal != null) {
      await _showApproval(repo, created.captureId, created.proposal!);
    } else if (created.state == 'question_answered' && created.answer != null) {
      setState(() => _status = created.answer);
    }
  }

  Future<void> _showApproval(
    CaptureRepository repo,
    String captureId,
    Map<String, dynamic> proposal,
  ) {
    return ApprovalSheet.show(
      context,
      proposal: proposal,
      onApprove: () async {
        final result = await repo.approve(captureId);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          miraRoute(
            (_) => MemoryGraphScreen(
              highlightNodeId: result.highlightEntityId,
              title: AppLocalizations.of(context)!.sharedImportGraphTitle,
              subtitle: AppLocalizations.of(context)!.sharedImportGraphSubtitle,
            ),
          ),
        );
      },
      onDismiss: () async {
        await repo.dismiss(captureId);
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isImage = widget.item.type == SharedImportType.image;
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
                  : l10n.sharedImportTextTitle,
              style: AppTypography.dosis(size: 24, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isImage ? l10n.sharedImportImageBody : l10n.sharedImportTextBody,
              style: AppTypography.dosis(
                size: 15,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            if (isImage) _ImagePreview(item: widget.item),
            if (!isImage) _TextPreview(text: widget.item.text ?? ''),
            const SizedBox(height: 16),
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
          ],
        ),
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
