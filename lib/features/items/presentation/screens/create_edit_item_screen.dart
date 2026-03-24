import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/presentation/widgets/smart_form_field.dart';
import '../../../../core/theme/color_palette.dart';
import '../../domain/entities/item.dart';
import '../providers/forms/item_form_notifier.dart';

/// Create / Edit screen for a single Item.
///
/// Architecture: Controller-Free Form Pattern (Riverpod + SmartFormField)
/// - Screen owns ZERO controllers — ItemFormNotifier is single source of truth.
/// - SmartFormField.didUpdateWidget handles edit-mode pre-population automatically.
///
/// Layout exactly matches Behance:
/// - Micro-label above value in every field (iOS-style)
/// - Each field is its own individual card
/// - Left-aligned 120px image thumbnail
/// - Inline animated status dropdown
/// - Each expanded More Field = its own card
/// - Congratulations dialog on success
class CreateEditItemScreen extends ConsumerStatefulWidget {
  final String collectionId;
  final String? collectionName;
  final String? itemId;

  const CreateEditItemScreen({
    super.key,
    required this.collectionId,
    this.collectionName,
    this.itemId,
  });

  @override
  ConsumerState<CreateEditItemScreen> createState() =>
      _CreateEditItemScreenState();
}

class _CreateEditItemScreenState extends ConsumerState<CreateEditItemScreen> {
  bool _statusOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(itemFormNotifierProvider.notifier).initialize(widget.itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemFormNotifierProvider);
    final notifier = ref.read(itemFormNotifierProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.itemId != null;

    ref.listen(itemFormNotifierProvider, (previous, next) {
      if (next.isSuccess && context.mounted) {
        _showSuccessDialog(context);
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    // Adaptive surface colors
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF4F4F6);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final microLabelColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    final valueTextColor = isDark ? Colors.white : Colors.black87;
    final dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          (isEdit ? 'Edit Item' : 'New Item'),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onPressed: () {},
            ),
        ],
      ),
      body: state.isInit && isEdit
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Title field — own card ─────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Item title',
                            isRequired: true,
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'Enter title',
                              initialValue: state.title,
                              onChanged: notifier.updateTitle,
                              errorText: state.fieldErrors['title'],
                              autofocus: !isEdit,
                              style: TextStyle(
                                fontSize: 15,
                                color: valueTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Image field — own card ─────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _ImageLabeledRow(
                            imagePath: state.imagePath,
                            isDark: isDark,
                            labelColor: microLabelColor,
                            onPickTap: () =>
                                _showImageSourceSheet(context, notifier),
                            onRemove: () => notifier.updateImagePath(null),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Description field — own card ───────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Description',
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'Add a note...',
                              initialValue: state.description,
                              onChanged: notifier.updateDescription,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 15,
                                color: valueTextColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Status field — own card, inline dropdown ───
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _StatusInlineDropdown(
                            status: state.status,
                            isOpen: _statusOpen,
                            isDark: isDark,
                            labelColor: microLabelColor,
                            valueColor: valueTextColor,
                            dividerColor: dividerColor,
                            onTap: () =>
                                setState(() => _statusOpen = !_statusOpen),
                            onSelect: (s) {
                              notifier.updateStatus(s);
                              setState(() => _statusOpen = false);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── More fields label + chips ──────────────────
                        _MoreFieldsChipsRow(
                          expandedFields: state.expandedFields,
                          isDark: isDark,
                          onToggle: notifier.toggleExpandedField,
                        ),

                        // ── Each expanded more-field = own card ────────
                        if (state.expandedFields.contains('link')) ...[
                          const SizedBox(height: 12),
                          _FieldCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: _LabeledField(
                              label: 'Link',
                              labelColor: microLabelColor,
                              child: SmartFormField(
                                hint: 'https://',
                                initialValue: state.link,
                                onChanged: notifier.updateLink,
                                keyboardType: TextInputType.url,
                                style: TextStyle(
                                    fontSize: 15, color: valueTextColor),
                              ),
                            ),
                          ),
                        ],

                        if (state.expandedFields.contains('location')) ...[
                          const SizedBox(height: 12),
                          _FieldCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: _LabeledField(
                              label: 'Location',
                              labelColor: microLabelColor,
                              child: SmartFormField(
                                hint: 'Address or place name',
                                initialValue: state.location,
                                onChanged: notifier.updateLocation,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 15, color: valueTextColor),
                              ),
                            ),
                          ),
                        ],

                        if (state.expandedFields.contains('tags')) ...[
                          const SizedBox(height: 12),
                          _FieldCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: _LabeledField(
                              label: 'Tags',
                              labelColor: microLabelColor,
                              child: SmartFormField(
                                hint: 'coffee, cozy, must-visit',
                                initialValue: state.tags,
                                onChanged: notifier.updateTags,
                                style: TextStyle(
                                    fontSize: 15, color: valueTextColor),
                              ),
                            ),
                          ),
                        ],

                        // ── Dynamic Custom Fields ──────────────────────
                        ...state.customFields.values.map((field) {
                          TextInputType keyboardType = TextInputType.text;
                          int maxLines = 1;

                          switch (field.type) {
                            case CustomFieldType.number:
                              keyboardType = TextInputType.number;
                              break;
                            case CustomFieldType.url:
                              keyboardType = TextInputType.url;
                              break;
                            case CustomFieldType.text:
                            default:
                              keyboardType = TextInputType.multiline;
                              maxLines = 2;
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _FieldCard(
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  child: _LabeledField(
                                    label: field.name,
                                    labelColor: microLabelColor,
                                    child: SmartFormField(
                                      hint: 'Enter ${field.name.toLowerCase()}',
                                      initialValue: field.value?.toString(),
                                      onChanged: (val) =>
                                          notifier.updateCustomFieldValue(
                                              field.id, val),
                                      keyboardType: keyboardType,
                                      maxLines: maxLines,
                                      style: TextStyle(
                                          fontSize: 15, color: valueTextColor),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () =>
                                        notifier.removeCustomField(field.id),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // ── Fixed bottom Save button ──────────────────────────
                Container(
                  color: bg,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: state.isSubmitting || state.isInit
                            ? null
                            : () => notifier.submit(
                                  collectionId: widget.collectionId,
                                  existingItemId: widget.itemId,
                                ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                isEdit ? 'Save changes' : 'Save',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  void _showImageSourceSheet(
      BuildContext context, ItemFormNotifier notifier) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from device'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null && mounted) notifier.updateImagePath(picked.path);
    }
  }

  void _showAddCustomFieldSheet(
      BuildContext context, ItemFormNotifier notifier, bool isDark) {
    String fieldName = '';
    CustomFieldType fieldType = CustomFieldType.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Custom Field',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Field Name',
                  hintText: 'e.g. Rating, Cook Time, Deal Size',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) => fieldName = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CustomFieldType>(
                // ignore: deprecated_member_use
                value: fieldType,
                decoration: InputDecoration(
                  labelText: 'Field Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: CustomFieldType.text, child: Text('Text')),
                  DropdownMenuItem(
                      value: CustomFieldType.number, child: Text('Number')),
                  DropdownMenuItem(
                      value: CustomFieldType.url, child: Text('URL')),
                  // We can add Date/Boolean later when we build UI fields for them
                ],
                onChanged: (val) {
                  if (val != null) setState(() => fieldType = val);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (fieldName.trim().isNotEmpty) {
                    notifier.addCustomField(fieldName.trim(), fieldType);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Field',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final isEdit = widget.itemId != null;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded,
                      size: 52, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Congratulations!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                isEdit ? 'Item updated successfully' : 'New item is added',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Ok',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private building blocks
// ═══════════════════════════════════════════════════════════════════════════

/// Rounded white (or dark-surface) card wrapping a single field.
class _FieldCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color cardColor;

  const _FieldCard(
      {required this.child, required this.isDark, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: isDark
        //     ? null
        //     : [
        //         BoxShadow(
        //           color: Colors.black.withValues(alpha: 0.05),
        //           blurRadius: 10,
        //           offset: const Offset(0, 2),
        //         )
        //       ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: child,
    );
  }
}

/// Micro-label above + field below — Behance iOS-style form row.
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final Color labelColor;
  final bool isRequired;

  const _LabeledField({
    required this.label,
    required this.child,
    required this.labelColor,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: labelColor,
                letterSpacing: 0.1,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Image row: micro-label "Image" above, then left-aligned 120px thumbnail
/// (or dashed "+ " placeholder if no image).
class _ImageLabeledRow extends StatelessWidget {
  final String? imagePath;
  final bool isDark;
  final Color labelColor;
  final VoidCallback onPickTap;
  final VoidCallback onRemove;

  const _ImageLabeledRow({
    required this.imagePath,
    required this.isDark,
    required this.labelColor,
    required this.onPickTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 10),
        if (imagePath != null) ...[
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: onPickTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 350,
                        maxWidth: double.infinity,
                      ),
                      child: imagePath!.startsWith('http')
                          ? Image.network(imagePath!, fit: BoxFit.contain)
                          : Image.file(File(imagePath!), fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: onPickTap,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Status field: micro-label "Status" above, value + chevron below,
/// expands inline to show selectable options — no bottom sheet.
class _StatusInlineDropdown extends StatelessWidget {
  final ItemStatus status;
  final bool isOpen;
  final bool isDark;
  final Color labelColor;
  final Color valueColor;
  final Color dividerColor;
  final VoidCallback onTap;
  final ValueChanged<ItemStatus> onSelect;

  const _StatusInlineDropdown({
    required this.status,
    required this.isOpen,
    required this.isDark,
    required this.labelColor,
    required this.valueColor,
    required this.dividerColor,
    required this.onTap,
    required this.onSelect,
  });

  String _labelFor(ItemStatus s) {
    switch (s) {
      case ItemStatus.pending:
        return 'Pending';
      case ItemStatus.visited:
        return 'Visited';
      case ItemStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row — tappable
        GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    _labelFor(status),
                    style: TextStyle(fontSize: 15, color: valueColor),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Inline options — animated
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              Divider(height: 1, color: dividerColor),
              ...ItemStatus.values.map((s) {
                final selected = s == status;
                return InkWell(
                  onTap: () => onSelect(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          _labelFor(s),
                          style: TextStyle(
                            fontSize: 15,
                            color: selected ? AppColors.primary : valueColor,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(Icons.check,
                              size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// "More fields" section: label + horizontally scrollable chips.
/// Chips adapt color properly in both light AND dark mode.
class _MoreFieldsChipsRow extends ConsumerWidget {
  final Set<String> expandedFields;
  final bool isDark;
  final ValueChanged<String> onToggle;

  const _MoreFieldsChipsRow({
    required this.expandedFields,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More fields',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FieldChip(
              label: 'Location',
              active: expandedFields.contains('location'),
              isDark: isDark,
              onTap: () => onToggle('location'),
            ),
            _FieldChip(
              label: 'Tags',
              active: expandedFields.contains('tags'),
              isDark: isDark,
              onTap: () => onToggle('tags'),
            ),
            _FieldChip(
              label: 'Link',
              active: expandedFields.contains('link'),
              isDark: isDark,
              onTap: () => onToggle('link'),
            ),
            _FieldChip(
              label: 'Custom field',
              active: false,
              isDark: isDark,
              // we don't use checkmark for custom fields because it's a 1-to-many relationship
              onTap: () {
                final state = context
                    .findAncestorStateOfType<_CreateEditItemScreenState>();
                if (state != null) {
                  state._showAddCustomFieldSheet(context,
                      ref.read(itemFormNotifierProvider.notifier), isDark);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated pill chip — correctly adapts to dark mode via [isDark].
class _FieldChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _FieldChip({
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dark mode: inactive chip = dark surface, not white
    final inactiveBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final inactiveBorder = isDark ? Colors.white24 : Colors.grey[300]!;
    final inactiveText = isDark ? Colors.grey[300]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:
              active ? AppColors.primary.withValues(alpha: 0.15) : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : inactiveBorder,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check : Icons.add,
              size: 13,
              color: active ? AppColors.primary : inactiveText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.primary : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
