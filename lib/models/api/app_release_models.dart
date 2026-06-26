class AppReleaseInfo {
  const AppReleaseInfo({
    required this.versionName,
    required this.buildNumber,
    required this.minBuildNumber,
    required this.downloadUrl,
    required this.optional,
  });

  factory AppReleaseInfo.fromJson(Map<String, dynamic> json) {
    return AppReleaseInfo(
      versionName: json['versionName']?.toString() ?? '',
      buildNumber: _asInt(json['buildNumber']),
      minBuildNumber: _asInt(json['minBuildNumber']),
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      optional: json['optional'] as bool? ?? true,
    );
  }

  final String versionName;
  final int buildNumber;
  final int minBuildNumber;
  final String downloadUrl;
  final bool optional;

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
