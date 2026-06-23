import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final title = proposal['title'] as String? ?? 'Memory';
    final summary = proposal['summary'] as String? ?? '';
    final nodeType = proposal['node_type'] as String? ?? 'Note';

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
            'Save to memory?',
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nodeType,
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              color: AppColors.hintText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onApprove();
                  },
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
