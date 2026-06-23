import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/core/mira_nav_config.dart';
import 'package:mira_app/features/capture/capture_flow_controller.dart';
import 'package:mira_app/features/capture/capture_ui_phase.dart';
import 'package:mira_app/features/capture/capture_workflow_initial_action.dart';
import 'package:mira_app/features/capture/screens/capture_workflow_screen.dart';
import 'package:mira_app/features/capture/widgets/capture_bubble_menu.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_screen.dart';
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DailyBriefScreen()));
  }

  void _openCaptureWorkflow(CaptureWorkflowInitialAction? action) {
    _flow?.hideBubbleMenu();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaptureWorkflowScreen(initialAction: action),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = _flow!;
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scaler = FigmaScaler(width);
    final s = scaler.scale;
    final answer = flow.lastAnswer;

    final navHeight = MiraNavConfig.barHeightForWidth(width);
    final tipBottom =
        bottomInset + navHeight + HomeScreenTokens.tipGapAboveNav * s;
    final overlayBottom = bottomInset + navHeight + 24 * s;

    final showTip =
        flow.phase == CaptureUiPhase.idle ||
        flow.phase == CaptureUiPhase.bubbleMenu;
    final showBubble = flow.phase == CaptureUiPhase.bubbleMenu;
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
                    child: Text(answer, style: TextStyle(fontSize: 14 * s)),
                  ),
                ),
              ),
            if (processing)
              Positioned(
                top: HomeScreenTokens.headlineTop * s - 8 * s,
                left: 0,
                right: 0,
                child: Text(
                  flow.phase == CaptureUiPhase.uploading
                      ? 'Uploading voice…'
                      : 'Thinking…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.micBlueNav,
                  ),
                ),
              ),
            if (showTip)
              Positioned(
                bottom: tipBottom,
                left: 0,
                right: 0,
                child: HomeTipBar(scale: s),
              ),
            if (showBubble)
              Positioned(
                bottom: overlayBottom + 56 * s,
                left: 16 * s,
                right: 16 * s,
                child: CaptureBubbleMenu(
                  onTextTap: () => flow.openTextPrompt(),
                  onLinkTap: () =>
                      _openCaptureWorkflow(CaptureWorkflowInitialAction.link),
                  onImageTap: () => _openCaptureWorkflow(
                    CaptureWorkflowInitialAction.attachMenu,
                  ),
                  onDismiss: () => flow.hideBubbleMenu(),
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
