import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_app/features/capture/utils/capture_review_actions.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/capture_models.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('resolves primary and at most two secondary server actions', () {
    final card = CaptureResultCard(
      phase: 'review',
      nextStep: {
        'primaryAction': {
          'id': 'capture.approve',
          'label': 'Approve and commit',
          'endpoint': '/captures/x/actions/capture.approve',
          'style': 'primary',
        },
        'secondaryActions': [
          {
            'id': 'communication.share',
            'label': 'Prepare share',
            'endpoint': '/captures/x/actions/communication.share',
            'sideEffect': 'external',
          },
          {
            'id': 'capture.ask',
            'label': 'Ask Mira',
            'endpoint': '/captures/x/actions/capture.ask',
          },
          {
            'id': 'extra',
            'label': 'Extra',
            'endpoint': '/captures/x/actions/extra',
          },
        ],
      },
    );

    expect(resolveReviewPrimaryAction(resultCard: card)?.id, 'capture.approve');
    expect(resolveReviewSecondaryActions(resultCard: card).map((a) => a.id), [
      'communication.share',
      'capture.ask',
    ]);
  });

  test('falls back to availableActions when nextStep is empty', () {
    final actions = [
      CaptureAction(
        id: 'capture.approve',
        label: 'Approve',
        endpoint: '/a',
        style: 'primary',
      ),
      CaptureAction(id: 'proposal.edit', label: 'Edit', endpoint: '/b'),
      CaptureAction(id: 'source.open', label: 'Open', endpoint: '/c'),
    ];

    expect(
      resolveReviewPrimaryAction(availableActions: actions)?.id,
      'capture.approve',
    );
    expect(
      resolveReviewSecondaryActions(availableActions: actions).map((a) => a.id),
      ['proposal.edit', 'source.open'],
    );
  });

  test('localizes known actions and keeps honest external copy', () {
    const share = CaptureAction(
      id: 'communication.share',
      label: 'Prepare share or response',
      endpoint: '/x',
      sideEffect: 'external',
    );
    expect(localizeCaptureActionLabel(share, l10n), l10n.rdCaptureActionShare);
    expect(
      localizeCaptureActionSubtitle(share, l10n),
      l10n.rdCaptureActionExternalHint,
    );
    const schedule = CaptureAction(
      id: 'content.schedule',
      label: 'Schedule',
      endpoint: '/schedule',
    );
    expect(
      localizeCaptureActionLabel(schedule, l10n),
      l10n.rdCaptureActionCalendar,
    );
    expect(
      localizeCaptureActionSubtitle(schedule, l10n),
      l10n.rdCaptureActionCalendarSub,
    );
  });

  test('execution honesty never claims send for blocked configuration', () {
    const blocked = CaptureExecutionRequest(
      id: '1',
      captureId: 'c',
      kind: 'share',
      status: 'BLOCKED_CONFIGURATION',
      error: 'No share executor is configured',
    );
    expect(blocked.claimsExternalSuccess, isFalse);
    expect(
      localizeExecutionStatus(blocked, l10n),
      l10n.rdCaptureExecutionBlocked,
    );
    expect(
      localizeExecutionHonesty(blocked, l10n),
      l10n.rdCaptureExecutionBlockedHint,
    );
  });
}
