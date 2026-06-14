import 'package:flutter/material.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';
import 'package:mira_app/widgets/app_bottom_shell.dart';
import 'package:mira_app/widgets/daily_brief/brief_section_divider.dart';
import 'package:mira_app/widgets/daily_brief/daily_brief_header.dart';
import 'package:mira_app/widgets/daily_brief/image_brief_card.dart';
import 'package:mira_app/widgets/daily_brief/note_brief_card.dart';
import 'package:mira_app/widgets/daily_brief/task_brief_card.dart';

/// Daily Brief feed — Figma frames 564:2520 + card components.
class DailyBriefScreen extends StatefulWidget {
  const DailyBriefScreen({super.key});

  @override
  State<DailyBriefScreen> createState() => _DailyBriefScreenState();
}

class _DailyBriefScreenState extends State<DailyBriefScreen> {
  late List<BriefItem> _items;

  @override
  void initState() {
    super.initState();
    _items = DailyBriefData.initialItems();
  }

  void _toggleTask(String id, bool completed) {
    setState(() {
      _items = _items.map((item) {
        if (item is BriefTask && item.id == id) {
          return item.copyWith(isCompleted: completed);
        }
        return item;
      }).toList();
    });
  }

  void _toggleNoteExpand(String id) {
    setState(() {
      _items = _items.map((item) {
        if (item is BriefNote && item.id == id) {
          return item.copyWith(isExpanded: !item.isExpanded);
        }
        return item;
      }).toList();
    });
  }

  void _showItemSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<String> get _sections {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in _items) {
      if (seen.add(item.section)) ordered.add(item.section);
    }
    return ordered;
  }

  Widget _buildCard(BriefItem item) {
    return switch (item) {
      BriefTask task => TaskBriefCard(
          task: task,
          onCheckboxChanged: (v) => _toggleTask(task.id, v),
          onTap: () => _showItemSnackBar('Open task: ${task.title}'),
        ),
      BriefNote note => NoteBriefCard(
          note: note,
          onMoreTap: () => _toggleNoteExpand(note.id),
          onTap: () => _showItemSnackBar('Open note: ${note.title}'),
        ),
      BriefImageItem image => ImageBriefCard(
          item: image,
          onTap: () => _showItemSnackBar('Open image: ${image.title}'),
        ),
    };
  }

  List<Widget> _buildSectionChildren(String section) {
    final sectionItems = _items.where((i) => i.section == section).toList();
    return [
      BriefSectionDivider(label: section),
      const SizedBox(height: 14),
      for (var i = 0; i < sectionItems.length; i++) ...[
        _buildCard(sectionItems[i]),
        if (i < sectionItems.length - 1) const SizedBox(height: 10),
      ],
      const SizedBox(height: 24),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DailyBriefHeader(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  for (final section in _sections) ..._buildSectionChildren(section),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomShell(
        activeTab: NavTab.dailyBrief,
        onHomeTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}
