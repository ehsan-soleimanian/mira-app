enum MiraThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const MiraThemePreference(this.apiValue);

  final String apiValue;

  static MiraThemePreference fromApi(String? value) {
    return MiraThemePreference.values.firstWhere(
      (mode) => mode.apiValue == value,
      orElse: () => MiraThemePreference.system,
    );
  }
}

enum MiraLanguagePreference {
  english('en'),
  persian('fa');

  const MiraLanguagePreference(this.apiValue);

  final String apiValue;

  static MiraLanguagePreference fromApi(String? value) {
    return MiraLanguagePreference.values.firstWhere(
      (language) => language.apiValue == value,
      orElse: () => MiraLanguagePreference.english,
    );
  }
}

class UserSettings {
  const UserSettings({
    this.language = MiraLanguagePreference.english,
    this.theme = MiraThemePreference.system,
    this.notificationsEnabled = true,
    this.dailyBriefEnabled = true,
    this.memoryInsightsEnabled = true,
    this.analyticsEnabled = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    language: MiraLanguagePreference.fromApi(
      json['preferred_language'] as String?,
    ),
    theme: MiraThemePreference.fromApi(json['theme_mode'] as String?),
    notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    dailyBriefEnabled: json['daily_brief_enabled'] as bool? ?? true,
    memoryInsightsEnabled: json['memory_insights_enabled'] as bool? ?? true,
    analyticsEnabled: json['analytics_enabled'] as bool? ?? false,
  );

  final MiraLanguagePreference language;
  final MiraThemePreference theme;
  final bool notificationsEnabled;
  final bool dailyBriefEnabled;
  final bool memoryInsightsEnabled;
  final bool analyticsEnabled;

  Map<String, dynamic> toJson() => {
    'preferred_language': language.apiValue,
    'theme_mode': theme.apiValue,
    'notifications_enabled': notificationsEnabled,
    'daily_brief_enabled': dailyBriefEnabled,
    'memory_insights_enabled': memoryInsightsEnabled,
    'analytics_enabled': analyticsEnabled,
  };

  UserSettings copyWith({
    MiraLanguagePreference? language,
    MiraThemePreference? theme,
    bool? notificationsEnabled,
    bool? dailyBriefEnabled,
    bool? memoryInsightsEnabled,
    bool? analyticsEnabled,
  }) {
    return UserSettings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyBriefEnabled: dailyBriefEnabled ?? this.dailyBriefEnabled,
      memoryInsightsEnabled:
          memoryInsightsEnabled ?? this.memoryInsightsEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}
