import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mira_app/l10n/app_localizations.dart';

import 'models/rd_capture_mode.dart';
import 'screens/rd_appearance.dart';
import 'screens/rd_ask_screen.dart';
import 'screens/rd_canvas_screen.dart';
import 'screens/rd_capture_flow.dart';
import 'screens/rd_chat_screen.dart';
import 'screens/rd_connected_apps.dart';
import 'screens/rd_daily_brief_screen.dart';
import 'screens/rd_home_screen.dart';
import 'screens/rd_library_screen.dart';
import 'screens/rd_listen_screen.dart';
import 'screens/rd_memory_screen.dart';
import 'screens/rd_onboarding.dart';
import 'screens/rd_paywall.dart';
import 'screens/rd_reminders.dart';
import 'screens/rd_settings.dart';
import 'screens/rd_setup_wizard.dart';
import 'screens/rd_storage.dart';
import 'theme/rd_colors.dart';
import 'widgets/rd_bottom_nav.dart';
import 'widgets/rd_capture_entry_sheet.dart';
import 'widgets/rd_icon.dart';
import 'widgets/rd_swipe_back.dart';

/// Root navigator for the redesign. Mirrors the design's `go(screen)` model:
/// the four tab screens (home / daily / library / canvas) reset the stack;
/// anything else is pushed on top, or — if it's already below in the stack —
/// popped back to (so onboarding "back" and system back both work). Screens
/// not yet built fall back to [_ComingSoon].
class RdRoot extends StatefulWidget {
  const RdRoot({super.key, this.initial = 'home'});

  /// Screen id to boot into (e.g. 'home' for the app, 'splash' for onboarding).
  final String initial;

  @override
  State<RdRoot> createState() => _RdRootState();
}

class _RdRootState extends State<RdRoot> {
  static const _tabs = {'home', 'daily', 'library', 'canvas'};

  static const _pushedScreens = {
    'memory',
    'chat',
    'account',
    'storage',
    'appearance',
    'notifications',
    'connectedapps',
    'ask',
    'reminders',
    'paywall',
    'listen',
    'captureflow',
  };

  late final List<({String id, Object? arg})> _stack = [
    (id: widget.initial, arg: null),
  ];

  bool _captureSheetOpen = false;

  void _go(String screen, {Object? arg}) {
    if (screen == 'capture') {
      setState(() => _captureSheetOpen = true);
      return;
    }
    setState(() {
      _captureSheetOpen = false;
      if (_tabs.contains(screen) || screen == 'splash') {
        _stack
          ..clear()
          ..add((id: screen, arg: null));
        return;
      }
      final idx = _stack.indexWhere((e) => e.id == screen);
      if (idx != -1) {
        _stack.removeRange(idx + 1, _stack.length);
      } else {
        _stack.add((id: screen, arg: arg));
      }
    });
  }

  void _pickCaptureMode(RdCaptureMode mode) {
    setState(() {
      _captureSheetOpen = false;
      _stack.add((id: 'captureflow', arg: RdCaptureModeArg(mode)));
    });
  }

  void _back() {
    if (_stack.length > 1) {
      setState(() {
        _captureSheetOpen = false;
        _stack.removeLast();
      });
    }
  }

  Widget _screenFor(BuildContext context, String id, Object? arg) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'home':
        return RdHomeScreen(go: _go);
      case 'daily':
        return RdDailyBriefScreen(go: _go);
      case 'library':
        return RdLibraryScreen(go: _go);
      case 'canvas':
        return RdCanvasScreen(go: _go);
      case 'splash':
        return RdSplashScreen(go: _go);
      case 'login':
        return RdLoginScreen(go: _go);
      case 'invite':
        return RdInviteScreen(go: _go, email: arg is String ? arg : null);
      case 'email':
        return RdEmailCodeScreen(go: _go, email: arg is String ? arg : null);
      case 'details':
        final ob = arg is RdOnboardingArg ? arg : null;
        return RdDetailsScreen(
          go: _go,
          email: ob?.email ?? (arg is String ? arg : null),
          onboarding: ob,
        );
      case 'remember':
        return RdRememberScreen(
          go: _go,
          onboarding: arg is RdOnboardingArg ? arg : null,
        );
      case 'understood':
        return RdUnderstoodScreen(
          go: _go,
          onboarding: arg is RdOnboardingArg ? arg : null,
        );
      case 'wizard':
        return RdSetupWizard(
          go: _go,
          initialDisplayName: arg is RdOnboardingArg ? arg.displayName : null,
        );
      case 'account':
        return RdAccountScreen(go: _go, onBack: _back);
      case 'notifications':
        return RdNotificationsScreen(go: _go, onBack: _back);
      case 'connectedapps':
        return RdConnectedAppsScreen(go: _go, onBack: _back);
      case 'appearance':
        return RdAppearanceScreen(go: _go, onBack: _back);
      case 'memory':
        final a = arg is RdMemoryArg ? arg : null;
        return RdMemoryScreen(
          go: _go,
          onBack: _back,
          id: a?.id,
          isVoice: a?.isVoice ?? false,
          title: a?.title,
          body: a?.body,
        );
      case 'listen':
        return RdListenScreen(go: _go, onBack: _back);
      case 'chat':
        final memory = arg is RdMemoryArg
            ? arg
            : (arg is RdChatArg ? arg.memory : null);
        final chat = arg is RdChatArg ? arg : null;
        return RdChatScreen(
          go: _go,
          onBack: _back,
          anchorTitle: memory?.title,
          anchorIsVoice: memory?.isVoice ?? false,
          anchorId: memory?.id,
          initialPrompt: chat?.initialPrompt,
          autoSend: chat?.autoSend ?? false,
        );
      case 'ask':
        return RdAskScreen(go: _go, onBack: _back);
      case 'reminders':
        return RdRemindersScreen(
          go: _go,
          onBack: _back,
          backLabel: l10n.rdCommonAccount,
        );
      case 'paywall':
        return RdPaywallScreen(go: _go, onBack: _back);
      case 'storage':
        return RdStorageScreen(go: _go, onBack: _back);
      case 'captureflow':
        final mode = arg is RdCaptureModeArg
            ? arg.mode
            : RdCaptureMode.voice;
        return RdCaptureFlow(go: _go, initialMode: mode);
      default:
        return _ComingSoon(
          id: id,
          go: _go,
          onBack: _back,
          isTab: _tabs.contains(id),
          l10n: l10n,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _stack.last;
    final screen = _screenFor(context, current.id, current.arg);
    final swipeEnabled = _pushedScreens.contains(current.id);

    return PopScope(
      canPop: _stack.length <= 1 && !_captureSheetOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_captureSheetOpen) {
          setState(() => _captureSheetOpen = false);
          return;
        }
        _back();
      },
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(current.id),
              child: RdSwipeBack(
                enabled: swipeEnabled,
                onBack: _back,
                child: screen,
              ),
            ),
          ),
          if (_captureSheetOpen)
            Positioned.fill(
              child: RdCaptureEntrySheet(
                onPick: _pickCaptureMode,
                onClose: () => setState(() => _captureSheetOpen = false),
              ),
            ),
        ],
      ),
    );
  }
}

/// Placeholder for screens still on the roadmap. Tabs keep the bottom nav so
/// you can move between them; pushed screens get a back affordance.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.id,
    required this.go,
    required this.onBack,
    required this.isTab,
    required this.l10n,
  });

  final String id;
  final RdGo go;
  final VoidCallback onBack;
  final bool isTab;
  final AppLocalizations l10n;

  String _titleFor(String screenId) {
    return switch (screenId) {
      'account' => l10n.rdCommonAccount,
      'memory' => l10n.rdRootTitleMemory,
      'capture' => l10n.rdRootTitleCapture,
      'notifications' => l10n.rdRootTitleNotifications,
      'connectedapps' => l10n.rdRootTitleConnectedApps,
      'listen' => l10n.rdRootTitleListening,
      'chat' => l10n.rdRootTitleChat,
      'wizard' => l10n.rdRootTitleSetup,
      _ => screenId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(id);
    return Scaffold(
      backgroundColor: RdColors.bg,
      body: Stack(
        children: [
          if (!isTab)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onBack,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: RdIcon(
                        RdIcons.chevronLeft,
                        size: 24,
                        stroke: '#45464E',
                        strokeWidth: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dosis(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: RdColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.rdCommonComingSoon,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    color: RdColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (isTab)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RdBottomNav(active: id, go: go),
            ),
        ],
      ),
    );
  }
}
