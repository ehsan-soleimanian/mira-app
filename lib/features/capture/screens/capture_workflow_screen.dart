import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/components/molecules/mira_back_button.dart';
import 'package:mira_app/components/molecules/mira_inner_shadow_painter.dart';
import 'package:mira_app/components/molecules/mira_stop_button.dart';
import 'package:mira_app/components/organisms/mira_composer_bar.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/capture/capture_workflow_initial_action.dart';
import 'package:mira_app/features/capture/media/capture_media_picker.dart';
import 'package:mira_app/features/capture/utils/capture_errors.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/features/capture/widgets/capture_link_sheet.dart';
import 'package:mira_app/features/graph/screens/memory_graph_screen.dart';
import 'package:mira_app/features/graph/widgets/memory_graph_icon_button.dart';
import 'package:mira_app/models/api/capture_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/stop_button_tokens.dart';

enum _CaptureWorkflowMode { compose, listening, conversation }

enum _AttachmentKind { camera, picture, file, link }

class CaptureWorkflowScreen extends StatefulWidget {
  const CaptureWorkflowScreen({super.key, this.initialAction});

  final CaptureWorkflowInitialAction? initialAction;

  @override
  State<CaptureWorkflowScreen> createState() => _CaptureWorkflowScreenState();
}

class _CaptureWorkflowScreenState extends State<CaptureWorkflowScreen> {
  final _controller = TextEditingController();
  final VoiceRecorderPort _recorder = createVoiceRecorder();
  final CaptureMediaPickerPort _mediaPicker = createCaptureMediaPicker();

  CaptureRepository? _captures;
  _CaptureWorkflowMode _mode = _CaptureWorkflowMode.compose;
  bool _showAttachMenu = false;
  bool _memorySaved = false;
  bool _pendingApproval = false;
  bool _busy = false;
  Timer? _timer;
  Duration _listeningDuration = Duration.zero;
  String? _lastPrompt;
  String? _captureId;
  Map<String, dynamic>? _proposal;
  String? _answer;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    final action = widget.initialAction;
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case CaptureWorkflowInitialAction.attachMenu:
          setState(() => _showAttachMenu = true);
        case CaptureWorkflowInitialAction.link:
          unawaited(_submitLink());
        case CaptureWorkflowInitialAction.gallery:
          unawaited(_submitAttachment(_AttachmentKind.picture));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captures ??= AppScope.servicesOf(context).captureRepository;
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_recorder is DeviceVoiceRecorder) {
      _recorder.dispose();
    } else if (_recorder is SimulatedVoiceRecorder) {
      _recorder.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _toggleAttachMenu() {
    if (_busy) return;
    setState(() => _showAttachMenu = !_showAttachMenu);
  }

  Future<void> _startListening() async {
    if (_busy || _recorder.isRecording) return;
    final started = await _recorder.start();
    if (!started) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone is not available')),
      );
      return;
    }
    _timer?.cancel();
    setState(() {
      _mode = _CaptureWorkflowMode.listening;
      _showAttachMenu = false;
      _listeningDuration = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _listeningDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _stopListening() async {
    if (_busy) return;
    _timer?.cancel();
    final result = await _recorder.stop();
    await _submitCapture(
      prompt: 'Voice note',
      create: (repo) => repo.createVoiceCapture(
        durationMs: result.duration.inMilliseconds,
        audioPath: result.filePath,
      ),
    );
  }

  Future<void> _submitText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    _controller.clear();
    await _submitCapture(
      prompt: text,
      create: (repo) => repo.createTextCapture(text),
    );
  }

  Future<void> _submitAttachment(_AttachmentKind kind) async {
    if (_busy) return;
    if (kind == _AttachmentKind.link) {
      await _submitLink();
      return;
    }

    setState(() => _showAttachMenu = false);

    final PickedCaptureMedia? picked;
    switch (kind) {
      case _AttachmentKind.camera:
        picked = await _mediaPicker.pickCameraImage();
      case _AttachmentKind.picture:
        picked = await _mediaPicker.pickGalleryImage();
      case _AttachmentKind.file:
        picked = await _mediaPicker.pickFile();
      case _AttachmentKind.link:
        return;
    }
    if (!mounted) return;
    if (picked == null) {
      _showSnack(
        kind == _AttachmentKind.camera
            ? 'دسترسی دوربین داده نشد یا انتخاب لغو شد.'
            : kind == _AttachmentKind.picture
            ? 'دسترسی به تصاویر داده نشد یا انتخاب لغو شد.'
            : 'انتخاب فایل لغو شد.',
      );
      return;
    }
    final media = picked;

    if (media.bytes.length > captureMediaMaxBytes) {
      _showSnack('File is too large (max 10 MB).');
      return;
    }

    final caption = _controller.text.trim();
    final prompt = caption.isNotEmpty ? caption : media.filename;
    if (caption.isNotEmpty) _controller.clear();

    await _submitCapture(
      prompt: prompt,
      create: (repo) {
        if (kind == _AttachmentKind.file) {
          return repo.createFileCapture(
            bytes: media.bytes,
            filename: media.filename,
            caption: caption.isEmpty ? null : caption,
          );
        }
        return repo.createImageCapture(
          bytes: media.bytes,
          filename: media.filename,
          caption: caption.isEmpty ? null : caption,
        );
      },
    );
  }

  Future<void> _submitLink() async {
    if (_busy) return;
    setState(() => _showAttachMenu = false);
    final input = await showCaptureLinkSheet(context);
    if (!mounted || input == null) return;

    final prompt = input.note?.isNotEmpty == true ? input.note! : input.url;
    await _submitCapture(
      prompt: prompt,
      create: (repo) => repo.createLinkCapture(
        url: input.url,
        note: input.note,
      ),
    );
  }

  Future<void> _submitCapture({
    required String prompt,
    required Future<CaptureResponse> Function(CaptureRepository repo) create,
  }) async {
    final repo = _captures;
    if (repo == null || _busy) return;
    setState(() {
      _busy = true;
      _mode = _CaptureWorkflowMode.conversation;
      _showAttachMenu = false;
      _lastPrompt = prompt;
      _captureId = null;
      _proposal = null;
      _answer = null;
      _memorySaved = false;
      _pendingApproval = false;
      _statusText = 'Mira is thinking...';
    });

    try {
      final created = await create(repo);
      await _consumeCaptureStream(repo, created);
    } catch (error) {
      _showSnack(formatCaptureError(error));
      if (mounted) {
        setState(() => _statusText = 'Capture failed. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _consumeCaptureStream(
    CaptureRepository repo,
    CaptureResponse created,
  ) async {
    _captureId = created.captureId;

    await for (final event in repo.streamCapture(created.captureId)) {
      if (!mounted) return;
      switch (event.event) {
        case 'status':
          setState(() => _statusText = 'Mira is processing...');
        case 'time_clarification':
          setState(() {
            _statusText =
                event.data['prompt']?.toString() ?? 'Confirming time...';
          });
          final updated = await repo.confirmTime(
            created.captureId,
            accepted: true,
            resolvedTime: event.data['suggestion']?.toString(),
          );
          if (updated.proposal != null) {
            _applyProposal(updated.proposal!, created.captureId);
          }
        case 'proposal':
          _applyProposal(event.data, created.captureId);
        case 'question_answer':
          _applyAnswer(event.data['answer']?.toString() ?? 'Answer received');
        case 'error':
          setState(() {
            _statusText = event.data['detail']?.toString() ?? 'Capture failed.';
          });
        case 'done':
          return;
      }
    }

    if (!mounted) return;
    if (created.state == 'awaiting_approval' && created.proposal != null) {
      _applyProposal(created.proposal!, created.captureId);
    } else if (created.state == 'question_answered' && created.answer != null) {
      _applyAnswer(created.answer!);
    } else if (created.state == 'clarification_needed' &&
        created.proposal != null) {
      final time = created.proposal!['time'];
      final suggestion = time is Map ? time['suggestion']?.toString() : null;
      final updated = await repo.confirmTime(
        created.captureId,
        accepted: true,
        resolvedTime: suggestion,
      );
      if (updated.proposal != null) {
        _applyProposal(updated.proposal!, created.captureId);
      }
    }
  }

  void _applyProposal(Map<String, dynamic> proposal, String captureId) {
    if (!mounted) return;
    setState(() {
      _captureId = captureId;
      _proposal = proposal;
      _answer = null;
      _pendingApproval = true;
      _memorySaved = false;
      _statusText = null;
    });
  }

  void _applyAnswer(String answer) {
    if (!mounted) return;
    setState(() {
      _answer = answer;
      _proposal = null;
      _pendingApproval = false;
      _memorySaved = false;
      _statusText = null;
    });
  }

  Future<void> _approveCurrentCapture() async {
    final repo = _captures;
    final captureId = _captureId;
    if (repo == null || captureId == null || _busy) return;
    setState(() => _busy = true);
    try {
      final node = await repo.approve(captureId);
      if (!mounted) return;
      setState(() {
        _memorySaved = true;
        _pendingApproval = false;
        _proposal = {
          'title': node.title,
          'summary': node.summary,
          'node_type': node.nodeType,
        };
      });
      _showSnack('Saved to memory');
    } catch (error) {
      _showSnack('Save failed: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _dismissCurrentCapture() async {
    final repo = _captures;
    final captureId = _captureId;
    if (repo == null || captureId == null || _busy) return;
    if (!_pendingApproval) {
      _showSnack('Backend remove-memory endpoint is not available yet.');
      return;
    }
    setState(() => _busy = true);
    try {
      await repo.dismiss(captureId);
      if (!mounted) return;
      setState(() {
        _pendingApproval = false;
        _memorySaved = false;
        _proposal = null;
        _captureId = null;
        _statusText = 'Capture dismissed.';
      });
    } catch (error) {
      _showSnack('Cancel failed: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _handleMemoryToggle() async {
    if (_pendingApproval) {
      await _dismissCurrentCapture();
      return;
    }
    if (_memorySaved) {
      _showSnack('Backend remove-memory endpoint is not available yet.');
    }
  }

  void _openMemoryGraph({String? highlightNodeId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MemoryGraphScreen(highlightNodeId: highlightNodeId),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final s = width / HomeScreenTokens.designWidth;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: _mode == _CaptureWorkflowMode.listening
                  ? _ListeningContent(
                      scale: s,
                      duration: _listeningDuration,
                      onStop: () {
                        _stopListening();
                      },
                    )
                  : _WorkflowContent(
                      scale: s,
                      mode: _mode,
                      prompt: _lastPrompt,
                      proposal: _proposal,
                      answer: _answer,
                      statusText: _statusText,
                      memorySaved: _memorySaved,
                      pendingApproval: _pendingApproval,
                      busy: _busy,
                      onSave: _approveCurrentCapture,
                      onCancel: _dismissCurrentCapture,
                      onMemoryToggle: _handleMemoryToggle,
                    ),
            ),
            _WorkflowHeader(
              scale: s,
              memoryActive: _memorySaved || _pendingApproval,
              onGraphTap: _openMemoryGraph,
            ),
            if (_mode != _CaptureWorkflowMode.listening)
              Positioned(
                left: 24 * s,
                right: 24 * s,
                bottom: keyboardInset + bottomInset + 20 * s,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showAttachMenu) ...[
                      _AttachmentMenu(
                        scale: s,
                        onSelected: _submitAttachment,
                      ),
                      SizedBox(height: 8 * s),
                    ],
                    MiraComposerBar(
                      controller: _controller,
                      scale: s,
                      onAdd: _toggleAttachMenu,
                      onMicTap: () {
                        _startListening();
                      },
                      onSend: (value) {
                        _submitText(value);
                      },
                      onSubmitted: (value) {
                        _submitText(value);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowHeader extends StatelessWidget {
  const _WorkflowHeader({
    required this.scale,
    required this.memoryActive,
    required this.onGraphTap,
  });

  final double scale;
  final bool memoryActive;
  final VoidCallback onGraphTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Positioned(
      top: 24 * s,
      left: 24 * s,
      right: 24 * s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MiraBackButton(size: 48 * s),
          MemoryGraphIconButton(
            size: 48 * s,
            active: memoryActive,
            onTap: onGraphTap,
          ),
        ],
      ),
    );
  }
}

class _WorkflowContent extends StatelessWidget {
  const _WorkflowContent({
    required this.scale,
    required this.mode,
    required this.prompt,
    required this.proposal,
    required this.answer,
    required this.statusText,
    required this.memorySaved,
    required this.pendingApproval,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    required this.onMemoryToggle,
  });

  final double scale;
  final _CaptureWorkflowMode mode;
  final String? prompt;
  final Map<String, dynamic>? proposal;
  final String? answer;
  final String? statusText;
  final bool memorySaved;
  final bool pendingApproval;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onMemoryToggle;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    if (mode == _CaptureWorkflowMode.conversation) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24 * s, 96 * s, 24 * s, 120 * s),
        child: _ConversationView(
          scale: s,
          prompt: prompt ?? 'Call John about the contract',
          proposal: proposal,
          answer: answer,
          statusText: statusText,
          memorySaved: memorySaved,
          pendingApproval: pendingApproval,
          busy: busy,
          onSave: onSave,
          onCancel: onCancel,
          onMemoryToggle: onMemoryToggle,
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          top: 210 * s,
          left: 0,
          right: 0,
          child: Center(child: MiraSphere(size: 145 * s)),
        ),
        Positioned(
          top: 412 * s,
          left: 0,
          right: 0,
          child: Text(
            'How can I help you ?',
            textAlign: TextAlign.center,
            style: AppTypography.homeHeadline(s),
          ),
        ),
        Positioned(
          top: 472 * s,
          left: 0,
          right: 0,
          child: Text(
            'Speak,ask or share anythings',
            textAlign: TextAlign.center,
            style: AppTypography.homeSubtitle(s),
          ),
        ),
        Positioned(
          left: 74 * s,
          right: 74 * s,
          bottom: 134 * s,
          child: _WorkflowHint(scale: s),
        ),
      ],
    );
  }
}

class _ListeningContent extends StatelessWidget {
  const _ListeningContent({
    required this.scale,
    required this.duration,
    required this.onStop,
  });

  final double scale;
  final Duration duration;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Stack(
      children: [
        Positioned(
          top: 74 * s,
          left: 0,
          right: 0,
          child: Center(child: MiraSphere(size: 145 * s)),
        ),
        Positioned(
          top: 214 * s,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Im listening...',
                textAlign: TextAlign.center,
                style: AppTypography.dosis(
                  size: 34 * s,
                  weight: FontWeight.w700,
                  color: AppColors.headline,
                ),
              ),
              SizedBox(height: 12 * s),
              Text(
                'Speak naturally Mira is taking notes',
                textAlign: TextAlign.center,
                style: AppTypography.vazirmatn(
                  size: 16 * s,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 130 * s,
          child: Column(
            children: [
              MiraStopButton(
                size: StopButtonTokens.defaultSize * s,
                onTap: onStop,
              ),
              SizedBox(height: 14 * s),
              Text(
                formatRecordingDuration(duration),
                style: TextStyle(
                  fontSize: 24 * s,
                  color: AppColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: 18 * s),
              Text(
                'TAP TO STOP',
                style: TextStyle(
                  fontSize: 12 * s,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView({
    required this.scale,
    required this.prompt,
    required this.proposal,
    required this.answer,
    required this.statusText,
    required this.memorySaved,
    required this.pendingApproval,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    required this.onMemoryToggle,
  });

  final double scale;
  final String prompt;
  final Map<String, dynamic>? proposal;
  final String? answer;
  final String? statusText;
  final bool memorySaved;
  final bool pendingApproval;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onMemoryToggle;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    if (proposal != null ||
        answer != null ||
        statusText != null ||
        pendingApproval ||
        !memorySaved) {
      return _DynamicConversationBody(
        scale: s,
        prompt: prompt,
        proposal: proposal,
        answer: answer,
        statusText: statusText,
        memorySaved: memorySaved,
        pendingApproval: pendingApproval,
        busy: busy,
        onSave: onSave,
        onCancel: onCancel,
        onMemoryToggle: onMemoryToggle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _ChatBubble(scale: s, text: prompt, maxWidth: 252 * s),
        ),
        SizedBox(height: 22 * s),
        Text(
          "Saved to your memory  If this is wrong, tell me. I'll\nchange it.",
          style: TextStyle(fontSize: 16 * s, height: 1.2, color: Colors.black),
        ),
        SizedBox(height: 10 * s),
        _MemoryToggle(scale: s, saved: memorySaved, onTap: onMemoryToggle),
        SizedBox(height: 30 * s),
        Align(
          alignment: Alignment.centerRight,
          child: _ChatBubble(
            scale: s,
            text: "It's not a task. It's a\nreminder for tomorrow.",
            maxWidth: 210 * s,
          ),
        ),
        SizedBox(height: 20 * s),
        Text(
          'Got it. I updated it\n"Call John about the contract — tomorrow"',
          style: TextStyle(fontSize: 15 * s, height: 1.2, color: Colors.black),
        ),
        SizedBox(height: 10 * s),
        _MemoryToggle(scale: s, saved: memorySaved, onTap: onMemoryToggle),
      ],
    );
  }
}

class _DynamicConversationBody extends StatelessWidget {
  const _DynamicConversationBody({
    required this.scale,
    required this.prompt,
    required this.proposal,
    required this.answer,
    required this.statusText,
    required this.memorySaved,
    required this.pendingApproval,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    required this.onMemoryToggle,
  });

  final double scale;
  final String prompt;
  final Map<String, dynamic>? proposal;
  final String? answer;
  final String? statusText;
  final bool memorySaved;
  final bool pendingApproval;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onMemoryToggle;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final proposalTitle = proposal?['title']?.toString();
    final proposalSummary = proposal?['summary']?.toString();
    final hasProposal = proposalTitle != null || proposalSummary != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _ChatBubble(scale: s, text: prompt, maxWidth: 252 * s),
        ),
        SizedBox(height: 22 * s),
        if (hasProposal) ...[
          if (proposalTitle != null)
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                scale: s,
                text: proposalTitle,
                maxWidth: 286 * s,
              ),
            ),
          if (proposalTitle != null) SizedBox(height: 20 * s),
          Text(
            memorySaved
                ? "Saved to your memory  If this is wrong, tell me. I'll\nchange it."
                : "Save this to your memory  If this is wrong, tell me. I'll\nchange it.",
            style: TextStyle(
              fontSize: 16 * s,
              height: 1.2,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10 * s),
          _MemoryToggle(
            scale: s,
            saved: memorySaved || pendingApproval,
            onTap: onMemoryToggle,
          ),
          if (proposalSummary != null) ...[
            SizedBox(height: 30 * s),
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                scale: s,
                text: proposalSummary,
                maxWidth: 230 * s,
              ),
            ),
          ],
          if (pendingApproval) ...[
            SizedBox(height: 28 * s),
            _ApprovalActions(
              scale: s,
              busy: busy,
              onSave: onSave,
              onCancel: onCancel,
            ),
          ],
        ] else if (answer != null) ...[
          Text(
            answer!,
            style: TextStyle(
              fontSize: 16 * s,
              height: 1.25,
              color: Colors.black,
            ),
          ),
        ] else ...[
          Text(
            statusText ?? 'Mira is processing...',
            style: TextStyle(
              fontSize: 16 * s,
              height: 1.25,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ApprovalActions extends StatelessWidget {
  const _ApprovalActions({
    required this.scale,
    required this.busy,
    required this.onSave,
    required this.onCancel,
  });

  final double scale;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38 * s,
            child: ElevatedButton(
              onPressed: busy ? null : onSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0B399D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                ),
              ),
              child: Text('Save', style: TextStyle(fontSize: 14 * s)),
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: SizedBox(
            height: 38 * s,
            child: OutlinedButton(
              onPressed: busy ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B399D),
                side: const BorderSide(color: Color(0xFF0B399D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                ),
              ),
              child: Text('cancel', style: TextStyle(fontSize: 14 * s)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.scale,
    required this.text,
    required this.maxWidth,
  });

  final double scale;
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16 * s,
              height: 1.18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryToggle extends StatelessWidget {
  const _MemoryToggle({
    required this.scale,
    required this.saved,
    required this.onTap,
  });

  final double scale;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = saved ? AppColors.micBlueNav : const Color(0xFF9B2C2C);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            saved ? Icons.verified_outlined : Icons.cancel_outlined,
            size: 16 * s,
            color: color,
          ),
          SizedBox(width: 5 * s),
          Text(
            saved ? 'save to memory' : 'Remove memory',
            style: TextStyle(fontSize: 14 * s, color: color),
          ),
        ],
      ),
    );
  }
}

class _WorkflowHint extends StatelessWidget {
  const _WorkflowHint({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _InsetTip(
      scale: scale,
      text: 'You can send or ask in memory photo link',
      color: const Color(0xFF1F3C82),
    );
  }
}

class _InsetTip extends StatelessWidget {
  const _InsetTip({
    required this.scale,
    required this.text,
    required this.color,
  });

  final double scale;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return CustomPaint(
      painter: MiraInnerShadowPainter(
        shape: (size) => Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Offset.zero & size,
              Radius.circular(4 * s),
            ),
          ),
        baseColor: const Color(0xFFF4F4F5),
        darkShadow: const Color(0xFFD0D0D4).withValues(alpha: 0.58),
        lightShadow: Colors.white.withValues(alpha: 0.95),
        blur: 6 * s,
        offset: 3 * s,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 11 * s),
        child: Text(
          text,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: AppTypography.tip(s).copyWith(color: color),
        ),
      ),
    );
  }
}

class _AttachmentMenu extends StatelessWidget {
  const _AttachmentMenu({
    required this.scale,
    required this.onSelected,
  });

  final double scale;
  final ValueChanged<_AttachmentKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final inset = (ComposerTokens.addButtonSize * s - 40 * s) / 2;

    return Padding(
      padding: EdgeInsets.only(left: inset.clamp(0.0, double.infinity)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AttachmentItem(
            scale: s,
            icon: Icons.photo_camera_outlined,
            onTap: () => onSelected(_AttachmentKind.camera),
          ),
          _AttachmentItem(
            scale: s,
            icon: Icons.add_photo_alternate_outlined,
            onTap: () => onSelected(_AttachmentKind.picture),
          ),
          _AttachmentItem(
            scale: s,
            icon: Icons.create_new_folder_outlined,
            onTap: () => onSelected(_AttachmentKind.file),
          ),
          _AttachmentItem(
            scale: s,
            icon: Icons.link_rounded,
            onTap: () => onSelected(_AttachmentKind.link),
          ),
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  const _AttachmentItem({
    required this.scale,
    required this.icon,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 40 * s, minHeight: 40 * s),
      icon: Icon(icon, size: 24 * s, color: AppColors.textPrimary),
    );
  }
}
