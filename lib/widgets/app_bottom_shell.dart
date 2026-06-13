import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/mira_bottom_nav.dart';
import 'package:mira_app/widgets/prompt_input_bar.dart';

/// پوسته مشترک bottom bar (navbar / prompt input)
class AppBottomShell extends StatefulWidget {
  const AppBottomShell({
    super.key,
    required this.activeTab,
    this.onHomeTap,
    this.onDailyBriefTap,
  });

  final NavTab activeTab;
  final VoidCallback? onHomeTap;
  final VoidCallback? onDailyBriefTap;

  @override
  State<AppBottomShell> createState() => _AppBottomShellState();
}

class _AppBottomShellState extends State<AppBottomShell> {
  bool _showPromptInput = false;

  void _openPromptInput() => setState(() => _showPromptInput = true);

  void _closePromptInput() => setState(() => _showPromptInput = false);

  @override
  Widget build(BuildContext context) {
    if (_showPromptInput) {
      return PromptInputBar(
        onAddTap: () {},
        onFieldTap: () {},
        onMicTap: _closePromptInput,
      );
    }

    return MiraBottomNav(
      activeTab: widget.activeTab,
      onHomeTap: widget.onHomeTap,
      onVoiceShortTap: _openPromptInput,
      onDailyBriefTap: widget.onDailyBriefTap,
    );
  }
}
