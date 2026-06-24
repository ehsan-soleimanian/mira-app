import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/theme/app_colors.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.initialSettings});

  final UserSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MiraPageHeader(
              title: 'Notifications',
              onBack: () => Navigator.of(context).pop(initialSettings),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(48 * s, 4 * s, 48 * s, 48 * s),
                children: [
                  const _NotificationCard(date: 'Today'),
                  SizedBox(height: 16 * s),
                  const _NotificationCard(date: '2026,01,02'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28 * s, 24 * s, 28 * s, 28 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 22 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5D5D5D),
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 27 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2B2B2B),
                height: 1.35,
              ),
              children: const [
                TextSpan(text: '☀️ '),
                TextSpan(
                  text: 'Good morning. You have 3 things waiting for you today.',
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * s),
          Text(
            'Check your daily brief to see what matters today.',
            style: GoogleFonts.inter(
              fontSize: 25 * s,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
