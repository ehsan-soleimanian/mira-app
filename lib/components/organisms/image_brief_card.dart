import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mira_app/components/atoms/brief_card_badge.dart';
import 'package:mira_app/components/molecules/brief_card_shell.dart';
import 'package:mira_app/models/daily_brief_models.dart';
import 'package:mira_app/theme/daily_brief_theme.dart';

class ImageBriefCard extends StatelessWidget {
  const ImageBriefCard({super.key, required this.item, this.onTap});

  final BriefImageItem item;
  final VoidCallback? onTap;

  static const _thumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    return BriefCardShell(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _Thumbnail(item: item),
      ),
      badge: BriefCardBadge(
        label: item.nodeType,
        background: DailyBriefColors.imageBadgeBg,
        textColor: DailyBriefColors.imageBadgeText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: Text(item.title, style: DailyBriefTypography.cardTitle(1)),
          ),
          const SizedBox(height: 4),
          Text(item.preview, style: DailyBriefTypography.cardBody(1)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final BriefImageItem item;

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeThumbnail(item.thumbnailB64);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: ImageBriefCard._thumbSize,
        height: ImageBriefCard._thumbSize,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    final asset = item.imageAsset;
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        width: ImageBriefCard._thumbSize,
        height: ImageBriefCard._thumbSize,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: ImageBriefCard._thumbSize,
      height: ImageBriefCard._thumbSize,
      color: DailyBriefColors.imageBadgeBg,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: DailyBriefColors.imageBadgeText,
        size: 28,
      ),
    );
  }

  Uint8List? _decodeThumbnail(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}
