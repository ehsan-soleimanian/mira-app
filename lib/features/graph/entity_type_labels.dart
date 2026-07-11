import 'package:mira_app/l10n/app_localizations.dart';

/// Localized label for Graph V2 entity types shown in memory detail and canvas.
String graphEntityTypeLabel(AppLocalizations l10n, String? entityType) {
  final normalized = (entityType ?? '').trim().toUpperCase().replaceAll(' ', '_');
  switch (normalized) {
    case 'PERSON':
      return l10n.graphEntityPerson;
    case 'ORGANIZATION':
    case 'COMPANY':
      return l10n.graphEntityOrganization;
    case 'PROJECT':
      return l10n.graphEntityProject;
    case 'PLACE':
      return l10n.graphEntityPlace;
    case 'ACTIVITY':
      return l10n.graphEntityActivity;
    case 'TOPIC':
      return l10n.graphEntityTopic;
    case 'DOCUMENT':
      return l10n.graphEntityDocument;
    case 'ASSET':
      return l10n.graphEntityAsset;
    default:
      final raw = entityType?.trim();
      if (raw != null && raw.isNotEmpty) return raw;
      return l10n.graphEntityUnknown;
  }
}
