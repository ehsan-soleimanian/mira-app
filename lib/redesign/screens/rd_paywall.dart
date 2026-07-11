import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mira_app/core/membership.dart';
import 'package:mira_app/l10n/app_localizations.dart';

import '../theme/rd_theme.dart';
import '../widgets/rd_bottom_nav.dart';
import '../widgets/rd_icon.dart';

/// Paywall — the "Mira Plus" upgrade offer, reached from the Account "Plan" row
/// and (later) soft-limit prompts. Calm and trust-forward: no urgency tricks.
/// Faithful to `paywall.jsx` (`.rd-paywall` / `.pw-*`) and dark-aware from the
/// start via `context.rd`, styled to match the redesign (Dosis/Vazirmatn,
/// [RdIcon], rounded cards).
///
/// UI-ONLY — there is no billing backend. The [pw-demo] segmented control flips
/// between the two designed states (Free upgrade offer vs. active Plus member).
/// Every purchase affordance — the CTA, "Restore purchase", "Manage/Cancel" —
/// resolves to a placeholder [_toast]; nothing navigates to a payment flow.
/// A close / "Maybe later" affordance simply calls [onBack].
class RdPaywallScreen extends StatefulWidget {
  const RdPaywallScreen({super.key, required this.go, required this.onBack});

  final RdGo go;
  final VoidCallback onBack;

  @override
  State<RdPaywallScreen> createState() => _RdPaywallScreenState();
}

/// Which billing cadence is selected in the upgrade view.
enum _Plan { annual, monthly }

class _RdPaywallScreenState extends State<RdPaywallScreen> {
  /// Selected plan in the upgrade view (annual leads — it carries the savings).
  _Plan _plan = _Plan.annual;

  /// Local-only demo toggle mirroring the design's `pw-demo` control: `false`
  /// shows the upgrade offer, `true` previews the active-member state. No
  /// billing is involved — this only swaps which mock layout renders.
  bool _member = false;

  @override
  void initState() {
    super.initState();
    _member = Membership.isPlus.value;
    Membership.ensureLoaded().then((_) {
      if (mounted) setState(() => _member = Membership.isPlus.value);
    });
  }

  /// Start Plus — flips the shared, persisted membership flag so the Account
  /// plan row updates in lockstep. No real checkout (no billing backend yet).
  Future<void> _subscribe() async {
    await Membership.setPlus(true);
    if (mounted) {
      setState(() => _member = true);
      _toast(AppLocalizations.of(context)!.rdPaywallWelcome);
    }
  }

  Future<void> _cancelPlus() async {
    await Membership.setPlus(false);
    if (mounted) {
      setState(() => _member = false);
      _toast(AppLocalizations.of(context)!.rdPaywallCancelled);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    final rd = context.rd;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: rd.ink,
          content: Text(
            message,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: rd.bg),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Scaffold(
      backgroundColor: rd.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: _member ? _memberView() : _upgradeView(),
              ),
            ),
          ),
          // Close ("Maybe later") — pops back to Account. Sits over the scroll.
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: _CloseButton(onTap: widget.onBack),
              ),
            ),
          ),
          // Demo segmented control (design's `pw-demo`) — local state preview.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: _DemoToggle(
                    member: _member,
                    onFree: () => setState(() => _member = false),
                    onPlus: () => setState(() => _member = true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══ upgrade view (non-member) ══════════════════════════════════════════
  Widget _upgradeView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        _Hero(
          live: false,
          badge: l10n.rdPaywallBadge,
          title: l10n.rdPaywallTitle,
          sub: l10n.rdPaywallSubtitle,
        ),
        const SizedBox(height: 26),
        _benefits(),
        const SizedBox(height: 24),
        _plans(),
        const SizedBox(height: 22),
        _cta(),
        const SizedBox(height: 13),
        _fine(),
        const SizedBox(height: 20),
        _links(),
        const SizedBox(height: 20),
        _Trust(l10n.rdPaywallPrivacyNote),
      ],
    );
  }

  Widget _benefits() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _Benefit(
          icon:
              '<path d="M4 7c0-1 .9-2 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2Z"/><path d="M4 11h16"/>',
          title: l10n.rdPaywallFeatUnlimitedTitle,
          sub: l10n.rdPaywallFeatUnlimitedSub,
        ),
        _Benefit(
          icon:
              '<circle cx="6" cy="6" r="2.4"/><circle cx="18" cy="10" r="2.4"/><circle cx="9" cy="18" r="2.4"/><path d="M8 7.5 15.5 9.5M8.5 16 16 11.5"/>',
          title: l10n.rdPaywallFeatGraphTitle,
          sub: l10n.rdPaywallFeatGraphSub,
        ),
        _Benefit(
          icon: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
          title: l10n.rdPaywallFeatVoiceTitle,
          sub: l10n.rdPaywallFeatVoiceSub,
        ),
        _Benefit(
          icon:
              '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
          title: l10n.rdPaywallFeatConnectTitle,
          sub: l10n.rdPaywallFeatConnectSub,
        ),
        _Benefit(
          icon: '<path d="M12 3a9 9 0 1 0 9 9"/><path d="M12 3v9l6 3"/>',
          title: l10n.rdPaywallFeatBriefTitle,
          sub: l10n.rdPaywallFeatBriefSub,
        ),
      ],
    );
  }

  Widget _plans() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PlanCard(
            selected: _plan == _Plan.annual,
            save: '2 months free',
            name: l10n.rdPaywallPlanAnnual,
            price: '\$6',
            per: '/mo',
            note: '\$72 billed yearly',
            onTap: () => setState(() => _plan = _Plan.annual),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _PlanCard(
            selected: _plan == _Plan.monthly,
            name: l10n.rdPaywallPlanMonthly,
            price: '\$8',
            per: '/mo',
            note: l10n.rdPaywallPlanMonthlyNote,
            onTap: () => setState(() => _plan = _Plan.monthly),
          ),
        ),
      ],
    );
  }

  Widget _cta() {
    final l10n = AppLocalizations.of(context)!;
    return _PrimaryButton(
      label: l10n.rdPaywallCtaTrial,
      height: 54,
      // No real checkout (no billing backend); flips the shared Plus flag so
      // the member view + Account plan row update.
      onTap: _subscribe,
    );
  }

  Widget _fine() {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final then =
        _plan == _Plan.annual ? l10n.rdPaywallThenAnnual : l10n.rdPaywallThenMonthly;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
        child: Text(
          '$then · cancel anytime.\nNo charge today — we’ll remind you before it ends.',
          textAlign: TextAlign.center,
          style: GoogleFonts.vazirmatn(
            fontSize: 12,
            height: 1.5,
            color: rd.muted,
          ),
        ),
      ),
    );
  }

  Widget _links() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LinkButton(l10n.rdPaywallRestore, onTap: () => _toast(l10n.rdPaywallComingSoon)),
        _linkDot(),
        _LinkButton(l10n.rdPaywallTerms, onTap: () => _toast(l10n.rdPaywallTermsToast)),
        _linkDot(),
        _LinkButton(l10n.rdPaywallPrivacy,
            onTap: () => _toast(l10n.rdPaywallPrivacyToast)),
      ],
    );
  }

  Widget _linkDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Text(
        '·',
        style: GoogleFonts.vazirmatn(fontSize: 11, color: context.rd.faint),
      ),
    );
  }

  // ══ member view (active Plus) ══════════════════════════════════════════
  Widget _memberView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        _Hero(
          live: true,
          badge: l10n.rdPaywallActiveBadge,
          title: l10n.rdPaywallActiveTitle,
          sub: l10n.rdPaywallActiveSubtitle,
        ),
        const SizedBox(height: 26),
        _memCard(),
        const SizedBox(height: 18),
        _usage(),
        const SizedBox(height: 26),
        _perksLabel(),
        const SizedBox(height: 10),
        _perks(),
        const SizedBox(height: 26),
        _PrimaryButton(
          label: l10n.rdPaywallManage,
          height: 52,
          onTap: () => _toast(l10n.rdPaywallComingSoon),
        ),
        const SizedBox(height: 9),
        _cancel(),
        const SizedBox(height: 20),
        _Trust(
          l10n.rdPaywallCancelNote,
          icon:
              '<rect x="4" y="11" width="16" height="10" rx="2.5"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
        ),
      ],
    );
  }

  Widget _memCard() {
    final rd = context.rd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        children: [
          _memRow('Plan', 'Annual · \$6/mo'),
          Divider(height: 1, thickness: 1, color: rd.line),
          _memRow('Renews', 'Aug 12, 2025'),
          Divider(height: 1, thickness: 1, color: rd.line),
          _memRow('Payment', 'Apple ID'),
        ],
      ),
    );
  }

  Widget _memRow(String k, String v) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: GoogleFonts.vazirmatn(fontSize: 13.5, color: rd.muted)),
          Text(
            v,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: rd.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _usage() {
    final rd = context.rd;
    // Bar track has no palette token: keep the exact light literal, darken for
    // dark mode (mirrors the neutral-track pattern in rd_settings.dart).
    final trackBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2B33)
        : const Color(0xFFEAEAE4);
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      decoration: BoxDecoration(
        color: rd.card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: rd.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Memories held',
                style: GoogleFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: rd.ink,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '1,284 '),
                    TextSpan(
                      text: '· unlimited',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: rd.success,
                      ),
                    ),
                  ],
                  style: GoogleFonts.dosis(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: rd.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 7,
              color: trackBg,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.34,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5F6FB8), Color(0xFF2E9E6C)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Growing calmly. On Free this would have stopped at 2,000.',
            style: GoogleFonts.vazirmatn(
              fontSize: 12,
              height: 1.45,
              color: rd.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _perksLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'YOUR PLUS PERKS',
        style: GoogleFonts.dosis(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.25,
          color: context.rd.muted,
        ),
      ),
    );
  }

  Widget _perks() {
    return Column(
      children: const [
        _Perk(
          icon:
              '<path d="M4 7c0-1 .9-2 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2Z"/><path d="M4 11h16"/>',
          title: 'Unlimited memories',
        ),
        _Perk(
          icon:
              '<circle cx="6" cy="6" r="2.4"/><circle cx="18" cy="10" r="2.4"/><circle cx="9" cy="18" r="2.4"/><path d="M8 7.5 15.5 9.5M8.5 16 16 11.5"/>',
          title: 'Full memory graph',
        ),
        _Perk(
          icon: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
          title: 'Longer history & 10-min voice',
        ),
        _Perk(
          icon:
              '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>',
          title: 'Unlimited connected apps',
        ),
      ],
    );
  }

  Widget _cancel() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // No real store call; flips the shared Plus flag back to Free.
      onTap: _cancelPlus,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(
          l10n.rdPaywallCancelCta,
          style: GoogleFonts.vazirmatn(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: context.rd.muted,
          ),
        ),
      ),
    );
  }
}

// ══ hero ═════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  const _Hero({
    required this.live,
    required this.badge,
    required this.title,
    required this.sub,
  });

  /// `true` renders the green "active" orb + badge; `false` the periwinkle
  /// upgrade orb + badge.
  final bool live;
  final String badge;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Badge chip: upgrade uses periSoft/navy; active uses a soft green fill.
    // The green chip has no token — keep the exact light tint, use a deep green
    // surface on dark (mirrors the success-chip handling in rd_settings.dart).
    final badgeBg = live
        ? (isDark ? const Color(0xFF1B2E24) : const Color(0xFFE4F3EB))
        : rd.periSoft;
    final badgeFg = live ? rd.success : rd.navy;
    return Column(
      children: [
        _Orb(live: live),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(13, 5, 13, 5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            badge.toUpperCase(),
            style: GoogleFonts.dosis(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: badgeFg,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.dosis(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.3,
            color: rd.ink,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              height: 1.55,
              color: rd.muted,
            ),
          ),
        ),
      ],
    );
  }
}

/// The layered gradient orb with two concentric halo rings. Periwinkle for the
/// upgrade offer, green for the active-member state.
class _Orb extends StatelessWidget {
  const _Orb({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    final core = live
        ? const [Color(0xFF9DE0BE), Color(0xFF2E9E6C)]
        : const [Color(0xFFA6B2E0), Color(0xFF5F6FB8)];
    final ringColor = live ? const Color(0xFF2E9E6C) : const Color(0xFF7E8BC9);
    final glow = live ? const Color(0xFF1F8A5B) : const Color(0xFF5F6FB8);
    return SizedBox(
      width: 62,
      height: 62,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer halo ring.
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
            ),
            // Inner halo ring.
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
            // Core.
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.32, -0.4),
                  colors: core,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.38),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ benefit row (upgrade) ══════════════════════════════════════════════════
class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title, required this.sub});

  final String icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rd.periSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: RdIcon(icon, size: 20, color: rd.navy, strokeWidth: 1.8),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: rd.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12.5,
                    height: 1.4,
                    color: rd.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══ plan card (upgrade) ════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.selected,
    required this.name,
    required this.price,
    required this.per,
    required this.note,
    required this.onTap,
    this.save,
  });

  final bool selected;
  final String name;
  final String price;
  final String per;
  final String note;
  final String? save;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Extra top margin leaves room for the "save" badge to overhang.
        margin: EdgeInsets.only(top: save != null ? 9 : 0),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
        decoration: BoxDecoration(
          color: rd.card,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? rd.navy : rd.line,
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: rd.periSoft, blurRadius: 0, spreadRadius: 3)]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: rd.muted,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.dosis(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: rd.ink,
                      ),
                    ),
                    Text(
                      per,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: rd.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  note,
                  style: GoogleFonts.vazirmatn(fontSize: 11.5, color: rd.faint),
                ),
              ],
            ),
            // Selected check — top-right.
            Positioned(
              top: -2,
              right: -2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rd.navy,
                  ),
                  child: const Center(
                    child: RdIcon(
                      RdIcons.check,
                      size: 12,
                      stroke: '#FFFFFF',
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
            // "Save" badge — overhangs the top-left corner.
            if (save != null)
              Positioned(
                top: -24,
                left: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: rd.success,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    save!,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══ perk row (member) ══════════════════════════════════════════════════════
class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.title});

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Green perk chip — no token; exact light tint, deep-green surface on dark.
    final chipBg = isDark ? const Color(0xFF1B2E24) : const Color(0xFFE4F3EB);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child:
                  RdIcon(icon, size: 17, color: rd.success, strokeWidth: 1.9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.vazirmatn(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: rd.ink,
              ),
            ),
          ),
          RdIcon(RdIcons.check, size: 14, color: rd.success, strokeWidth: 2.4),
        ],
      ),
    );
  }
}

// ══ trust footer ═══════════════════════════════════════════════════════════
class _Trust extends StatelessWidget {
  const _Trust(this.text, {this.icon});

  final String text;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Periwinkle info panel — mirrors _CaPrivacy in rd_settings.dart: exact
    // light tint, periSoft token on dark (its dark value is the deep surface).
    final panelBg = isDark ? rd.periSoft : const Color(0xFFEDEFF8);
    // Muted-blue body copy; on dark it reads against the deep panel as muted.
    final bodyColor = isDark ? rd.muted : const Color(0xFF55586A);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: RdIcon(
              icon ??
                  '<rect x="4" y="11" width="16" height="10" rx="2.5"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
              size: 14,
              color: rd.navy,
              strokeWidth: 1.9,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vazirmatn(
                fontSize: 12,
                height: 1.5,
                color: bodyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ primary button ═════════════════════════════════════════════════════════
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.height,
    required this.onTap,
  });

  final String label;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rd.navy,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: rd.navy.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ══ text link ══════════════════════════════════════════════════════════════
class _LinkButton extends StatelessWidget {
  const _LinkButton(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: GoogleFonts.vazirmatn(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: context.rd.muted,
        ),
      ),
    );
  }
}

// ══ close button ═══════════════════════════════════════════════════════════
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Frosted circle over the scroll. Design uses translucent white; on dark
    // use a translucent lifted card so the glyph stays legible.
    final bg = isDark
        ? rd.card.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        child: Center(
          child: RdIcon(RdIcons.close, size: 18, color: rd.muted, strokeWidth: 2),
        ),
      ),
    );
  }
}

// ══ demo toggle (design's pw-demo) ═════════════════════════════════════════
class _DemoToggle extends StatelessWidget {
  const _DemoToggle({
    required this.member,
    required this.onFree,
    required this.onPlus,
  });

  final bool member;
  final VoidCallback onFree;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final rd = context.rd;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trayBg = isDark
        ? rd.card.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trayBg,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: rd.navy.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(l10n.rdPaywallDemoFree, !member, onFree),
          const SizedBox(width: 3),
          _seg(l10n.rdPaywallDemoPlus, member, onPlus),
        ],
      ),
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap) {
    return Builder(builder: (context) {
      final rd = context.rd;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: on ? rd.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: GoogleFonts.vazirmatn(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: on ? Colors.white : rd.muted,
            ),
          ),
        ),
      );
    });
  }
}
