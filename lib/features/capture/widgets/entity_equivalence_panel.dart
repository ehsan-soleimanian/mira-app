import 'package:flutter/material.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/features/capture/widgets/capture_chat_widgets.dart';

class EntityEquivalencePanel extends StatelessWidget {
  const EntityEquivalencePanel({
    super.key,
    required this.scale,
    required this.prompt,
    required this.busy,
    required this.onSamePerson,
    required this.onDifferentPeople,
  });

  final double scale;
  final String prompt;
  final bool busy;
  final VoidCallback onSamePerson;
  final VoidCallback onDifferentPeople;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  onPressed: busy ? null : onSamePerson,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0B399D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    l10n.captureEntityEquivalenceSamePerson,
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
                  onPressed: busy ? null : onDifferentPeople,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B399D),
                    side: const BorderSide(color: Color(0xFF0B399D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                  ),
                  child: Text(
                    l10n.captureEntityEquivalenceDifferentPeople,
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
