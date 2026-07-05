import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/organisms/task_brief_card.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class TasksBriefScreen extends StatefulWidget {
  const TasksBriefScreen({super.key});

  @override
  State<TasksBriefScreen> createState() => _TasksBriefScreenState();
}

class _TasksBriefScreenState extends State<TasksBriefScreen> {
  var _items = const <BriefItem>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await AppScope.servicesOf(
      context,
    ).dailyBriefRepository.fetchDailyUpdate();
    if (!mounted) return;
    setState(() {
      _items = DailyBriefData.fromDailyUpdateItems(response.items);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _items.whereType<BriefTask>().toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
        children: [
          Text(
            'Brief & Tasks',
            style: AppTypography.dosis(size: 28, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'No open tasks yet. Mira will place reminders and extracted tasks here.',
                style: AppTypography.dosis(
                  size: 15,
                ).copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            for (final task in tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskBriefCard(task: task),
              ),
        ],
      ),
    );
  }
}
