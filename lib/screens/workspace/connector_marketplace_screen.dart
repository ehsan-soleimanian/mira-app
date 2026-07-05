import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/app/app_scope.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final plugins = await AppScope.servicesOf(context).pluginRepository.list();
    if (!mounted) return;
    setState(() {
      _plugins = plugins;
      _loading = false;
    });
  }

  Future<void> _connectAndSync(PluginManifestDto plugin) async {
    final repo = AppScope.servicesOf(context).pluginRepository;
    await repo.connect(plugin.id);
    await repo.sync(plugin.id);
    if (mounted) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 136),
      children: [
        Text(
          'Connectors',
          style: AppTypography.dosis(size: 28, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Gmail, Drive, and Calendar are wired for v1 sync. The rest are manifest-ready for plugin rollout.',
          style: AppTypography.dosis(
            size: 15,
          ).copyWith(color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          for (final plugin in _plugins)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7E7EF)),
                ),
                child: Row(
                  children: [
                    Icon(
                      plugin.enabled
                          ? Icons.cloud_sync_outlined
                          : Icons.extension_off_outlined,
                      color: plugin.enabled ? AppColors.accent : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plugin.name,
                            style: AppTypography.dosis(
                              size: 17,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            plugin.configured
                                ? 'Connected'
                                : plugin.enabled
                                ? 'Ready to connect'
                                : 'Manifest ready',
                            style: AppTypography.dosis(
                              size: 13,
                            ).copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: plugin.enabled ? 'Connect and sync' : 'Planned',
                      onPressed: plugin.enabled
                          ? () => _connectAndSync(plugin)
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
