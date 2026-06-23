import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/theme/app_colors.dart';

/// Dialog when backend emits `time_clarification` SSE event.
class TimeClarificationSheet extends StatefulWidget {
  const TimeClarificationSheet({
    super.key,
    required this.prompt,
    required this.suggestion,
    required this.onConfirm,
    required this.onDismiss,
  });

  final String prompt;
  final String? suggestion;
  final Future<void> Function({required bool accepted, String? resolvedTime})
      onConfirm;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String prompt,
    required String? suggestion,
    required Future<void> Function({required bool accepted, String? resolvedTime})
        onConfirm,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TimeClarificationSheet(
        prompt: prompt,
        suggestion: suggestion,
        onConfirm: onConfirm,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<TimeClarificationSheet> createState() => _TimeClarificationSheetState();
}

class _TimeClarificationSheetState extends State<TimeClarificationSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.suggestion ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'Clarify time',
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.prompt,
            style: GoogleFonts.vazirmatn(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Resolved time',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDismiss();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onConfirm(
                      accepted: true,
                      resolvedTime: _controller.text.trim(),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
