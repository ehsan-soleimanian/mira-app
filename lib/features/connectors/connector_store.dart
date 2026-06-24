import 'package:shared_preferences/shared_preferences.dart';

enum ConnectorId {
  gmail,
  googleCalendar,
  googleDrive,
  slack,
  notion,
  outlook,
}

class ConnectorInfo {
  const ConnectorInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final ConnectorId id;
  final String name;
  final String description;
  final String icon;
}

const kDefaultConnectors = <ConnectorInfo>[
  ConnectorInfo(
    id: ConnectorId.gmail,
    name: 'Gmail',
    description: 'Read and summarize email threads',
    icon: '📧',
  ),
  ConnectorInfo(
    id: ConnectorId.googleCalendar,
    name: 'Google Calendar',
    description: 'Sync events and reminders',
    icon: '📅',
  ),
  ConnectorInfo(
    id: ConnectorId.googleDrive,
    name: 'Google Drive',
    description: 'Access files and documents',
    icon: '📁',
  ),
  ConnectorInfo(
    id: ConnectorId.slack,
    name: 'Slack',
    description: 'Capture messages and tasks',
    icon: '💬',
  ),
  ConnectorInfo(
    id: ConnectorId.notion,
    name: 'Notion',
    description: 'Sync pages and databases',
    icon: '📝',
  ),
  ConnectorInfo(
    id: ConnectorId.outlook,
    name: 'Outlook',
    description: 'Email and calendar integration',
    icon: '📬',
  ),
];

/// Local persistence for connector on/off until backend API is available.
class ConnectorStore {
  ConnectorStore(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'connector_enabled_';

  static Future<ConnectorStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ConnectorStore(prefs);
  }

  bool isEnabled(ConnectorId id) =>
      _prefs.getBool('$_prefix${id.name}') ?? _defaultFor(id);

  Future<void> setEnabled(ConnectorId id, bool value) =>
      _prefs.setBool('$_prefix${id.name}', value);

  Future<Map<ConnectorId, bool>> loadAll() async {
    final map = <ConnectorId, bool>{};
    for (final c in kDefaultConnectors) {
      map[c.id] = isEnabled(c.id);
    }
    return map;
  }

  bool _defaultFor(ConnectorId id) {
    switch (id) {
      case ConnectorId.gmail:
      case ConnectorId.googleCalendar:
        return true;
      default:
        return false;
    }
  }
}
