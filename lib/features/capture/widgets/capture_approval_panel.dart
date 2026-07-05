import 'package:flutter/material.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';
import 'package:mira_app/features/capture/widgets/capture_chat_widgets.dart';
import 'package:mira_app/l10n/app_localizations.dart';

/// Figma conversation approval — user bubble right, Mira plain left, Save / cancel.
class CaptureApprovalPanel extends StatelessWidget {
  const CaptureApprovalPanel({
    super.key,
    required this.scale,
    required this.proposal,
    required this.busy,
    required this.onSave,
    required this.onCancel,
    this.prompt,
  });

  final double scale;
  final Map<String, dynamic> proposal;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? prompt;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final display = resolveProposalDisplay(proposal);
    final title = display.title;
    final summary = display.summary;
    final l10n = AppLocalizations.of(context)!;
    final userLine = (prompt?.trim().isNotEmpty == true)
        ? prompt!.trim()
        : (summary.isNotEmpty ? summary : title);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        CaptureChatTokens.horizontalPadding * s,
        CaptureChatTokens.contentTopPadding * s,
        CaptureChatTokens.horizontalPadding * s,
        CaptureChatTokens.bottomPadding * s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CaptureConversationColumn(
              children: [
                if (userLine.isNotEmpty) ...[
                  CaptureUserBubble(scale: s, text: userLine),
                  SizedBox(height: 22 * s),
                ],
                CaptureDraftReview(
                  scale: s,
                  title: title,
                  summary: summary,
                  nodeType: display.nodeType,
                  label: l10n.captureApprovalDraftLabel,
                ),
                SizedBox(height: 18 * s),
                CaptureMiraMessage(
                  scale: s,
                  text: l10n.captureApprovalSavePrompt,
                ),
              ],
            ),
          ),
          CaptureApprovalActions(
            scale: s,
            busy: busy,
            onSave: onSave,
            onCancel: onCancel,
            saveLabel: l10n.captureApprovalSaveAction,
            cancelLabel: l10n.captureApprovalDismissAction,
          ),
        ],
      ),
    );
  }
}
