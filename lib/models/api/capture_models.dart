class VoiceTranscriptResult {
  const VoiceTranscriptResult({required this.text, required this.source});

  final String text;
  final String source;
}

class RealtimeVoiceSession {
  const RealtimeVoiceSession({
    required this.sessionId,
    required this.eventsPath,
    required this.audioWsPath,
    required this.expiresAt,
    this.captureType = 'voice',
  });

  factory RealtimeVoiceSession.fromJson(Map<String, dynamic> json) =>
      RealtimeVoiceSession(
        sessionId: json['sessionId'] as String,
        eventsPath: json['eventsPath'] as String,
        audioWsPath: json['audioWsPath'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        captureType: json['captureType'] as String? ?? 'voice',
      );

  final String sessionId;
  final String eventsPath;
  final String audioWsPath;
  final DateTime expiresAt;
  final String captureType;

  bool get isLiveMeeting => captureType == 'live_meeting';
}

/// One evidence/source reference inside `capture_input.v1`.
class CaptureSourceInput {
  const CaptureSourceInput({
    required this.sourceId,
    required this.kind,
    this.libraryItemId,
    this.externalRef,
    this.mimeType,
    this.title,
    this.text,
    this.locator,
    this.metadata = const {},
    this.retention = 'transient',
  });

  factory CaptureSourceInput.fromJson(Map<String, dynamic> json) =>
      CaptureSourceInput(
        sourceId: json['sourceId']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'text',
        libraryItemId: json['libraryItemId']?.toString(),
        externalRef: json['externalRef']?.toString(),
        mimeType: json['mimeType']?.toString(),
        title: json['title']?.toString(),
        text: json['text']?.toString(),
        locator: json['locator'] is Map ? _map(json['locator']) : null,
        metadata: _map(json['metadata']),
        retention: json['retention']?.toString() ?? 'transient',
      );

  final String sourceId;
  final String kind;
  final String? libraryItemId;
  final String? externalRef;
  final String? mimeType;
  final String? title;
  final String? text;
  final Map<String, dynamic>? locator;
  final Map<String, dynamic> metadata;
  final String retention;

  Map<String, dynamic> toJson() => {
    'sourceId': sourceId,
    'kind': kind,
    if (libraryItemId != null) 'libraryItemId': libraryItemId,
    if (externalRef != null) 'externalRef': externalRef,
    if (mimeType != null) 'mimeType': mimeType,
    if (title != null) 'title': title,
    if (text != null) 'text': text,
    if (locator != null) 'locator': locator,
    if (metadata.isNotEmpty) 'metadata': metadata,
    'retention': retention,
  };
}

/// One typed component inside a `bundle` capture.
class CaptureComponentInput {
  const CaptureComponentInput({
    required this.componentId,
    required this.kind,
    this.text,
    this.url,
    this.data = const {},
    this.sources = const [],
  });

  factory CaptureComponentInput.fromJson(Map<String, dynamic> json) =>
      CaptureComponentInput(
        componentId: json['componentId']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'text',
        text: json['text']?.toString(),
        url: json['url']?.toString(),
        data: _map(json['data']),
        sources: _mapList(
          json['sources'],
        ).map(CaptureSourceInput.fromJson).toList(),
      );

  final String componentId;
  final String kind;
  final String? text;
  final String? url;
  final Map<String, dynamic> data;
  final List<CaptureSourceInput> sources;

  Map<String, dynamic> toJson() => {
    'componentId': componentId,
    'kind': kind,
    if (text != null) 'text': text,
    if (url != null) 'url': url,
    if (data.isNotEmpty) 'data': data,
    if (sources.isNotEmpty) 'sources': sources.map((s) => s.toJson()).toList(),
  };
}

/// Canonical `capture_input.v1` request body for `POST /captures`.
class CaptureInput {
  const CaptureInput({
    required this.type,
    this.text,
    this.url,
    this.data = const {},
    this.sources = const [],
    this.components = const [],
    this.channel = 'mobile',
  });

  final String type;
  final String? text;
  final String? url;
  final Map<String, dynamic> data;
  final List<CaptureSourceInput> sources;
  final List<CaptureComponentInput> components;
  final String channel;

  Map<String, dynamic> toJson({String? timezone, String? locale}) => {
    'type': type,
    if (text != null) 'text': text,
    if (url != null) 'url': url,
    if (data.isNotEmpty) 'data': data,
    if (sources.isNotEmpty) 'sources': sources.map((s) => s.toJson()).toList(),
    if (components.isNotEmpty)
      'components': components.map((c) => c.toJson()).toList(),
    'channel': channel,
    'timezone': ?timezone,
    'locale': ?locale,
  };
}

class CaptureProcessStep {
  const CaptureProcessStep({
    required this.step,
    required this.status,
    required this.processor,
    this.confidence,
    this.outputRefs = const [],
    this.warnings = const [],
  });

  factory CaptureProcessStep.fromJson(Map<String, dynamic> json) =>
      CaptureProcessStep(
        step: json['step']?.toString() ?? '',
        status: json['status']?.toString() ?? 'skipped',
        processor: json['processor']?.toString() ?? '',
        confidence: (json['confidence'] as num?)?.toDouble(),
        outputRefs: _stringList(json['outputRefs']),
        warnings: _stringList(json['warnings']),
      );

  final String step;
  final String status;
  final String processor;
  final double? confidence;
  final List<String> outputRefs;
  final List<String> warnings;
}

class CaptureProcessingReport {
  const CaptureProcessingReport({
    this.schemaVersion = 'capture_processing.v1',
    this.steps = const [],
  });

  factory CaptureProcessingReport.fromJson(Map<String, dynamic> json) =>
      CaptureProcessingReport(
        schemaVersion:
            json['schemaVersion']?.toString() ?? 'capture_processing.v1',
        steps: _mapList(json['steps']).map(CaptureProcessStep.fromJson).toList(),
      );

  final String schemaVersion;
  final List<CaptureProcessStep> steps;
}

class CaptureAction {
  const CaptureAction({
    required this.id,
    required this.label,
    required this.endpoint,
    this.style = 'secondary',
    this.method = 'POST',
    this.payload = const {},
    this.input,
    this.phase = 'review',
    this.sideEffect = 'none',
    this.requiresConfirmation = true,
    this.expectedGraphEffects = const [],
  });

  factory CaptureAction.fromJson(Map<String, dynamic> json) => CaptureAction(
    id: json['id']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    endpoint: json['endpoint']?.toString() ?? '',
    style: json['style']?.toString() ?? 'secondary',
    method: json['method']?.toString() ?? 'POST',
    payload: _map(json['payload']),
    input: json['input'] is Map ? _map(json['input']) : null,
    phase: json['phase']?.toString() ?? 'review',
    sideEffect:
        json['side_effect']?.toString() ??
        json['sideEffect']?.toString() ??
        'none',
    requiresConfirmation:
        json['requires_confirmation'] as bool? ??
        json['requiresConfirmation'] as bool? ??
        true,
    expectedGraphEffects: _stringList(json['expectedGraphEffects']),
  );

  final String id;
  final String label;
  final String endpoint;
  final String style;
  final String method;
  final Map<String, dynamic> payload;
  final Map<String, dynamic>? input;
  final String phase;
  final String sideEffect;
  final bool requiresConfirmation;
  final List<String> expectedGraphEffects;

  bool get isApprove =>
      id == 'capture.approve' || id == 'content.create_or_update';
  bool get isExternalSideEffect => sideEffect == 'external';
}

class CaptureConfidence {
  const CaptureConfidence({
    this.score = 0,
    this.level = 'low',
    this.requiresReview = true,
    this.reasons = const [],
  });

  factory CaptureConfidence.fromJson(Map<String, dynamic> json) =>
      CaptureConfidence(
        score: (json['score'] as num?)?.toDouble() ?? 0,
        level: json['level']?.toString() ?? 'low',
        requiresReview:
            json['requiresReview'] as bool? ??
            json['requires_review'] as bool? ??
            true,
        reasons: _stringList(json['reasons']),
      );

  final double score;
  final String level;
  final bool requiresReview;
  final List<String> reasons;
}

class CaptureDetectedItem {
  const CaptureDetectedItem({
    required this.id,
    required this.kind,
    this.role = 'derived',
    this.status = 'proposed',
    this.fields = const {},
    this.confidence = const CaptureConfidence(),
    this.fieldConfidence = const {},
    this.evidenceRefs = const [],
    this.availableActionIds = const [],
  });

  factory CaptureDetectedItem.fromJson(Map<String, dynamic> json) =>
      CaptureDetectedItem(
        id: json['id']?.toString() ?? '',
        kind: json['kind']?.toString() ?? 'note',
        role: json['role']?.toString() ?? 'derived',
        status: json['status']?.toString() ?? 'proposed',
        fields: _map(json['fields']),
        confidence: json['confidence'] is Map
            ? CaptureConfidence.fromJson(_map(json['confidence']))
            : const CaptureConfidence(),
        fieldConfidence: _doubleMap(json['fieldConfidence']),
        evidenceRefs: _stringList(json['evidenceRefs']),
        availableActionIds: _stringList(json['availableActionIds']),
      );

  final String id;
  final String kind;
  final String role;
  final String status;
  final Map<String, dynamic> fields;
  final CaptureConfidence confidence;
  final Map<String, double> fieldConfidence;
  final List<String> evidenceRefs;
  final List<String> availableActionIds;

  bool get isExcluded => status == 'excluded';
}

class CaptureResultCard {
  const CaptureResultCard({
    this.schemaVersion = 'capture_result.v1',
    required this.phase,
    this.interpretation = const {},
    this.extractedItems = const [],
    this.workLog = const [],
    this.plannedEffects = const [],
    this.committedEffects = const [],
    this.nextStep = const {},
    this.provenance = const {},
    this.memoryControls = const {},
  });

  factory CaptureResultCard.fromJson(Map<String, dynamic> json) =>
      CaptureResultCard(
        schemaVersion: json['schemaVersion']?.toString() ?? 'capture_result.v1',
        phase: json['phase']?.toString() ?? 'processing',
        interpretation: _map(json['interpretation']),
        extractedItems: _mapList(
          json['extractedItems'],
        ).map(CaptureDetectedItem.fromJson).toList(),
        workLog: _mapList(json['workLog']),
        plannedEffects: _mapList(json['plannedEffects']),
        committedEffects: _mapList(json['committedEffects']),
        nextStep: _map(json['nextStep']),
        provenance: _map(json['provenance']),
        memoryControls: _map(json['memoryControls']),
      );

  final String schemaVersion;
  final String phase;
  final Map<String, dynamic> interpretation;
  final List<CaptureDetectedItem> extractedItems;
  final List<Map<String, dynamic>> workLog;
  final List<Map<String, dynamic>> plannedEffects;
  final List<Map<String, dynamic>> committedEffects;
  final Map<String, dynamic> nextStep;
  final Map<String, dynamic> provenance;
  final Map<String, dynamic> memoryControls;

  CaptureAction? get primaryAction {
    final value = nextStep['primaryAction'];
    return value is Map ? CaptureAction.fromJson(_map(value)) : null;
  }

  List<CaptureAction> get secondaryActions => _mapList(
    nextStep['secondaryActions'],
  ).map(CaptureAction.fromJson).take(2).toList();
}

class PendingInteractionInput {
  const PendingInteractionInput({
    required this.field,
    required this.label,
    this.type = 'text',
    this.required = true,
  });

  factory PendingInteractionInput.fromJson(Map<String, dynamic> json) =>
      PendingInteractionInput(
        field: json['field']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        type: json['type']?.toString() ?? 'text',
        required: json['required'] as bool? ?? true,
      );

  final String field;
  final String label;
  final String type;
  final bool required;
}

/// Versioned next-action contract (`capture_interaction.v1`).
class PendingInteraction {
  const PendingInteraction({
    this.schemaVersion = 'capture_interaction.v1',
    required this.kind,
    required this.prompt,
    this.required = true,
    this.actions = const [],
    this.context = const {},
  });

  factory PendingInteraction.fromJson(Map<String, dynamic> json) =>
      PendingInteraction(
        schemaVersion:
            json['schema_version']?.toString() ??
            json['schemaVersion']?.toString() ??
            'capture_interaction.v1',
        kind: json['kind']?.toString() ?? '',
        prompt: json['prompt']?.toString() ?? '',
        required: json['required'] as bool? ?? true,
        actions: _mapList(json['actions']).map(CaptureAction.fromJson).toList(),
        context: _map(json['context']),
      );

  final String schemaVersion;
  final String kind;
  final String prompt;
  final bool required;
  final List<CaptureAction> actions;
  final Map<String, dynamic> context;
}

/// One typed mutation inside a review action request.
class ProposalMutationOperation {
  const ProposalMutationOperation({
    required this.op,
    this.itemId,
    this.sourceId,
    this.field,
    this.value,
    this.toKind,
    this.parts = const [],
  });

  final String op;
  final String? itemId;
  final String? sourceId;
  final String? field;
  final Object? value;
  final String? toKind;
  final List<Map<String, dynamic>> parts;

  Map<String, dynamic> toJson() => {
    'op': op,
    if (itemId != null) 'itemId': itemId,
    if (sourceId != null) 'sourceId': sourceId,
    if (field != null) 'field': field,
    if (value != null) 'value': value,
    if (toKind != null) 'toKind': toKind,
    if (parts.isNotEmpty) 'parts': parts,
  };
}

/// Body for `POST /captures/{id}/actions/{actionId}`.
class CaptureActionRequest {
  const CaptureActionRequest({
    this.proposalRevision = 0,
    this.idempotencyKey,
    this.input = const {},
    this.operations = const [],
  });

  final int proposalRevision;
  final String? idempotencyKey;
  final Map<String, dynamic> input;
  final List<ProposalMutationOperation> operations;

  Map<String, dynamic> toJson() => {
    'proposalRevision': proposalRevision,
    if (idempotencyKey != null && idempotencyKey!.isNotEmpty)
      'idempotencyKey': idempotencyKey,
    if (input.isNotEmpty) 'input': input,
    if (operations.isNotEmpty)
      'operations': operations.map((op) => op.toJson()).toList(),
  };
}

/// Normalized result of a server-owned capture action.
class CaptureActionOutcome {
  const CaptureActionOutcome({
    required this.raw,
    this.capture,
    this.receipt,
    this.answer,
    this.status,
    this.actionOutcome = const {},
  });

  factory CaptureActionOutcome.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion']?.toString();
    if (schema == 'capture_commit_receipt.v1' ||
        json.containsKey('ledgerEventId') ||
        json.containsKey('ledger_event_id')) {
      return CaptureActionOutcome(
        raw: json,
        receipt: CaptureCommitReceipt.fromJson(json),
      );
    }
    if (json.containsKey('capture_id') && json.containsKey('state')) {
      return CaptureActionOutcome(
        raw: json,
        capture: CaptureResponse.fromJson(json),
        actionOutcome: _map(json['actionOutcome']),
      );
    }
    return CaptureActionOutcome(
      raw: json,
      answer: json['answer']?.toString(),
      status: json['status']?.toString(),
      actionOutcome: _map(json['actionOutcome']),
    );
  }

  final Map<String, dynamic> raw;
  final CaptureResponse? capture;
  final CaptureCommitReceipt? receipt;
  final String? answer;
  final String? status;
  final Map<String, dynamic> actionOutcome;

  bool get isCommit => receipt != null;
  bool get memoryChanged => raw['memoryChanged'] as bool? ?? receipt != null;
  bool get awaitsExternalConfirmation =>
      actionOutcome['status']?.toString() == 'awaiting_external_confirmation';
}

class CaptureResponse {
  const CaptureResponse({
    required this.captureId,
    required this.state,
    this.captureType,
    this.proposal,
    this.answer,
    this.pendingInteraction,
    this.sourceMetadata = const {},
    this.inputManifest = const {},
    this.processingReport,
    this.resultCard,
    this.proposalRevision = 0,
    this.availableActions = const [],
    this.createdAt,
  });

  factory CaptureResponse.fromJson(Map<String, dynamic> json) =>
      CaptureResponse(
        captureId: json['capture_id'] as String,
        state: json['state'] as String,
        captureType: json['capture_type'] as String?,
        proposal: json['proposal'] as Map<String, dynamic>?,
        answer: json['answer'] as String?,
        pendingInteraction: json['pending_interaction'] is Map
            ? PendingInteraction.fromJson(_map(json['pending_interaction']))
            : null,
        sourceMetadata:
            (json['source_metadata'] as Map<String, dynamic>?) ?? const {},
        inputManifest: _map(json['input_manifest']),
        processingReport: json['processing_report'] is Map
            ? CaptureProcessingReport.fromJson(_map(json['processing_report']))
            : null,
        resultCard: json['result_card'] is Map
            ? CaptureResultCard.fromJson(_map(json['result_card']))
            : null,
        proposalRevision: json['proposal_revision'] as int? ?? 0,
        availableActions: _mapList(
          json['available_actions'],
        ).map(CaptureAction.fromJson).toList(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String).toLocal(),
      );

  final String captureId;
  final String state;
  final String? captureType;
  final Map<String, dynamic>? proposal;
  final String? answer;
  final PendingInteraction? pendingInteraction;
  final Map<String, dynamic> sourceMetadata;
  final Map<String, dynamic> inputManifest;
  final CaptureProcessingReport? processingReport;
  final CaptureResultCard? resultCard;
  final int proposalRevision;
  final List<CaptureAction> availableActions;
  final DateTime? createdAt;

  CaptureAction? get primaryAction => resultCard?.primaryAction;

  List<CaptureAction> get secondaryActions =>
      resultCard?.secondaryActions ?? const [];
}

class CaptureProjectionStatus {
  const CaptureProjectionStatus({
    required this.name,
    required this.status,
    this.error,
  });

  factory CaptureProjectionStatus.fromJson(Map<String, dynamic> json) =>
      CaptureProjectionStatus(
        name: json['name']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        error: json['error']?.toString(),
      );

  final String name;
  final String status;
  final String? error;
}

class CaptureCommitReceipt {
  const CaptureCommitReceipt({
    required this.captureId,
    required this.ledgerEventId,
    this.schemaVersion = 'capture_commit_receipt.v1',
    this.commitStatus = 'committed',
    this.projections = const [],
    this.committedEffects = const [],
    this.nextActions = const [],
    this.createdEntities = const [],
    this.createdAssertions = const [],
    this.materializedEdges = const [],
    this.tasks = const [],
    this.preferences = const [],
  });

  factory CaptureCommitReceipt.fromJson(Map<String, dynamic> json) =>
      CaptureCommitReceipt(
        schemaVersion:
            json['schemaVersion']?.toString() ?? 'capture_commit_receipt.v1',
        captureId:
            json['captureId']?.toString() ??
            json['capture_id']?.toString() ??
            '',
        ledgerEventId:
            json['ledgerEventId']?.toString() ??
            json['ledger_event_id']?.toString() ??
            '',
        commitStatus: json['commitStatus']?.toString() ?? 'committed',
        projections: _mapList(
          json['projections'],
        ).map(CaptureProjectionStatus.fromJson).toList(),
        committedEffects: _mapList(json['committedEffects']),
        nextActions: _mapList(json['nextActions']),
        createdEntities: _stringList(
          json['createdEntities'] ?? json['created_entities'],
        ),
        createdAssertions: _stringList(
          json['createdAssertions'] ?? json['created_assertions'],
        ),
        materializedEdges: _stringList(
          json['materializedEdges'] ?? json['materialized_edges'],
        ),
        tasks: _stringList(json['tasks']),
        preferences: _stringList(json['preferences']),
      );

  final String schemaVersion;
  final String captureId;
  final String ledgerEventId;
  final String commitStatus;
  final List<CaptureProjectionStatus> projections;
  final List<Map<String, dynamic>> committedEffects;
  final List<Map<String, dynamic>> nextActions;
  final List<String> createdEntities;
  final List<String> createdAssertions;
  final List<String> materializedEdges;
  final List<String> tasks;
  final List<String> preferences;

  String get projectionStatus {
    if (projections.any((item) => item.status == 'DEAD')) return 'DEAD';
    if (projections.any((item) => item.status == 'RETRY')) return 'RETRY';
    if (projections.any((item) => item.status == 'PROCESSING')) {
      return 'PROCESSING';
    }
    if (projections.any((item) => item.status == 'PENDING')) return 'PENDING';
    return 'APPLIED';
  }

  String? get projectionError => projections
      .where((item) => item.error != null && item.error!.isNotEmpty)
      .map((item) => item.error)
      .firstOrNull;

  bool get isProjected => projectionStatus == 'APPLIED';

  bool get isProjectionPending => const {
    'PENDING',
    'PROCESSING',
    'RETRY',
  }.contains(projectionStatus);

  String? get highlightEntityId =>
      createdEntities.isNotEmpty ? createdEntities.first : null;
}

class CaptureExecutionRequest {
  const CaptureExecutionRequest({
    required this.id,
    required this.captureId,
    required this.kind,
    required this.status,
    this.payload = const {},
    this.result = const {},
    this.executor,
    this.error,
    this.confirmedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory CaptureExecutionRequest.fromJson(Map<String, dynamic> json) =>
      CaptureExecutionRequest(
        id: json['id']?.toString() ?? '',
        captureId: json['captureId']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        status: json['status']?.toString() ?? 'DRAFT',
        payload: _map(json['payload']),
        result: _map(json['result']),
        executor: json['executor']?.toString(),
        error: json['error']?.toString(),
        confirmedAt: json['confirmedAt'] == null
            ? null
            : DateTime.tryParse(json['confirmedAt'].toString())?.toLocal(),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.tryParse(json['createdAt'].toString())?.toLocal(),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.tryParse(json['updatedAt'].toString())?.toLocal(),
      );

  final String id;
  final String captureId;
  final String kind;
  final String status;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> result;
  final String? executor;
  final String? error;
  final DateTime? confirmedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDraft => status == 'DRAFT';
  bool get isBlockedConfiguration => status == 'BLOCKED_CONFIGURATION';
  bool get isValidated => status == 'VALIDATED';

  /// Honest UX: confirmation is not proof an external action ran.
  bool get claimsExternalSuccess =>
      status == 'EXECUTED' || status == 'SENT' || status == 'COMPLETED';
}

class CaptureExecutionTestResult {
  const CaptureExecutionTestResult({
    required this.requestId,
    required this.status,
    this.sideEffectExecuted = false,
    this.sample = const {},
  });

  factory CaptureExecutionTestResult.fromJson(Map<String, dynamic> json) =>
      CaptureExecutionTestResult(
        requestId: json['requestId']?.toString() ?? '',
        status: json['status']?.toString() ?? 'VALIDATED',
        sideEffectExecuted: json['sideEffectExecuted'] as bool? ?? false,
        sample: _map(json['sample']),
      );

  final String requestId;
  final String status;
  final bool sideEffectExecuted;
  final Map<String, dynamic> sample;
}

class MemoryNodeResponse {
  const MemoryNodeResponse({
    required this.id,
    required this.captureId,
    required this.nodeType,
    required this.title,
    required this.summary,
  });

  factory MemoryNodeResponse.fromJson(Map<String, dynamic> json) =>
      MemoryNodeResponse(
        id: json['id'] as String,
        captureId: json['capture_id'] as String,
        nodeType: json['node_type'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
      );

  final String id;
  final String captureId;
  final String nodeType;
  final String title;
  final String summary;
}

class CaptureStreamEvent {
  const CaptureStreamEvent({required this.event, required this.data});

  final String event;
  final Map<String, dynamic> data;
}

/// Live-meeting marker payload for the realtime audio WebSocket.
Map<String, dynamic> liveMeetingMarker({
  required String kind,
  required int atMs,
  String? label,
}) {
  assert(
    kind == 'decision' || kind == 'action' || kind == 'important',
    'marker kind must be decision, action, or important',
  );
  return {
    'type': 'marker',
    'kind': kind,
    'atMs': atMs,
    if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
  };
}

Map<String, dynamic> _map(Object? value) => value is Map
    ? value.map((key, item) => MapEntry(key.toString(), item))
    : <String, dynamic>{};

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value.whereType<Map>().map(_map).toList()
    : <Map<String, dynamic>>[];

List<String> _stringList(Object? value) => value is List
    ? value.map((item) => item.toString()).toList()
    : <String>[];

Map<String, double> _doubleMap(Object? value) {
  if (value is! Map) return const {};
  final out = <String, double>{};
  value.forEach((key, item) {
    if (item is num) out[key.toString()] = item.toDouble();
  });
  return out;
}
