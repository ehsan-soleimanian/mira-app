import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/app/mira_services.dart';
import 'package:mira_app/features/capture/media/capture_media_picker.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/features/reminders/reminders_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';
import 'package:mira_app/models/api/graph_models.dart';

import '../models/rd_capture_mode.dart';
import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_capture_mode_views.dart';
import '../widgets/rd_icon.dart';
import '../widgets/rd_orb.dart';

/// Capture flow — voice / photo / screenshot / link / type paths through
/// understanding → review & confirm → kept. Faithful to `capture.jsx`.
class RdCaptureFlow extends StatefulWidget {
  const RdCaptureFlow({
    super.key,
    required this.go,
    this.initialMode = RdCaptureMode.voice,
  });

  final RdGo go;
  final RdCaptureMode initialMode;

  @override
  State<RdCaptureFlow> createState() => _RdCaptureFlowState();
}

/// Navy CTA / brand accent — constant across light & dark, so it stays a fixed
/// hex here for the standalone sheet widgets that render outside a `context.rd`
/// scope.
const _navy = Color(0xFF14328C);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Neutral fallback transcript/title, used only when a real device transcript
/// is unavailable (web, desktop, denied permission, or a failed/empty
/// transcribe). Empty on purpose: the listen screen shows the live transcript
/// streaming from the mic and never fabricates placeholder content.
const _voiceTranscript = '';
const _voiceTitle = '';

class _RdCaptureFlowState extends State<RdCaptureFlow> {
  String _view = 'listen';
  int _sec = 0;
  int _steps = 0;

  bool _conn1 = true;
  bool _conn2 = true;
  bool _conn3 = false;
  bool _remind = true;

  // Live transcript state. Defaults to the simulated sentence and is overridden
  // only when a real device recording is transcribed successfully.
  String _transcript = _voiceTranscript;
  String _transcriptTitle = _voiceTitle;
  bool _realTranscript = false;

  // Real device-mic recorder (with its own built-in simulated fallback). A
  // recording is started when the listen view opens and stopped/transcribed on
  // finish. Null until the first listen session begins.
  VoiceRecorderPort? _recorder;
  bool _recorderActive = false;
  StreamSubscription<CaptureStreamEvent>? _realtimeSub;
  bool _useRealtimePath = false;
  Completer<int>? _durationCompleter;

  // ── real capture ingest pipeline ────────────────────────────────────
  // When the real backend pipeline succeeds, these hold the live capture id and
  // the extracted proposal so "Add to memory" can approve() it and the review
  // can render GENUINE data. When any of these is null/empty the review and the
  // confirm both fall back to the current simulated behaviour.
  String? _captureId;
  ProposalDisplay? _proposal;
  bool _realProposal = false;
  // Guards `_runPipeline` so text + voice can't both drive it for one session.
  bool _pipelineStarted = false;
  // Indices of real connection rows the user has toggled on (all on by default).
  final Set<int> _connOn = <int>{};

  // ── editable review state ───────────────────────────────────────────
  // Detail chips become user-mutable once edited: null means "render the
  // computed source"; a non-null list means the user has removed/added chips.
  List<String>? _chips;
  // Change-type override — null falls back to the auto-detected / default type.
  String? _typeName;
  String? _typeIcon;

  // What was captured — drives the review's preview header, eyebrow and default
  // type, and which persist path "Add to memory" takes.
  String _kind = 'voice'; // voice | text | photo | screenshot | link
  PickedCaptureMedia? _pendingMedia; // held for photo/screenshot confirm
  String? _pendingUrl; // held for link confirm
  String? _pendingTitle;
  String _linkCrawlState = 'idle'; // idle | ready | metadata_only | failed
  String? _linkCrawlMethod;
  bool _savingLink = false;

  Timer? _secTimer;
  final List<Timer> _timers = [];

  bool _fromEntrySheet = false;

  @override
  void initState() {
    super.initState();
    _fromEntrySheet = widget.initialMode != RdCaptureMode.voice;
    switch (widget.initialMode) {
      case RdCaptureMode.voice:
        _startListen();
      case RdCaptureMode.photo:
        setState(() => _view = 'photo_cam');
      case RdCaptureMode.screenshot:
        setState(() => _view = 'shot_pick');
      case RdCaptureMode.link:
        setState(() => _view = 'link_capture');
      case RdCaptureMode.type:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _openTextEntry(fromSheet: true),
        );
    }
  }

  @override
  void dispose() {
    _secTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    _realtimeSub?.cancel();
    _realtimeSub = null;
    _useRealtimePath = false;
    final recorder = _recorder;
    if (recorder != null) {
      unawaited(recorder.cancel().catchError((_) {}));
      if (recorder is DeviceVoiceRecorder) recorder.dispose();
    }
    super.dispose();
  }

  void _clearTimers() {
    _secTimer?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _startListen() {
    _clearTimers();
    setState(() {
      _view = 'listen';
      _sec = 0;
      // Reset transcript to the neutral default; a real recording (below)
      // overrides it as it streams / on finish.
      _transcript = _voiceTranscript;
      _transcriptTitle = _voiceTitle;
      _realTranscript = false;
      // Reset any real pipeline result from a previous session.
      _captureId = null;
      _proposal = null;
      _realProposal = false;
      _pipelineStarted = false;
      // Reset non-voice + editable-review state for a fresh session.
      _kind = 'voice';
      _pendingMedia = null;
      _pendingUrl = null;
      _pendingTitle = null;
      _linkCrawlState = 'idle';
      _linkCrawlMethod = null;
      _savingLink = false;
      _chips = null;
      _typeName = null;
      _typeIcon = null;
    });
    unawaited(_beginRecording());
    _secTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _sec++),
    );
    // Demo auto-advance: on platforms without a real mic (web / desktop /
    // denied permission) nothing streams and the ✓ is never tapped, so move to
    // processing after a short window. On a real device a live recording is in
    // progress — the user taps ✓ to finish and this no-ops.
    _timers.add(
      Timer(const Duration(seconds: 6), () {
        if (mounted &&
            _view == 'listen' &&
            !_recorderActive &&
            !_useRealtimePath) {
          _toProc();
        }
      }),
    );
  }

  /// Start recording — tries realtime voice first, then batch file capture.
  Future<void> _beginRecording() async {
    final services = AppScope.servicesOf(context);
    final recorder = _recorder ??= createVoiceRecorder();

    try {
      _durationCompleter = Completer<int>();
      final session = await services.captureRepository
          .startRealtimeVoiceSession();
      final started = await recorder.startRealtime();
      final audioStream = recorder.realtimeAudioStream;
      if (started && audioStream != null) {
        _useRealtimePath = true;
        _recorderActive = true;
        _realtimeSub = services.captureRepository
            .streamRealtimeVoiceEvents(session)
            .listen(_onRealtimeEvent, onError: (_) {});
        unawaited(
          services.captureRepository
              .sendRealtimeVoiceAudio(
                session: session,
                audioStream: audioStream,
                durationMs: _durationCompleter!.future,
              )
              .catchError((_) {}),
        );
        return;
      }
    } catch (_) {
      _useRealtimePath = false;
    }

    try {
      final started = await recorder.start();
      if (mounted) _recorderActive = started;
    } catch (_) {
      _recorderActive = false;
    }
  }

  void _onRealtimeEvent(CaptureStreamEvent event) {
    if (!mounted) return;
    switch (event.event) {
      case 'transcript_delta':
      case 'transcript_final':
        final text = (event.data['text'] as String? ?? '').trim();
        if (text.isEmpty) return;
        setState(() {
          _transcript = text;
          _transcriptTitle = _titleFrom(text);
          if (event.event == 'transcript_final') _realTranscript = true;
        });
      case 'capture_created':
        final id = event.data['captureId'] as String?;
        if (id != null && id.isNotEmpty) {
          _captureId = id;
          _pipelineStarted = true;
        }
      case 'proposal':
        final display = resolveProposalDisplay(event.data);
        if (display.hasContent) {
          setState(() {
            _proposal = display;
            _realProposal = true;
          });
        }
      case 'question_answer':
        if (mounted) {
          widget.go(
            'chat',
            arg: RdChatArg(initialPrompt: _transcript, autoSend: true),
          );
        }
      case 'done':
        final state = event.data['state']?.toString();
        if (state == 'question_answered') {
          if (mounted) {
            widget.go(
              'chat',
              arg: RdChatArg(initialPrompt: _transcript, autoSend: true),
            );
          }
        }
      default:
        break;
    }
  }

  /// Stop the recording and, when a real audio file was captured, transcribe it
  /// to a real sentence. Returns silently (leaving the simulated transcript in
  /// place) on ANY failure: no active recorder, simulated capture, missing
  /// file, transcription error, or an empty/whitespace result. Never throws.
  Future<void> _finishRecording() async {
    final recorder = _recorder;
    if (recorder == null || !_recorderActive) return;
    _recorderActive = false;
    final services = AppScope.servicesOf(context);
    try {
      final result = await recorder.stop();
      if (_durationCompleter != null && !_durationCompleter!.isCompleted) {
        _durationCompleter!.complete(result.duration.inMilliseconds);
      }
      await _realtimeSub?.cancel();
      _realtimeSub = null;

      if (_useRealtimePath && _realTranscript) return;

      final path = result.filePath;
      if (result.simulated || path == null || path.isEmpty) return;

      final transcript = await services.captureRepository.transcribeVoice(
        durationMs: result.duration.inMilliseconds,
        audioPath: path,
      );
      final text = transcript.text.trim();
      if (text.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _transcript = text;
        _transcriptTitle = _titleFrom(text);
        _realTranscript = true;
      });
    } catch (_) {}
  }

  void _toProc() {
    _clearTimers();
    setState(() {
      _view = 'proc';
      _steps = 0;
    });
    // Animate the three "Understanding" steps. The review transition is NOT tied
    // to these timers anymore — it is driven by `_driveVoiceUnderstanding` below
    // so the real pipeline (which runs concurrently) can populate the review.
    for (var k = 0; k < 3; k++) {
      _timers.add(
        Timer(
          Duration(milliseconds: 500 + k * 650),
          () => setState(() => _steps = k + 1),
        ),
      );
    }
    unawaited(_driveVoiceUnderstanding());
  }

  /// Voice path: stop + transcribe the recording, run the real ingest pipeline
  /// on the resulting transcript, then show the review. Keeps the "Understanding"
  /// animation visible for at least its natural length and never longer than the
  /// pipeline's own timeout. Any failure leaves the simulated transcript/chips in
  /// place and still lands on the review — the flow can never break here.
  Future<void> _driveVoiceUnderstanding() async {
    // Minimum on-screen time so the animation always plays through.
    final minShown = Future<void>.delayed(
      const Duration(milliseconds: 500 + 3 * 650 + 500),
    );
    // Transcribe first (best-effort — may leave the simulated transcript), then
    // feed the final transcript text into the shared real pipeline.
    await _finishRecording();
    if (!(_useRealtimePath && _captureId != null && _realProposal)) {
      await _runPipeline(_transcript);
    }
    await minShown;
    if (!mounted || _view != 'proc') return;
    setState(() => _view = 'review');
  }

  /// Run the REAL capture ingest pipeline for [text] and, on full success,
  /// record the live capture id + extracted proposal so the review renders
  /// genuine data and "Add to memory" can approve() it.
  ///
  /// This method NEVER throws and NEVER surfaces an error. It silently leaves
  /// `_realProposal` false — falling the whole flow back to the simulated chips
  /// and the one-shot `createNote` — for ANY of:
  ///   • empty/blank input text,
  ///   • `createTextCapture` or `streamCapture` throwing (offline, auth, 4xx/5xx),
  ///   • the stream taking longer than the 12s timeout,
  ///   • the stream emitting an error or a clarification-only result
  ///     (time / intent / entity-equivalence — we don't build those sub-flows),
  ///   • the stream ending in a non-approval state, and
  ///   • a proposal that carries no usable display content.
  Future<void> _runPipeline(String text) async {
    if (_pipelineStarted) return;
    _pipelineStarted = true;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final services = AppScope.servicesOf(context);
    try {
      final capture = await services.captureRepository.createTextCapture(
        trimmed,
      );
      final captureId = capture.captureId;

      // Seed from the create response if it already carries a proposal.
      Map<String, dynamic>? proposalJson = capture.proposal;
      var clarificationOnly = false;
      var streamOk = true;

      try {
        await for (final event
            in services.captureRepository
                .streamCapture(captureId)
                .timeout(const Duration(seconds: 12))) {
          switch (event.event) {
            case 'proposal':
              proposalJson = event.data;
            case 'error':
              streamOk = false;
            case 'question_answer':
              if (mounted) {
                widget.go(
                  'chat',
                  arg: RdChatArg(initialPrompt: text, autoSend: true),
                );
              }
              return;
            // Any clarification path means the pipeline wants a sub-flow we
            // deliberately do not build — treat as a fallback trigger.
            case 'clarification':
            case 'time_clarification':
            case 'entity_clarification':
              clarificationOnly = true;
            case 'done':
              final state = event.data['state']?.toString();
              // Only a clean awaiting_approval is a real, approvable result.
              if (state != null && state != 'awaiting_approval') {
                if (state == 'question_answered') {
                  if (mounted) {
                    widget.go(
                      'chat',
                      arg: RdChatArg(initialPrompt: text, autoSend: true),
                    );
                  }
                  return;
                }
                clarificationOnly = true;
              }
          }
        }
      } on TimeoutException {
        streamOk = false;
      }

      if (!streamOk || clarificationOnly || proposalJson == null) return;

      final display = resolveProposalDisplay(proposalJson);
      if (!display.hasContent) return;

      if (!mounted) return;
      setState(() {
        _captureId = captureId;
        _proposal = display;
        _realProposal = true;
        // Default every extracted connection row to selected.
        _connOn
          ..clear()
          ..addAll(List<int>.generate(display.relatedLabels.length, (i) => i));
      });
    } catch (_) {
      // Best-effort — keep the simulated flow. Never surface a hard error.
      _captureId = null;
      _realProposal = false;
    }
  }

  String get _time => '${_sec ~/ 60}:${(_sec % 60).toString().padLeft(2, '0')}';

  /// Confirm the review: persist the memory, create the reminder (if its toggle
  /// is on), and show the "kept in memory" screen. The persist is fire-and-forget
  /// and best-effort so the confirmation is instant and still shows even offline.
  ///
  /// When a REAL proposal was extracted, this approves the live capture into the
  /// knowledge graph (the genuine ingest path). Otherwise it falls back to the
  /// one-shot note write, exactly like before.
  void _addToMemory() {
    final services = AppScope.servicesOf(context);
    switch (_kind) {
      case 'photo':
      case 'screenshot':
        final media = _pendingMedia;
        if (media != null) unawaited(_persistMedia(services, media));
      case 'link':
        final captureId = _captureId;
        if (_realProposal && captureId != null) {
          unawaited(_confirmLinkMemory(services, captureId));
        }
        return;
      default:
        final captureId = _captureId;
        if (_realProposal && captureId != null) {
          unawaited(_approveCapture(services, captureId));
        } else {
          unawaited(
            _persistNote(
              services,
              title: _transcriptTitle,
              content: _transcript,
            ),
          );
        }
    }
    if (_remind) unawaited(_createReminder(services));
    setState(() => _view = 'added');
  }

  Future<void> _confirmLinkMemory(
    MiraServices services,
    String captureId,
  ) async {
    if (_savingLink) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _savingLink = true);
    try {
      final result = await services.captureRepository.approve(
        captureId,
        title: _pendingTitle,
      );
      await services.memoryStore.load(force: true);
      if (_remind) await _createReminder(services);
      if (!mounted) return;
      setState(() {
        _savingLink = false;
        _view = 'added';
      });
      if (result.isProjectionPending) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureSyncPending)));
        _watchCaptureProjection(services, result);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingLink = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureLinkSaveFailed)));
    }
  }

  /// Approve the live capture, promoting the extracted proposal into the graph.
  /// A temporary graph failure is represented by a durable projection receipt;
  /// do not create a second Library note because the server may already have
  /// committed the ledger event even when the response is interrupted.
  Future<void> _approveCapture(MiraServices services, String captureId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await services.captureRepository.approve(captureId);
      await services.memoryStore.load(force: true);
      if (!mounted) return;
      if (result.isProjectionPending) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureSyncPending)));
        _watchCaptureProjection(services, result);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureMemorySaveFailed)));
    }
  }

  void _watchCaptureProjection(
    MiraServices services,
    GraphIngestResponse result,
  ) {
    final eventId = result.ledgerEventId;
    if (eventId == null || !result.isProjectionPending) return;
    unawaited(() async {
      final receipt = await services.graphRepository.waitForProjection(
        MemoryProjectionReceipt(
          eventId: eventId,
          status: result.projectionStatus,
          error: result.projectionError,
        ),
      );
      if (receipt.isApplied) await services.memoryStore.load(force: true);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (receipt.isApplied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureSyncComplete)));
      } else if (receipt.isDead) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.rdCaptureSyncFailed)));
      }
    }());
  }

  /// Create a real note memory in the backend library. Best-effort: a failure
  /// (offline, auth) is swallowed so the capture UX still completes.
  Future<void> _persistNote(
    MiraServices services, {
    required String title,
    required String content,
  }) async {
    try {
      final item = await services.libraryRepository.createNote(
        title: title,
        content: content,
      );
      services.memoryStore.upsertLocal(item);
    } catch (_) {
      // Best-effort — the capture is still shown as kept.
    }
  }

  Future<void> _createReminder(MiraServices services) async {
    try {
      // The reminder title is the real captured content — the extracted title,
      // else the transcript. Never a fabricated placeholder.
      final title = _transcriptTitle.trim().isNotEmpty
          ? _transcriptTitle.trim()
          : _transcript.trim();
      if (title.isEmpty) return;
      await RemindersRepository(
        apiClient: services.apiClient,
      ).create(title: title);
    } catch (_) {
      // Best-effort — the capture is still kept.
    }
  }

  // ── quick entry modes ───────────────────────────────────────────────
  /// Type a note and add it to memory. Pauses the voice simulation, collects
  /// text via a bottom sheet, then runs the REAL ingest pipeline on it — showing
  /// the "Understanding" animation and a review of the genuinely extracted
  /// entities/connections. If the pipeline is unavailable it silently falls back
  /// to the review with simulated chips (persisted on confirm via `createNote`).
  Future<void> _openTextEntry({bool fromSheet = false}) async {
    _clearTimers();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return _ComposeSheet(
          title: l10n.rdCaptureTypeSheetTitle,
          hint: l10n.rdCaptureTypeSheetHint,
          icon: RdIcons.pencil,
          multiline: true,
        );
      },
    );
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      if (fromSheet || _fromEntrySheet) {
        widget.go('home');
      } else {
        _startListen();
      }
      return;
    }
    final trimmed = text.trim();
    // The typed text becomes the "understood" content and the reminder/fallback
    // note source. It reads as a real transcript (no John/Friday markup).
    setState(() {
      _transcript = trimmed;
      _transcriptTitle = _titleFrom(trimmed);
      _realTranscript = true;
      _captureId = null;
      _proposal = null;
      _realProposal = false;
      _pipelineStarted = false;
      _view = 'proc';
      _steps = 0;
    });
    unawaited(_driveTextUnderstanding(trimmed));
  }

  /// Text path: animate "Understanding" while the real pipeline runs on [text],
  /// then show the review. Mirrors `_driveVoiceUnderstanding` without the STT
  /// step. Never blocks the animation past the pipeline timeout and never throws.
  Future<void> _driveTextUnderstanding(String text) async {
    final minShown = Future<void>.delayed(
      const Duration(milliseconds: 500 + 3 * 650 + 500),
    );
    for (var k = 0; k < 3; k++) {
      _timers.add(
        Timer(Duration(milliseconds: 500 + k * 650), () {
          if (mounted && _view == 'proc') setState(() => _steps = k + 1);
        }),
      );
    }
    await _runPipeline(text);
    await minShown;
    if (!mounted || _view != 'proc') return;
    setState(() => _view = 'review');
  }

  /// Crawl a link, wait for its real Graph V2 proposal, and only then show review.
  Future<void> _driveLinkUnderstanding() async {
    _clearTimers();
    setState(() {
      _view = 'proc';
      _steps = 0;
      _captureId = null;
      _proposal = null;
      _realProposal = false;
      _pipelineStarted = true;
      _linkCrawlState = 'idle';
      _linkCrawlMethod = null;
    });
    for (var k = 0; k < 3; k++) {
      _timers.add(
        Timer(Duration(milliseconds: 500 + k * 650), () {
          if (mounted && _view == 'proc') setState(() => _steps = k + 1);
        }),
      );
    }
    final minShown = Future<void>.delayed(
      const Duration(milliseconds: 500 + 3 * 650 + 500),
    );
    final succeeded = await _runLinkPipeline();
    await minShown;
    if (!mounted || _view != 'proc') return;
    setState(() => _view = succeeded ? 'review' : 'link_error');
  }

  Future<bool> _runLinkPipeline() async {
    final url = _pendingUrl?.trim() ?? '';
    if (url.isEmpty) return false;
    final services = AppScope.servicesOf(context);
    final metadata = <String, dynamic>{};
    Map<String, dynamic>? proposalJson;
    String? captureId;

    void absorb(CaptureResponse capture) {
      captureId = capture.captureId;
      metadata.addAll(capture.sourceMetadata);
      proposalJson ??= capture.proposal;
    }

    try {
      final created = await services.captureRepository.createLinkCapture(
        url: url,
        title: _pendingTitle,
      );
      absorb(created);

      if (proposalJson == null) {
        try {
          await for (final event
              in services.captureRepository
                  .streamCapture(created.captureId)
                  .timeout(const Duration(seconds: 15))) {
            if (event.event == 'proposal') proposalJson = event.data;
          }
        } on TimeoutException {
          // A fast worker can publish before SSE subscribes; poll below.
        }
      }

      for (var attempt = 0; proposalJson == null && attempt < 5; attempt++) {
        final current = await services.captureRepository.getCapture(
          created.captureId,
        );
        absorb(current);
        if (proposalJson == null) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      }

      final proposal = proposalJson;
      if (proposal == null) {
        if (mounted) setState(() => _captureId = captureId);
        return false;
      }
      final source = proposal['source'];
      if (source is Map<String, dynamic>) metadata.addAll(source);
      final display = resolveProposalDisplay(proposal);
      if (!display.hasContent) return false;

      final scraped =
          metadata['is_scraped_url'] == true ||
          metadata['isScrapedUrl'] == true;
      final method = metadata['link_extraction_method']?.toString();
      final scrapedTitle = metadata['scraped_title']?.toString().trim() ?? '';
      if ((_pendingTitle?.trim().isEmpty ?? true) && scrapedTitle.isNotEmpty) {
        _pendingTitle = scrapedTitle;
      }
      if (!mounted) return false;
      setState(() {
        _captureId = captureId;
        _proposal = display;
        _realProposal = true;
        _linkCrawlState = scraped ? 'ready' : 'metadata_only';
        _linkCrawlMethod = method;
        _connOn
          ..clear()
          ..addAll(List<int>.generate(display.relatedLabels.length, (i) => i));
      });
      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _captureId = captureId;
          _realProposal = false;
          _linkCrawlState = 'failed';
        });
      }
      return false;
    }
  }

  Future<void> _retryLink() async {
    final captureId = _captureId;
    if (captureId != null) {
      try {
        await AppScope.servicesOf(context).captureRepository.dismiss(captureId);
      } catch (_) {}
    }
    if (!mounted) return;
    unawaited(_driveLinkUnderstanding());
  }

  /// Drives the preview-only understanding animation for photo/screenshot.
  /// Links use `_driveLinkUnderstanding`, which waits for a real crawl/proposal.
  void _startUnderstanding() {
    _clearTimers();
    setState(() {
      _view = 'proc';
      _steps = 0;
    });
    for (var k = 0; k < 3; k++) {
      _timers.add(
        Timer(
          Duration(milliseconds: 500 + k * 650),
          () => mounted ? setState(() => _steps = k + 1) : null,
        ),
      );
    }
    _timers.add(
      Timer(const Duration(milliseconds: 500 + 3 * 650 + 500), () {
        if (mounted && _view == 'proc') setState(() => _view = 'review');
      }),
    );
  }

  /// Paste a URL (optional title) → Understanding → review → (confirm) import as
  /// a real link memory.
  Future<void> _openLinkEntry() async {
    _clearTimers();
    final result = await showModalBottomSheet<_LinkInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LinkSheet(),
    );
    if (!mounted) return;
    final url = result?.url.trim() ?? '';
    if (url.isEmpty) {
      _startListen();
      return;
    }
    setState(() {
      _kind = 'link';
      _pendingUrl = url;
      _pendingTitle = result?.title;
      _linkCrawlState = 'idle';
      _linkCrawlMethod = null;
    });
    unawaited(_driveLinkUnderstanding());
  }

  /// Pick a photo or screenshot from the gallery → Understanding → review →
  /// (confirm) upload as a real image memory.
  Future<void> _pickPhoto({bool screenshot = false}) async {
    _clearTimers();
    PickedCaptureMedia? media;
    try {
      media = await createCaptureMediaPicker().pickGalleryImage();
    } catch (_) {
      media = null;
    }
    if (!mounted) return;
    if (media == null) {
      _startListen();
      return;
    }
    setState(() {
      _kind = screenshot ? 'screenshot' : 'photo';
      _pendingMedia = media;
    });
    _startUnderstanding();
  }

  Future<void> _persistMedia(
    MiraServices services,
    PickedCaptureMedia media,
  ) async {
    try {
      final item = await services.libraryRepository.uploadBytes(
        bytes: media.bytes,
        filename: media.filename,
        mimeType: media.mimeType,
      );
      services.memoryStore.upsertLocal(item);
    } catch (_) {
      // Best-effort — the capture is still shown as kept.
    }
  }

  /// Derive a short title from free text: first line, clipped to ~60 chars.
  String _titleFrom(String text) {
    final firstLine = text.split('\n').first.trim();
    final base = firstLine.isEmpty ? text.trim() : firstLine;
    if (base.length <= 60) return base;
    return '${base.substring(0, 57).trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.rd.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(key: ValueKey(_view), child: _current()),
        ),
      ),
    );
  }

  Widget _current() {
    switch (_view) {
      case 'listen':
        return _listen();
      case 'photo_cam':
        return _photoCam();
      case 'shot_pick':
        return _shotPick();
      case 'link_capture':
        return _linkCapture();
      case 'link_error':
        return _linkError();
      case 'proc':
        return _proc();
      case 'review':
        return _review();
      default:
        return _added();
    }
  }

  Widget _photoCam() {
    return RdPhotoCaptureView(
      onClose: () => widget.go('home'),
      onGallery: () => _pickPhoto(),
      onCapture: () async {
        PickedCaptureMedia? media;
        try {
          media = await createCaptureMediaPicker().pickCameraImage();
        } catch (_) {
          media = null;
        }
        if (!mounted) return;
        if (media == null) {
          setState(() => _view = 'photo_cam');
          return;
        }
        setState(() {
          _kind = 'photo';
          _pendingMedia = media;
          capturePreviewBytes = media!.bytes;
        });
        _startUnderstanding();
      },
    );
  }

  Widget _shotPick() {
    return RdScreenshotPickerView(
      onClose: () => widget.go('home'),
      onSelected: () async {
        await _pickPhoto(screenshot: true);
      },
    );
  }

  Widget _linkCapture() {
    return RdLinkCaptureView(
      onClose: () => widget.go('home'),
      onSubmit: (url, title) {
        setState(() {
          _kind = 'link';
          _pendingUrl = url;
          _pendingTitle = title;
          _linkCrawlState = 'idle';
          _linkCrawlMethod = null;
        });
        unawaited(_driveLinkUnderstanding());
      },
    );
  }

  Widget _linkError() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _reviewTop(l10n.rdCaptureCancel, () => widget.go('home')),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: rd.periSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: RdIcon(
                        RdIcons.linkChain,
                        size: 28,
                        color: rd.peri,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.rdCaptureLinkFailedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dosis(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: rd.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.rdCaptureLinkFailedBody,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 14,
                      height: 1.55,
                      color: rd.muted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _retryLink,
                    style: FilledButton.styleFrom(
                      backgroundColor: rd.navy,
                      minimumSize: const Size(210, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.rdCaptureLinkRetry,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _liveEntityChips() {
    final proposal = _proposal;
    if (proposal == null) return const [];
    final chips = <String>[
      ...proposal.relatedLabels,
      ...proposal.insightLabels,
    ].take(4).toList();
    if (chips.isEmpty) return const [];
    final rd = context.rd;
    return [
      const SizedBox(height: 10),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: chips
            .map(
              (c) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: rd.card,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: rd.line),
                ),
                child: Text(
                  c,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: rd.ink,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ];
  }

  // ── listen ──────────────────────────────────────────────────────────
  Widget _listen() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circBtn(
                '<path d="M6 6l12 12M18 6 6 18"/>',
                () => widget.go('home'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: rd.card,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: rd.line, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE24B4A),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _time,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rd.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
        ),
        const Spacer(),
        const RdOrb(size: 120),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Text(
                l10n.rdCaptureListening,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: rd.peri,
                ),
              ),
              const SizedBox(height: 12),
              // Live transcript streaming from the mic. Empty until the first
              // words arrive (or on platforms without a real transcriber).
              if (_transcript.trim().isNotEmpty)
                Text(
                  _transcript,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 19,
                    height: 1.5,
                    color: rd.ink,
                  ),
                ),
              ..._liveEntityChips(),
            ],
          ),
        ),
        const Spacer(),
        // Quick entry modes — each runs through review, then persists a real
        // memory to the library on confirm.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _entryChip(RdIcons.pencil, l10n.rdCaptureEntryType, _openTextEntry),
            _entryChip(
              RdIcons.linkChain,
              l10n.rdCaptureEntryLink,
              _openLinkEntry,
            ),
            _entryChip(RdIcons.photo, l10n.rdCaptureEntryPhoto, _pickPhoto),
            _entryChip(
              '<rect x="4" y="3" width="16" height="14" rx="2"/><path d="M8 21h8"/>',
              l10n.rdCaptureModeScreenshot,
              () => _pickPhoto(screenshot: true),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _Waveform(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circBtn(
              '<path d="M6 6l12 12M18 6 6 18"/>',
              () => widget.go('home'),
              size: 52,
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: _toProc,
              child: Container(
                width: 72,
                height: 72,
                // Brand orb button — fixed navy gradient + shadow across themes.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.28, -0.4),
                    colors: [Color(0xFF3A5AD0), _navy],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14328C).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: RdIcon(
                    '<path d="m5 12 5 5 9-11"/>',
                    size: 30,
                    stroke: '#FFFFFF',
                    strokeWidth: 2.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
            const SizedBox(width: 52),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          l10n.rdCaptureTapWhenFinished,
          style: GoogleFonts.vazirmatn(fontSize: 12.5, color: rd.muted),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── processing ──────────────────────────────────────────────────────
  Widget _proc() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.rdCaptureStepTranscribe,
      l10n.rdCaptureStepRecognise,
      l10n.rdCaptureStepConnections,
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RdOrb(size: 120),
          const SizedBox(height: 26),
          Text(
            l10n.rdCaptureUnderstanding,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: rd.peri,
            ),
          ),
          const SizedBox(height: 22),
          for (var k = 0; k < labels.length; k++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: k < _steps ? 1 : 0.4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      // Completed step → fixed navy fill; pending → adaptive hairline.
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: k < _steps ? rd.navy : rd.line,
                      ),
                      child: k < _steps
                          ? const Center(
                              child: RdIcon(
                                '<path d="m5 12 5 5 9-11"/>',
                                size: 12,
                                stroke: '#FFFFFF',
                                strokeWidth: 3,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 11),
                    Text(
                      labels[k],
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: rd.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The text shown in the "Mira understood this" card. Prefers the real
  /// proposal's understood title (falling back to its summary), then the
  /// transcript, so genuine extraction is reflected verbatim.
  String _understoodText(AppLocalizations l10n) {
    if (_kind == 'link') {
      final t = _pendingTitle?.trim() ?? '';
      if (t.isNotEmpty) return t;
      return _pendingUrl ?? l10n.rdCaptureSavedLink;
    }
    if (_kind == 'photo') {
      return l10n.rdCaptureKeptPhoto;
    }
    if (_kind == 'screenshot') {
      return l10n.rdCaptureKeptScreenshot;
    }
    final proposal = _proposal;
    if (_realProposal && proposal != null) {
      if (proposal.title.trim().isNotEmpty) return proposal.title.trim();
      if (proposal.summary.trim().isNotEmpty) return proposal.summary.trim();
    }
    final t = _transcript.trim();
    return t.isNotEmpty ? t : l10n.rdCaptureYourNote;
  }

  /// The "Details Mira extracted" chips. Real proposal → genuine detail labels
  /// (deadline + extracted insights, de-duplicated, capped); otherwise the
  /// design's illustrative 👤/📅/# chips. Always ends with the "+ Add" chip.
  /// The detail chips before any edit — the real extracted labels. Empty when
  /// nothing was extracted (the user can still add their own via "+ Add");
  /// never fabricated placeholder chips.
  List<String> _computedChips(AppLocalizations l10n) =>
      _realProposal ? _extractedDetailLabels(l10n) : const [];

  /// The chips actually shown: the user's edited list once they've touched it,
  /// otherwise the computed source (so real extraction still flows through).
  List<String> _currentChips(AppLocalizations l10n) =>
      _chips ?? _computedChips(l10n);

  void _removeChip(int i, AppLocalizations l10n) {
    final list = [..._currentChips(l10n)]..removeAt(i);
    setState(() => _chips = list);
  }

  void _addChipLabel(String raw, AppLocalizations l10n) {
    var v = raw.trim();
    if (v.isEmpty) return;
    // Prefix a bare word with '#' (matching the design's inline tag editor).
    if (!RegExp(r'^[#@🎵📅📍👤✈️💺🔖]').hasMatch(v)) {
      v = '# ${v.replaceFirst(RegExp(r'^#\s*'), '')}';
    }
    setState(() => _chips = [..._currentChips(l10n), v]);
  }

  Widget _detailChips(AppLocalizations l10n) {
    final labels = _currentChips(l10n);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          _EChip(labels[i], onRemove: () => _removeChip(i, l10n)),
        _EChip('+ Add', add: true, onTap: _openAddTag),
      ],
    );
  }

  /// Genuine detail labels for the real proposal: the resolved deadline first,
  /// then the extracted insight labels (roles / task titles / evidence). Trimmed,
  /// de-duplicated, and capped so the review stays tidy.
  List<String> _extractedDetailLabels(AppLocalizations l10n) {
    final proposal = _proposal;
    if (proposal == null) return const [];
    final out = <String>[];
    void add(String value) {
      final v = value.trim();
      if (v.isNotEmpty && !out.contains(v)) out.add(v);
    }

    if (proposal.deadline.isNotEmpty) add('📅 ${proposal.deadline}');
    for (final label in proposal.insightLabels) {
      add(label);
    }
    // Keep the source content out of the chips when it's just the whole
    // understood sentence repeated back.
    out.removeWhere((l) => l == _understoodText(l10n).trim());
    return out.take(6).toList();
  }

  /// The "Connect to existing memory" section. Real proposal → one toggleable
  /// row per extracted related node/relationship (omitted entirely when there
  /// are none). Otherwise the design's three illustrative connection rows.
  List<Widget> _connectSection(AppLocalizations l10n) {
    if (_realProposal) {
      final related = _proposal?.relatedLabels ?? const <String>[];
      if (related.isEmpty) return const [];
      final rows = <Widget>[_fieldLabel(l10n.rdCaptureConnectMemory)];
      for (var i = 0; i < related.length; i++) {
        if (i > 0) rows.add(const SizedBox(height: 8));
        final on = _connOn.contains(i);
        rows.add(
          _connRow(
            '<circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/>',
            related[i],
            l10n.rdCaptureRelatedMemory,
            on,
            () => setState(() {
              if (on) {
                _connOn.remove(i);
              } else {
                _connOn.add(i);
              }
            }),
          ),
        );
      }
      return rows;
    }
    // Photo / screenshot / link → "Suggested actions" instead of the voice-note
    // connection rows.
    if (_kind == 'photo' || _kind == 'screenshot' || _kind == 'link') {
      return _suggestedActions(l10n);
    }
    // No real extraction → no fabricated connection rows. The graph will link
    // this memory on approval; nothing to show or toggle here.
    return const [];
  }

  /// The number of connections/actions currently toggled on — drives the
  /// dynamic "Add · linking N" confirm-button label.
  int get _linkCount => _realProposal
      ? _connOn.length
      : [_conn1, _conn2, _conn3].where((x) => x).length;

  /// Kind-aware reminder line for the bottom reminder card. For voice/text it
  /// reflects the real extracted deadline when one was found; otherwise a
  /// neutral prompt — never a fabricated day.
  String _reminderText(AppLocalizations l10n) {
    switch (_kind) {
      case 'link':
        return l10n.rdCaptureRemindWeekend;
      case 'photo':
      case 'screenshot':
        return l10n.rdCaptureRemindLater;
      default:
        final deadline = _realProposal
            ? (_proposal?.deadline.trim() ?? '')
            : '';
        if (deadline.isNotEmpty) return l10n.rdCaptureRemindBefore(deadline);
        return l10n.rdCaptureRemindLater;
    }
  }

  List<Widget> _suggestedActions(AppLocalizations l10n) {
    const calendar =
        '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>';
    const topic = '<path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/>';
    const person =
        '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>';
    final List<(String, String, String)> rows;
    if (_kind == 'link') {
      rows = [
        (topic, l10n.rdCaptureActionAddTopic, l10n.rdCaptureActionAddTopicSub),
        (person, l10n.rdCaptureActionShare, l10n.rdCaptureActionShareSub),
      ];
    } else {
      rows = [
        (
          calendar,
          l10n.rdCaptureActionCalendar,
          l10n.rdCaptureActionCalendarSub,
        ),
        (topic, l10n.rdCaptureActionAddTopic, l10n.rdCaptureActionAddTopicSub),
        (
          person,
          l10n.rdCaptureActionAddPeople,
          l10n.rdCaptureActionAddPeopleSub,
        ),
      ];
    }
    final on = [_conn1, _conn2, _conn3];
    final toggles = <VoidCallback>[
      () => setState(() => _conn1 = !_conn1),
      () => setState(() => _conn2 = !_conn2),
      () => setState(() => _conn3 = !_conn3),
    ];
    final out = <Widget>[_fieldLabel(l10n.rdCaptureSuggestedActions)];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 8));
      out.add(_connRow(rows[i].$1, rows[i].$2, rows[i].$3, on[i], toggles[i]));
    }
    return out;
  }

  // ── change type ─────────────────────────────────────────────────────
  String get _currentTypeLabel =>
      _typeName ?? _autoTypeLabel(AppLocalizations.of(context)!);

  String _autoTypeLabel(AppLocalizations l10n) {
    switch (_kind) {
      case 'link':
        return l10n.rdCaptureTypeLink;
      case 'photo':
      case 'screenshot':
        return l10n.rdCaptureTypeNote;
      default:
        return _realProposal && (_proposal?.nodeType.isNotEmpty ?? false)
            ? _proposal!.nodeType
            : l10n.rdCaptureTypeTask;
    }
  }

  String get _currentTypeIcon => _typeIcon ?? _iconForType(_currentTypeLabel);

  String _iconForType(String label) {
    final l10n = AppLocalizations.of(context)!;
    final l = label.trim().toLowerCase();
    for (final t in _captureTypes(l10n)) {
      if (t.$1.toLowerCase() == l) return t.$2;
    }
    const english = [
      'note',
      'task',
      'event',
      'person',
      'place',
      'link',
      'article',
      'idea',
      'travel',
    ];
    for (var i = 0; i < english.length; i++) {
      if (english[i] == l) return _captureTypeIconPaths[i];
    }
    // Default (task/pencil) for unknown auto-detected proposal types.
    return '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>';
  }

  /// Opens the "Change type" picker (design typeScrim) — tapping a type sets the
  /// review's type chip. All nine memory types.
  Future<void> _openTypePicker() async {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final types = _captureTypes(l10n);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final navInset = sheetContext.rdNavBarInset;
        return Container(
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: EdgeInsets.fromLTRB(18, 12, 18, 24 + navInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: rd.line,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Text(
                l10n.rdCaptureChangeType,
                style: GoogleFonts.dosis(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.rdCaptureFilePrompt,
                style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.muted),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [for (final t in types) _typeOpt(t.$1, t.$2)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeOpt(String label, String icon) {
    final rd = context.rd;
    final cur = _currentTypeLabel.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _typeName = label;
          _typeIcon = icon;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        width: 98,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cur ? rd.navy.withValues(alpha: 0.08) : rd.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cur ? rd.navy : rd.line,
            width: cur ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            RdIcon(
              icon,
              size: 22,
              color: cur ? rd.navy : rd.ink,
              strokeWidth: 1.8,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: cur ? rd.navy : rd.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inline "+ Add" tag editor — a small sheet that appends a detail chip.
  Future<void> _openAddTag() async {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final ctl = TextEditingController();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: rd.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            22 +
                math.max(
                  0.0,
                  MediaQuery.of(ctx).viewPadding.bottom -
                      MediaQuery.of(ctx).viewInsets.bottom,
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: rd.line,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Text(
                l10n.rdCaptureAddDetail,
                style: GoogleFonts.dosis(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: rd.ink,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) => Navigator.of(ctx).pop(v),
                style: GoogleFonts.vazirmatn(fontSize: 15, color: rd.ink),
                decoration: InputDecoration(
                  hintText: l10n.rdCaptureAddDetailHint,
                  hintStyle: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    color: rd.faint,
                  ),
                  filled: true,
                  fillColor: rd.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: rd.line, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: rd.navy, width: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ctl.dispose();
    if (value != null) _addChipLabel(value, l10n);
  }

  // ── review preview header (photo / screenshot / link) ────────────────
  String _reviewEyebrow(AppLocalizations l10n) {
    switch (_kind) {
      case 'photo':
        return l10n.rdCaptureReadPhoto;
      case 'screenshot':
        return l10n.rdCaptureReadScreenshot;
      case 'link':
        return l10n.rdCaptureReadPage;
      default:
        return l10n.rdCaptureUnderstood;
    }
  }

  static String _linkHost(String? url) {
    if (url == null) return 'link';
    try {
      final h = Uri.parse(url).host;
      return h.isEmpty ? url : h.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  Widget _previewBadge(String label, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(icon, size: 13, stroke: '#FFFFFF', strokeWidth: 1.9),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// The preview shown atop the review for photo / screenshot / link captures
  /// (the real picked image, or a link hero). Null for voice / text.
  Widget? _previewHeader(AppLocalizations l10n) {
    final rd = context.rd;
    if (_kind == 'photo' || _kind == 'screenshot') {
      final bytes = _pendingMedia?.bytes;
      final shot = _kind == 'screenshot';
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: bytes != null
                  ? Image.memory(bytes, fit: BoxFit.cover)
                  : Container(color: rd.periSoft),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: _previewBadge(
                shot ? l10n.rdCaptureModeScreenshot : l10n.rdCaptureModePhoto,
                shot
                    ? '<rect x="4" y="3" width="16" height="14" rx="2"/><path d="M8 21h8"/>'
                    : '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/>',
              ),
            ),
          ],
        ),
      );
    }
    if (_kind == 'link') {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF243056), Color(0xFF121A33)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: _previewBadge(
                l10n.rdCaptureLinkBadge(_linkHost(_pendingUrl)),
                '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                _understoodText(l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dosis(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  Widget _linkCrawlStatus(AppLocalizations l10n) {
    final rd = context.rd;
    final ready = _linkCrawlState == 'ready';
    final label = ready
        ? l10n.rdCaptureLinkCrawlReady(
            (_linkCrawlMethod ?? 'reader').replaceAll('_', ' '),
          )
        : l10n.rdCaptureLinkMetadataOnly;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ready ? rd.periSoft : rd.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ready ? rd.peri : rd.line),
      ),
      child: Row(
        children: [
          RdIcon(
            ready ? RdIcons.check : RdIcons.linkChain,
            size: 18,
            color: ready ? rd.peri : rd.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: ready ? rd.peri : rd.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── review ──────────────────────────────────────────────────────────
  Widget _review() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final preview = _previewHeader(l10n);
    return Column(
      children: [
        _reviewTop(l10n.rdCaptureCancel, () => widget.go('home')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow(_reviewEyebrow(l10n)),
                const SizedBox(height: 12),
                if (preview != null) ...[preview, const SizedBox(height: 14)],
                if (_kind == 'link') ...[
                  _linkCrawlStatus(l10n),
                  const SizedBox(height: 14),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: rd.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: rd.line, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Real proposal → the auto-detected node type; else the
                          // design's default "Task".
                          _typeChip(_currentTypeIcon, _currentTypeLabel),
                          GestureDetector(
                            onTap: _openTypePicker,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                RdIcon(
                                  '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>',
                                  size: 13,
                                  color: rd.muted,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.rdCaptureChangeType,
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: rd.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // The understood text, verbatim from the real transcript /
                      // extracted proposal (or the link/photo summary).
                      Text(
                        _understoodText(l10n),
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          height: 1.5,
                          color: rd.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                _fieldLabel(l10n.rdCaptureDetailsExtracted),
                _detailChips(l10n),
                ..._connectSection(l10n),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => setState(() => _remind = !_remind),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: rd.periSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // On-periSoft icon + text → rd.peri (navy vanishes on dark periSoft).
                        RdIcon(
                          '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M12 2h0M9 2h6"/>',
                          size: 20,
                          color: rd.peri,
                          strokeWidth: 1.8,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            _reminderText(l10n),
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: rd.peri,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _Tog(on: _remind),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _reviewBar(),
      ],
    );
  }

  // ── added ───────────────────────────────────────────────────────────
  /// The confirmation sentence, reflecting the real connection count, whether a
  /// reminder was set, and who (if anyone) will be notified.
  String _addedSummary(AppLocalizations l10n) {
    final parts = <String>[];
    final n = _linkCount;
    if (n > 0) parts.add(l10n.rdCaptureLinkedMemories(n));
    if (_remind) parts.add(l10n.rdCaptureHasReminder);
    if (parts.isEmpty) {
      return l10n.rdCaptureKeptSafe;
    }
    final joined = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return l10n.rdCaptureKeptJoined(joined);
  }

  Widget _added() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              // Success orb — fixed brand green gradient across themes.
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F8A5B), Color(0xFF34A56F)],
                ),
              ),
              child: const Center(
                child: RdIcon(
                  '<path d="m5 12 5 5 9-11"/>',
                  size: 40,
                  stroke: '#FFFFFF',
                  strokeWidth: 2.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.rdCaptureKeptTitle,
              style: GoogleFonts.dosis(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: rd.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _addedSummary(l10n),
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                height: 1.5,
                color: rd.muted,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _graphDot(11, false),
                _graphLine(),
                _graphDot(20, true),
                _graphLine(),
                _graphDot(11, false),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => widget.go('home'),
              child: Container(
                width: 220,
                height: 52,
                alignment: Alignment.center,
                // Fixed navy CTA.
                decoration: BoxDecoration(
                  color: rd.navy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  l10n.rdCaptureDone,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── shared bits ─────────────────────────────────────────────────────
  Widget _reviewTop(String backLabel, VoidCallback onBack) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RdIcon(
                  '<path d="M15 18l-6-6 6-6"/>',
                  size: 18,
                  color: rd.muted,
                  strokeWidth: 2,
                ),
                const SizedBox(width: 3),
                Text(
                  backLabel,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: rd.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.rdCaptureReview,
            style: GoogleFonts.dosis(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: rd.ink,
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _reviewBar() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: rd.line, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.go('home'),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rd.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: rd.line, width: 1),
              ),
              child: Text(
                l10n.rdCaptureDiscard,
                style: GoogleFonts.vazirmatn(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: rd.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _savingLink ? null : _addToMemory,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                // Fixed navy CTA. Label reflects how many connections/actions
                // are toggled on (design's "Add · linking N").
                decoration: BoxDecoration(
                  color: rd.navy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _savingLink
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _linkCount > 0
                            ? l10n.rdCaptureAddLinking(_linkCount)
                            : l10n.rdCaptureAddToMemory,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eyebrow(String text) {
    final rd = context.rd;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: rd.peri),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.vazirmatn(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: rd.faint,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.vazirmatn(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.rd.muted,
        ),
      ),
    );
  }

  Widget _typeChip(String icon, String label) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: rd.periSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // On-periSoft badge → rd.peri (navy vanishes on dark periSoft).
          RdIcon(icon, size: 14, color: rd.peri, strokeWidth: 2),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: rd.peri,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connRow(
    String icon,
    String name,
    String sub,
    bool on,
    VoidCallback onTap,
  ) {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: rd.periSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            // On-periSoft icon → rd.peri (navy vanishes on dark periSoft).
            child: Center(
              child: RdIcon(icon, size: 18, color: rd.peri, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.vazirmatn(fontSize: 12, color: rd.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: _Tog(on: on),
          ),
        ],
      ),
    );
  }

  Widget _circBtn(String icon, VoidCallback onTap, {double size = 42}) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: rd.card,
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Center(
          child: RdIcon(
            icon,
            size: size * 0.4,
            color: rd.gearIcon,
            strokeWidth: 2.1,
          ),
        ),
      ),
    );
  }

  /// A pill button for the alternative capture entry modes on the listen screen.
  Widget _entryChip(String icon, String label, VoidCallback onTap) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: rd.line, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RdIcon(icon, size: 15, color: rd.gearIcon, strokeWidth: 1.9),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: rd.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graphDot(double size, bool hub) {
    final rd = context.rd;
    return Container(
      width: size,
      height: size,
      // Hub node keeps its fixed brand gradient; satellite dots use adaptive
      // periSoft fill + peri border so they read on both themes.
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hub
            ? const RadialGradient(
                colors: [Color(0xFFAEB9E8), Color(0xFF6472B6)],
              )
            : null,
        color: hub ? null : rd.periSoft,
        border: hub ? null : Border.all(color: rd.peri, width: 1.5),
      ),
    );
  }

  Widget _graphLine() => Container(
    width: 34,
    height: 1.5,
    color: context.rd.peri.withValues(alpha: 0.5),
  );
}

/// SVG glyphs for the nine memory types in the "Change type" picker.
const List<String> _captureTypeIconPaths = [
  '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>',
  '<circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/>',
  '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>',
  '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/>',
  '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
  '<path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22.5z"/><path d="M8 7h8M8 11h6"/>',
  '<path d="M9 18h6M10 22h4"/><path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.2 1 2h6c0-.8.4-1.5 1-2A7 7 0 0 0 12 2Z"/>',
  '<path d="M17.8 19.2 16 11l3.5-3.5a2.1 2.1 0 0 0-3-3L13 8 4.8 6.2a.5.5 0 0 0-.5.8L8 11l-2 2-3-1-1 1 4 2 2 4 1-1-1-3 2-2 3.5 3.7a.5.5 0 0 0 .8-.5z"/>',
];

List<(String, String)> _captureTypes(AppLocalizations l10n) => [
  (l10n.rdCaptureTypeNote, _captureTypeIconPaths[0]),
  (l10n.rdCaptureTypeTask, _captureTypeIconPaths[1]),
  (l10n.rdCaptureTypeEvent, _captureTypeIconPaths[2]),
  (l10n.rdCaptureTypePerson, _captureTypeIconPaths[3]),
  (l10n.rdCaptureTypePlace, _captureTypeIconPaths[4]),
  (l10n.rdCaptureTypeLink, _captureTypeIconPaths[5]),
  (l10n.rdCaptureTypeArticle, _captureTypeIconPaths[6]),
  (l10n.rdCaptureTypeIdea, _captureTypeIconPaths[7]),
  (l10n.rdCaptureTypeTravel, _captureTypeIconPaths[8]),
];

class _EChip extends StatelessWidget {
  const _EChip(this.label, {this.add = false, this.onRemove, this.onTap});

  final String label;
  final bool add;

  /// When set, renders a trailing × that removes the chip.
  final VoidCallback? onRemove;

  /// When set, the whole chip is tappable (used by the "+ Add" chip).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final chip = Container(
      padding: EdgeInsets.fromLTRB(12, 8, onRemove != null ? 8 : 12, 8),
      decoration: BoxDecoration(
        color: add ? Colors.transparent : rd.card,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: add ? rd.peri.withValues(alpha: 0.5) : rd.line,
          width: 1,
        ),
      ),
      // The "+ Add" chip sits on the page bg (not periSoft) → rd.peri to stay
      // legible on dark; genuine detail chips use ink text.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: add ? rd.peri : rd.ink,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: RdIcon(
                '<path d="M6 6l12 12M18 6 6 18"/>',
                size: 12,
                color: rd.faint,
                strokeWidth: 2.4,
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }
    return chip;
  }
}

class _Tog extends StatelessWidget {
  const _Tog({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    // On-track is brand navy (fixed accent). Off-track has no token: keep the
    // exact light literal, and use a lifted neutral on dark for contrast.
    final offTrack = _isDark(context)
        ? const Color(0xFF3A3B44)
        : const Color(0xFFD3D5DE);
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: on ? context.rd.navy : offTrack,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform();

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peri = context.rd.peri;
    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 27; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Container(
                  width: 3,
                  height:
                      6 +
                      26 *
                          (0.5 +
                                  0.5 *
                                      math.sin(
                                        (_c.value * 2 * math.pi) + i * 0.55,
                                      ))
                              .abs(),
                  decoration: BoxDecoration(
                    color: peri.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Result of the link-entry sheet: a URL plus an optional display title.
class _LinkInput {
  const _LinkInput({required this.url, this.title});
  final String url;
  final String? title;
}

/// Bottom sheet that collects free text (a note) and returns it on "Add".
/// Styled to match the capture flow — soft card surface, navy CTA.
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({
    required this.title,
    required this.hint,
    required this.icon,
    this.multiline = false,
  });

  final String title;
  final String hint;
  final String icon;
  final bool multiline;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final can = _controller.text.trim().isNotEmpty;
      if (can != _canSubmit) setState(() => _canSubmit = can);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SheetShell(
      icon: widget.icon,
      title: widget.title,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          maxLines: widget.multiline ? 5 : 1,
          minLines: widget.multiline ? 3 : 1,
          textInputAction: widget.multiline
              ? TextInputAction.newline
              : TextInputAction.done,
          style: GoogleFonts.vazirmatn(
            fontSize: 15,
            height: 1.5,
            color: context.rd.ink,
          ),
          decoration: _fieldDecoration(context, widget.hint),
        ),
        const SizedBox(height: 14),
        _SheetSubmit(
          label: l10n.rdCaptureAddToMemory,
          enabled: _canSubmit,
          onTap: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}

/// Bottom sheet that collects a URL and an optional title for a link memory.
class _LinkSheet extends StatefulWidget {
  const _LinkSheet();

  @override
  State<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends State<_LinkSheet> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(() {
      final can = _looksLikeUrl(_urlController.text);
      if (can != _canSubmit) setState(() => _canSubmit = can);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool _looksLikeUrl(String value) {
    final v = value.trim();
    return v.contains('.') && !v.contains(' ') && v.length > 3;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SheetShell(
      icon: RdIcons.linkChain,
      title: l10n.rdCaptureLinkSheetTitle,
      children: [
        TextField(
          controller: _urlController,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.vazirmatn(fontSize: 15, color: context.rd.ink),
          decoration: _fieldDecoration(context, l10n.rdCaptureUrlHint),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.vazirmatn(fontSize: 15, color: context.rd.ink),
          decoration: _fieldDecoration(
            context,
            l10n.rdCaptureLinkTitleOptional,
          ),
        ),
        const SizedBox(height: 14),
        _SheetSubmit(
          label: l10n.rdCaptureAddToMemory,
          enabled: _canSubmit,
          onTap: () => Navigator.of(context).pop(
            _LinkInput(
              url: _urlController.text,
              title: _titleController.text.trim().isEmpty
                  ? null
                  : _titleController.text.trim(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared rounded-top sheet chrome: grab handle, header with icon, and a
/// keyboard-aware padded body.
class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.icon,
    required this.title,
    required this.children,
  });

  final String icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
    // Clear the nav bar only when the keyboard isn't already covering it.
    final navGap = math.max(0.0, mq.viewPadding.bottom - bottomInset);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: rd.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(22, 12, 22, 22 + navGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: rd.periSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // On-periSoft icon → rd.peri (navy vanishes on dark periSoft).
                  child: Center(
                    child: RdIcon(
                      icon,
                      size: 18,
                      color: rd.peri,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Text(
                  title,
                  style: GoogleFonts.dosis(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: rd.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The navy "Add to memory" button used across the entry sheets.
class _SheetSubmit extends StatelessWidget {
  const _SheetSubmit({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, String hint) {
  final rd = context.rd;
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.vazirmatn(fontSize: 15, color: rd.faint),
    filled: true,
    fillColor: rd.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: rd.line, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: rd.peri, width: 1.5),
    ),
  );
}
