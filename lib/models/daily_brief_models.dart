import 'package:mira_app/models/api/daily_update_models.dart';

enum BriefItemType { task, note, image }

/// Single item in the Daily Brief feed.
sealed class BriefItem {
  const BriefItem({required this.id, required this.section});

  final String id;
  final String section;
  BriefItemType get type;
}

class BriefTask extends BriefItem {
  const BriefTask({
    required super.id,
    required super.section,
    required this.title,
    required this.timeLabel,
    this.summary = '',
    this.nodeType = 'Task',
    this.createdAt,
    this.isCompleted = false,
  });

  final String title;
  final String timeLabel;
  final String summary;
  final String nodeType;
  final DateTime? createdAt;
  final bool isCompleted;

  @override
  BriefItemType get type => BriefItemType.task;

  BriefTask copyWith({bool? isCompleted}) => BriefTask(
    id: id,
    section: section,
    title: title,
    timeLabel: timeLabel,
    summary: summary,
    nodeType: nodeType,
    createdAt: createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class BriefNote extends BriefItem {
  const BriefNote({
    required super.id,
    required super.section,
    required this.title,
    required this.preview,
    required this.fullText,
    this.nodeType = 'Note',
    this.createdAt,
    this.isExpanded = false,
  });

  final String title;
  final String preview;
  final String fullText;
  final String nodeType;
  final DateTime? createdAt;
  final bool isExpanded;

  @override
  BriefItemType get type => BriefItemType.note;

  BriefNote copyWith({bool? isExpanded}) => BriefNote(
    id: id,
    section: section,
    title: title,
    preview: preview,
    fullText: fullText,
    nodeType: nodeType,
    createdAt: createdAt,
    isExpanded: isExpanded ?? this.isExpanded,
  );
}

class BriefImageItem extends BriefItem {
  const BriefImageItem({
    required super.id,
    required super.section,
    required this.title,
    required this.preview,
    this.imageAsset,
    this.thumbnailB64,
    this.nodeType = 'Image',
    this.createdAt,
  });

  final String title;
  final String preview;
  final String? imageAsset;
  final String? thumbnailB64;
  final String nodeType;
  final DateTime? createdAt;

  @override
  BriefItemType get type => BriefItemType.image;
}

/// Placeholder thumb for API-backed image memories (raw bytes are not stored).
const String kDailyBriefImagePlaceholderAsset =
    'assets/images/daily_brief/landscape_thumb.png';

/// Default feed mirroring Figma Daily Brief frames (564:2520).
abstract final class DailyBriefData {
  static const today = 'Today';
  static const yesterday = 'Yesterday';

  static List<BriefItem> fromDailyUpdateItems(List<DailyUpdateItem> items) =>
      items.map(_fromDailyUpdateItem).toList();

  static BriefItem _fromDailyUpdateItem(DailyUpdateItem item) {
    final nodeType = _normalizedNodeType(item.nodeType);
    final captureType = item.captureType?.trim().toLowerCase();
    final section = sectionFor(item.createdAt);
    final title = item.title.trim().isEmpty ? 'Untitled memory' : item.title;
    final summary = item.summary.trim().isEmpty ? title : item.summary;

    if (nodeType == 'Task' || nodeType == 'Reminder') {
      return BriefTask(
        id: item.id,
        section: section,
        title: title,
        timeLabel: timeLabelFor(item.createdAt),
        summary: summary,
        nodeType: nodeType,
        createdAt: item.createdAt,
      );
    }

    if (_isImageBriefItem(captureType, nodeType, summary)) {
      return BriefImageItem(
        id: item.id,
        section: section,
        title: title,
        preview: summary,
        thumbnailB64: item.thumbnailB64,
        imageAsset: item.thumbnailB64 == null
            ? kDailyBriefImagePlaceholderAsset
            : null,
        nodeType: 'Image',
        createdAt: item.createdAt,
      );
    }

    return BriefNote(
      id: item.id,
      section: section,
      title: title,
      preview: summary,
      fullText: summary,
      nodeType: nodeType,
      createdAt: item.createdAt,
    );
  }

  static bool _isImageBriefItem(
    String? captureType,
    String nodeType,
    String summary,
  ) {
    if (captureType == 'image') return true;
    if (nodeType != 'Resource') return false;
    return summary.toLowerCase().contains('image upload');
  }

  static String _normalizedNodeType(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Note';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  static String sectionFor(DateTime value) {
    final now = DateTime.now();
    final local = value.toLocal();
    final todayDate = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(local.year, local.month, local.day);
    final days = todayDate.difference(itemDate).inDays;
    if (days == 0) return today;
    if (days == 1) return yesterday;
    return '${_monthName(local.month)} ${local.day}';
  }

  static String timeLabelFor(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour;
    final suffix = hour >= 12 ? 'P.M' : 'A.M';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '${sectionFor(local)}, $displayHour:$minute $suffix';
  }

  static String dateLabelFor(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  static String _monthName(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  static List<BriefItem> initialItems() => [
    const BriefTask(
      id: 'task-today-1',
      section: today,
      title: 'Product review with the team',
      timeLabel: 'Today, 10 A.M',
    ),
    const BriefNote(
      id: 'note-today-1',
      section: today,
      title: 'Lorem ipsum dolor sit amet,',
      preview: 'consectetur adipiscing elit, sed do',
      fullText:
          'consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
    ),
    const BriefImageItem(
      id: 'image-today-1',
      section: today,
      title: 'Lorem ipsum dolor sit',
      preview: 'consectetur adipiscing elit, sed do more',
      imageAsset: kDailyBriefImagePlaceholderAsset,
    ),
    const BriefTask(
      id: 'task-yesterday-1',
      section: yesterday,
      title: 'Send weekly report',
      timeLabel: 'Yesterday, 4 P.M',
      isCompleted: true,
    ),
    const BriefNote(
      id: 'note-yesterday-1',
      section: yesterday,
      title: 'Meeting notes from design sync',
      preview: 'Discussed nav bar cradle and mic states',
      fullText:
          'Discussed nav bar cradle and mic states. Action items: rebuild checkbox component, wire prompt input bar, export SVG icons from Figma.',
    ),
  ];
}
