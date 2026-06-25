import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/features/capture/widgets/capture_chat_widgets.dart';

class IntentClarificationPanel extends StatelessWidget {
  const IntentClarificationPanel({
    super.key,
    required this.scale,
    required this.prompt,
    required this.busy,
    required this.onQuestion,
    required this.onSave,
  });

  final double scale;
  final String prompt;
  final bool busy;
  final VoidCallback onQuestion;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return CaptureConversationColumn(
      children: [
        CaptureMiraMessage(scale: scale, text: prompt),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38 * scale,
                child: ElevatedButton(
                  onPressed: busy ? null : onQuestion,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0B399D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    'این یک سوال است',
                    style: AppTypography.dosis(
                      size: 13 * scale,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: SizedBox(
                height: 38 * scale,
                child: OutlinedButton(
                  onPressed: busy ? null : onSave,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B399D),
                    side: const BorderSide(color: Color(0xFF0B399D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    'به حافظه ذخیره کن',
                    style: AppTypography.dosis(
                      size: 13 * scale,
                      weight: FontWeight.w600,
                      color: const Color(0xFF0B399D),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
