import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/daily_brief/daily_brief_repository.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_empty_preview.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

/// Daily Brief feed - Figma frames 564:2520 + card components.
class DailyBriefScreen extends StatefulWidget {
  const DailyBriefScreen({super.key});

  @override
  State<DailyBriefScreen> createState() => _DailyBriefScreenState();
}

class _DailyBriefScreenState extends State<DailyBriefScreen> {
  List<BriefItem> _items = const [];
  List<BriefItem> _previewItems = DailyBriefData.placeholderPreviewItems();
  DailyBriefRepository? _repository;
  CaptureFlowController? _captureFlow;
  CaptureUiPhase? _lastCapturePhase;
  bool _loading = true;
  Object? _error;
  BriefItem? _lastDismissedPreview;
  int _lastDismissedIndex = 0;
  bool _showUndo = false;
  Timer? _undoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppScope.servicesOf(context);
    _repository = services.dailyBriefRepository;

    final nextFlow = services.captureFlow;
    if (!identical(nextFlow, _captureFlow)) {
      _captureFlow?.removeListener(_onCaptureFlowChanged);
      _captureFlow = nextFlow;
      _lastCapturePhase = nextFlow.phase;
      nextFlow.addListener(_onCaptureFlowChanged);
    }
  }

  @override
  void dispose() {
    _captureFlow?.removeListener(_onCaptureFlowChanged);
    _undoTimer?.cancel();
    super.dispose();
  }

  void _onCaptureFlowChanged() {
    final phase = _captureFlow?.phase;
    final finishedCapture =
        _lastCapturePhase != null &&
        _lastCapturePhase != CaptureUiPhase.idle &&
        phase == CaptureUiPhase.idle;
    _lastCapturePhase = phase;
    if (finishedCapture && mounted) {
      _load(showLoader: false);
    }
  }

  Future<void> _load({bool showLoader = true}) async {
    final repository = _repository;
    if (repository == null) return;

    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await repository.fetchDailyUpdate();
      if (!mounted) return;
      setState(() {
        _items = DailyBriefData.fromDailyUpdateItems(response.items);
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  void _toggleTask(String id, bool completed) {
    setState(() {
      _items = _items.map((item) {
        if (item is BriefTask && item.id == id) {
          return item.copyWith(isCompleted: completed);
        }
        return item;
      }).toList();
    });
  }

  void _toggleNoteExpand(String id) {
    setState(() {
      _items = _items.map((item) {
        if (item is BriefNote && item.id == id) {
          return item.copyWith(isExpanded: !item.isExpanded);
        }
        return item;
      }).toList();
    });
  }

  void _togglePreviewTask(String id, bool completed) {
    setState(() {
      _previewItems = _previewItems.map((item) {
        if (item is BriefTask && item.id == id) {
          return item.copyWith(isCompleted: completed);
        }
        return item;
      }).toList();
    });
  }

  void _togglePreviewNoteExpand(String id) {
    setState(() {
      _previewItems = _previewItems.map((item) {
        if (item is BriefNote && item.id == id) {
          return item.copyWith(isExpanded: !item.isExpanded);
        }
        return item;
      }).toList();
    });
  }

  void _dismissPreviewCard(BriefItem item) {
    final index = _previewItems.indexWhere((i) => i.id == item.id);
    if (index < 0) return;

    setState(() {
      _lastDismissedPreview = item;
      _lastDismissedIndex = index;
      _previewItems = _previewItems.where((i) => i.id != item.id).toList();
      _showUndo = true;
    });

    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showUndo = false;
          _lastDismissedPreview = null;
        });
      }
    });
  }

  void _undoDismissPreview() {
    final item = _lastDismissedPreview;
    if (item == null) return;

    _undoTimer?.cancel();
    setState(() {
      final next = List<BriefItem>.from(_previewItems);
      final insertAt = _lastDismissedIndex.clamp(0, next.length);
      next.insert(insertAt, item);
      _previewItems = next;
      _showUndo = false;
      _lastDismissedPreview = null;
    });
  }

  List<String> get _sections {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in _items) {
      if (seen.add(item.section)) ordered.add(item.section);
    }
    return ordered;
  }

  Widget _buildCard(BriefItem item) {
    return switch (item) {
      BriefTask task => TaskBriefCard(
        task: task,
        onCheckboxChanged: (v) => _toggleTask(task.id, v),
        onTap: () => _showItemDetails(task),
      ),
      BriefNote note => NoteBriefCard(
        note: note,
        onMoreTap: () => _toggleNoteExpand(note.id),
        onTap: () => _showItemDetails(note),
      ),
      BriefImageItem image => ImageBriefCard(
        item: image,
        onTap: () => _showItemDetails(image),
      ),
    };
  }

  List<Widget> _buildSectionChildren(String section) {
    final sectionItems = _items.where((i) => i.section == section).toList();
    return [
      BriefSectionDivider(label: section),
      const SizedBox(height: 14),
      for (var i = 0; i < sectionItems.length; i++) ...[
        _buildCard(sectionItems[i]),
        if (i < sectionItems.length - 1) const SizedBox(height: 10),
      ],
      const SizedBox(height: 24),
    ];
  }

  void _showItemDetails(BriefItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DailyBriefDetailSheet(item: item),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }

    if (_error != null) {
      return _DailyBriefStatusView(
        title: 'Daily Brief is unavailable',
        message: _describeError(_error!),
        actionLabel: 'Retry',
        onAction: _load,
      );
    }

    if (_items.isEmpty) {
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _load(showLoader: false),
            child: DailyBriefEmptyPreview(
              items: _previewItems,
              onDismiss: _dismissPreviewCard,
              onCardTap: _showItemDetails,
              onCheckboxChanged: _togglePreviewTask,
              onNoteExpand: _togglePreviewNoteExpand,
            ),
          ),
          if (_showUndo)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: DailyBriefUndoBar(onUndo: _undoDismissPreview),
            ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(showLoader: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          for (final section in _sections) ..._buildSectionChildren(section),
        ],
      ),
    );
  }

  String _describeError(Object error) {
    if (error is DioException) {
      final detail = error.response?.data;
      if (detail is Map && detail['detail'] != null) {
        return detail['detail'].toString();
      }
      if (error.response?.statusCode == 401) {
        return 'Please sign in again to load your daily update.';
      }
      return error.message ?? 'Could not reach Mira backend.';
    }
    return 'Something went wrong while loading your daily update.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DailyBriefHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.dailyBrief,
        onHomeTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _DailyBriefStatusView extends StatelessWidget {
  const _DailyBriefStatusView({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onAction(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
        children: [
          const MiraSphere(size: 78),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: DailyBriefTypography.headerTitle(1.08),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: DailyBriefTypography.cardBody(1),
          ),
          const SizedBox(height: 24),
          Center(
            child: MiraButton(
              label: actionLabel,
              onPressed: onAction,
              color: MiraButtonColor.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBriefDetailSheet extends StatelessWidget {
  const _DailyBriefDetailSheet({required this.item});

  final BriefItem item;

  @override
  Widget build(BuildContext context) {
    final title = switch (item) {
      BriefTask task => task.title,
      BriefNote note => note.title,
      BriefImageItem image => image.title,
    };
    final body = switch (item) {
      BriefTask task => task.summary.isEmpty ? task.title : task.summary,
      BriefNote note => note.fullText,
      BriefImageItem image => image.preview,
    };
    final nodeType = switch (item) {
      BriefTask task => task.nodeType,
      BriefNote note => note.nodeType,
      BriefImageItem image => image.nodeType,
    };
    final createdAt = switch (item) {
      BriefTask task => task.createdAt,
      BriefNote note => note.createdAt,
      BriefImageItem image => image.createdAt,
    };
    final date = DailyBriefData.dateLabelFor(createdAt);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BriefCardBadge(
              label: nodeType,
              background: DailyBriefColors.taskBadgeBg,
              textColor: DailyBriefColors.taskBadgeText,
            ),
            const SizedBox(height: 14),
            Text(title, style: DailyBriefTypography.headerTitle(1.08)),
            const SizedBox(height: 10),
            Text(body, style: DailyBriefTypography.cardBody(1.05)),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(date, style: DailyBriefTypography.sectionLabel(1)),
            ],
            const SizedBox(height: 24),
            MiraButton(
              label: 'Done',
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
