enum BriefItemType { task, note, image }

/// Single item in the Daily Brief feed.
sealed class BriefItem {
  const BriefItem({
    required this.id,
    required this.section,
  });

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
    this.isCompleted = false,
  });

  final String title;
  final String timeLabel;
  final bool isCompleted;

  @override
  BriefItemType get type => BriefItemType.task;

  BriefTask copyWith({bool? isCompleted}) => BriefTask(
        id: id,
        section: section,
        title: title,
        timeLabel: timeLabel,
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
    this.isExpanded = false,
  });

  final String title;
  final String preview;
  final String fullText;
  final bool isExpanded;

  @override
  BriefItemType get type => BriefItemType.note;

  BriefNote copyWith({bool? isExpanded}) => BriefNote(
        id: id,
        section: section,
        title: title,
        preview: preview,
        fullText: fullText,
        isExpanded: isExpanded ?? this.isExpanded,
      );
}

class BriefImageItem extends BriefItem {
  const BriefImageItem({
    required super.id,
    required super.section,
    required this.title,
    required this.preview,
    required this.imageAsset,
  });

  final String title;
  final String preview;
  final String imageAsset;

  @override
  BriefItemType get type => BriefItemType.image;
}

/// Default feed mirroring Figma Daily Brief frames (564:2520).
abstract final class DailyBriefData {
  static const today = 'Today';
  static const yesterday = 'Yesterday';

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
          imageAsset: 'assets/images/daily_brief/landscape_thumb.png',
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
