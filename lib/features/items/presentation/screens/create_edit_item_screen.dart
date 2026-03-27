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
                        // ── URL field — required ────────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'URL',
                            isRequired: true,
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'https://example.com/article',
                              initialValue: state.link,
                              onChanged: notifier.updateLink,
                              errorText: state.fieldErrors['link'],
                              keyboardType: TextInputType.url,
                              style: TextStyle(
                                fontSize: 15,
                                color: valueTextColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Title field — required ──────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Title',
                            isRequired: true,
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'e.g. LinkVault docs',
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

                        // ── Description (page summary) ─────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Description',
                            labelColor: microLabelColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Page summary — often filled from the link preview',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: microLabelColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SmartFormField(
                                  hint: 'Optional summary text',
                                  initialValue: state.description,
                                  onChanged: notifier.updateDescription,
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: valueTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Preview identity block ──────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _UrlIdentityPreview(
                            link: state.link,
                            siteName: state.siteName,
                            faviconUrl: state.faviconUrl,
                            labelColor: microLabelColor,
                            valueTextColor: valueTextColor,
                            isDark: isDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Thumbnail field — own card ──────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _ImageLabeledRow(
                            imageUrl: state.imageUrl,
                            imagePath: state.imagePath,
                            isDark: isDark,
                            labelColor: microLabelColor,
                            onPickTap: () =>
                                _showImageSourceSheet(context, notifier),
                            onRemove: () {
                              notifier.updateImageUrl(null);
                              notifier.updateImagePath(null);
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Notes field — own card ──────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Notes',
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'Add a note...',
                              initialValue: state.annotation,
                              onChanged: notifier.updateAnnotation,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 15,
                                color: valueTextColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Tags field — own card ───────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Tags',
                            labelColor: microLabelColor,
                            child: SmartFormField(
                              hint: 'flutter, docs, reference',
                              initialValue: state.tags,
                              onChanged: notifier.updateTags,
                              style: TextStyle(
                                  fontSize: 15, color: valueTextColor),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Status ─────────────────────────────────────
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: _LabeledField(
                            label: 'Status',
                            labelColor: microLabelColor,
                            child: DropdownButtonFormField<ItemStatus>(
                              key: ValueKey(state.status),
                              initialValue: state.status,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              items: ItemStatus.values
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(_itemStatusLabel(s)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) notifier.updateStatus(v);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Advanced metadata (optional / future fields) ─
                        _FieldCard(
                          isDark: isDark,
                          cardColor: cardColor,
                          child: Theme(
                            data: theme.copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding:
                                  const EdgeInsets.only(top: 4, bottom: 8),
                              title: Text(
                                'Advanced metadata',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: valueTextColor,
                                ),
                              ),
                              subtitle: Text(
                                'Site name, canonical URL, type, publish date',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: microLabelColor,
                                ),
                              ),
                              children: [
                                _LabeledField(
                                  label: 'Site name',
                                  labelColor: microLabelColor,
                                  child: SmartFormField(
                                    hint: 'e.g. Medium',
                                    initialValue: state.siteName,
                                    onChanged: notifier.updateSiteName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: valueTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: 'Canonical URL',
                                  labelColor: microLabelColor,
                                  child: SmartFormField(
                                    hint: 'https://…',
                                    initialValue: state.canonicalUrl,
                                    onChanged: notifier.updateCanonicalUrl,
                                    keyboardType: TextInputType.url,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: valueTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: 'Content type',
                                  labelColor: microLabelColor,
                                  child: SmartFormField(
                                    hint: 'article, video, pdf…',
                                    initialValue: state.contentType,
                                    onChanged: notifier.updateContentType,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: valueTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Published',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: microLabelColor,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    state.publishedAt == null
                                        ? 'No date set'
                                        : MaterialLocalizations.of(context)
                                            .formatFullDate(state.publishedAt!),
                                    style: TextStyle(color: valueTextColor),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (state.publishedAt != null)
                                        IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () =>
                                              notifier.updatePublishedAt(null),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.calendar_today_outlined),
                                        onPressed: () async {
                                          final now = DateTime.now();
                                          final picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate:
                                                state.publishedAt ?? now,
                                            firstDate: DateTime(1970),
                                            lastDate: DateTime(now.year + 2),
                                          );
                                          if (picked != null) {
                                            notifier.updatePublishedAt(picked);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

String _itemStatusLabel(ItemStatus s) {
  switch (s) {
    case ItemStatus.unread:
      return 'Unread';
    case ItemStatus.read:
      return 'Read';
    case ItemStatus.archived:
      return 'Archived';
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
  final String? imageUrl;
  final String? imagePath;
  final bool isDark;
  final Color labelColor;
  final VoidCallback onPickTap;
  final VoidCallback onRemove;

  const _ImageLabeledRow({
    required this.imageUrl,
    required this.imagePath,
    required this.isDark,
    required this.labelColor,
    required this.onPickTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final displayImage = imageUrl ?? imagePath;
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
        if (displayImage != null) ...[
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
                      child: displayImage.startsWith('http')
                          ? Image.network(displayImage, fit: BoxFit.contain)
                          : Image.file(File(displayImage), fit: BoxFit.contain),
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

class _UrlIdentityPreview extends StatelessWidget {
  const _UrlIdentityPreview({
    required this.link,
    required this.siteName,
    required this.faviconUrl,
    required this.labelColor,
    required this.valueTextColor,
    required this.isDark,
  });

  final String? link;
  final String? siteName;
  final String? faviconUrl;
  final Color labelColor;
  final Color valueTextColor;
  final bool isDark;

  String _domainFromLink(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final normalized = raw.startsWith('http') ? raw : 'https://$raw';
    try {
      final host = Uri.parse(normalized).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = _domainFromLink(link);
    final displayName = (siteName?.trim().isNotEmpty ?? false)
        ? siteName!.trim()
        : domain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: faviconUrl != null && faviconUrl!.startsWith('http')
                    ? Image.network(
                        faviconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackFavicon(),
                      )
                    : _fallbackFavicon(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty ? displayName : 'No preview yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueTextColor,
                    ),
                  ),
                  if (domain.isNotEmpty)
                    Text(
                      domain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackFavicon() {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.language_rounded,
        size: 14,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
