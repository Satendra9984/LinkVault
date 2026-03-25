import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../domain/collection_display_defaults.dart';
import '../providers/forms/collection_form_notifier.dart';

/// Description + display defaults, styled like other create/edit form blocks
/// (24px corners, 20×16 padding on fields).
class CollectionExtendedFieldsSection extends ConsumerWidget {
  final Color inputBgColor;
  final Color textColor;

  const CollectionExtendedFieldsSection({
    super.key,
    required this.inputBgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(collectionFormNotifierProvider);
    final notifier = ref.read(collectionFormNotifierProvider.notifier);
    final subtle = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SmartFormField(
            label: 'Description',
            hint: 'Optional — shown on cards and for search later',
            initialValue: state.description,
            onChanged: notifier.updateDescription,
            maxLines: 3,
            errorText: state.fieldErrors['description'],
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display defaults',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Separate layouts for nested folders and saved links.',
                style: TextStyle(color: subtle, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _fieldLabel(subtle, 'Folders in this list'),
              const SizedBox(height: 8),
              _layoutChips(
                theme: theme,
                textColor: textColor,
                selected: CollectionLayoutMode.normalize(
                    state.childCollectionsLayout),
                onSelect: notifier.updateChildCollectionsLayout,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: subtle.withValues(alpha: 0.25)),
              ),
              _fieldLabel(subtle, 'Saved links'),
              const SizedBox(height: 8),
              _layoutChips(
                theme: theme,
                textColor: textColor,
                selected:
                    CollectionLayoutMode.normalize(state.itemsLayout),
                onSelect: notifier.updateItemsLayout,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: subtle.withValues(alpha: 0.25)),
              ),
              _fieldLabel(subtle, 'Default sort (links)'),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: CollectionItemsSortDefault.normalize(
                        state.itemsSortDefault),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.colorScheme.surfaceContainerHigh,
                    style: TextStyle(color: textColor, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                        value: CollectionItemsSortDefault.manual,
                        child: Text('Manual order'),
                      ),
                      DropdownMenuItem(
                        value: CollectionItemsSortDefault.addedDesc,
                        child: Text('Newest first'),
                      ),
                      DropdownMenuItem(
                        value: CollectionItemsSortDefault.titleAsc,
                        child: Text('Title A–Z'),
                      ),
                      DropdownMenuItem(
                        value: CollectionItemsSortDefault.lastOpenedDesc,
                        child: Text('Last opened'),
                      ),
                    ],
                    onChanged: notifier.updateItemsSortDefault,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: subtle.withValues(alpha: 0.25)),
              ),
              _fieldLabel(subtle, 'Open links'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: CollectionOpenLinksIn.inApp,
                    label: Text('In app'),
                    icon: Icon(Icons.open_in_browser_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: CollectionOpenLinksIn.externalBrowser,
                    label: Text('Browser'),
                    icon: Icon(Icons.launch_outlined, size: 18),
                  ),
                ],
                selected: {
                  CollectionOpenLinksIn.normalize(state.openLinksIn),
                },
                onSelectionChanged: (s) {
                  if (s.isNotEmpty) notifier.updateOpenLinksIn(s.first);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Show link previews',
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                subtitle: Text(
                  'Thumbnails when available.',
                  style: TextStyle(color: subtle, fontSize: 12),
                ),
                value: state.showLinkPreviews,
                onChanged: notifier.updateShowLinkPreviews,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _fieldLabel(Color subtle, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: subtle,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _layoutChips({
    required ThemeData theme,
    required Color textColor,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    final modes = <String, String>{
      CollectionLayoutMode.list: 'List',
      CollectionLayoutMode.grid: 'Grid',
      CollectionLayoutMode.compactGrid: 'Compact',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modes.entries.map((e) {
        final isSel = e.key == selected;
        return FilterChip(
          label: Text(e.value),
          selected: isSel,
          showCheckmark: false,
          labelStyle: TextStyle(
            color: isSel ? theme.colorScheme.onPrimary : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          selectedColor: theme.colorScheme.primary,
          backgroundColor:
              theme.colorScheme.surface.withValues(alpha: 0.45),
          side: BorderSide(
            color: isSel
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.28),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (_) => onSelect(e.key),
        );
      }).toList(),
    );
  }
}
