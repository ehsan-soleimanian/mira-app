import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mira_app/app/app_scope.dart';
import 'package:mira_app/l10n/app_localizations.dart';
import 'package:mira_app/models/api/workspace_models.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

class RdConnectedAppsScreen extends StatefulWidget {
  const RdConnectedAppsScreen({
    super.key,
    required this.go,
    required this.onBack,
  });

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdConnectedAppsScreen> createState() => _RdConnectedAppsScreenState();
}

class _RdConnectedAppsScreenState extends State<RdConnectedAppsScreen>
    with WidgetsBindingObserver {
  List<PluginManifestDto> _plugins = const [];
  final Set<String> _busy = {};
  String? _pending;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pending != null) {
      unawaited(_refreshPending());
    }
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final items = await AppScope.servicesOf(context).pluginRepository.list();
      if (!mounted) return;
      setState(() {
        _plugins = items.where((item) => item.enabled).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshPending() async {
    final id = _pending;
    if (id == null) return;
    try {
      final connected = await AppScope.servicesOf(
        context,
      ).pluginRepository.refreshStatus(id);
      if (!mounted) return;
      if (connected) _pending = null;
    } finally {
      if (mounted) await _load();
    }
  }

  Future<void> _connect(PluginManifestDto plugin) async {
    if (_busy.contains(plugin.id)) return;
    setState(() => _busy.add(plugin.id));
    try {
      final result = await AppScope.servicesOf(
        context,
      ).pluginRepository.connect(plugin.id);
      final url = Uri.tryParse(result.connectUrl ?? '');
      final opened =
          url != null &&
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('connect link unavailable');
      if (mounted) setState(() => _pending = plugin.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.rdConnectedAppsOpenFailed,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(plugin.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connected = _plugins.where((item) => item.connected).toList();
    final available = _plugins.where((item) => !item.connected).toList();
    return Scaffold(
      backgroundColor: context.rd.bg,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(l10n)),
            if (_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: context.rd.peri),
                ),
              )
            else if (_plugins.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _empty(l10n))
            else ...[
              if (connected.isNotEmpty)
                _section(l10n.rdConnectedAppsSectionConnected, connected),
              if (available.isNotEmpty)
                _section(l10n.rdConnectedAppsSectionAvailable, available),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                  child: Text(
                    l10n.rdConnectedAppsPrivacy,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12.5,
                      height: 1.55,
                      color: context.rd.faint,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 24, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: widget.onBack,
          icon: RdIcon(RdIcons.chevronLeft, size: 19, color: context.rd.navy),
          label: Text(l10n.rdCommonSettings),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            l10n.rdConnectedAppsTitle,
            style: GoogleFonts.dosis(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: context.rd.ink,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Text(
            l10n.rdConnectedAppsIntro,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              height: 1.5,
              color: context.rd.muted,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _empty(AppLocalizations l10n) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RdIcon(RdIcons.linkChain, size: 38, color: context.rd.faint),
          const SizedBox(height: 14),
          Text(
            l10n.rdConnectedAppsUnavailable,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.rd.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rdConnectedAppsManagedByComposio,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: context.rd.muted),
          ),
        ],
      ),
    ),
  );

  SliverToBoxAdapter _section(String title, List<PluginManifestDto> items) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.rd.faint,
                  ),
                ),
              ),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.rd.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.rd.line),
                ),
                child: Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      if (index > 0) Divider(height: 1, color: context.rd.line),
                      _ConnectorTile(
                        plugin: items[index],
                        pending: _pending == items[index].id,
                        busy: _busy.contains(items[index].id),
                        onConnect: () => _connect(items[index]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ConnectorTile extends StatelessWidget {
  const _ConnectorTile({
    required this.plugin,
    required this.pending,
    required this.busy,
    required this.onConnect,
  });

  final PluginManifestDto plugin;
  final bool pending;
  final bool busy;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.rd.periSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              plugin.name.isEmpty ? '?' : plugin.name[0].toUpperCase(),
              style: GoogleFonts.dosis(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.rd.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plugin.name,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.rd.ink,
                  ),
                ),
                Text(
                  plugin.connected
                      ? l10n.rdConnectedAppsManagedByComposio
                      : plugin.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: context.rd.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (plugin.connected)
            Text(
              l10n.rdCommonConnected,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: context.rd.success,
              ),
            )
          else if (busy)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.rd.peri,
              ),
            )
          else
            FilledButton(
              onPressed: onConnect,
              child: Text(
                pending
                    ? l10n.rdConnectedAppsAuthorizing
                    : l10n.rdCommonConnect,
              ),
            ),
        ],
      ),
    );
  }
}
