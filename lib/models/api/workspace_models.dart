class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.source,
    required this.extractionStatus,
    required this.createdAt,
    required this.updatedAt,
    this.contentText,
    this.storageKey,
    this.mimeType,
    this.sizeBytes,
    this.checksum,
    this.spaceIds = const [],
    this.tags = const [],
    this.metadata = const {},
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) => LibraryItem(
    id: json['id'] as String,
    type: json['type'] as String? ?? 'note',
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    contentText: json['contentText'] as String?,
    source: json['source'] as String? ?? 'manual',
    storageKey: json['storageKey'] as String?,
    mimeType: json['mimeType'] as String?,
    sizeBytes: json['sizeBytes'] as int?,
    checksum: json['checksum'] as String?,
    spaceIds: (json['spaceIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    tags: (json['tags'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    extractionStatus: json['extractionStatus'] as String? ?? 'ready',
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
  );

  final String id;
  final String type;
  final String title;
  final String summary;
  final String? contentText;
  final String source;
  final String? storageKey;
  final String? mimeType;
  final int? sizeBytes;
  final String? checksum;
  final List<String> spaceIds;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String extractionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SpaceDto {
  const SpaceDto({
    required this.id,
    required this.name,
    required this.description,
    required this.isSmart,
  });

  factory SpaceDto.fromJson(Map<String, dynamic> json) => SpaceDto(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isSmart: json['isSmart'] as bool? ?? false,
  );

  final String id;
  final String name;
  final String description;
  final bool isSmart;
}

class CanvasDto {
  const CanvasDto({
    required this.id,
    required this.title,
    this.nodes = const [],
    this.edges = const [],
    this.viewport = const {},
  });

  factory CanvasDto.fromJson(Map<String, dynamic> json) => CanvasDto(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    nodes: (json['nodes'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(),
    edges: (json['edges'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(),
    viewport: (json['viewport'] as Map<String, dynamic>?) ?? const {},
  );

  final String id;
  final String title;
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> edges;
  final Map<String, dynamic> viewport;
}

class AssistantResponse {
  const AssistantResponse({
    required this.answer,
    this.citations = const [],
    this.createdItem,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json) =>
      AssistantResponse(
        answer: json['answer'] as String? ?? '',
        citations: (json['citations'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(LibraryItem.fromJson)
            .toList(),
        createdItem: json['createdItem'] is Map<String, dynamic>
            ? LibraryItem.fromJson(json['createdItem'] as Map<String, dynamic>)
            : null,
      );

  final String answer;
  final List<LibraryItem> citations;
  final LibraryItem? createdItem;
}

class PublishLinkDto {
  const PublishLinkDto({
    required this.id,
    required this.token,
    required this.url,
    required this.viewCount,
  });

  factory PublishLinkDto.fromJson(Map<String, dynamic> json) => PublishLinkDto(
    id: json['id'] as String,
    token: json['token'] as String? ?? '',
    url: json['url'] as String? ?? '',
    viewCount: json['viewCount'] as int? ?? 0,
  );

  final String id;
  final String token;
  final String url;
  final int viewCount;
}

class PluginManifestDto {
  const PluginManifestDto({
    required this.id,
    required this.name,
    required this.enabled,
    required this.configured,
    required this.connected,
    this.capabilities = const [],
  });

  factory PluginManifestDto.fromJson(Map<String, dynamic> json) =>
      PluginManifestDto(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? false,
        configured: json['configured'] as bool? ?? false,
        connected: json['connected'] as bool? ?? false,
        capabilities: (json['capabilities'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  final String id;
  final String name;
  final bool enabled;
  final bool configured;
  final bool connected;
  final List<String> capabilities;
}
