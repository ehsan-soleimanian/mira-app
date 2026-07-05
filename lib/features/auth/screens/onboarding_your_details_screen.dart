import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_sphere.dart';
import 'package:mira_app/components/molecules/mira_input_field.dart';
import 'package:mira_app/features/auth/models/onboarding_data.dart';
import 'package:mira_app/features/auth/widgets/auth_step_widgets.dart';
import 'package:mira_app/features/auth/widgets/onboarding_choice_chip.dart';
import 'package:mira_app/features/auth/widgets/onboarding_progress.dart';
import 'package:mira_app/theme/composer_tokens.dart';
import 'package:mira_app/theme/mira_spacing.dart';
import 'package:mira_app/theme/onboarding_tokens.dart';

/// Post-auth seed profile. Collects the least context Mira needs to feel useful.
class OnboardingYourDetailsScreen extends StatefulWidget {
  const OnboardingYourDetailsScreen({
    super.key,
    required this.onContinue,
    required this.initialData,
  });

  final ValueChanged<OnboardingData> onContinue;
  final OnboardingData initialData;

  @override
  State<OnboardingYourDetailsScreen> createState() =>
      _OnboardingYourDetailsScreenState();
}

class _OnboardingYourDetailsScreenState
    extends State<OnboardingYourDetailsScreen> {
  static const _stepCount = 4;
  static const _roles = [
    'Founder / CEO',
    'Product',
    'Engineer',
    'Designer',
    'Operations',
    'Student',
    'Creator',
    'Other',
  ];
  static const _focusAreas = [
    'People',
    'Projects',
    'Tasks',
    'Decisions',
    'Ideas',
    'Learning',
    'Health',
    'Emotions',
  ];
  static const _addressing = [
    'Use my name',
    'Warm and friendly',
    'Direct and concise',
    'Prefer not to say',
  ];
  static const _supportStyles = [
    'Brief summaries',
    'Daily coach',
    'Gentle reminders',
    'Challenge my thinking',
  ];

  late OnboardingData _data;
  late final PageController _pageController;
  late final TextEditingController _nameController;
  late final TextEditingController _currentFocusController;
  late final TextEditingController _importantPeopleController;
  late final TextEditingController _openLoopsController;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _pageController = PageController();
    _nameController = TextEditingController(text: _data.displayName.trim());
    _currentFocusController = TextEditingController(
      text: _data.currentFocus.trim(),
    );
    _importantPeopleController = TextEditingController(
      text: _data.importantPeople.trim(),
    );
    _openLoopsController = TextEditingController(text: _data.openLoops.trim());
    for (final controller in [
      _nameController,
      _currentFocusController,
      _importantPeopleController,
      _openLoopsController,
    ]) {
      controller.addListener(_syncTextFields);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _currentFocusController,
      _importantPeopleController,
      _openLoopsController,
    ]) {
      controller.removeListener(_syncTextFields);
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _syncTextFields() {
    final next = _data.copyWith(
      displayName: _nameController.text.trim(),
      currentFocus: _currentFocusController.text.trim(),
      importantPeople: _importantPeopleController.text.trim(),
      openLoops: _openLoopsController.text.trim(),
    );
    if (next.displayName != _data.displayName ||
        next.currentFocus != _data.currentFocus ||
        next.importantPeople != _data.importantPeople ||
        next.openLoops != _data.openLoops) {
      setState(() => _data = next);
    }
  }

  bool get _canContinue {
    return switch (_step) {
      0 => _data.displayName.trim().isNotEmpty && _data.role.isNotEmpty,
      1 => _data.focusAreas.length >= 2,
      2 => _data.supportStyle.isNotEmpty,
      _ => _data.isComplete,
    };
  }

  Future<void> _next() async {
    if (!_canContinue) return;
    _syncTextFields();
    if (_step == _stepCount - 1) {
      widget.onContinue(_data);
      return;
    }
    setState(() => _step++);
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _back() async {
    if (_step == 0) return;
    setState(() => _step--);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleFocus(String value) {
    final next = [..._data.focusAreas];
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    setState(() => _data = _data.copyWith(focusAreas: next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: OnboardingTokens.maxContentWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: _SeedHeader(
                    step: _step,
                    stepCount: _stepCount,
                    score: _data.seedScore,
                    onBack: _step == 0 ? null : _back,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdentityStep(),
                      _buildFocusStep(),
                      _buildStyleStep(),
                      _buildSeedStep(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: AuthCtaButton(
                    label: _step == _stepCount - 1
                        ? 'Create my memory seed'
                        : 'Continue',
                    enabled: _canContinue,
                    onPressed: _canContinue ? _next : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityStep() {
    return _SeedStepShell(
      eyebrow: 'Spark 1 of 4',
      title: 'Who is Mira meeting?',
      subtitle:
          'Start with the simple identity cues that make your second mind feel like it belongs to you.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldCaption('Display name'),
          MiraInputField(
            controller: _nameController,
            hintText: 'Sara',
            showMic: false,
            variant: MiraInputVariant.flat,
            height: 58,
            radius: ComposerTokens.flatFieldRadius,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canContinue) _next();
            },
          ),
          const SizedBox(height: 22),
          const _FieldCaption('What is your current mode?'),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final role in _roles)
                OnboardingChoiceChip(
                  label: role,
                  selected: _data.role == role,
                  onTap: () =>
                      setState(() => _data = _data.copyWith(role: role)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusStep() {
    return _SeedStepShell(
      eyebrow: 'Spark 2 of 4',
      title: 'What should Mira watch for?',
      subtitle:
          'Pick at least two lanes. These become the first hints for your graph, daily brief, and recall.',
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final area in _focusAreas)
                OnboardingChoiceChip(
                  label: area,
                  selected: _data.focusAreas.contains(area),
                  onTap: () => _toggleFocus(area),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _RewardCard(
            title: _data.focusAreas.length >= 2
                ? 'Context anchor unlocked'
                : 'Choose two to unlock the next spark',
            subtitle: '${_data.focusAreas.length}/2 memory lanes selected',
            active: _data.focusAreas.length >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleStep() {
    return _SeedStepShell(
      eyebrow: 'Spark 3 of 4',
      title: 'How should Mira help?',
      subtitle:
          'This is your preference layer: how Mira speaks, reminds, and reflects things back.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldCaption('Response style'),
          for (final style in _supportStyles) ...[
            _SelectionRow(
              label: style,
              selected: _data.supportStyle == style,
              onTap: () =>
                  setState(() => _data = _data.copyWith(supportStyle: style)),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          const _FieldCaption('Addressing preference'),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final option in _addressing)
                OnboardingChoiceChip(
                  label: option,
                  selected: _data.gender == option,
                  onTap: () =>
                      setState(() => _data = _data.copyWith(gender: option)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _ToggleRow(
            title: 'Daily brief',
            subtitle: 'Let Mira surface open loops and useful patterns.',
            value: _data.dailyBriefEnabled,
            onChanged: (value) => setState(
              () => _data = _data.copyWith(dailyBriefEnabled: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedStep() {
    return _SeedStepShell(
      eyebrow: 'Spark 4 of 4',
      title: 'Give Mira its first anchors',
      subtitle:
          'Short notes are enough. Mira will turn this into an editable first memory on the next screen.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldCaption('Current priority'),
          MiraInputField(
            controller: _currentFocusController,
            hintText: 'What are you focused on this week?',
            showMic: false,
            variant: MiraInputVariant.flat,
            height: 86,
            maxLines: 2,
            radius: ComposerTokens.flatFieldRadius,
          ),
          const SizedBox(height: 14),
          const _FieldCaption('People or projects to remember'),
          MiraInputField(
            controller: _importantPeopleController,
            hintText: 'Names, projects, clients, classes, teams...',
            showMic: false,
            variant: MiraInputVariant.flat,
            height: 86,
            maxLines: 2,
            radius: ComposerTokens.flatFieldRadius,
          ),
          const SizedBox(height: 14),
          const _FieldCaption('Open loops'),
          MiraInputField(
            controller: _openLoopsController,
            hintText: 'Decisions, follow-ups, habits, worries...',
            showMic: false,
            variant: MiraInputVariant.flat,
            height: 86,
            maxLines: 2,
            radius: ComposerTokens.flatFieldRadius,
          ),
          const SizedBox(height: 18),
          _RewardCard(
            title: 'Memory seed ready',
            subtitle:
                '${_data.seedScore}/5 sparks collected. You can edit the capture before saving.',
            active: _data.seedScore >= 4,
          ),
        ],
      ),
    );
  }
}

class _SeedHeader extends StatelessWidget {
  const _SeedHeader({
    required this.step,
    required this.stepCount,
    required this.score,
    required this.onBack,
  });

  final int step;
  final int stepCount;
  final int score;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: OnboardingTokens.headlineColor,
            tooltip: 'Back',
          ),
        ),
        Expanded(
          child: Column(
            children: [
              OnboardingProgress(currentStep: step, totalSteps: stepCount),
              const SizedBox(height: 8),
              Text(
                'Memory kit $score/5',
                style: const TextStyle(
                  color: OnboardingTokens.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${step + 1}/$stepCount',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: OnboardingTokens.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeedStepShell extends StatelessWidget {
  const _SeedStepShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: constraints.maxHeight < 680 ? 4 : 16),
                const Center(
                  child: MiraSphere(size: OnboardingTokens.smallSphereSize),
                ),
                const SizedBox(height: 22),
                Text(
                  eyebrow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: OnboardingTokens.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.headlineColor,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.42,
                    color: OnboardingTokens.subtitleColor,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 26),
                child,
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: OnboardingTokens.mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 58,
          decoration: ComposerTokens.raisedSurfaceDecoration(
            borderRadius: BorderRadius.circular(18),
            active: selected,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? OnboardingTokens.progressActive
                          : OnboardingTokens.headlineColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? OnboardingTokens.progressActive
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? OnboardingTokens.progressActive
                          : OnboardingTokens.chipBorder,
                      width: 1.4,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: ComposerTokens.raisedSurfaceDecoration(
        borderRadius: BorderRadius.circular(18),
        active: value,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: OnboardingTokens.headlineColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: OnboardingTokens.subtitleColor,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFF8F3) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? OnboardingTokens.success.withValues(alpha: 0.28)
              : OnboardingTokens.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: active
                  ? OnboardingTokens.success
                  : OnboardingTokens.progressInactive,
              shape: BoxShape.circle,
            ),
            child: Icon(
              active ? Icons.check_rounded : Icons.lock_open_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: MiraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: OnboardingTokens.headlineColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: OnboardingTokens.subtitleColor,
                    fontSize: 13,
                    height: 1.3,
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
