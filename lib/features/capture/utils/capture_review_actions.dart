import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';

/// Resolves the one primary review/commit action from the server contract.
CaptureAction? resolveReviewPrimaryAction({
  CaptureResultCard? resultCard,
  List<CaptureAction> availableActions = const [],
}) {
  final fromCard = resultCard?.primaryAction;
  if (fromCard != null && fromCard.id.isNotEmpty) return fromCard;
  for (final action in availableActions) {
    if (action.style == 'primary' || action.isApprove) return action;
  }
  return null;
}

/// At most two secondary suggestions; never invents action IDs.
List<CaptureAction> resolveReviewSecondaryActions({
  CaptureResultCard? resultCard,
  List<CaptureAction> availableActions = const [],
}) {
  final fromCard = resultCard?.secondaryActions ?? const <CaptureAction>[];
  if (fromCard.isNotEmpty) return fromCard.take(2).toList();

  final primaryId = resolveReviewPrimaryAction(
    resultCard: resultCard,
    availableActions: availableActions,
  )?.id;
  return availableActions
      .where((action) => action.id.isNotEmpty && action.id != primaryId)
      .where((action) => action.style != 'primary')
      .take(2)
      .toList();
}

String localizeCaptureActionLabel(CaptureAction action, AppLocalizations l10n) {
  switch (action.id) {
    case 'capture.approve':
    case 'content.create_or_update':
      return l10n.rdCaptureAddToMemory;
    case 'capture.dismiss':
      return l10n.rdCaptureDiscard;
    case 'communication.share':
      return l10n.rdCaptureActionShare;
    case 'automation.create':
      return l10n.rdCaptureActionAutomation;
    case 'capture.ask':
      return l10n.rdCaptureActionAsk;
    case 'source.open':
      return l10n.rdCaptureActionOpenSource;
    case 'content.complete':
      return l10n.rdCaptureActionComplete;
    case 'content.schedule':
      return l10n.rdCaptureActionCalendar;
    case 'graph.connect':
      return l10n.rdCaptureActionConnect;
    case 'memory.privacy':
      return l10n.rdCaptureActionPrivacy;
    case 'proposal.edit':
      return l10n.rdCaptureActionEdit;
    case 'proposal.convert':
      return l10n.rdCaptureActionConvert;
    default:
      final label = action.label.trim();
      return label.isEmpty ? action.id : label;
  }
}

String localizeCaptureActionSubtitle(
  CaptureAction action,
  AppLocalizations l10n,
) {
  if (action.isExternalSideEffect) {
    return l10n.rdCaptureActionExternalHint;
  }
  switch (action.id) {
    case 'capture.ask':
      return l10n.rdCaptureActionAskSub;
    case 'source.open':
      return l10n.rdCaptureActionOpenSourceSub;
    case 'content.complete':
      return l10n.rdCaptureActionCompleteSub;
    case 'content.schedule':
      return l10n.rdCaptureActionCalendarSub;
    case 'graph.connect':
      return l10n.rdCaptureActionConnectSub;
    case 'memory.privacy':
      return l10n.rdCaptureActionPrivacySub;
    case 'proposal.edit':
      return l10n.rdCaptureActionEditSub;
    case 'proposal.convert':
      return l10n.rdCaptureActionConvertSub;
    case 'automation.create':
      return l10n.rdCaptureActionAutomationSub;
    case 'communication.share':
      return l10n.rdCaptureActionShareSub;
    default:
      return l10n.rdCaptureActionLocalHint;
  }
}

String captureActionIconPath(String actionId) {
  switch (actionId) {
    case 'communication.share':
      return '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>';
    case 'automation.create':
      return '<path d="M12 2v4M12 18v4M4.9 4.9l2.8 2.8M16.3 16.3l2.8 2.8M2 12h4M18 12h4M4.9 19.1l2.8-2.8M16.3 7.7l2.8-2.8"/><circle cx="12" cy="12" r="3"/>';
    case 'capture.ask':
      return '<circle cx="12" cy="12" r="9"/><path d="M9.1 9a3 3 0 0 1 5.8 1c0 2-3 2.5-3 4M12 17h.01"/>';
    case 'source.open':
      return '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>';
    case 'content.complete':
      return '<path d="m5 12 5 5 9-11"/>';
    case 'content.schedule':
      return '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>';
    case 'graph.connect':
      return '<circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/>';
    case 'memory.privacy':
      return '<rect x="4" y="10" width="16" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>';
    case 'proposal.edit':
      return '<path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>';
    case 'capture.dismiss':
      return '<path d="M18 6 6 18M6 6l12 12"/>';
    default:
      return '<path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/>';
  }
}

String localizeExecutionStatus(
  CaptureExecutionRequest request,
  AppLocalizations l10n,
) {
  switch (request.status) {
    case 'DRAFT':
      return l10n.rdCaptureExecutionDraft;
    case 'VALIDATED':
      return l10n.rdCaptureExecutionValidated;
    case 'BLOCKED_CONFIGURATION':
      return l10n.rdCaptureExecutionBlocked;
    case 'EXECUTED':
    case 'SENT':
    case 'COMPLETED':
      return l10n.rdCaptureExecutionCompleted;
    default:
      return request.status;
  }
}

String localizeExecutionKind(
  CaptureExecutionRequest request,
  AppLocalizations l10n,
) {
  switch (request.kind) {
    case 'share':
      return l10n.rdCaptureActionShare;
    case 'automation':
      return l10n.rdCaptureActionAutomation;
    default:
      return request.kind;
  }
}

/// Honest body copy — confirmation is never proof an external action ran.
String localizeExecutionHonesty(
  CaptureExecutionRequest request,
  AppLocalizations l10n,
) {
  if (request.claimsExternalSuccess) {
    return l10n.rdCaptureExecutionCompletedHint;
  }
  if (request.isBlockedConfiguration) {
    return l10n.rdCaptureExecutionBlockedHint;
  }
  if (request.isValidated) {
    return l10n.rdCaptureExecutionValidatedHint;
  }
  return l10n.rdCaptureExecutionDraftHint;
}

bool captureActionNeedsTextInput(String actionId) =>
    actionId == 'capture.ask' ||
    actionId == 'proposal.edit' ||
    actionId == 'communication.share' ||
    actionId == 'automation.create';
