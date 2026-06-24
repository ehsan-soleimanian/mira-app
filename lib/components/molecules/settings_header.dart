import 'package:flutter/material.dart';
import 'package:mira_app/components/molecules/mira_page_header.dart';

/// Settings page header — back + centered title.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return MiraPageHeader(title: 'Settings', onBack: onBack);
  }
}
