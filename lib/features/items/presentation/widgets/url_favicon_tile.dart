import 'package:flutter/material.dart';
import '../../domain/entities/item.dart';

class UrlFaviconTile extends StatelessWidget {
  const UrlFaviconTile({
    super.key,
    required this.item,
    this.size = 18,
  });

  final Item item;
  final double size;

  String? _normalizedUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://$value';
  }

  String _fallbackDomain(String? normalizedUrl) {
    if (normalizedUrl == null) return '';
    try {
      final host = Uri.parse(normalizedUrl).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return '';
    }
  }

  String _faviconUrl(String normalizedUrl) {
    return 'https://www.google.com/s2/favicons?sz=64&domain_url=$normalizedUrl';
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizedUrl(item.link);
    final fallbackDomain = _fallbackDomain(normalized);

    final fallback = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackDomain.isNotEmpty ? fallbackDomain[0].toUpperCase() : 'L',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );

    if (normalized == null) {
      return SizedBox(width: size, height: size, child: fallback);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          _faviconUrl(normalized),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

