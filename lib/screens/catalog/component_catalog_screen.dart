import 'package:flutter/material.dart';
import 'package:mira_app/components/components.dart';
import 'package:mira_app/screens/catalog/bottom_nav_preview_pane.dart';
import 'package:mira_app/screens/catalog/composer_preview_pane.dart';
import 'package:mira_app/screens/catalog/ear_nav_mic_button_preview_pane.dart';
import 'package:mira_app/screens/catalog/mira_input_preview_pane.dart';
import 'package:mira_app/screens/catalog/note_card_preview_pane.dart';
import 'package:mira_app/screens/catalog/mira_button_preview_pane.dart';
import 'package:mira_app/screens/catalog/stop_button_preview_pane.dart';
import 'package:mira_app/screens/catalog/neumorphic_icon_preview_pane.dart';
import 'package:mira_app/screens/catalog/tap_capture_workflow_preview_pane.dart';
import 'package:mira_app/screens/catalog/voice_recording_workflow_preview_pane.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/screens/daily_brief/daily_brief_screen.dart';
import 'package:mira_app/screens/home/home_screen.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Dev screen — preview Figma components (frame 742:12525) as they are built.
class ComponentCatalogScreen extends StatefulWidget {
  const ComponentCatalogScreen({super.key});

  @override
  State<ComponentCatalogScreen> createState() => _ComponentCatalogScreenState();
}

class _ComponentCatalogScreenState extends State<ComponentCatalogScreen> {
  bool _taskChecked = false;
  bool _noteExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mira Components'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const HomeScreen())),
            child: const Text('Home'),
          ),
        ],
      ),
      body: ListView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(MiraSpacing.md),
        children: [
          const _Section(
            title: 'Organisms / Bottom Nav',
            child: BottomNavPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Screens',
            child: Wrap(
              spacing: MiraSpacing.sm,
              runSpacing: MiraSpacing.sm,
              children: [
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                  ),
                  child: const Text('Home Screen'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DailyBriefScreen(),
                    ),
                  ),
                  child: const Text('Daily Brief'),
                ),
              ],
            ),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Atoms / MiraText',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                MiraText(
                  'How can I help you ?',
                  variant: MiraTextVariant.headline,
                ),
                SizedBox(height: MiraSpacing.sm),
                MiraText('Home', variant: MiraTextVariant.title),
                SizedBox(height: MiraSpacing.sm),
                MiraText(
                  'Speak, ask or share anything',
                  variant: MiraTextVariant.body,
                ),
                SizedBox(height: MiraSpacing.sm),
                MiraText('v1.0.0', variant: MiraTextVariant.caption),
              ],
            ),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Atoms / MiraSphere (692:4137)',
            child: Center(child: MiraSphere(size: 100)),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Molecules / HintBar (742:10883)',
            child: const HintBar(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Molecules / MiraInputField (742:11005 / 742:11091)',
            child: MiraInputPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Organisms / MiraComposerBar (742:11005)',
            child: ComposerPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Molecules / MiraButton (742:13615)',
            child: MiraButtonPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Molecules / MiraEarNavMicButton (741:4986-mic)',
            child: EarNavMicButtonPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Molecules / MiraStopButton (618:3447)',
            child: StopButtonPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Organisms / TapCaptureWorkflow (564:2520)',
            child: TapCaptureWorkflowPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Organisms / VoiceRecordingOverlay (long press)',
            child: VoiceRecordingWorkflowPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Molecules / NeumorphicIconButton',
            child: NeumorphicIconPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Molecules / SettingsButton (Neumorphic inset)',
            child: Align(
              alignment: Alignment.centerLeft,
              child: SettingsButton(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings tapped')),
                ),
              ),
            ),
          ),
          const SizedBox(height: MiraSpacing.md),
          const _Section(
            title: 'Organisms / NoteCard',
            child: NoteCardPreviewPane(),
          ),
          const SizedBox(height: MiraSpacing.md),
          _Section(
            title: 'Organisms / Brief Cards',
            child: Column(
              children: [
                TaskBriefCard(
                  task: BriefTask(
                    id: 'preview-task',
                    section: 'Today',
                    title: 'Product review with the team',
                    timeLabel: 'Today, 10 A.M',
                    isCompleted: _taskChecked,
                  ),
                  onCheckboxChanged: (v) => setState(() => _taskChecked = v),
                ),
                const SizedBox(height: MiraSpacing.sm),
                NoteBriefCard(
                  note: BriefNote(
                    id: 'preview-note',
                    section: 'Today',
                    title: 'Lorem ipsum dolor sit amet,',
                    preview: 'consectetur adipiscing elit, sed do',
                    fullText:
                        'consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    isExpanded: _noteExpanded,
                  ),
                  onMoreTap: () =>
                      setState(() => _noteExpanded = !_noteExpanded),
                ),
                const SizedBox(height: MiraSpacing.sm),
                ImageBriefCard(
                  item: const BriefImageItem(
                    id: 'preview-image',
                    section: 'Today',
                    title: 'Lorem ipsum dolor sit',
                    preview: 'consectetur adipiscing elit, sed do more',
                    imageAsset: 'assets/images/daily_brief/landscape_thumb.png',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MiraSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MiraSpacing.md),
          child,
        ],
      ),
    );
  }
}
