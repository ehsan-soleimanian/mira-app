class VoiceTranscriptResult {
  const VoiceTranscriptResult({required this.text, required this.source});

  final String text;
  final String source;
}

class CaptureResponse {
  const CaptureResponse({
    required this.captureId,
    required this.state,
    this.proposal,
    this.answer,
  });

  factory CaptureResponse.fromJson(Map<String, dynamic> json) =>
      CaptureResponse(
        captureId: json['capture_id'] as String,
        state: json['state'] as String,
        proposal: json['proposal'] as Map<String, dynamic>?,
        answer: json['answer'] as String?,
      );

  final String captureId;
  final String state;
  final Map<String, dynamic>? proposal;
  final String? answer;
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
