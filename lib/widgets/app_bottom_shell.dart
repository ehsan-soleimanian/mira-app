import 'package:flutter/material.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/mira_bottom_nav.dart';
import 'package:mira_app/widgets/prompt_input_bar.dart';

/// Shared bottom shell — navbar or prompt input after mic short-tap.
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
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _openPromptInput() => setState(() => _showPromptInput = true);

  void _closePromptInput() {
    setState(() {
      _showPromptInput = false;
      _promptController.clear();
    });
  }

  void _submitPrompt(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent: $text'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _closePromptInput();
  }

  @override
  Widget build(BuildContext context) {
    if (_showPromptInput) {
      return PromptInputBar(
        controller: _promptController,
        onMicTap: _closePromptInput,
        onSubmitted: _submitPrompt,
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
