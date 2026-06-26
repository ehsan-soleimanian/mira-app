import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/auth_repository.dart';
import 'package:mira_app/core/auth/google_sign_in_service.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/core/update/app_release_repository.dart';
import 'package:mira_app/features/auth/onboarding_repository.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/utils/capture_errors.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';
import 'package:mira_app/features/capture/voice/device_voice_recorder.dart';
import 'package:mira_app/features/capture/voice/voice_recorder_port.dart';
import 'package:mira_app/features/capture/widgets/approval_sheet.dart';
import 'package:mira_app/features/capture/widgets/time_clarification_sheet.dart';
import 'package:mira_app/features/daily_brief/daily_brief_repository.dart';
import 'package:mira_app/features/graph/graph_repository.dart';
import 'package:mira_app/features/settings/settings_repository.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';

/// Orchestrates capture UI state, voice recording, submit → SSE → approval.
class CaptureFlowController extends ChangeNotifier {
  CaptureFlowController({
    required CaptureRepository captureRepository,
    VoiceRecorderPort? voiceRecorder,
  }) : _captures = captureRepository,
       _recorder = voiceRecorder ?? createVoiceRecorder();

  final CaptureRepository _captures;
  final VoiceRecorderPort _recorder;

  CaptureUiPhase phase = CaptureUiPhase.idle;
  Duration recordingDuration = Duration.zero;
  String? lastAnswer;
  bool usedMockPipeline = false;
  bool requestTextPrompt = false;

  /// Active voice long-press session (stays on [VoiceRecordingScreen] until idle).
  bool voiceSessionActive = false;
  String? activeCaptureId;
  Map<String, dynamic>? pendingProposal;
  String? voiceSessionPrompt;
  bool approvalBusy = false;
  String? lastCaptureError;
  String? voiceFailureMessage;
  Map<String, dynamic>? pendingTimeClarification;
  Map<String, dynamic>? pendingIntentClarification;
  Map<String, dynamic>? pendingEntityClarification;

  Timer? _recordingTimer;
  Stream<double>? _amplitudeStream;

  Stream<double> get amplitudeStream =>
      _amplitudeStream ?? const Stream.empty();

  bool get isProcessing =>
      phase == CaptureUiPhase.uploading || phase == CaptureUiPhase.processing;

  bool get isVoiceApproval =>
      voiceSessionActive && phase == CaptureUiPhase.approving;

  void showBubbleMenu() {
    if (phase != CaptureUiPhase.idle) return;
    phase = CaptureUiPhase.bubbleMenu;
    notifyListeners();
  }

  void hideBubbleMenu() {
    if (phase != CaptureUiPhase.bubbleMenu) return;
    phase = CaptureUiPhase.idle;
    notifyListeners();
  }

  void openTextPrompt() {
    hideBubbleMenu();
    requestTextPrompt = true;
    notifyListeners();
  }

  void clearTextPromptRequest() {
    if (!requestTextPrompt) return;
    requestTextPrompt = false;
    notifyListeners();
  }

  void clearLastCaptureError() {
    if (lastCaptureError == null) return;
    lastCaptureError = null;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (phase != CaptureUiPhase.idle &&
        phase != CaptureUiPhase.bubbleMenu &&
        phase != CaptureUiPhase.voiceFailed) {
      return;
    }
    hideBubbleMenu();
    voiceFailureMessage = null;
    final started = await _recorder.start();
    if (!started) {
      if (phase == CaptureUiPhase.bubbleMenu) {
        phase = CaptureUiPhase.idle;
      }
      notifyListeners();
      return;
    }
    _amplitudeStream = _recorder.amplitudeStream;
    recordingDuration = Duration.zero;
    voiceSessionActive = false;
    activeCaptureId = null;
    pendingProposal = null;
    voiceSessionPrompt = null;
    phase = CaptureUiPhase.recording;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> cancelRecording() async {
    _recordingTimer?.cancel();
    await _recorder.cancel();
    recordingDuration = Duration.zero;
    voiceFailureMessage = null;
    _resetVoiceSession();
    phase = CaptureUiPhase.idle;
    notifyListeners();
  }

  /// Leave voice failure screen without recording again.
  void dismissVoiceFailure() {
    voiceFailureMessage = null;
    _resetVoiceSession();
    phase = CaptureUiPhase.idle;
    notifyListeners();
  }

  /// Re-record after STT / upload failure (stays on voice route).
  Future<void> retryVoiceAfterFailure() async {
    if (phase != CaptureUiPhase.voiceFailed) return;
    await startRecording();
  }

  /// Close voice route and open home text composer.
  void openTextFallbackFromVoice() {
    voiceFailureMessage = null;
    _resetVoiceSession();
    phase = CaptureUiPhase.idle;
    requestTextPrompt = true;
    notifyListeners();
  }

  /// Stop mic, upload voice, consume SSE — approval UI stays on voice route.
  Future<void> stopRecordingAndSubmit() async {
    if (phase != CaptureUiPhase.recording) return;
    _recordingTimer?.cancel();
    lastCaptureError = null;
    voiceSessionActive = true;
    phase = CaptureUiPhase.uploading;
    notifyListeners();

    final result = await _recorder.stop();
    phase = CaptureUiPhase.processing;
    notifyListeners();

    usedMockPipeline = false;
    try {
      final created = await _captures.createVoiceCapture(
        durationMs: result.duration.inMilliseconds,
        audioPath: result.filePath,
      );
      if (created.captureId == 'mock-voice-capture') {
        usedMockPipeline = true;
      }
      activeCaptureId = created.captureId;
      await _consumeCaptureStream(
        created,
        presentation: _CapturePresentation.voiceRoute,
      );
    } catch (error) {
      _enterVoiceFailure(formatVoiceCaptureError(error));
    } finally {
      recordingDuration = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> submitPrompt(BuildContext context, String text) async {
    if (text.trim().isEmpty) return;
    hideBubbleMenu();
    phase = CaptureUiPhase.processing;
    notifyListeners();

    try {
      final created = await _captures.createTextCapture(text.trim());
      if (!context.mounted) return;
      await _consumeCaptureStream(
        created,
        presentation: _CapturePresentation.sheet,
        sheetContext: context,
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Capture error: $error')));
      }
    } finally {
      if (!voiceSessionActive) {
        phase = CaptureUiPhase.idle;
      }
      notifyListeners();
    }
  }

  Future<void> approvePendingCapture() async {
    final captureId = activeCaptureId;
    if (captureId == null || approvalBusy) return;
    approvalBusy = true;
    notifyListeners();
    try {
      await _captures.approve(captureId);
      final suffix = usedMockPipeline ? ' (sample data)' : '';
      lastAnswer = 'Saved to memory$suffix';
      _resetVoiceSession();
      phase = CaptureUiPhase.idle;
    } catch (error) {
      lastCaptureError = formatCaptureError(error);
    } finally {
      approvalBusy = false;
      notifyListeners();
    }
  }

  Future<void> dismissPendingCapture() async {
    final captureId = activeCaptureId;
    if (captureId == null || approvalBusy) return;
    approvalBusy = true;
    notifyListeners();
    try {
      await _captures.dismiss(captureId);
      _resetVoiceSession();
      phase = CaptureUiPhase.idle;
    } catch (error) {
      lastCaptureError = 'Cancel failed: $error';
    } finally {
      approvalBusy = false;
      notifyListeners();
    }
  }

  void _enterVoiceFailure(String message) {
    voiceSessionActive = true;
    voiceFailureMessage = message;
    activeCaptureId = null;
    pendingProposal = null;
    voiceSessionPrompt = null;
    pendingTimeClarification = null;
    pendingIntentClarification = null;
    approvalBusy = false;
    phase = CaptureUiPhase.voiceFailed;
    notifyListeners();
  }

  void _resetVoiceSession() {
    voiceSessionActive = false;
    activeCaptureId = null;
    pendingProposal = null;
    voiceSessionPrompt = null;
    approvalBusy = false;
    pendingTimeClarification = null;
    pendingIntentClarification = null;
  }

  void _enterVoiceApproval(String captureId, Map<String, dynamic> proposal) {
    activeCaptureId = captureId;
    pendingProposal = proposal;
    voiceSessionPrompt = resolveProposalDisplay(proposal).title;
    phase = CaptureUiPhase.approving;
    notifyListeners();
  }

  Future<void> _consumeCaptureStream(
    CaptureResponse created, {
    required _CapturePresentation presentation,
    BuildContext? sheetContext,
  }) async {
    await for (final event in _captures.streamCapture(created.captureId)) {
      if (presentation == _CapturePresentation.sheet) {
        if (sheetContext == null || !sheetContext.mounted) return;
      }

      switch (event.event) {
        case 'time_clarification':
          if (presentation == _CapturePresentation.voiceRoute) {
            pendingTimeClarification = event.data;
            notifyListeners();
          } else if (sheetContext != null && sheetContext.mounted) {
            await _handleTimeClarification(
              sheetContext,
              created.captureId,
              event,
              presentation: presentation,
            );
          }
        case 'entity_clarification':
          if (presentation == _CapturePresentation.voiceRoute) {
            activeCaptureId = created.captureId;
            pendingEntityClarification = event.data;
            pendingIntentClarification = null;
            phase = CaptureUiPhase.approving;
            notifyListeners();
          } else if (sheetContext != null && sheetContext.mounted) {
            await _handleEntityClarification(
              sheetContext,
              created.captureId,
              event.data,
              presentation: presentation,
            );
          }
        case 'clarification':
          if (presentation == _CapturePresentation.voiceRoute) {
            activeCaptureId = created.captureId;
            pendingIntentClarification = {
              'prompt': event.data['prompt']?.toString(),
            };
            phase = CaptureUiPhase.approving;
            notifyListeners();
          } else if (sheetContext != null && sheetContext.mounted) {
            await _handleIntentClarification(
              sheetContext,
              created.captureId,
              event.data['prompt']?.toString(),
            );
          }
        case 'proposal':
          if (presentation == _CapturePresentation.voiceRoute) {
            _enterVoiceApproval(created.captureId, event.data);
          } else if (sheetContext != null && sheetContext.mounted) {
            await _handleProposal(sheetContext, created.captureId, event.data);
          }
        case 'question_answer':
          lastAnswer = event.data['answer'] as String?;
          if (presentation == _CapturePresentation.voiceRoute) {
            _resetVoiceSession();
            phase = CaptureUiPhase.idle;
          } else if (sheetContext != null && sheetContext.mounted) {
            ScaffoldMessenger.of(sheetContext).showSnackBar(
              SnackBar(
                content: Text(lastAnswer ?? 'Answer received'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        case 'error':
          final detail =
              event.data['detail']?.toString() ?? 'Capture failed';
          if (presentation == _CapturePresentation.voiceRoute) {
            _enterVoiceFailure(
              detail.length > 120
                  ? 'Voice processing failed. Try again.'
                  : detail,
            );
          } else if (sheetContext != null && sheetContext.mounted) {
            ScaffoldMessenger.of(sheetContext).showSnackBar(
              SnackBar(content: Text(detail)),
            );
          }
        case 'done':
          return;
      }
    }

    if (presentation == _CapturePresentation.sheet) {
      if (sheetContext == null || !sheetContext.mounted) return;
    }

    if (created.state == 'clarification_needed' && created.proposal != null) {
      if (sheetContext != null && sheetContext.mounted) {
        await _handleTimeClarification(
          sheetContext,
          created.captureId,
          CaptureStreamEvent(
            event: 'time_clarification',
            data: {
              'prompt':
                  (created.proposal!['time'] as Map?)?['clarification_prompt']
                      ?.toString() ??
                  'Please confirm the time',
              'suggestion': (created.proposal!['time'] as Map?)?['suggestion']
                  ?.toString(),
            },
          ),
          presentation: presentation,
        );
      }
    } else if (created.state == 'clarification_needed' &&
        _isEntityEquivalencePending(created.proposal)) {
      if (presentation == _CapturePresentation.voiceRoute) {
        activeCaptureId = created.captureId;
        pendingEntityClarification = {
          'prompt': created.answer,
          'entityEquivalence': created.proposal!['entityEquivalence'],
        };
        pendingIntentClarification = null;
        phase = CaptureUiPhase.approving;
        notifyListeners();
      } else if (sheetContext != null && sheetContext.mounted) {
        await _handleEntityClarification(
          sheetContext,
          created.captureId,
          {
            'prompt': created.answer,
            'entityEquivalence': created.proposal!['entityEquivalence'],
          },
          presentation: presentation,
        );
      }
    } else if (created.state == 'clarification_needed' && created.answer != null) {
      if (presentation == _CapturePresentation.voiceRoute) {
        activeCaptureId = created.captureId;
        pendingIntentClarification = {
          'prompt': created.answer!,
        };
        phase = CaptureUiPhase.approving;
      } else if (sheetContext != null && sheetContext.mounted) {
        await _handleIntentClarification(
          sheetContext,
          created.captureId,
          created.answer,
        );
      }
    } else if (created.state == 'awaiting_approval' &&
        created.proposal != null) {
      if (presentation == _CapturePresentation.voiceRoute) {
        _enterVoiceApproval(created.captureId, created.proposal!);
      } else if (sheetContext != null && sheetContext.mounted) {
        await _handleProposal(
          sheetContext,
          created.captureId,
          created.proposal!,
        );
      }
    } else if (created.state == 'question_answered' && created.answer != null) {
      lastAnswer = created.answer;
      if (presentation == _CapturePresentation.voiceRoute) {
        _resetVoiceSession();
        phase = CaptureUiPhase.idle;
      } else if (sheetContext != null && sheetContext.mounted) {
        ScaffoldMessenger.of(sheetContext).showSnackBar(
          SnackBar(
            content: Text(created.answer!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleProposal(
    BuildContext context,
    String captureId,
    Map<String, dynamic> proposal,
  ) async {
    await ApprovalSheet.show(
      context,
      proposal: proposal,
      onApprove: () async {
        await _captures.approve(captureId);
        if (context.mounted) {
          final suffix = usedMockPipeline ? ' (sample data)' : '';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved to memory$suffix')));
        }
      },
      onDismiss: () => _captures.dismiss(captureId),
    );
  }

  Future<void> resolvePendingTimeClarification(BuildContext context) async {
    final captureId = activeCaptureId;
    final pending = pendingTimeClarification;
    if (captureId == null || pending == null || !context.mounted) return;
    pendingTimeClarification = null;
    await _handleTimeClarification(
      context,
      captureId,
      CaptureStreamEvent(event: 'time_clarification', data: pending),
      presentation: _CapturePresentation.voiceRoute,
    );
  }

  Future<void> resolvePendingIntentClarification({
    required bool asQuestion,
  }) async {
    final captureId = activeCaptureId;
    if (captureId == null || approvalBusy) return;
    approvalBusy = true;
    notifyListeners();
    try {
      final updated = await _captures.clarifyIntent(
        captureId,
        intent: asQuestion ? 'question' : 'save',
      );
      pendingIntentClarification = null;
      if (updated.state == 'awaiting_approval' && updated.proposal != null) {
        _enterVoiceApproval(captureId, updated.proposal!);
      } else if (updated.state == 'question_answered' && updated.answer != null) {
        lastAnswer = updated.answer;
        _resetVoiceSession();
        phase = CaptureUiPhase.idle;
      } else if (updated.state == 'clarification_needed') {
        pendingIntentClarification = {
          'prompt': updated.answer,
        };
        phase = CaptureUiPhase.approving;
      }
    } catch (error) {
      lastCaptureError = 'Clarification failed: $error';
    } finally {
      approvalBusy = false;
      notifyListeners();
    }
  }

  Future<void> _handleTimeClarification(
    BuildContext context,
    String captureId,
    CaptureStreamEvent event, {
    required _CapturePresentation presentation,
  }) async {
    await TimeClarificationSheet.show(
      context,
      prompt: event.data['prompt'] as String? ?? 'Confirm time',
      suggestion: event.data['suggestion'] as String?,
      onConfirm: ({required bool accepted, String? resolvedTime}) async {
        final updated = await _captures.confirmTime(
          captureId,
          accepted: accepted,
          resolvedTime: resolvedTime,
        );
        if (updated.proposal != null) {
          if (presentation == _CapturePresentation.voiceRoute) {
            _enterVoiceApproval(captureId, updated.proposal!);
          } else if (context.mounted) {
            await _handleProposal(context, captureId, updated.proposal!);
          }
        }
      },
      onDismiss: () => _captures.dismiss(captureId),
    );
  }

  Future<void> confirmEntityEquivalenceChoice({
    required String captureId,
    required bool same,
    String? targetEntityId,
  }) async {
    approvalBusy = true;
    notifyListeners();
    try {
      final updated = await _captures.confirmEntityEquivalence(
        captureId,
        same: same,
        targetEntityId: targetEntityId,
      );
      pendingEntityClarification = null;
      if (updated.state == 'awaiting_approval' && updated.proposal != null) {
        if (voiceSessionActive) {
          _enterVoiceApproval(captureId, updated.proposal!);
        }
      }
    } finally {
      approvalBusy = false;
      notifyListeners();
    }
  }

  Future<void> _handleEntityClarification(
    BuildContext context,
    String captureId,
    Map<String, dynamic> data, {
    required _CapturePresentation presentation,
  }) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final prompt =
        data['prompt']?.toString() ?? l10n.captureEntityEquivalenceDefaultPrompt;
    final same = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EntityEquivalenceSheet(prompt: prompt),
    );
    if (same == null) return;
    final updated = await _captures.confirmEntityEquivalence(
      captureId,
      same: same,
      targetEntityId: _suggestedTargetEntityId(data),
    );
    if (updated.state == 'awaiting_approval' && updated.proposal != null) {
      if (presentation == _CapturePresentation.voiceRoute) {
        _enterVoiceApproval(captureId, updated.proposal!);
      } else if (context.mounted) {
        await _handleProposal(context, captureId, updated.proposal!);
      }
    }
  }

  String? _suggestedTargetEntityId(Map<String, dynamic> data) {
    final equivalence = data['entityEquivalence'];
    if (equivalence is! Map) return null;
    final suggested = equivalence['suggestedTargetEntityId'];
    return suggested?.toString();
  }

  bool _isEntityEquivalencePending(Map<String, dynamic>? proposal) {
    final equivalence = proposal?['entityEquivalence'];
    if (equivalence is! Map) return false;
    return equivalence['status']?.toString() == 'pending';
  }

  Future<void> _handleIntentClarification(
    BuildContext context,
    String captureId,
    String? prompt,
  ) async {
    if (!context.mounted) return;
    final selectedIntent = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _IntentClarificationSheet(
        prompt: prompt,
      ),
    );
    if (selectedIntent == null) return;
    final updated = await _captures.clarifyIntent(captureId, intent: selectedIntent);
    if (updated.state == 'awaiting_approval' && updated.proposal != null) {
      if (context.mounted) {
        await _handleProposal(context, captureId, updated.proposal!);
      }
    } else if (updated.state == 'question_answered' && updated.answer != null) {
      lastAnswer = updated.answer;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updated.answer!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    final recorder = _recorder;
    if (recorder is DeviceVoiceRecorder) {
      recorder.dispose();
    } else if (recorder is SimulatedVoiceRecorder) {
      recorder.dispose();
    }
    super.dispose();
  }
}

enum _CapturePresentation { voiceRoute, sheet }

class _EntityEquivalenceSheet extends StatelessWidget {
  const _EntityEquivalenceSheet({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0D1430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(prompt, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.captureEntityEquivalenceSamePerson),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.captureEntityEquivalenceDifferentPeople),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentClarificationSheet extends StatelessWidget {
  const _IntentClarificationSheet({required this.prompt});

  final String? prompt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0D1430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                prompt ?? l10n.captureIntentClarificationPrompt,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('question'),
                child: Text(l10n.captureIntentThisIsQuestion),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop('save'),
                child: Text(l10n.captureIntentSaveToMemory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// App-wide services for API access.
class MiraServices {
  MiraServices._({
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.googleSignInService,
    required this.onboardingRepository,
    required this.captureRepository,
    required this.dailyBriefRepository,
    required this.graphRepository,
    required this.settingsRepository,
    required this.appReleaseRepository,
    required this.captureFlow,
  });

  factory MiraServices.create() {
    final tokenStorage = TokenStorage();
    late AuthRepository authRepository;
    final apiClient = ApiClient(
      tokenStorage: tokenStorage,
      onRefresh: () => authRepository.refreshAccessToken(),
    );
    final googleSignInService = GoogleSignInService();
    authRepository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      googleSignInService: googleSignInService,
    );
    final onboardingRepository = OnboardingRepository(apiClient: apiClient);
    final captureRepository = CaptureRepository(apiClient: apiClient);
    final dailyBriefRepository = DailyBriefRepository(apiClient: apiClient);
    final graphRepository = GraphRepository(apiClient: apiClient);
    final settingsRepository = SettingsRepository(apiClient: apiClient);
    final appReleaseRepository = AppReleaseRepository(apiClient: apiClient);
    final captureFlow = CaptureFlowController(
      captureRepository: captureRepository,
    );
    return MiraServices._(
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: authRepository,
      googleSignInService: googleSignInService,
      onboardingRepository: onboardingRepository,
      captureRepository: captureRepository,
      dailyBriefRepository: dailyBriefRepository,
      graphRepository: graphRepository,
      settingsRepository: settingsRepository,
      appReleaseRepository: appReleaseRepository,
      captureFlow: captureFlow,
    );
  }

  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final GoogleSignInService googleSignInService;
  final OnboardingRepository onboardingRepository;
  final CaptureRepository captureRepository;
  final DailyBriefRepository dailyBriefRepository;
  final GraphRepository graphRepository;
  final SettingsRepository settingsRepository;
  final AppReleaseRepository appReleaseRepository;
  final CaptureFlowController captureFlow;
}
