import 'package:flutter/material.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';
import 'package:mira_app/features/capture/widgets/capture_chat_widgets.dart';

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
                if (title.isNotEmpty) ...[
                  CaptureMiraMessage(scale: s, text: title),
                  SizedBox(height: 16 * s),
                ],
                if (summary.isNotEmpty && summary != title) ...[
                  CaptureMiraMessage(scale: s, text: summary),
                  SizedBox(height: 20 * s),
                ],
                CaptureMiraMessage(
                  scale: s,
                  text:
                      "Save this to your memory. If this is wrong, tell me. I'll change it.",
                ),
              ],
            ),
          ),
          CaptureApprovalActions(
            scale: s,
            busy: busy,
            onSave: onSave,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}
