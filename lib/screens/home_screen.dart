import 'package:flutter/material.dart';
import 'package:mira_app/screens/daily_brief_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/widgets/app_bottom_shell.dart';
import 'package:mira_app/widgets/hint_bar.dart';
import 'package:mira_app/widgets/mira_sphere.dart';
import 'package:mira_app/widgets/settings_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDailyBrief(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyBriefScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sphereSize = MediaQuery.sizeOf(context).width * 0.40;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SettingsButton(
                  key: const Key('settings_button'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.04),
                    MiraSphere(size: sphereSize),
                    SizedBox(height: screenHeight * 0.045),
                    Text(
                      'How can I help you ?',
                      textAlign: TextAlign.center,
                      style: AppTypography.headline(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Speak,ask or share anythings',
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(context),
                    ),
                    const Spacer(),
                    const HintBar(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.home,
        onDailyBriefTap: () => _openDailyBrief(context),
      ),
    );
  }
}
