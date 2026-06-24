import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';
import 'package:mira_app/features/connectors/connector_store.dart';
import 'package:mira_app/screens/settings/settings_widgets.dart';
import 'package:mira_app/theme/app_colors.dart';

class ConnectorSettingsScreen extends StatefulWidget {
  const ConnectorSettingsScreen({super.key});

  @override
  State<ConnectorSettingsScreen> createState() =>
      _ConnectorSettingsScreenState();
}

class _ConnectorSettingsScreenState extends State<ConnectorSettingsScreen> {
  ConnectorStore? _store;
  Map<ConnectorId, bool> _enabled = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await ConnectorStore.create();
    final states = await store.loadAll();
    if (!mounted) return;
    setState(() {
      _store = store;
      _enabled = states;
      _loading = false;
    });
  }

  Future<void> _toggle(ConnectorId id, bool value) async {
    final store = _store;
    if (store == null) return;
    await store.setEnabled(id, value);
    if (!mounted) return;
    setState(() => _enabled[id] = value);
  }

  @override
  Widget build(BuildContext context) {
    final s = figmaSettingsScale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MiraPageHeader(
              title: 'Connector Settings',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(48 * s, 4 * s, 48 * s, 48 * s),
                      children: [
                        Text(
                          'Connect Mira to your apps. Toggle each service on or off.',
                          style: GoogleFonts.inter(
                            fontSize: 22 * s,
                            color: const Color(0xFF6B6B6B),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 24 * s),
                        ...kDefaultConnectors.map((connector) {
                          final on = _enabled[connector.id] ?? false;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16 * s),
                            child: FigmaSettingsCard(
                              padding: figmaInsets(context, 20, 22, 20, 22),
                              child: Row(
                                children: [
                                  Text(
                                    connector.icon,
                                    style: TextStyle(fontSize: 32 * s),
                                  ),
                                  SizedBox(width: 16 * s),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          connector.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 26 * s,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 6 * s),
                                        Text(
                                          connector.description,
                                          style: GoogleFonts.inter(
                                            fontSize: 20 * s,
                                            color: const Color(0xFF7A7A7A),
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: on,
                                    activeTrackColor: AppColors.micBlueNav,
                                    onChanged: (value) =>
                                        _toggle(connector.id, value),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
