import 'package:flutter/material.dart';

import '../../../../core/constants/app_categories.dart';

/// Multi-select category picker for folder filters. Shows only presets not yet
/// selected; supports custom labels. Calls [onDone] with the full selection set.
Future<void> showFolderFilterCategoryPicker({
  required BuildContext context,
  required Set<String> initialSelection,
  required ValueChanged<Set<String>> onDone,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => _FolderFilterCategoryPickerBody(
      initialSelection: initialSelection,
      onDone: onDone,
    ),
  );
}

class _FolderFilterCategoryPickerBody extends StatefulWidget {
  const _FolderFilterCategoryPickerBody({
    required this.initialSelection,
    required this.onDone,
  });

  final Set<String> initialSelection;
  final ValueChanged<Set<String>> onDone;

  @override
  State<_FolderFilterCategoryPickerBody> createState() =>
      _FolderFilterCategoryPickerBodyState();
}

class _FolderFilterCategoryPickerBodyState
    extends State<_FolderFilterCategoryPickerBody> {
  late Set<String> _draft;
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = Set<String>.from(widget.initialSelection);
  }

  @override
  void dispose() {
    _customController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _addCustom() {
    final t = _customController.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _draft.add(t);
      _customController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurfaceVariant;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.78;
    final q = _filterController.text.trim().toLowerCase();

    final available = AppCategories.list
        .where((c) => !_draft.contains(c))
        .where((c) {
          if (q.isEmpty) return true;
          return c.toLowerCase().contains(q);
        })
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: maxH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Tap a preset to add it. Only categories not yet selected are listed.',
                style: theme.textTheme.bodySmall?.copyWith(color: subtle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustom(),
                      decoration: InputDecoration(
                        labelText: 'Custom category',
                        hintText: 'Type and add',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton.filledTonal(
                      onPressed: _addCustom,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _filterController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Filter presets',
                  hintText: 'Search list',
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: available.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          q.isEmpty
                              ? 'All presets are selected or none match.'
                              : 'No presets match your filter.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: subtle),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final label = available[index];
                        return Material(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _draft.add(label)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: () {
                  widget.onDone(Set<String>.from(_draft));
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
