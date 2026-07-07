import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/features/capture/utils/proposal_display.dart';
import 'package:mira_app/features/capture/widgets/capture_chat_widgets.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Bottom sheet for approving a structured capture proposal.
class ApprovalSheet extends StatelessWidget {
  const ApprovalSheet({
    super.key,
    required this.proposal,
    required this.onApprove,
    required this.onDismiss,
  });

  final Map<String, dynamic> proposal;
  final VoidCallback onApprove;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> proposal,
    required VoidCallback onApprove,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ApprovalSheet(
        proposal: proposal,
        onApprove: onApprove,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = resolveProposalDisplay(proposal);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.captureApprovalReviewTitle,
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.captureApprovalSavePrompt,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          CaptureDraftReview(
            scale: 1,
            title: display.title,
            summary: display.summary,
            nodeType: display.nodeType,
            label: l10n.captureApprovalDraftLabel,
            sourceLabel: l10n.captureApprovalSourceLabel,
            memoryLabel: l10n.captureApprovalMemoryLabel,
            savedAsLabel: l10n.captureApprovalSavedAsLabel,
            emptySummaryLabel: l10n.captureApprovalEmptySummary,
            moreContextLabel: l10n.captureApprovalMoreContext,
            sourceTitle: display.sourceTitle,
            sourceType: display.sourceType,
            deadline: display.deadline,
            relatedLabels: display.relatedLabels,
            insightLabels: display.insightLabels,
            needsMoreContext: display.needsMoreContext,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss();
                  },
                  child: Text(l10n.captureApprovalDismissAction),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onApprove();
                  },
                  child: Text(l10n.captureApprovalSaveAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
