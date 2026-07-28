"""Phase 5: fix compile errors + wire remaining redesign i18n."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fix_appearance() -> None:
    p = ROOT / "lib/redesign/screens/rd_appearance.dart"
    text = p.read_text(encoding="utf-8")
    imp = "import 'package:mira_app/models/api/settings_models.dart';"
    if imp not in text:
        text = text.replace(
            "import 'package:mira_app/l10n/app_localizations.dart';",
            "import 'package:mira_app/l10n/app_localizations.dart';\n" + imp,
        )
    p.write_text(text, encoding="utf-8")
    print("rd_appearance: import fixed")


def fix_setup_wizard() -> None:
    p = ROOT / "lib/redesign/screens/rd_setup_wizard.dart"
    text = p.read_text(encoding="utf-8")

    # Remove duplicate top-level const data that shadows instance methods.
    text = re.sub(
        r"// ══ data ══.*?"
        r"const _channels = \[.*?\];\n\n",
        "",
        text,
        count=1,
        flags=re.DOTALL,
    )

    # Loop helpers — invoke methods with l10n.
    for fn in ("_tones", "_foci", "_times", "_assurances", "_sourceList", "_channels"):
        text = text.replace(f"for (final t in {fn})", f"for (final t in {fn}(l10n))")
        text = text.replace(f"for (final f in {fn})", f"for (final f in {fn}(l10n))")
        text = text.replace(f"for (final s in {fn})", f"for (final s in {fn}(l10n))")
        text = text.replace(f"for (final a in {fn})", f"for (final a in {fn}(l10n))")
        text = text.replace(f"for (final c in {fn})", f"for (final c in {fn}(l10n))")
        text = text.replace(f"if (t != {fn}.last)", f"if (t != {fn}(l10n).last)")
        text = text.replace(f"if (c != {fn}.last)", f"if (c != {fn}(l10n).last)")

    # Inject l10n into step builders missing it.
    step_methods = (
        "_welcome", "_address", "_focusStep", "_peopleStep", "_rhythm", "_privacy",
        "_sourcesStep", "_importStep", "_permissions", "_weaving", "_ready", "_tour", "_invite",
    )
    for m in step_methods:
        pat = rf"(  Widget {m}\(\) \{{\n)"
        if re.search(pat, text) and f"Widget {m}()" in text:
            text, n = re.subn(
                pat,
                r"\1    final l10n = AppLocalizations.of(context)!;\n",
                text,
                count=1,
            )

    replacements = [
        ("'Let’s set up\nyour second mind.'", "l10n.rdSetupWelcomeTitle"),
        (
            "'A few quick questions so Mira remembers the way you do. About two minutes — and you can change any of it later.'",
            "l10n.rdSetupWelcomeDesc",
        ),
        ("label: 'Begin setup'", "label: l10n.rdSetupBeginSetup"),
        ("label: 'Skip for now'", "label: l10n.rdSetupSkipForNow"),
        ("ctaLabel: 'Continue'", "ctaLabel: l10n.rdSetupContinue"),
        ("ctaLabel: _focus.isEmpty ? 'Pick a few' : 'Continue'", "ctaLabel: _focus.isEmpty ? l10n.rdSetupPickFew : l10n.rdSetupContinue"),
        ("_h('What should Mira\ncall you?')", "_h(l10n.rdSetupAddressTitle)"),
        ("_desc('This is how your Brief and reminders will greet you.')", "_desc(l10n.rdSetupAddressDesc)"),
        ("hint: 'Your name'", "hint: l10n.rdSetupNameHint"),
        ("_fieldLabel('And how should it speak?')", "_fieldLabel(l10n.rdSetupToneLabel)"),
        ("_h('What matters\nto you?')", "_h(l10n.rdSetupFocusTitle)"),
        ("_desc('Mira will cluster your memories around these. Choose any that fit.')", "_desc(l10n.rdSetupFocusDesc)"),
        ("_h('Who’s important\nto you?')", "_h(l10n.rdSetupPeopleTitle)"),
        (
            "_desc('Mira links what you capture to the people in your life. Add a few — first names are enough.')",
            "_desc(l10n.rdSetupPeopleDesc)",
        ),
        ("hint: 'Add a name'", "hint: l10n.rdSetupPeopleHint"),
        ("'No one yet — Mira will still learn as you capture.'", "l10n.rdSetupPeopleEmpty"),
        ("_h('When should your\nBrief arrive?')", "_h(l10n.rdSetupRhythmTitle)"),
        ("_desc('A calm once-a-day summary of what needs you — nothing more.')", "_desc(l10n.rdSetupRhythmDesc)"),
        ("title: 'Quiet hours'", "title: l10n.rdSetupQuietHours"),
        ("sub: 'No nudges 22:00 – 07:00'", "sub: l10n.rdSetupQuietHoursSub"),
        ("_h('Your memory\nstays yours.')", "_h(l10n.rdSetupPrivacyTitle)"),
        ("_desc('Before you connect anything, here’s the promise Mira is built on.')", "_desc(l10n.rdSetupPrivacyDesc)"),
        ("_fieldLabel('Your choices')", "_fieldLabel(l10n.rdSetupChoicesLabel)"),
        ("title: 'Sync across my devices'", "title: l10n.rdSetupSyncDevices"),
        ("sub: 'Encrypted backup so your memory follows you.'", "sub: l10n.rdSetupSyncDevicesSub"),
        ("title: 'Help improve Mira'", "title: l10n.rdSetupHelpImprove"),
        ("sub: 'Share anonymous, aggregated usage — never your content.'", "sub: l10n.rdSetupHelpImproveSub"),
        ("_h('Connect\nyour world.')", "_h(l10n.rdSetupSourcesTitle)"),
        (
            "_desc('Give Mira a head start. It only reads what you connect, and processes it privately.')",
            "_desc(l10n.rdSetupSourcesDesc)",
        ),
        ("_h('Bring your\nnotes with you.')", "_h(l10n.rdSetupImportTitle)"),
        (
            "_desc('Already keep notes elsewhere? Import them once and Mira will weave them into your graph. Nothing is deleted from the original app.')",
            "_desc(l10n.rdSetupImportDesc)",
        ),
        ("sub: '~${_fmtK(a.count)} notes found'", "sub: l10n.rdSetupImportNotesFound(_fmtK(a.count))"),
        ("'You can also import later from Settings.'", "l10n.rdSetupImportLater"),
        ("'Mira will import in the background — you can start using it right away.'", "l10n.rdSetupImportBackground"),
        ("ctaLabel: _imports.isEmpty ? 'Continue' : 'Import ${_fmtK(_importTotal)} notes'", "ctaLabel: _imports.isEmpty ? l10n.rdSetupContinue : l10n.rdSetupImportCta(_importTotal)"),
        ("_h('Let Mira\nhelp quietly.')", "_h(l10n.rdSetupPermissionsTitle)"),
        ("_desc('Two permissions, both optional. Turn off anything, anytime.')", "_desc(l10n.rdSetupPermissionsDesc)"),
        ("title: 'Microphone'", "title: l10n.rdSetupMicTitle"),
        ("sub: 'So you can speak a memory anytime'", "sub: l10n.rdSetupMicSub"),
        ("title: 'Notifications'", "title: l10n.rdSetupNotifTitle"),
        ("sub: 'Only your Brief and reminders you set'", "sub: l10n.rdSetupNotifSub"),
        ("'Weaving your\nmemory…'", "l10n.rdSetupWeavingTitle"),
        ("'Your second\nmind is ready.'", "l10n.rdSetupReadyTitle"),
        ("label: 'Take a quick tour'", "label: l10n.rdSetupTakeTour"),
        ("label: 'Skip the tour'", "label: l10n.rdSetupSkipTour"),
        ("'Give someone a\ncalmer mind.'", "l10n.rdSetupInviteTitle"),
        (
            "'Mira is better with the people you think alongside. Invite a few — they skip the waitlist, and you both get a month of Plus.'",
            "l10n.rdSetupInviteDesc",
        ),
        ("label: 'Share your invite'", "label: l10n.rdSetupShareInvite"),
        ("label: 'Maybe later'", "label: l10n.rdSetupMaybeLater"),
        ("'YOUR INVITE CODE'", "l10n.rdSetupInviteCodeLabel"),
    ]
    for old, new in replacements:
        text = text.replace(old, new)

    # Weaving echo line
    weaving_block = """    final echoes = <String>[];
    if (_focus.isNotEmpty) {
      echoes.add('${_focus.length} focus ${_focus.length == 1 ? 'area' : 'areas'}');
    }
    if (_people.isNotEmpty) {
      echoes.add('${_people.length} ${_people.length == 1 ? 'person' : 'people'}');
    }
    if (_sources.isNotEmpty) {
      echoes.add('${_sources.length} ${_sources.length == 1 ? 'source' : 'sources'}');
    }
    if (_importTotal > 0) echoes.add('${_fmtK(_importTotal)} imported notes');
    final line = echoes.isEmpty ? 'your preferences' : echoes.join(' · ');"""

    weaving_new = """    final echoes = <String>[];
    if (_focus.isNotEmpty) echoes.add(l10n.rdSetupWeavingFocusAreas(_focus.length));
    if (_people.isNotEmpty) echoes.add(l10n.rdSetupWeavingPeople(_people.length));
    if (_sources.isNotEmpty) echoes.add(l10n.rdSetupWeavingSources(_sources.length));
    if (_importTotal > 0) echoes.add(l10n.rdSetupWeavingImported(_importTotal));
    final line = echoes.isEmpty ? l10n.rdSetupWeavingPreferences : echoes.join(' · ');"""
    text = text.replace(weaving_block, weaving_new)

    weaving_desc = "'Mira is arranging $line into the shape of your mind.'"
    weaving_desc_new = "l10n.rdSetupWeavingDesc(line)"
    text = text.replace(weaving_desc, weaving_desc_new)

    # Ready greet
    ready_greet = """    final greet = _nameCtl.text.trim().isEmpty
        ? 'you'
        : _nameCtl.text.trim().split(' ').first;"""
    ready_greet_new = """    final greet = _nameCtl.text.trim().isEmpty
        ? l10n.rdSetupReadyYou
        : _nameCtl.text.trim().split(' ').first;"""
    text = text.replace(ready_greet, ready_greet_new)

    ready_desc = "'Everything you capture from here, $greet, has a place to live — and a way back to you.'"
    ready_desc_new = "l10n.rdSetupReadyDesc(greet)"
    text = text.replace(ready_desc, ready_desc_new)

    # Tour stops — build from l10n
    tour_old = """    const stops = [
      ('One place to capture', 'Type, speak, or snap a photo — everything you save starts right here.', 0.30, 62.0, 18.0, true),
      ('Everything lands here', 'Each capture joins your timeline, already linked to what it relates to.', 0.50, 74.0, 14.0, true),
      ('Capture from anywhere', 'Tap the mic any time — even mid-conversation — to save a thought in a breath.', 0.88, 76.0, 38.0, false),
      ('Move around calmly', 'Home, Library, Canvas and your Daily Brief all live down here.', 0.94, 84.0, 20.0, false),
    ];"""
    tour_new = """    final stops = [
      (l10n.rdSetupTour1Title, l10n.rdSetupTour1Body, 0.30, 62.0, 18.0, true),
      (l10n.rdSetupTour2Title, l10n.rdSetupTour2Body, 0.50, 74.0, 14.0, true),
      (l10n.rdSetupTour3Title, l10n.rdSetupTour3Body, 0.88, 76.0, 38.0, false),
      (l10n.rdSetupTour4Title, l10n.rdSetupTour4Body, 0.94, 84.0, 20.0, false),
    ];"""
    text = text.replace(tour_old, tour_new)

    # _inviteCode needs l10n — add at start of method
    if "_inviteCode(String code)" in text and "Widget _inviteCode(String code) {\n    final l10n" not in text:
        text = text.replace(
            "  Widget _inviteCode(String code) {\n    final rd = context.rd;",
            "  Widget _inviteCode(String code) {\n    final l10n = AppLocalizations.of(context)!;\n    final rd = context.rd;",
        )

    p.write_text(text, encoding="utf-8")
    print("rd_setup_wizard: fixed")


def fix_settings() -> None:
    p = ROOT / "lib/redesign/screens/rd_settings.dart"
    text = p.read_text(encoding="utf-8")

    if "import 'package:mira_app/l10n/app_localizations.dart';" not in text:
        text = text.replace(
            "import 'package:mira_app/models/api/auth_models.dart';",
            "import 'package:mira_app/l10n/app_localizations.dart';\nimport 'package:mira_app/models/api/auth_models.dart';",
        )

    text = text.replace(
        "  /// Neutral placeholder name shown until the real profile loads, or if it\n  /// can't — never a fabricated identity.\n  static const _placeholderName = 'Your account';\n\n",
        "",
    )
    text = text.replace(
        "  String get _name {\n    final name = _user?.displayName.trim() ?? '';\n    return name.isEmpty ? _placeholderName : name;\n  }",
        "  String _name(AppLocalizations l10n) {\n    final name = _user?.displayName.trim() ?? '';\n    return name.isEmpty ? l10n.rdAccountPlaceholderName : name;\n  }",
    )
    text = text.replace(
        "        _name.split(RegExp(r'\\s+'))",
        "        _name(AppLocalizations.of(context)!).split(RegExp(r'\\s+'))",
    )
    text = text.replace("    _toast('Signed out');", "    _toast(AppLocalizations.of(context)!.rdAccountSignedOut);")

    # Account build
    text = text.replace(
        "  @override\n  Widget build(BuildContext context) {\n    return _AcScaffold(",
        "  @override\n  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;\n    return _AcScaffold(",
        1,
    )
    ac_repls = [
        ("title: 'Account',", "title: l10n.rdAccountTitle,"),
        ("_AcProfile(name: _name, email: _email, initials: _initials)", "_AcProfile(name: _name(l10n), email: _email, initials: _initials)"),
        ("label: 'Profile',", "label: l10n.rdAccountSectionProfile,"),
        ("title: 'Name', value: _name)", "title: l10n.rdAccountName, value: _name(l10n))"),
        ("title: 'Email',", "title: l10n.rdAccountEmail,"),
        ("title: 'Phone',", "title: l10n.rdAccountPhone,"),
        ("label: 'Security',", "label: l10n.rdAccountSectionSecurity,"),
        ("title: 'Face ID unlock',", "title: l10n.rdAccountFaceIdTitle,"),
        ("sub: 'Require Face ID to open Mira',", "sub: l10n.rdAccountFaceIdSub,"),
        ("title: 'Auto-lock',", "title: l10n.rdAccountAutoLockTitle,"),
        ("sub: 'Lock after 5 minutes idle',", "sub: l10n.rdAccountAutoLockSub,"),
        ("title: 'Change password'", "title: l10n.rdAccountChangePassword"),
        ("label: 'Plan',", "label: l10n.rdAccountSectionPlan,"),
        ("title: isPlus ? 'Mira Plus' : 'Mira Free',", "title: isPlus ? l10n.rdAccountMiraPlus : l10n.rdAccountMiraFree,"),
        ("? 'Active · \\$8 / month'", "? l10n.rdAccountPlusActiveSub"),
        (": '34 of 2,000 memories used'", ": l10n.rdAccountFreeUsageSub(34, 2000)"),
        ("value: isPlus ? 'Manage' : 'Upgrade',", "value: isPlus ? l10n.rdCommonManage : l10n.rdCommonUpgrade,"),
        ("label: 'Preferences',", "label: l10n.rdAccountSectionPreferences,"),
        ("title: 'Notifications',", "title: l10n.rdAccountNotificationsTitle,"),
        ("sub: 'Brief, reminders & quiet hours',", "sub: l10n.rdAccountNotificationsSub,"),
        ("title: 'Reminders',", "title: l10n.rdAccountRemindersTitle,"),
        ("sub: 'Everything Mira is holding for you',", "sub: l10n.rdAccountRemindersSub,"),
        ("title: 'Appearance',", "title: l10n.rdAccountAppearanceTitle,"),
        ("sub: 'Theme, accent, text size & motion',", "sub: l10n.rdAccountAppearanceSub,"),
        ("title: 'Connected apps',", "title: l10n.rdAccountConnectedAppsTitle,"),
        ("sub: 'Calendar, Notes, Photos & more',", "sub: l10n.rdAccountConnectedAppsSub,"),
        ("label: 'Memory & data',", "label: l10n.rdAccountSectionMemoryData,"),
        ("title: 'Export my data', sub: 'Download everything Mira holds'", "title: l10n.rdAccountExportData, sub: l10n.rdAccountExportDataSub"),
        ("title: 'Memory history', sub: 'See what was captured & when'", "title: l10n.rdAccountMemoryHistory, sub: l10n.rdAccountMemoryHistorySub"),
        ("title: 'Sign out',", "title: l10n.rdAccountSignOut,"),
        ("title: 'Delete account',", "title: l10n.rdAccountDeleteAccount,"),
        ("const _AcFoot('Mira · Version 1.0')", "_AcFoot(l10n.rdAccountFootVersion)"),
    ]
    for old, new in ac_repls:
        text = text.replace(old, new)

    # Notifications screen build — second build method
    text = text.replace(
        "  Widget build(BuildContext context) {\n    return _AcScaffold(\n      onBack: widget.onBack,\n      title: 'Notifications',",
        "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;\n    return _AcScaffold(\n      onBack: widget.onBack,\n      title: l10n.rdNotificationsTitle,",
    )
    notif_repls = [
        ("intro: 'Mira stays quiet by default — and only speaks up when it truly helps.',", "intro: l10n.rdNotificationsIntro,"),
        ("label: 'Daily Brief',", "label: l10n.rdNotificationsSectionDailyBrief,"),
        ("'Morning brief', 'A calm summary to start the day'", "l10n.rdNotificationsMorningBrief, l10n.rdNotificationsMorningBriefSub"),
        ("title: 'Brief time',", "title: l10n.rdNotificationsBriefTime,"),
        ("'Resurface a memory', 'Occasionally revisit something worth holding'", "l10n.rdNotificationsResurfaceMemory, l10n.rdNotificationsResurfaceMemorySub"),
        ("label: 'Reminders',", "label: l10n.rdNotificationsSectionReminders,"),
        ("'Time-sensitive reminders', 'Dates, tickets, and things that expire'", "l10n.rdNotificationsTimeSensitive, l10n.rdNotificationsTimeSensitiveSub"),
        ("'Gentle nudges', 'Soft prompts for unfinished threads'", "l10n.rdNotificationsGentleNudges, l10n.rdNotificationsGentleNudgesSub"),
        ("label: 'Captures',", "label: l10n.rdNotificationsSectionCaptures,"),
        ("'Confirm before saving', 'Ask before adding a capture to your graph'", "l10n.rdNotificationsConfirmBeforeSaving, l10n.rdNotificationsConfirmBeforeSavingSub"),
        ("'Weekly recap', 'A Sunday look back at the week'", "l10n.rdNotificationsWeeklyRecap, l10n.rdNotificationsWeeklyRecapSub"),
        ("label: 'Quiet hours',", "label: l10n.rdNotificationsSectionQuietHours,"),
        ("'Quiet hours', 'Hold all notifications while you rest'", "l10n.rdNotificationsQuietHours, l10n.rdNotificationsQuietHoursSub"),
        ("title: 'Schedule',", "title: l10n.rdNotificationsSchedule,"),
        ("label: 'Delivery',", "label: l10n.rdNotificationsSectionDelivery,"),
        ("'Sound', null", "l10n.rdNotificationsSound, null"),
        ("'Haptics', null", "l10n.rdNotificationsHaptics, null"),
        ("const _AcFoot('Mira notifies you gently, or not at all.')", "_AcFoot(l10n.rdNotificationsFoot)"),
        ("helpText: 'Quiet hours start'", "helpText: l10n.rdNotificationsQuietStartHelp"),
        ("helpText: 'Quiet hours end'", "helpText: l10n.rdNotificationsQuietEndHelp"),
        ("? 'AM' : 'PM'", "? l10n.rdCommonAm : l10n.rdCommonPm"),
    ]
    for old, new in notif_repls:
        text = text.replace(old, new)

    # Connected apps
    text = text.replace(
        "  Widget build(BuildContext context) {\n    return _AcScaffold(\n      onBack: widget.onBack,\n      title: 'Connected apps',",
        "  Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;\n    return _AcScaffold(\n      onBack: widget.onBack,\n      title: l10n.rdConnectedAppsTitle,",
    )
    ca_repls = [
        ("intro: 'Mira quietly weaves these sources into your memory — nothing leaves without your say.',", "intro: l10n.rdConnectedAppsIntro,"),
        ("label: 'Connected',", "label: l10n.rdConnectedAppsSectionConnected,"),
        ("title: 'Calendar', sub: 'Synced 2m ago · feeds your Brief'", "title: l10n.rdConnectedAppsCalendar, sub: l10n.rdConnectedAppsCalendarSub"),
        ("title: 'Notes', sub: 'Synced 1h ago · 128 notes'", "title: l10n.rdConnectedAppsNotes, sub: l10n.rdConnectedAppsNotesSub"),
        ("title: 'Photos', sub: 'Synced today · screenshots & scans'", "title: l10n.rdConnectedAppsPhotos, sub: l10n.rdConnectedAppsPhotosSub"),
        ("label: 'Available',", "label: l10n.rdConnectedAppsSectionAvailable,"),
        ("'Gmail', 'Turn important mail into memories'", "l10n.rdConnectedAppsGmail, l10n.rdConnectedAppsGmailSub"),
        ("'Safari', 'Save pages & highlights as you browse'", "l10n.rdConnectedAppsSafari, l10n.rdConnectedAppsSafariSub"),
        ("'Readwise', 'Import book & article highlights'", "l10n.rdConnectedAppsReadwise, l10n.rdConnectedAppsReadwiseSub"),
        ("'Voice Memos', 'Transcribe recordings into your graph'", "l10n.rdConnectedAppsVoiceMemos, l10n.rdConnectedAppsVoiceMemosSub"),
        ("Text('Connected',", "Text(AppLocalizations.of(context)!.rdCommonConnected,"),
        ("Text('Connect',", "Text(AppLocalizations.of(context)!.rdCommonConnect,"),
        ("Text('Settings',", "Text(AppLocalizations.of(context)!.rdCommonSettings,"),
        ("Text('All memories synced',", "Text(AppLocalizations.of(context)!.rdAccountAllMemoriesSynced,"),
        ("Text('34 memories',", "Text(AppLocalizations.of(context)!.rdAccountStorageHeadline(34),"),
        ("Text('of 2,000 · plenty of room',", "Text(AppLocalizations.of(context)!.rdAccountStorageSubline(2000),"),
        (
            "'Mira only reads what you connect, and processes it privately. Disconnect anytime.'",
            "AppLocalizations.of(context)!.rdConnectedAppsPrivacy",
        ),
    ]
    for old, new in ca_repls:
        text = text.replace(old, new)

    p.write_text(text, encoding="utf-8")
    print("rd_settings: fixed")


def fix_canvas() -> None:
    p = ROOT / "lib/redesign/screens/rd_canvas_screen.dart"
    text = p.read_text(encoding="utf-8")

    if "import 'package:mira_app/l10n/app_localizations.dart';" not in text:
        text = text.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\n\nimport 'package:mira_app/l10n/app_localizations.dart';",
        )

    repls = [
        ("_mapToast('Memories merged')", "_mapToast(AppLocalizations.of(context)!.rdCanvasMergeSuccess)"),
        ("_mapToast('Couldn’t merge those')", "_mapToast(AppLocalizations.of(context)!.rdCanvasMergeFail)"),
        ("_mapToast('Connection removed')", "_mapToast(AppLocalizations.of(context)!.rdCanvasUnlinkSuccess)"),
        ("_mapToast('Couldn’t remove that connection')", "_mapToast(AppLocalizations.of(context)!.rdCanvasUnlinkFail)"),
        ("title: 'My board'", "title: AppLocalizations.of(context)!.rdCanvasMyBoard"),
        ("title: 'New board'", "title: AppLocalizations.of(context)!.rdCanvasNewBoard"),
        ("? 'Board' :", "? AppLocalizations.of(context)!.rdCanvasBoardDefault :"),
        ("title: Text('Rename board',", "title: Text(AppLocalizations.of(context)!.rdCanvasRenameTitle,"),
        ("hintText: 'Board name',", "hintText: AppLocalizations.of(context)!.rdCanvasBoardNameHint,"),
        ("child: Text('Cancel',", "child: Text(AppLocalizations.of(context)!.rdCommonCancel,"),
        ("child: Text('Save',", "child: Text(AppLocalizations.of(context)!.rdCommonSave,"),
        ("? 'Loading…' : 'Board'", "? AppLocalizations.of(context)!.rdCanvasLoading : AppLocalizations.of(context)!.rdCanvasBoardDefault"),
        ("'BOARDS',", "AppLocalizations.of(context)!.rdCanvasBoardsHeader,"),
        ("'New board',", "AppLocalizations.of(context)!.rdCanvasNewBoard,"),
        ("? 'Untitled board' :", "? AppLocalizations.of(context)!.rdCanvasUntitledBoard :"),
        ("return 'Person';", "return AppLocalizations.of(context)!.rdCanvasNodePerson;"),
        ("return 'Task';", "return AppLocalizations.of(context)!.rdCanvasNodeTask;"),
        ("return 'Event';", "return AppLocalizations.of(context)!.rdCanvasNodeEvent;"),
        ("return 'Note';", "return AppLocalizations.of(context)!.rdCanvasNodeNote;"),
        ("return 'Book';", "return AppLocalizations.of(context)!.rdCanvasNodeBook;"),
        ("return 'Idea';", "return AppLocalizations.of(context)!.rdCanvasNodeIdea;"),
        ("return 'Topic';", "return AppLocalizations.of(context)!.rdCanvasNodeTopic;"),
        ("_GType.task => 'Tasks',", "_GType.task => AppLocalizations.of(context)!.rdCanvasClusterTasks,"),
        ("_GType.book => 'Books & ideas',", "_GType.book => AppLocalizations.of(context)!.rdCanvasClusterBooks,"),
        ("_GType.event => 'Events',", "_GType.event => AppLocalizations.of(context)!.rdCanvasClusterEvents,"),
        ("_ => 'Notes & memories',", "_ => AppLocalizations.of(context)!.rdCanvasClusterNotes,"),
        ("'No clusters yet',", "AppLocalizations.of(context)!.rdCanvasNoClusters,"),
        ("'Your memory graph is empty',", "AppLocalizations.of(context)!.rdCanvasGraphEmpty,"),
        ("'Tap a memory · drag to explore',", "AppLocalizations.of(context)!.rdCanvasTapExplore,"),
        ("Text('Focus this constellation',", "Text(AppLocalizations.of(context)!.rdCanvasFocusConstellation,"),
        ("Text('Merge a duplicate',", "Text(AppLocalizations.of(context)!.rdCanvasMergeDuplicate,"),
        ("content: Text('Card removed',", "content: Text(AppLocalizations.of(context)!.rdCanvasCardRemoved,"),
        ("label: 'Undo',", "label: AppLocalizations.of(context)!.rdCommonUndo,"),
        ("tag: 'Note',", "tag: AppLocalizations.of(context)!.rdCanvasNodeNote,"),
        ("title: 'New note',", "title: AppLocalizations.of(context)!.rdCanvasNewNoteTitle,"),
    ]

    # Map context string — needs local l10n in method
    text = text.replace(
        "'Your memory · ${nodes.length} memories · ${edges.length} connections';",
        "AppLocalizations.of(context)!.rdCanvasMapContext(nodes.length, edges.length);",
    )

    for old, new in repls:
        text = text.replace(old, new)

    p.write_text(text, encoding="utf-8")
    print("rd_canvas_screen: partial fix")


def main() -> None:
    fix_appearance()
    fix_setup_wizard()
    fix_settings()
    fix_canvas()
    print("done")


if __name__ == "__main__":
    main()
