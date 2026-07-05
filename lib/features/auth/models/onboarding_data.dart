/// In-memory onboarding answers collected across wizard steps.
class OnboardingData {
  const OnboardingData({
    this.displayName = '',
    this.role = '',
    this.gender = '',
    this.bio = '',
    this.focusAreas = const [],
    this.supportStyle = '',
    this.currentFocus = '',
    this.importantPeople = '',
    this.openLoops = '',
    this.dailyBriefEnabled = true,
    this.memoryInsightsEnabled = true,
    this.firstCaptureText = '',
    this.voiceIntroCompleted = false,
  });

  final String displayName;
  final String role;
  final String gender;
  final String bio;
  final List<String> focusAreas;
  final String supportStyle;
  final String currentFocus;
  final String importantPeople;
  final String openLoops;
  final bool dailyBriefEnabled;
  final bool memoryInsightsEnabled;
  final String firstCaptureText;
  final bool voiceIntroCompleted;

  OnboardingData copyWith({
    String? displayName,
    String? role,
    String? gender,
    String? bio,
    List<String>? focusAreas,
    String? supportStyle,
    String? currentFocus,
    String? importantPeople,
    String? openLoops,
    bool? dailyBriefEnabled,
    bool? memoryInsightsEnabled,
    String? firstCaptureText,
    bool? voiceIntroCompleted,
  }) {
    return OnboardingData(
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      focusAreas: focusAreas ?? this.focusAreas,
      supportStyle: supportStyle ?? this.supportStyle,
      currentFocus: currentFocus ?? this.currentFocus,
      importantPeople: importantPeople ?? this.importantPeople,
      openLoops: openLoops ?? this.openLoops,
      dailyBriefEnabled: dailyBriefEnabled ?? this.dailyBriefEnabled,
      memoryInsightsEnabled:
          memoryInsightsEnabled ?? this.memoryInsightsEnabled,
      firstCaptureText: firstCaptureText ?? this.firstCaptureText,
      voiceIntroCompleted: voiceIntroCompleted ?? this.voiceIntroCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'role': _blankToNull(role),
    'gender': _blankToNull(gender),
    'bio': _blankToNull(profileBio),
    'voice_intro_completed': voiceIntroCompleted,
  };

  String get profileBio {
    final lines = <String>[
      if (bio.trim().isNotEmpty) bio.trim(),
      if (focusAreas.isNotEmpty) 'Focus areas: ${focusAreas.join(', ')}',
      if (supportStyle.trim().isNotEmpty) 'Mira style: ${supportStyle.trim()}',
      if (currentFocus.trim().isNotEmpty)
        'Current focus: ${currentFocus.trim()}',
      if (importantPeople.trim().isNotEmpty)
        'Important people and projects: ${importantPeople.trim()}',
      if (openLoops.trim().isNotEmpty) 'Open loops: ${openLoops.trim()}',
      'Daily brief enabled: $dailyBriefEnabled',
      'Memory insights enabled: $memoryInsightsEnabled',
    ];
    final text = lines.join('\n');
    if (text.length <= 1900) return text;
    return text.substring(0, 1900).trim();
  }

  String get seedCaptureText {
    final lines = <String>[
      'Mira onboarding seed for ${displayName.trim()}:',
      if (role.trim().isNotEmpty) 'Role or life mode: ${role.trim()}.',
      if (gender.trim().isNotEmpty) 'Addressing preference: ${gender.trim()}.',
      if (focusAreas.isNotEmpty)
        'Things Mira should help track: ${focusAreas.join(', ')}.',
      if (supportStyle.trim().isNotEmpty)
        'Preferred support style: ${supportStyle.trim()}.',
      if (currentFocus.trim().isNotEmpty)
        'Current priority: ${currentFocus.trim()}.',
      if (importantPeople.trim().isNotEmpty)
        'People or projects to remember: ${importantPeople.trim()}.',
      if (openLoops.trim().isNotEmpty)
        'Open loops to keep in mind: ${openLoops.trim()}.',
    ];
    return lines.join('\n');
  }

  int get seedScore {
    var score = 0;
    if (displayName.trim().isNotEmpty) score++;
    if (role.trim().isNotEmpty) score++;
    if (focusAreas.length >= 2) score++;
    if (supportStyle.trim().isNotEmpty) score++;
    if (currentFocus.trim().isNotEmpty ||
        importantPeople.trim().isNotEmpty ||
        openLoops.trim().isNotEmpty) {
      score++;
    }
    return score;
  }

  bool get isComplete =>
      displayName.trim().isNotEmpty &&
      role.isNotEmpty &&
      focusAreas.length >= 2 &&
      supportStyle.isNotEmpty;

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
