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

  String? get sourceUrl {
    final url = metadata['url'] ?? metadata['canonical_url'];
    return url is String && url.trim().isNotEmpty ? url.trim() : null;
  }

  Map<String, dynamic> get mediaMetadata {
    final media = metadata['media'];
    return media is Map<String, dynamic> ? media : const {};
  }

  String? get thumbnailUrl {
    final raw = mediaMetadata['thumbnail_url'] ?? metadata['thumbnail_url'];
    return raw is String && raw.trim().isNotEmpty ? raw.trim() : null;
  }

  bool get isMedia =>
      type == 'audio' ||
      type == 'video' ||
      type == 'image' ||
      source == 'import:youtube' ||
      source == 'import:tiktoks' ||
      source == 'import:reels';
}

class LibraryChunk {
  const LibraryChunk({
    required this.id,
    required this.itemId,
    required this.chunkType,
    required this.chunkIndex,
    required this.text,
    required this.createdAt,
    this.startMs,
    this.endMs,
    this.locator,
    this.metadata = const {},
  });

  factory LibraryChunk.fromJson(Map<String, dynamic> json) => LibraryChunk(
    id: json['id'] as String,
    itemId: json['itemId'] as String? ?? '',
    chunkType: json['chunkType'] as String? ?? 'text',
    chunkIndex: json['chunkIndex'] as int? ?? 0,
    text: json['text'] as String? ?? '',
    startMs: json['startMs'] as int?,
    endMs: json['endMs'] as int?,
    locator: json['locator'] as String?,
    metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final String id;
  final String itemId;
  final String chunkType;
  final int chunkIndex;
  final String text;
  final int? startMs;
  final int? endMs;
  final String? locator;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  bool get hasTimestamp => startMs != null || locator != null;
}

class ImportSourceDto {
  const ImportSourceDto({
    required this.id,
    required this.name,
    required this.category,
    required this.action,
    required this.status,
    required this.description,
    this.extensions = const [],
  });

  factory ImportSourceDto.fromJson(Map<String, dynamic> json) =>
      ImportSourceDto(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        action: json['action'] as String? ?? '',
        status: json['status'] as String? ?? '',
        description: json['description'] as String? ?? '',
        extensions: (json['extensions'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  final String id;
  final String name;
  final String category;
  final String action;
  final String status;
  final String description;
  final List<String> extensions;

  bool get isConnector => action == 'connect_provider';
  bool get isLink => action == 'paste_link';
  bool get isText =>
      action == 'upload_or_paste_text' || action == 'create_note';
  bool get isGuide => action == 'share_or_upload_export';
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
    this.createdAt,
    this.updatedAt,
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
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String).toLocal(),
  );

  final String id;
  final String title;
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> edges;
  final Map<String, dynamic> viewport;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    required this.authType,
    required this.category,
    required this.description,
    required this.implementationStatus,
    this.capabilities = const [],
    this.syncModes = const [],
    this.scopes = const [],
    this.lastSyncAt,
  });

  factory PluginManifestDto.fromJson(Map<String, dynamic> json) =>
      PluginManifestDto(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? false,
        configured: json['configured'] as bool? ?? false,
        connected: json['connected'] as bool? ?? false,
        authType: json['authType'] as String? ?? 'oauth2',
        category: json['category'] as String? ?? 'Connectors',
        description: json['description'] as String? ?? '',
        implementationStatus:
            json['implementationStatus'] as String? ?? 'manifest_ready',
        capabilities: (json['capabilities'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        syncModes: (json['syncModes'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        scopes: (json['scopes'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        lastSyncAt: json['lastSyncAt'] == null
            ? null
            : DateTime.parse(json['lastSyncAt'] as String).toLocal(),
      );

  final String id;
  final String name;
  final bool enabled;
  final bool configured;
  final bool connected;
  final String authType;
  final String category;
  final String description;
  final String implementationStatus;
  final List<String> capabilities;
  final List<String> syncModes;
  final List<String> scopes;
  final DateTime? lastSyncAt;

  bool get isNativeSync => implementationStatus == 'native_sync';
  bool get canRun => enabled;
}
