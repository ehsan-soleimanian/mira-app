import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_button.dart';
import 'package:mira_app/theme/app_typography.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';
import 'package:mira_app/theme/onboarding_welcome_tokens.dart';

/// Step 1 — splash / intro (Figma `724:4804`).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  static const _illustrationAsset =
      'assets/images/onboarding/welcome_illustration.png';

  @override
  Widget build(BuildContext context) {
    final scaler = FigmaScaler(MediaQuery.sizeOf(context).width);
    final s = scaler.scale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      // Welcome has no inputs — don't shrink when IME is visible.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = constraints.maxHeight < 520;
            final illustrationFlex = tight ? 52 : OnboardingWelcomeTokens.illustrationFlex;
            final panelFlex = tight ? 48 : OnboardingWelcomeTokens.panelFlex;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: illustrationFlex,
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          left: OnboardingWelcomeTokens.illustrationLeft * s,
                          top: OnboardingWelcomeTokens.illustrationTop * s,
                          width: OnboardingWelcomeTokens.illustrationWidth * s,
                          height:
                              OnboardingWelcomeTokens.illustrationArtHeight * s,
                          child: Image.asset(
                            _illustrationAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Positioned(
                          top: OnboardingWelcomeTokens.bubbleTextTop * s,
                          left:
                              OnboardingWelcomeTokens.bubbleTextHorizontal * s,
                          right:
                              OnboardingWelcomeTokens.bubbleTextHorizontal * s,
                          child: Text(
                            'Mira. Your second mind.',
                            textAlign: TextAlign.center,
                            style: AppTypography.dosis(
                              size: 16 * s,
                              weight: FontWeight.w700,
                              color: OnboardingTokens.headlineColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: panelFlex,
                  child: ColoredBox(
                    color: OnboardingTokens.background,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        OnboardingWelcomeTokens.panelHorizontal * s,
                        OnboardingWelcomeTokens.panelTopPadding * s,
                        OnboardingWelcomeTokens.panelHorizontal * s,
                        16 + bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Mira. Your second mind.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.dosis(
                                      size: (tight ? 24 : 30) * s,
                                      weight: FontWeight.w800,
                                      color: OnboardingTokens.headlineColor,
                                      height: 1.12,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        OnboardingWelcomeTokens.titleSubtitleGap *
                                        s,
                                  ),
                                  Text(
                                    "A second mind. For when you don't want to forget anything.",
                                    textAlign: TextAlign.center,
                                    style: AppTypography.vazirmatn(
                                      size: (tight ? 14 : 16) * s,
                                      color: OnboardingTokens.subtitleColor,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: tight ? 8 : 16),
                          MiraButton(
                            label: 'Next',
                            size: MiraButtonSize.large,
                            expand: true,
                            onPressed: onContinue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
