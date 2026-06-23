import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

/// User-confirmed link capture input (URL + optional note).
class CaptureLinkInput {
  const CaptureLinkInput({required this.url, this.note});

  final String url;
  final String? note;
}

/// Bottom sheet for submitting a link capture.
Future<CaptureLinkInput?> showCaptureLinkSheet(BuildContext context) {
  return showModalBottomSheet<CaptureLinkInput>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _CaptureLinkSheet(),
  );
}

class _CaptureLinkSheet extends StatefulWidget {
  const _CaptureLinkSheet();

  @override
  State<_CaptureLinkSheet> createState() => _CaptureLinkSheetState();
}

class _CaptureLinkSheetState extends State<_CaptureLinkSheet> {
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'لینک را وارد کنید.');
      return;
    }
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      CaptureLinkInput(url: url, note: note.isEmpty ? null : note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'افزودن لینک',
              style: AppTypography.dosis(
                size: 22,
                weight: FontWeight.w700,
                color: AppColors.headline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'https://example.com',
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'یادداشت (اختیاری)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.micBlueNav,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ارسال',
                style: AppTypography.vazirmatn(
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
