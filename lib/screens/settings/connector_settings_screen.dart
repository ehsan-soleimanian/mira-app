import 'package:flutter/material.dart';
import 'package:mira_app/screens/workspace/connector_marketplace_screen.dart';

class ConnectorSettingsScreen extends StatefulWidget {
  const ConnectorSettingsScreen({super.key});

  @override
  State<ConnectorSettingsScreen> createState() =>
      _ConnectorSettingsScreenState();
}

class _ConnectorSettingsScreenState extends State<ConnectorSettingsScreen> {
  @override
  Widget build(BuildContext context) => const ConnectorMarketplaceScreen();
}
