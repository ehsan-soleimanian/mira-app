import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the design's exact line icons (24×24 viewBox) via SVG so they stay
/// pixel-faithful to the Figma paths. [body] is the inner SVG markup; [stroke]
/// is a CSS hex string (matching how the design specifies colours).
///
/// For theme-aware (text-tone) icons, pass [color] — a Flutter [Color] such as
/// `context.rd.ink` — and it overrides [stroke] so the icon flips with the
/// light/dark palette. Leave [color] null to keep the fixed hex [stroke] (used
/// for on-brand icons that stay constant across themes: white on navy
/// gradients, brand fills, colored type-badges).
class RdIcon extends StatelessWidget {
  const RdIcon(
    this.body, {
    super.key,
    this.size = 24,
    this.stroke = '#1B1C24',
    this.strokeWidth = 1.5,
    this.fill = 'none',
    this.color,
  });

  final String body;
  final double size;
  final String stroke;
  final double strokeWidth;
  final String fill;

  /// When non-null, overrides [stroke] with this theme colour so the icon
  /// adapts to light/dark. When null, the hex [stroke] is used verbatim.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedStroke = color != null ? _hex(color!) : stroke;
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
        'viewBox="0 0 24 24" fill="$fill" stroke="$resolvedStroke" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">$body</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }

  /// Formats a [Color] as an `#RRGGBB` hex string for the SVG `stroke`
  /// attribute (the alpha channel is dropped — icons are fully opaque).
  static String _hex(Color c) {
    final r = (c.r * 255.0).round() & 0xff;
    final g = (c.g * 255.0).round() & 0xff;
    final b = (c.b * 255.0).round() & 0xff;
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}

/// Inner path bodies for the icons the redesign uses, copied verbatim from the
/// design source (`components.jsx` / `app.jsx`) so they render identically.
abstract final class RdIcons {
  static const gear =
      '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>';
  static const pencil =
      '<path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/>';
  static const mic =
      '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 19v3"/>';
  static const micSimple =
      '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/>';
  static const navHome = '<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/>';
  static const navLibrary =
      '<path d="M4 5h11"/><path d="M4 10h11"/><path d="M4 15h7"/><circle cx="18.5" cy="16.5" r="3"/><path d="M20.8 18.8 23 21"/>';
  static const navCanvas =
      '<circle cx="12" cy="5" r="2.4"/><circle cx="5.5" cy="18" r="2.4"/><circle cx="18.5" cy="18" r="2.4"/><path d="M11 7 6.6 15.8"/><path d="M13 7l4.4 8.8"/><path d="M7.9 18h8.2"/>';
  static const navBrief =
      '<circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/>';
  static const link =
      '<circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="M8.2 10.8 15.8 7"/><path d="M8.2 13.2 15.8 17"/>';

  // Daily Brief
  static const clock = '<circle cx="12" cy="12" r="9"/><path d="M12 8v4l3 2"/>';
  static const calendar =
      '<rect x="3" y="4" width="18" height="17" rx="2.5"/><path d="M16 2v4M8 2v4M3 10h18"/>';
  static const checkCircle =
      '<circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/>';
  static const bulb =
      '<path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.2 1 2h6c0-.8.4-1.5 1-2A7 7 0 0 0 12 2Z"/><path d="M9 21h6"/>';
  static const dueClock =
      '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/>';
  static const resurface =
      '<path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/>';
  static const vinyl =
      '<path d="M9 18V5l10-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/>';
  static const book =
      '<path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v18H6.5A2.5 2.5 0 0 0 4 22.5z"/><path d="M4 4.5v15"/>';
  static const check = '<path d="M20 6 9 17l-5-5"/>';
  static const checkThick = '<path d="m5 12 5 5 9-11"/>';
  static const chevronLeft = '<path d="M15 5 8 12l7 7"/>';

  // Library
  static const search = '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>';
  static const bell =
      '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>';
  static const moon =
      '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>';
  static const photo =
      '<rect x="3" y="5" width="18" height="14" rx="2.5"/><circle cx="12" cy="12" r="3.2"/>';
  static const linkChain =
      '<path d="M10 13a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/><path d="M14 11a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>';
  static const people =
      '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>';
  static const pin =
      '<path d="M12 21s-7-5.5-7-11a7 7 0 0 1 14 0c0 5.5-7 11-7 11Z"/><circle cx="12" cy="10" r="2.5"/>';
  static const work =
      '<rect x="3" y="4" width="18" height="16" rx="2.5"/><path d="M3 9h18M8 4v5"/>';
  static const folder =
      '<path d="M3 7a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>';
  static const close = '<path d="M6 6l12 12M18 6 6 18"/>';
  static const pushpin = '<path d="M12 17v5M9 3h6l-1 6 3 3H7l3-3-1-6Z"/>';
  static const archive =
      '<rect x="3" y="4" width="18" height="4" rx="1"/><path d="M5 8v11a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8M10 12h4"/>';
  static const trash =
      '<path d="M4 7h16M9 7V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13"/>';

  // Canvas
  static const hash = '<path d="M4 9h16M4 15h16M10 3 8 21M16 3l-2 18"/>';
  static const plusCircle = '<path d="M8 12h8M12 8v8"/><circle cx="12" cy="12" r="9"/>';
  static const move =
      '<path d="M5 9l-3 3 3 3M9 5l3-3 3 3M15 19l-3 3-3-3M19 9l3 3-3 3M2 12h20M12 2v20"/>';
  static const addCard =
      '<rect x="4" y="4" width="16" height="16" rx="3"/><path d="M12 9v6M9 12h6"/>';
  static const textT = '<path d="M5 6h14M12 6v13"/>';
  static const connect =
      '<circle cx="6" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="M8 8l8 8"/>';
  static const grid4 =
      '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>';

  // Onboarding
  static const arrowLeft = '<path d="M9.57 5.93 3.5 12l6.07 6.07M20.5 12H3.67"/>';
  static const shield =
      '<path d="M10.49 2.23 5.5 4.1C4.35 4.53 3.41 5.89 3.41 7.11v7.43c0 1.18.78 2.73 1.73 3.44l4.3 3.21c1.41 1.06 3.73 1.06 5.14 0l4.3-3.21c.95-.71 1.73-2.26 1.73-3.44V7.11c0-1.23-.94-2.59-2.09-3.02l-4.99-1.86c-.85-.31-2.21-.31-3.04 0Z"/>';
  static const shieldCheck =
      '<path d="M10.49 2.23 5.5 4.1C4.35 4.53 3.41 5.89 3.41 7.11v7.43c0 1.18.78 2.73 1.73 3.44l4.3 3.21c1.41 1.06 3.73 1.06 5.14 0l4.3-3.21c.95-.71 1.73-2.26 1.73-3.44V7.11c0-1.23-.94-2.59-2.09-3.02l-4.99-1.86c-.85-.31-2.21-.31-3.04 0Z"/><path d="M9.05 11.87 11 13.82l4-4"/>';
  static const user =
      '<circle cx="12" cy="6.5" r="3.7"/><path d="M5.4 19.6c0-3.16 2.95-5.72 6.6-5.72s6.6 2.56 6.6 5.72"/>';
  static const attachMic =
      '<path d="M12 14.4a2.5 2.5 0 0 0 2.5-2.5V6.5a2.5 2.5 0 1 0-5 0v5.4a2.5 2.5 0 0 0 2.5 2.5Z"/><path d="M7.5 10.8v1.1a4.5 4.5 0 0 0 9 0v-1.1"/>';
}
