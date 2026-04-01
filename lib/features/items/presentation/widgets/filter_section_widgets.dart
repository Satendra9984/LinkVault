import 'package:flutter/material.dart';

/// Shared visual tokens for folder/url filter full screens.
abstract final class FilterSectionTokens {
  static const double radius = 16;
  static const double borderWidth = 1;
  static const double sectionGap = 16;
}

/// Bordered surface grouping for filter sections.
class FilterSectionCard extends StatelessWidget {
  const FilterSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(FilterSectionTokens.radius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          width: FilterSectionTokens.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: subtle,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(color: subtle),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Tappable row with leading badge icon, primary label, optional date line, trailing action.
class FilterDateRow extends StatelessWidget {
  const FilterDateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onPickDate,
    required this.onTrailingPressed,
    required this.trailingIsClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPickDate;
  final VoidCallback onTrailingPressed;

  /// When true, trailing shows clear; otherwise calendar (pick).
  final bool trailingIsClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final hasValue = value != null;
    final loc = MaterialLocalizations.of(context);

    final borderColor = hasValue
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.55);
    final fill = hasValue
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.22)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPickDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: hasValue
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue
                          ? loc.formatShortDate(value!)
                          : 'Tap to choose a date',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasValue
                            ? theme.colorScheme.onSurface
                            : subtle,
                        fontStyle:
                            hasValue ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onTrailingPressed,
                icon: Icon(
                  trailingIsClear ? Icons.clear_rounded : Icons.edit_calendar,
                  size: 22,
                ),
                tooltip: trailingIsClear ? 'Clear' : 'Choose date',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Archive / boolean row with switch inside a card-style surface.
class FilterArchiveRow extends StatelessWidget {
  const FilterArchiveRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: subtle),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
