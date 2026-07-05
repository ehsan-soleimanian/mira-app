import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mira_app/core/mira_navigation.dart';
import 'package:mira_app/features/capture/shared_import/shared_import_review_screen.dart';
import 'package:mira_app/features/capture/shared_import/shared_import_service.dart';

class SharedImportListener extends StatefulWidget {
  const SharedImportListener({super.key, required this.child});

  final Widget child;

  @override
  State<SharedImportListener> createState() => _SharedImportListenerState();
}

class _SharedImportListenerState extends State<SharedImportListener> {
  late final SharedImportService _service;
  StreamSubscription<SharedImportItem>? _subscription;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _service = SharedImportService();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;
    _subscription = _service.stream.listen(_openImport);
    await _service.start();
  }

  void _openImport(SharedImportItem item) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(miraRoute((_) => SharedImportReviewScreen(item: item)));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
