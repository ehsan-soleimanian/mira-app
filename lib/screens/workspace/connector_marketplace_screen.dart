import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/workspace_models.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/app_typography.dart';

class ConnectorMarketplaceScreen extends StatefulWidget {
  const ConnectorMarketplaceScreen({super.key});

  @override
  State<ConnectorMarketplaceScreen> createState() =>
      _ConnectorMarketplaceScreenState();
}

class _ConnectorMarketplaceScreenState
    extends State<ConnectorMarketplaceScreen> {
  var _plugins = const <PluginManifestDto>[];
  var _loading = true;
  var _syncingIds = <String>{};
  String? _selectedCategory;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plugins = await AppScope.servicesOf(
        context,
      ).pluginRepository.list();
      if (!mounted) return;
      setState(() {
        _plugins = plugins;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.connectorsLoadFailed;
      });
    }
  }

  Future<void> _connectAndSync(PluginManifestDto plugin) async {
    if (!plugin.canRun || _syncingIds.contains(plugin.id)) return;
    setState(() => _syncingIds = {..._syncingIds, plugin.id});
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = AppScope.servicesOf(context).pluginRepository;
      await repo.connect(plugin.id);
      await repo.sync(plugin.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectorsSyncSuccess(plugin.name))),
      );
      unawaited(_load());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.connectorsSyncFailed(plugin.name))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncingIds = {..._syncingIds}..remove(plugin.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _categoriesFor(_plugins);
    final visiblePlugins = _selectedCategory == null
        ? _plugins
        : _plugins
              .where((plugin) => plugin.category == _selectedCategory)
              .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
        children: [
          _ConnectorHeader(
            total: _plugins.length,
            connected: _plugins.where((plugin) => plugin.connected).length,
            nativeSync: _plugins.where((plugin) => plugin.isNativeSync).length,
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ConnectorMessage(
              icon: Icons.cloud_off_rounded,
              title: l10n.connectorsLoadFailed,
              body: l10n.connectorsPullToRetry,
            )
          else ...[
            _CategoryFilter(
              categories: categories,
              selectedCategory: _selectedCategory,
              onChanged: (category) =>
                  setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 14),
            for (final plugin in visiblePlugins)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ConnectorTile(
                  plugin: plugin,
                  syncing: _syncingIds.contains(plugin.id),
                  onPressed: () => _connectAndSync(plugin),
                ),
              ),
          ],
        ],
      ),
    );
  }

  List<String> _categoriesFor(List<PluginManifestDto> plugins) {
    final categories =
        plugins
            .map((plugin) => plugin.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }
}

class _ConnectorHeader extends StatelessWidget {
  const _ConnectorHeader({
    required this.total,
    required this.connected,
    required this.nativeSync,
  });

  final int total;
  final int connected;
  final int nativeSync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E7EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.extension_rounded,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.connectorsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 27,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.connectorsSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 14,
                      ).copyWith(color: AppColors.textSecondary, height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: l10n.connectorsAvailableMetric,
                  value: total.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  label: l10n.connectorsConnectedMetric,
                  value: connected.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  label: l10n.connectorsNativeMetric,
                  value: nativeSync.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.dosis(size: 18, weight: FontWeight.w700),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.dosis(
              size: 11,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          final selected = selectedCategory == category;
          return ChoiceChip(
            label: Text(category ?? l10n.connectorsAllFilter),
            selected: selected,
            onSelected: (_) => onChanged(category),
            showCheckmark: false,
            labelStyle: AppTypography.dosis(
              size: 13,
              weight: selected ? FontWeight.w700 : FontWeight.w500,
            ).copyWith(color: selected ? Colors.white : AppColors.textPrimary),
            selectedColor: AppColors.accent,
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected ? AppColors.accent : const Color(0xFFE1E4EE),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectorTile extends StatelessWidget {
  const _ConnectorTile({
    required this.plugin,
    required this.syncing,
    required this.onPressed,
  });

  final PluginManifestDto plugin;
  final bool syncing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _statusText(l10n);
    final statusColor = plugin.connected
        ? const Color(0xFF12805C)
        : plugin.isNativeSync
        ? AppColors.accent
        : const Color(0xFF8A5A00);
    final actionLabel = plugin.connected
        ? l10n.connectorsSyncAction
        : l10n.connectorsConnectAction;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: syncing ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7E7EF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConnectorIcon(pluginId: plugin.id, active: plugin.enabled),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plugin.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.dosis(
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusBadge(label: status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plugin.description.isEmpty
                          ? l10n.connectorsDefaultDescription
                          : plugin.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 13,
                      ).copyWith(color: AppColors.textSecondary, height: 1.25),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TinyChip(
                          icon: Icons.lock_open_rounded,
                          label: plugin.authType.toUpperCase(),
                        ),
                        if (plugin.syncModes.isNotEmpty)
                          _TinyChip(
                            icon: Icons.sync_rounded,
                            label: plugin.syncModes.join('/'),
                          ),
                        for (final capability
                            in plugin.capabilities.take(2).toList())
                          _TinyChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: capability.replaceAll('_', ' '),
                          ),
                      ],
                    ),
                    if (plugin.lastSyncAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.connectorsLastSync(
                          TimeOfDay.fromDateTime(
                            plugin.lastSyncAt!,
                          ).format(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(
                          size: 12,
                        ).copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 88,
                child: FilledButton(
                  onPressed: syncing ? null : onPressed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 38),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: syncing
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          actionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.dosis(
                            size: 13,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(AppLocalizations l10n) {
    if (plugin.connected) return l10n.connectorsConnectedStatus;
    if (plugin.isNativeSync) return l10n.connectorsNativeStatus;
    return l10n.connectorsAdapterReadyStatus;
  }
}

class _ConnectorIcon extends StatelessWidget {
  const _ConnectorIcon({required this.pluginId, required this.active});

  final String pluginId;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? _colorFor(pluginId) : Colors.grey;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(_iconFor(pluginId), color: color, size: 22),
    );
  }

  Color _colorFor(String id) {
    switch (id) {
      case 'gmail':
      case 'google_drive':
      case 'google_calendar':
        return AppColors.accent;
      case 'slack':
      case 'telegram':
      case 'whatsapp':
      case 'bale':
        return const Color(0xFF18A58A);
      case 'github':
      case 'linear':
      case 'jira':
        return const Color(0xFF1A1C29);
      case 'figma':
        return const Color(0xFFFF6B4A);
      case 'readwise':
      case 'zotero':
      case 'rss':
        return const Color(0xFF8A5A00);
      default:
        return const Color(0xFF5D6475);
    }
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'gmail':
      case 'email_to_mira':
        return Icons.mail_outline_rounded;
      case 'google_drive':
      case 'dropbox':
        return Icons.cloud_queue_rounded;
      case 'google_calendar':
        return Icons.calendar_today_rounded;
      case 'notion':
        return Icons.article_outlined;
      case 'slack':
      case 'telegram':
      case 'whatsapp':
      case 'bale':
        return Icons.forum_outlined;
      case 'github':
        return Icons.code_rounded;
      case 'rss':
        return Icons.rss_feed_rounded;
      case 'web_clipper':
        return Icons.content_cut_rounded;
      case 'figma':
        return Icons.design_services_outlined;
      case 'linear':
      case 'jira':
        return Icons.task_alt_rounded;
      case 'readwise':
        return Icons.menu_book_outlined;
      case 'zotero':
        return Icons.school_outlined;
      default:
        return Icons.extension_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTypography.dosis(
          size: 11,
          weight: FontWeight.w700,
        ).copyWith(color: color),
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  const _TinyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.dosis(
                size: 11,
              ).copyWith(color: AppColors.textSecondary, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorMessage extends StatelessWidget {
  const _ConnectorMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7EF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.dosis(size: 17, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTypography.dosis(
                    size: 13,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
