import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/core/notifications/notification_service.dart';
import 'package:mira_app/models/api/settings_models.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/page_header_tokens.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, required this.initialSettings});

  final UserSettings initialSettings;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _leadOptions = <Duration>[
    Duration.zero,
    Duration(minutes: 10),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  late UserSettings _settings = widget.initialSettings;
  NotificationScheduleSnapshot? _snapshot;
  bool _loading = true;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) unawaited(_loadSnapshot());
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await AppScope.servicesOf(
      context,
    ).notificationService.snapshot();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool enabled) async {
    final previous = _settings;
    final next = _settings.copyWith(notificationsEnabled: enabled);
    setState(() {
      _settings = next;
      _saving = true;
    });

    final services = AppScope.servicesOf(context);
    try {
      await services.notificationService.setNotificationsEnabled(enabled);
      final granted = enabled
          ? await services.notificationService.requestPermissions()
          : _snapshot?.permissionGranted ?? false;
      final saved = await services.settingsRepository.updateSettings(next);
      if (!mounted) return;
      final snapshot = await services.notificationService.snapshot();
      if (!mounted) return;
      setState(() {
        _settings = saved;
        _snapshot = NotificationScheduleSnapshot(
          notificationsEnabled: saved.notificationsEnabled,
          permissionGranted: granted || snapshot.permissionGranted,
          scheduledTaskIds: snapshot.scheduledTaskIds,
          leadTime: snapshot.leadTime,
        );
        _saving = false;
      });
    } catch (error) {
      await services.notificationService.setNotificationsEnabled(
        previous.notificationsEnabled,
      );
      if (!mounted) return;
      setState(() {
        _settings = previous;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification update failed: $error')),
      );
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _saving = true);
    final service = AppScope.servicesOf(context).notificationService;
    final granted = await service.requestPermissions();
    final snapshot = await service.snapshot();
    if (!mounted) return;
    setState(() {
      _snapshot = NotificationScheduleSnapshot(
        notificationsEnabled: snapshot.notificationsEnabled,
        permissionGranted: granted || snapshot.permissionGranted,
        scheduledTaskIds: snapshot.scheduledTaskIds,
        leadTime: snapshot.leadTime,
      );
      _saving = false;
    });
  }

  Future<void> _setLeadTime(Duration leadTime) async {
    setState(() => _saving = true);
    final service = AppScope.servicesOf(context).notificationService;
    await service.setReminderLeadTime(leadTime);
    final snapshot = await service.snapshot();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MiraPageHeader(
              title: 'Notifications',
              onBack: () => Navigator.of(context).pop(_settings),
              trailing: _saving
                  ? const SizedBox(
                      width: PageHeaderTokens.actionSize,
                      height: PageHeaderTokens.actionSize,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        48 * s,
                        4 * s,
                        48 * s,
                        48 * s,
                      ),
                      children: [
                        FigmaSettingsToggleCard(
                          icon: Icons.notifications_active_outlined,
                          title: 'Task reminders',
                          subtitle: _settings.notificationsEnabled
                              ? 'Mira can remind you when approved tasks have a deadline'
                              : 'Task and daily brief notifications are paused',
                          value: _settings.notificationsEnabled,
                          onChanged: _saving ? (_) {} : _setEnabled,
                        ),
                        SizedBox(height: 16 * s),
                        _StatusCard(
                          enabled: _settings.notificationsEnabled,
                          permissionGranted:
                              snapshot?.permissionGranted ?? false,
                          scheduledCount: snapshot?.scheduledCount ?? 0,
                          onRequestPermission: _saving
                              ? null
                              : _requestPermission,
                        ),
                        SizedBox(height: 16 * s),
                        _LeadTimeCard(
                          selected:
                              snapshot?.leadTime ??
                              NotificationService.defaultLeadTime,
                          options: _leadOptions,
                          disabled: !_settings.notificationsEnabled || _saving,
                          onSelected: _setLeadTime,
                        ),
                        SizedBox(height: 16 * s),
                        const _SummaryCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.enabled,
    required this.permissionGranted,
    required this.scheduledCount,
    required this.onRequestPermission,
  });

  final bool enabled;
  final bool permissionGranted;
  final int scheduledCount;
  final VoidCallback? onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    final statusTitle = !enabled
        ? 'Paused'
        : permissionGranted
        ? 'Ready on this device'
        : 'System permission needed';
    final statusBody = !enabled
        ? 'Mira will not schedule local reminders until notifications are turned on.'
        : permissionGranted
        ? '$scheduledCount task reminder${scheduledCount == 1 ? '' : 's'} scheduled from your current brief.'
        : 'Allow notifications once so Mira can schedule task reminders locally.';

    return FigmaSettingsCard(
      padding: figmaInsets(context, 22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FigmaSettingsPeachIcon(
                icon: permissionGranted
                    ? Icons.check_circle_outline_rounded
                    : Icons.notifications_paused_outlined,
              ),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: GoogleFonts.inter(
                        fontSize: 26 * s,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      statusBody,
                      style: GoogleFonts.inter(
                        fontSize: 20 * s,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (enabled && !permissionGranted) ...[
            SizedBox(height: 18 * s),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.notifications_none_rounded),
                label: const Text('Allow notifications'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.micBlueNav,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(52 * s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadTimeCard extends StatelessWidget {
  const _LeadTimeCard({
    required this.selected,
    required this.options,
    required this.disabled,
    required this.onSelected,
  });

  final Duration selected;
  final List<Duration> options;
  final bool disabled;
  final ValueChanged<Duration> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return FigmaSettingsCard(
      padding: figmaInsets(context, 22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remind me',
            style: GoogleFonts.inter(
              fontSize: 26 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Choose how early local task notifications should fire before the detected deadline.',
            style: GoogleFonts.inter(
              fontSize: 20 * s,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 18 * s),
          Wrap(
            spacing: 10 * s,
            runSpacing: 10 * s,
            children: [
              for (final option in options)
                _LeadTimeChip(
                  label: _leadTimeLabel(option),
                  selected: option == selected,
                  disabled: disabled,
                  onTap: () => onSelected(option),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _leadTimeLabel(Duration value) {
    if (value == Duration.zero) return 'At deadline';
    if (value.inMinutes < 60) return '${value.inMinutes} min before';
    return '1 hour before';
  }
}

class _LeadTimeChip extends StatelessWidget {
  const _LeadTimeChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    final foreground = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.micBlueNav : const Color(0xFFF4F5F7),
      borderRadius: BorderRadius.circular(8 * s),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(8 * s),
        child: Container(
          constraints: BoxConstraints(minHeight: 42 * s),
          padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 11 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(
              color: selected ? AppColors.micBlueNav : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: disabled ? AppColors.textHint : foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return FigmaSettingsCard(
      padding: figmaInsets(context, 22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How reminders work',
            style: GoogleFonts.inter(
              fontSize: 26 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14 * s),
          const _SummaryRow(
            icon: Icons.task_alt_rounded,
            title: 'Approved tasks',
            body:
                'Mira schedules reminders only for tasks that have a detected due date and are still open.',
          ),
          Divider(height: 26 * s, color: AppColors.border),
          const _SummaryRow(
            icon: Icons.phone_android_rounded,
            title: 'Local scheduling',
            body:
                'Notifications are scheduled on this device after Home or Daily Brief syncs your task list.',
          ),
          Divider(height: 26 * s, color: AppColors.border),
          const _SummaryRow(
            icon: Icons.cloud_queue_rounded,
            title: 'Push later',
            body:
                'Server push and multi-device delivery are separate backend work, not part of local reminders yet.',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24 * s, color: const Color(0xFF756A66)),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
