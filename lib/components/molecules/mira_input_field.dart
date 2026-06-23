import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/mira_composer_glyphs.dart';
import 'package:mira_app/components/molecules/mira_gradient_border_painter.dart';
import 'package:mira_app/components/molecules/mira_send_button.dart';
import 'package:mira_app/theme/composer_tokens.dart';

/// Pill text field — Figma `742-11005` + active state `742-11091`.
///
/// **Composer mode** (default when [showMic] is true and no [trailing]):
/// empty → grey border + mic; typing → blue border + glow + send button.
///
/// **Form mode** ([showMic] false or [trailing] set): static grey border for
/// login / settings fields.
///
/// **Flat variant** ([variant] flat): single fill + solid border — no gradient
/// shine (onboarding «Your details», auth email fields).
enum MiraInputVariant { raised, flat }

class MiraInputField extends StatefulWidget {
  const MiraInputField({
    super.key,
    this.hintText = 'Type here...',
    this.controller,
    this.focusNode,
    this.onMicTap,
    this.onSend,
    this.onSubmitted,
    this.height = ComposerTokens.inputHeight,
    this.radius = ComposerTokens.inputRadius,
    this.showMic = true,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enabled = true,
    this.sendButtonSize = ComposerTokens.sendButtonSize,
    this.maxLines = 1,
    this.variant = MiraInputVariant.raised,
    this.onChanged,
    this.flatFillColor,
    this.flatBoxShadow,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onMicTap;
  final ValueChanged<String>? onSend;
  final ValueChanged<String>? onSubmitted;
  final double height;
  final double radius;
  final bool showMic;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enabled;
  final double sendButtonSize;
  final int maxLines;
  final MiraInputVariant variant;
  final ValueChanged<String>? onChanged;
  /// Override fill for [MiraInputVariant.flat] (e.g. white capture card).
  final Color? flatFillColor;
  final List<BoxShadow>? flatBoxShadow;

  bool get _composerMode =>
      variant == MiraInputVariant.raised &&
      showMic &&
      trailing == null &&
      !obscureText;

  @override
  State<MiraInputField> createState() => _MiraInputFieldState();
}

class _MiraInputFieldState extends State<MiraInputField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final bool _ownsController = widget.controller == null;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.trim().isNotEmpty;
    if (widget._composerMode) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void didUpdateWidget(covariant MiraInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget._composerMode) {
        oldWidget.controller?.removeListener(_onTextChanged);
      }
      if (widget._composerMode) {
        _controller.addListener(_onTextChanged);
        _hasText = _controller.text.trim().isNotEmpty;
      }
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    if (widget._composerMode) {
      _controller.removeListener(_onTextChanged);
    }
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text;
    if (widget.onSend != null) {
      widget.onSend!(text);
    } else {
      widget.onSubmitted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == MiraInputVariant.flat) {
      return _buildFlatField();
    }

    final active = widget._composerMode && _hasText;
    final borderLayers =
        active ? ComposerTokens.blueBorderLayers : ComposerTokens.greyBorderLayers;

    Widget? suffix;
    if (widget.trailing != null) {
      suffix = widget.trailing;
    } else if (widget._composerMode) {
      suffix = active
          ? MiraSendButton(
              size: widget.sendButtonSize,
              onTap: _handleSend,
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onMicTap,
              child: const SizedBox(
                width: 21,
                height: 24,
                child: CustomPaint(
                  painter: MiraComposerMicPainter(ComposerTokens.glyphColor),
                ),
              ),
            );
    } else if (widget.showMic) {
      suffix = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onMicTap,
        child: const SizedBox(
          width: 21,
          height: 24,
          child: CustomPaint(
            painter: MiraComposerMicPainter(ComposerTokens.glyphColor),
          ),
        ),
      );
    }

    final textColor = widget._composerMode
        ? ComposerTokens.composerTextColor
        : ComposerTokens.formTextColor;

    return Container(
      height: widget.height,
      decoration: ComposerTokens.raisedSurfaceDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        active: active,
      ),
      child: CustomPaint(
        painter: MiraGradientBorderPainter(
          radius: widget.radius,
          layers: borderLayers,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: suffix != null ? (active ? 7 : 12) : 18,
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: widget.maxLines > 1 ? 14 : 0),
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    onSubmitted: widget.onSubmitted,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    autocorrect: widget.autocorrect,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    textAlignVertical: widget.maxLines > 1
                        ? TextAlignVertical.top
                        : TextAlignVertical.center,
                    onChanged: widget.onChanged,
                    cursorColor: ComposerTokens.glyphColor,
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        color: ComposerTokens.hintColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 8),
                suffix,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlatField() {
    final fill = widget.flatFillColor ?? ComposerTokens.flatFieldFill;
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: ComposerTokens.flatFieldBorder,
          width: 1,
        ),
        boxShadow: widget.flatBoxShadow,
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        widget.maxLines > 1 ? 16 : 0,
        18,
        widget.maxLines > 1 ? 16 : 0,
      ),
      alignment: widget.maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onSubmitted: widget.onSubmitted,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autocorrect: widget.autocorrect,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        textAlignVertical: widget.maxLines > 1
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        onChanged: widget.onChanged,
        cursorColor: ComposerTokens.glyphColor,
        style: const TextStyle(
          color: ComposerTokens.formTextColor,
          fontSize: 15,
        ),
        decoration: InputDecoration.collapsed(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: ComposerTokens.hintColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
