import 'package:flutter/material.dart';
import 'package:mira_app/theme/app_colors.dart';
import 'package:mira_app/theme/mira_spacing.dart';

/// Floating capture options — Text, Link, Image (short tap on mic).
class CaptureBubbleMenu extends StatelessWidget {
  const CaptureBubbleMenu({
    super.key,
    required this.onTextTap,
    this.onLinkTap,
    this.onImageTap,
    this.onDismiss,
  });

  final VoidCallback onTextTap;
  final VoidCallback? onLinkTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BubbleRow(
            items: [
              _BubbleItem(
                label: 'Text',
                icon: Icons.edit_outlined,
                onTap: onTextTap,
              ),
              _BubbleItem(
                label: 'Link',
                icon: Icons.link_rounded,
                onTap: onLinkTap ??
                    () => _snack(context, 'Link capture — coming soon'),
              ),
              _BubbleItem(
                label: 'Image',
                icon: Icons.image_outlined,
                onTap: onImageTap ??
                    () => _snack(context, 'Image capture — coming soon'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BubbleRow extends StatefulWidget {
  const _BubbleRow({required this.items});

  final List<_BubbleItem> items;

  @override
  State<_BubbleRow> createState() => _BubbleRowState();
}

class _BubbleRowState extends State<_BubbleRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final start = i * 0.12;
              final t = Curves.easeOutBack.transform(
                ((_controller.value - start) / (1 - start)).clamp(0.0, 1.0),
              );
              return Transform.scale(
                scale: t,
                child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : MiraSpacing.sm,
                right: i == widget.items.length - 1 ? 0 : MiraSpacing.sm,
              ),
              child: _BubbleChip(item: widget.items[i]),
            ),
          ),
      ],
    );
  }
}

class _BubbleItem {
  const _BubbleItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _BubbleChip extends StatelessWidget {
  const _BubbleChip({required this.item});

  final _BubbleItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MiraSpacing.md,
            vertical: MiraSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: AppColors.micBlueNav, size: 20),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
