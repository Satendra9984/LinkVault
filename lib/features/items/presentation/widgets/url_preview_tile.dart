import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';
import 'url_favicon_tile.dart';
import '../../../../core/theme/color_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UrlPreviewTile extends StatelessWidget {
  const UrlPreviewTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.compact = false,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool compact;

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Icons.schedule_rounded;
      case ItemStatus.read:
        return Icons.check_circle_outline_rounded;
      case ItemStatus.archived:
        return Icons.star_border_rounded;
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return Colors.orange;
      case ItemStatus.read:
        return Colors.green;
      case ItemStatus.archived:
        return AppColors.primary;
    }
  }

  String _getStatusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.unread:
        return 'Unread';
      case ItemStatus.read:
        return 'Read';
      case ItemStatus.archived:
        return 'Archived';
    }
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _parseDominantColor(item.dominantColor) ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: const Icon(Icons.image_outlined),
    );
  }

  Color? _parseDominantColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    final raw = hex.replaceAll('#', '');
    final normalized = raw.length == 6 ? 'FF$raw' : raw;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  String _domain(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final normalized = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    try {
      final host = Uri.parse(normalized).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return rawUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = _domain(item.link);
    final statusColor = _getStatusColor(item.status);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: compact
                  ? SizedBox(
                      height: (44 *
                              MediaQuery.textScalerOf(context)
                                  .scale(1.0))
                          .clamp(44.0, 58.0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: (8 /
                                  MediaQuery.textScalerOf(context)
                                      .scale(1.0))
                              .clamp(3.0, 8.0),
                        ),
                        child: Row(
                          children: [
                            UrlFaviconTile(item: item, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 168;
                        final maxW = constraints.maxWidth;
                        final maxH = constraints.maxHeight;
                        final pad = narrow ? 10.0 : 12.0;
                        final scaler =
                            MediaQuery.textScalerOf(context).scale(1.0);
                        final titleBaseSize = narrow ? 13.0 : 14.0;
                        final descFontSize = narrow ? 11.0 : 12.0;
                        final hasDesc = item.description != null &&
                            item.description!.trim().isNotEmpty;

                        // Spec 8.11: title is always up to 2 lines; shrink image before title.
                        final gapAfterDomain = narrow ? 4.0 : 6.0;
                        final titleLineH = titleBaseSize * 1.25 * scaler;
                        // Small buffer so two lines are not clipped by rounding / font metrics.
                        const titleBlockBuffer = 4.0;
                        final minTitleBlockH = titleLineH * 2 + titleBlockBuffer;
                        final domainRowH = math.max(
                          narrow ? 18.0 : 20.0,
                          descFontSize * 1.2 * scaler + 2,
                        );
                        final footerMinForTitle = pad * 2 +
                            domainRowH +
                            gapAfterDomain +
                            minTitleBlockH;
                        final idealImageH = maxW * 9 / 16;
                        var imageH = math.min(
                          idealImageH,
                          math.max(0.0, maxH - footerMinForTitle),
                        );
                        imageH = math.min(imageH, maxH * 0.62);

                        Widget previewBlock() {
                          final url = item.imageUrl?.trim();
                          final path = item.imagePath?.trim();
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: url != null && url.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (ctx, _) =>
                                        _imagePlaceholder(ctx),
                                    errorWidget: (ctx, _, __) =>
                                        _imagePlaceholder(ctx),
                                  )
                                : path != null && path.isNotEmpty
                                    ? Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            _imagePlaceholder(context),
                                      )
                                    : _imagePlaceholder(context),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: imageH,
                              child: previewBlock(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(pad),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        UrlFaviconTile(
                                            item: item,
                                            size: narrow ? 16 : 18),
                                        SizedBox(width: narrow ? 6 : 8),
                                        Expanded(
                                          child: Text(
                                            domain,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: descFontSize,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: gapAfterDomain),
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, textBox) {
                                          final innerH = textBox.maxHeight;
                                          final gapTitleDesc =
                                              hasDesc ? (narrow ? 4.0 : 6.0) : 0.0;
                                          final descLineH =
                                              descFontSize * 1.25 * scaler;
                                          final titleSlotH = math.min(
                                            innerH,
                                            minTitleBlockH,
                                          );

                                          final titleStyle = TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: titleBaseSize,
                                            height: 1.25,
                                          );
                                          final descStyle = TextStyle(
                                            fontSize: descFontSize,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            height: 1.25,
                                          );

                                          // Degrade description only; title stays 2 lines (spec 8.11).
                                          var descMaxLines = 0;
                                          if (hasDesc) {
                                            final afterTitle =
                                                innerH - titleSlotH;
                                            if (afterTitle > gapTitleDesc) {
                                              final descAvail =
                                                  afterTitle - gapTitleDesc;
                                              if (!narrow &&
                                                  descAvail >=
                                                      descLineH * 2 - 1) {
                                                descMaxLines = 2;
                                              } else if (descAvail >=
                                                  descLineH - 1) {
                                                descMaxLines = 1;
                                              }
                                            }
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: titleSlotH,
                                                width: double.infinity,
                                                child: Align(
                                                  alignment:
                                                      Alignment.topLeft,
                                                  child: Text(
                                                    item.title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: titleStyle,
                                                  ),
                                                ),
                                              ),
                                              if (hasDesc &&
                                                  descMaxLines > 0) ...[
                                                SizedBox(height: gapTitleDesc),
                                                Expanded(
                                                  child: Text(
                                                    item.description!,
                                                    maxLines: descMaxLines,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: descStyle,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ),
            if (!compact)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(item.status),
                          size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(item.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
