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

  void _showUsage(PluginManifestDto plugin) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ConnectorPlannedSheet(plugin: plugin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
            children: [
              Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      l10n.connectorsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dosis(
                        size: 30,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.connectorsSubtitle,
                style: AppTypography.dosis(
                  size: 15,
                ).copyWith(color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 18),
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
              else
                _ConnectorList(
                  plugins: _plugins,
                  syncingIds: _syncingIds,
                  onNativeSync: (plugin) => unawaited(_connectAndSync(plugin)),
                  onUsage: _showUsage,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectorList extends StatelessWidget {
  const _ConnectorList({
    required this.plugins,
    required this.syncingIds,
    required this.onNativeSync,
    required this.onUsage,
  });

  final List<PluginManifestDto> plugins;
  final Set<String> syncingIds;
  final ValueChanged<PluginManifestDto> onNativeSync;
  final ValueChanged<PluginManifestDto> onUsage;

  @override
  Widget build(BuildContext context) {
    final google = plugins.where((plugin) => plugin.isNativeSync).toList();
    final adapters = plugins.where((plugin) => !plugin.isNativeSync).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (google.isNotEmpty) ...[
          _SectionLabel(
            label: AppLocalizations.of(context)!.connectorsNativeGroup,
          ),
          for (final plugin in google)
            _ConnectorRow(
              plugin: plugin,
              syncing: syncingIds.contains(plugin.id),
              onTap: () => onNativeSync(plugin),
            ),
        ],
        if (adapters.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionLabel(
            label: AppLocalizations.of(context)!.connectorsAdapterGroup,
          ),
          for (final plugin in adapters)
            _ConnectorRow(
              plugin: plugin,
              syncing: false,
              onTap: () => onUsage(plugin),
            ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTypography.dosis(
          size: 13,
          weight: FontWeight.w700,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ConnectorRow extends StatelessWidget {
  const _ConnectorRow({
    required this.plugin,
    required this.syncing,
    required this.onTap,
  });

  final PluginManifestDto plugin;
  final bool syncing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actionLabel = plugin.isNativeSync
        ? plugin.connected
              ? l10n.connectorsSyncAction
              : l10n.connectorsConnectAction
        : 'Details';
    final statusLabel = plugin.isNativeSync
        ? plugin.connected
              ? l10n.connectorsConnectedStatus
              : l10n.connectorsNativeStatus
        : 'Planned';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: syncing ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7E7EF)),
            ),
            child: Row(
              children: [
                _ConnectorIcon(pluginId: plugin.id),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(width: 8),
                          Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTypography.dosis(
                                  size: 12,
                                  weight: FontWeight.w700,
                                ).copyWith(
                                  color: plugin.isNativeSync
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subtitleFor(context, plugin),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.dosis(
                          size: 13,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: plugin.isNativeSync ? 86 : 96,
                  child: syncing
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Text(
                          actionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: AppTypography.dosis(
                            size: 13,
                            weight: FontWeight.w700,
                          ).copyWith(color: AppColors.accent),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(BuildContext context, PluginManifestDto plugin) {
    final l10n = AppLocalizations.of(context)!;
    if (plugin.isNativeSync) {
      return plugin.description.isEmpty
          ? l10n.connectorsDefaultDescription
          : plugin.description;
    }
    return plugin.description.isEmpty
        ? 'Provider sync manifest is ready; direct connection is not enabled yet.'
        : plugin.description;
  }
}

class _ConnectorPlannedSheet extends StatelessWidget {
  const _ConnectorPlannedSheet({required this.plugin});

  final PluginManifestDto plugin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ConnectorIcon(pluginId: plugin.id),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plugin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.dosis(
                      size: 24,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${plugin.name} has a connector manifest, scopes, and sync capabilities defined, but direct provider connection is not enabled in v1 yet. Manual files, links, and exports now live in Library > Add anything.',
              style: AppTypography.dosis(
                size: 15,
              ).copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final capability in plugin.capabilities)
                  Chip(label: Text(capability)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Auth: ${plugin.authType} · Sync: ${plugin.syncModes.join(', ')}',
              style: AppTypography.dosis(
                size: 13,
              ).copyWith(color: AppColors.textSecondary, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectorIcon extends StatelessWidget {
  const _ConnectorIcon({required this.pluginId});

  final String pluginId;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(pluginId);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(14),
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
