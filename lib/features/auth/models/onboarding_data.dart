/// In-memory onboarding answers collected across wizard steps.
class OnboardingData {
  const OnboardingData({
    this.displayName = '',
    this.role = '',
    this.gender = '',
    this.bio = '',
    this.voiceIntroCompleted = false,
  });

  final String displayName;
  final String role;
  final String gender;
  final String bio;
  final bool voiceIntroCompleted;

  OnboardingData copyWith({
    String? displayName,
    String? role,
    String? gender,
    String? bio,
    bool? voiceIntroCompleted,
  }) {
    return OnboardingData(
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      voiceIntroCompleted: voiceIntroCompleted ?? this.voiceIntroCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'role': role,
    'gender': gender,
    'bio': bio,
    'voice_intro_completed': voiceIntroCompleted,
  };

  bool get isComplete =>
      displayName.trim().isNotEmpty &&
      role.isNotEmpty &&
      gender.isNotEmpty &&
      bio.trim().isNotEmpty;
}
