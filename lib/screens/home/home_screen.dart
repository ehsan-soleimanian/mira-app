import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/mira_nav_config.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_screen.dart';
import 'package:mira_app/components/atoms/mira_markdown_text.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/theme/home_screen_tokens.dart';

/// Home screen — Figma iPhone 16 - 150 (692:4127).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CaptureFlowController? _flow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = AppScope.servicesOf(context).captureFlow;
    if (!identical(next, _flow)) {
      _flow?.removeListener(_onFlowChanged);
      _flow = next;
      _flow!.addListener(_onFlowChanged);
    }
  }

  @override
  void dispose() {
    _flow?.removeListener(_onFlowChanged);
    super.dispose();
  }

  void _onFlowChanged() {
    if (mounted) setState(() {});
  }

  void _openDailyBrief(BuildContext context) {
    Navigator.of(context).pushMira((_) => const DailyBriefScreen());
  }

  @override
  Widget build(BuildContext context) {
    final flow = _flow!;
    final width = MediaQuery.sizeOf(context).width;
    final scaler = FigmaScaler(width);
    final s = scaler.scale;
    final answer = flow.lastAnswer;

    final tipBottom = MiraNavConfig.homeTipBottomInset(width);

    final showTip = flow.phase == CaptureUiPhase.idle;
    final processing = flow.isProcessing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            HomeHero(scale: s, processing: processing),
            if (answer != null && answer.isNotEmpty)
              Positioned(
                top: HomeScreenTokens.subtitleTop * s + 48 * s,
                left: 24 * s,
                right: 24 * s,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16 * s),
                  color: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.all(12 * s),
                    child: MiraMarkdownText(
                      data: answer,
                      scale: s,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            if (processing)
              Positioned(
                top: HomeScreenTokens.headlineTop * s - 8 * s,
                left: 0,
                right: 0,
                child: MiraThinkingLabel(
                  scale: s,
                  uploading: flow.phase == CaptureUiPhase.uploading,
                ),
              ),
            if (showTip)
              Positioned(
                bottom: tipBottom,
                left: 0,
                right: 0,
                child: HomeTipBar(scale: s),
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
