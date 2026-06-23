import 'package:flutter/material.dart';

/// Mira App — text button system (Figma `Mira-App / 742-13615`).
///
/// One widget covers the whole board:
///   • [MiraButtonVariant] : filled | outlined
///   • [MiraButtonColor]   : primary (navy) | secondary (blue) | danger (red)
///   • [MiraButtonSize]    : small (h38, r8) | large (h53, r14 — CTA)
///   • states              : default / hover / pressed (via ink overlay) and
///                           disabled (when [onPressed] is null)
///
/// ```dart
/// MiraButton(label: 'Continue', onPressed: _next);                       // primary filled
/// MiraButton(label: 'Secondary', color: MiraButtonColor.secondary);
/// MiraButton(label: 'Logout', color: MiraButtonColor.danger);
/// MiraButton(label: 'Continue', variant: MiraButtonVariant.outlined);
/// MiraButton(label: 'Set new note', size: MiraButtonSize.large, expand: true);
/// ```
enum MiraButtonVariant { filled, outlined }

enum MiraButtonColor { primary, secondary, danger }

enum MiraButtonSize { small, large }

class MiraButton extends StatelessWidget {
  const MiraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MiraButtonVariant.filled,
    this.color = MiraButtonColor.primary,
    this.size = MiraButtonSize.small,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MiraButtonVariant variant;
  final MiraButtonColor color;
  final MiraButtonSize size;

  /// Stretch to the full available width (typical for the large CTA).
  final bool expand;

  static const Color _navy = Color(0xFF002A8C);
  static const Color _blue = Color(0xFF4364E8);
  static const Color _red = Color(0xFF971B28);
  static const Color _disabledFill = Color(0xFFD9DEE7);
  static const Color _disabledText = Color(0xFF9AA1B1);
  static const Color _disabledBorder = Color(0xFFD3D8E1);

  Color get _base => switch (color) {
        MiraButtonColor.primary => _navy,
        MiraButtonColor.secondary => _blue,
        MiraButtonColor.danger => _red,
      };

  bool get _large => size == MiraButtonSize.large;
  double get _height => _large ? 53 : 38;
  double get _radius => _large ? 14 : 8;
  double get _fontSize => _large ? 16 : 15;
  double get _hPad => _large ? 28 : 22;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final filled = variant == MiraButtonVariant.filled;

    final Color bg =
        filled ? (enabled ? _base : _disabledFill) : Colors.transparent;
    final Color fg = filled
        ? (enabled ? Colors.white : _disabledText)
        : (enabled ? _base : _disabledText);
    final BorderSide side = filled
        ? BorderSide.none
        : BorderSide(color: enabled ? _base : _disabledBorder, width: 1);

    Widget button = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: side,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          final overlay = filled ? Colors.black : _base;
          if (states.contains(WidgetState.pressed)) {
            return overlay.withValues(alpha: filled ? 0.16 : 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return overlay.withValues(alpha: filled ? 0.08 : 0.06);
          }
          return null;
        }),
        child: Container(
          height: _height,
          padding: EdgeInsets.symmetric(horizontal: _hPad),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
