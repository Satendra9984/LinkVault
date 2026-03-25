/*
/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/entities/item.dart';
import '../items_providers.dart';
import '../../../../../core/services/url_parsing_service.dart';
import 'item_form_state.dart';

/// Manages all state for CreateEditItemScreen.
///
/// Controllerless MVVM:
/// - The screen owns ZERO controllers.
/// - This notifier is the single source of truth for all field values.
class ItemFormNotifier extends AutoDisposeNotifier<ItemFormState> {
  int _linkExtractionRequestId = 0;

  @override
  ItemFormState build() {
    ref.onDispose(() {
      _linkExtractionRequestId++;
    });
    return const ItemFormState();
  }

  Future<void> initialize(String? itemId) async {
    if (!state.isInit) return;

    if (itemId == null) {
      state = state.copyWith(isInit: false);
      return;
    }

    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.getItem(itemId);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isInit: false,
        );
      },
      (item) {
        if (item == null) {
          state = state.copyWith(isInit: false);
          return;
        }

        state = state.copyWith(
          title: item.title,
          description: item.description,
          link: item.link,
          annotation: item.annotation,
          tags: item.tags,
          imagePath: item.imagePath,
          imageUrl: item.imageUrl,
          faviconUrl: item.faviconUrl,
          siteName: item.siteName,
          canonicalUrl: item.canonicalUrl,
          contentType: item.contentType,
          publishedAt: item.publishedAt,
          status: item.status,
          isInit: false,
        );
      },
    );
  }

  // ── Field updaters ─────────────────────────────────────────────────────────

  void updateTitle(String title) {
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('title');
    state = state.copyWith(
      title: title,
      fieldErrors: newErrors,
      errorMessage: null,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      clearDescription: description.isEmpty,
    );
  }

  void updateLink(String link) {
    state = state.copyWith(link: link, clearLink: link.isEmpty);

    final trimmed = link.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.contains('.')) return;

    final requestId = ++_linkExtractionRequestId;
    Future<void>.delayed(const Duration(milliseconds: 700), () async {
      final preview = await UrlParsingService.extractPreview(trimmed);
      if (requestId != _linkExtractionRequestId) return; // superseded/disposed
      if (preview == null) return;

      state = state.copyWith(
        title: state.title.trim().isEmpty
            ? (preview.title ?? state.title)
            : state.title,
        description: (state.description == null ||
                state.description!.trim().isEmpty)
            ? preview.description
            : state.description,
        siteName: preview.websiteName,
        faviconUrl: preview.faviconUrl,
        imageUrl: state.imageUrl ?? preview.thumbnailUrl,
        clearImagePath: preview.thumbnailUrl != null,
      );
    });
  }

  void updateLocation(String location) => updateAnnotation(location);

  void updateAnnotation(String annotation) {
    state = state.copyWith(
      annotation: annotation,
      clearAnnotation: annotation.isEmpty,
    );
  }

  void updateTags(String tags) {
    state = state.copyWith(tags: tags, clearTags: tags.isEmpty);
  }

  void updateImagePath(String? imagePath) {
    state = state.copyWith(
      imagePath: imagePath,
      clearImagePath: imagePath == null,
      // If the user picks a local image, override the parsed preview.
      clearImageUrl: imagePath != null,
    );
  }

  void updateImageUrl(String? imageUrl) {
    state = state.copyWith(
      imageUrl: imageUrl,
      clearImageUrl: imageUrl == null,
      // If we set a parsed URL thumbnail, clear any local file selection.
      clearImagePath: imageUrl != null,
    );
  }

  void updateStatus(ItemStatus status) {
    state = state.copyWith(status: status);
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> submit({
    required String collectionId,
    String? existingItemId,
  }) async {
    final title = state.title.trim();
    final link = state.link?.trim();

    final errors = <String, String>{};
    if (title.isEmpty) errors['title'] = 'Please enter a title';
    if (link == null || link.isEmpty) errors['link'] = 'Please enter a URL';

    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: errors,
        errorMessage: errors.values.first,
        isSubmitting: false,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      fieldErrors: const {},
    );

    final now = DateTime.now();
    final cleanLink = link?.isEmpty == true ? null : link;
    final cleanAnnotation = state.annotation?.trim().isEmpty == true
        ? null
        : state.annotation?.trim();
    final cleanTags = state.tags?.trim().isEmpty == true ? null : state.tags?.trim();
    final cleanDescription = state.description?.trim().isEmpty == true
        ? null
        : state.description?.trim();

    if (existingItemId != null) {
      final repo = ref.read(itemsRepositoryProvider);
      final existingEither = await repo.getItem(existingItemId);

      await existingEither.fold(
        (failure) async {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          );
        },
        (existing) async {
          if (existing == null) {
            state = state.copyWith(
              isSubmitting: false,
              errorMessage: 'Original item not found',
            );
            return;
          }

          final updated = Item(
            id: existing.id,
            title: title,
            description: cleanDescription,
            link: cleanLink,
            annotation: cleanAnnotation,
            tags: cleanTags,
            imagePath: state.imagePath,
            imageUrl: state.imageUrl,
            faviconUrl: state.faviconUrl,
            siteName: state.siteName,
            canonicalUrl: state.canonicalUrl,
            contentType: state.contentType,
            publishedAt: state.publishedAt,
            status: state.status,
            position: existing.position,
            createdAt: existing.createdAt,
            updatedAt: now,
            collectionId: collectionId,
            ownerId: existing.ownerId,
            isPinned: existing.isPinned,
            clickCount: existing.clickCount,
            lastAccessedAt: existing.lastAccessedAt,
            isDeleted: existing.isDeleted,
            deletedAt: existing.deletedAt,
          );

          final updateResult = await ref
              .read(updateItemUseCaseProvider)
              .call(updated);

          updateResult.fold(
            (failure) => state.copyWith(
              isSubmitting: false,
              errorMessage: failure.message,
            ),
            (_) {
              ref
                  .read(itemsNotifierProvider(collectionId).notifier)
                  .updateItemInState(updated);
              state = state.copyWith(isSubmitting: false, isSuccess: true);
            },
          );
        },
      );
      return;
    }

    final quota = await TierQuotaGuard.ensureCanCreateItem(
      isPremium: ref.read(isPremiumProvider),
      user: ref.read(currentUserProvider),
      itemsRepo: ref.read(itemsRepositoryProvider),
    );
    final blocked = quota.fold((f) => f.message, (_) => null);
    if (blocked != null) {
      state = state.copyWith(isSubmitting: false, errorMessage: blocked);
      return;
    }

    final newItem = Item(
      id: const Uuid().v4(),
      title: title,
      description: cleanDescription,
      link: cleanLink,
      annotation: cleanAnnotation,
      tags: cleanTags,
      imagePath: state.imagePath,
      imageUrl: state.imageUrl,
      faviconUrl: state.faviconUrl,
      siteName: state.siteName,
      canonicalUrl: state.canonicalUrl,
      contentType: state.contentType,
      publishedAt: state.publishedAt,
      status: state.status,
      position: 0,
      createdAt: now,
      updatedAt: now,
      collectionId: collectionId,
      // Defaults for new items
      isPinned: false,
      clickCount: 0,
      lastAccessedAt: null,
      isDeleted: false,
      deletedAt: null,
    );

    final createResult = await ref
        .read(createItemUseCaseProvider)
        .call(newItem);

    createResult.fold(
      (failure) => state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (_) {
        ref
            .read(itemsNotifierProvider(collectionId).notifier)
            .addItemToState(newItem);
        state = state.copyWith(isSubmitting: false, isSuccess: true);
      },
    );
  }
}

final itemFormNotifierProvider =
    NotifierProvider.autoDispose<ItemFormNotifier, ItemFormState>(
  ItemFormNotifier.new,
);
*/

*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/entities/item.dart';
import '../items_providers.dart';
import '../../../../../core/services/url_parsing_service.dart';
import 'item_form_state.dart';

/// Manages all state for CreateEditItemScreen.
///
/// Controllerless MVVM:
/// - The screen owns ZERO controllers.
/// - This notifier is the single source of truth for all field values.
class ItemFormNotifier extends AutoDisposeNotifier<ItemFormState> {
  int _linkExtractionRequestId = 0;

  @override
  ItemFormState build() {
    ref.onDispose(() {
      _linkExtractionRequestId++;
    });
    return const ItemFormState();
  }

  Future<void> initialize(String? itemId) async {
    if (!state.isInit) return;

    if (itemId == null) {
      state = state.copyWith(isInit: false);
      return;
    }

    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.getItem(itemId);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isInit: false,
        );
      },
      (item) {
        if (item == null) {
          state = state.copyWith(isInit: false);
          return;
        }

        state = state.copyWith(
          title: item.title,
          description: item.description,
          link: item.link,
          annotation: item.annotation,
          tags: item.tags,
          imagePath: item.imagePath,
          imageUrl: item.imageUrl,
          faviconUrl: item.faviconUrl,
          siteName: item.siteName,
          canonicalUrl: item.canonicalUrl,
          contentType: item.contentType,
          publishedAt: item.publishedAt,
          status: item.status,
          isInit: false,
        );
      },
    );
  }

  // ── Field updaters ─────────────────────────────────────────────────────────

  void updateTitle(String title) {
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('title');
    state = state.copyWith(
      title: title,
      fieldErrors: newErrors,
      errorMessage: null,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      clearDescription: description.isEmpty,
    );
  }

  void updateLink(String link) {
    state = state.copyWith(link: link, clearLink: link.isEmpty);

    final trimmed = link.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.contains('.')) return;

    final requestId = ++_linkExtractionRequestId;
    Future<void>.delayed(const Duration(milliseconds: 700), () async {
      final preview = await UrlParsingService.extractPreview(trimmed);
      if (requestId != _linkExtractionRequestId) return; // superseded/disposed
      if (preview == null) return;

      state = state.copyWith(
        title: state.title.trim().isEmpty
            ? (preview.title ?? state.title)
            : state.title,
        description: (state.description == null ||
                state.description!.trim().isEmpty)
            ? preview.description
            : state.description,
        siteName: preview.websiteName,
        faviconUrl: preview.faviconUrl,
        imageUrl: state.imageUrl ?? preview.thumbnailUrl,
        clearImagePath: preview.thumbnailUrl != null,
      );
    });
  }

  void updateLocation(String location) => updateAnnotation(location);

  void updateAnnotation(String annotation) {
    state = state.copyWith(
      annotation: annotation,
      clearAnnotation: annotation.isEmpty,
    );
  }

  void updateTags(String tags) {
    state = state.copyWith(tags: tags, clearTags: tags.isEmpty);
  }

  void updateImagePath(String? imagePath) {
    state = state.copyWith(
      imagePath: imagePath,
      clearImagePath: imagePath == null,
      // If the user picks a local image, override the parsed preview.
      clearImageUrl: imagePath != null,
    );
  }

  void updateImageUrl(String? imageUrl) {
    state = state.copyWith(
      imageUrl: imageUrl,
      clearImageUrl: imageUrl == null,
      // If we set a parsed URL thumbnail, clear any local file selection.
      clearImagePath: imageUrl != null,
    );
  }

  void updateStatus(ItemStatus status) {
    state = state.copyWith(status: status);
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> submit({
    required String collectionId,
    String? existingItemId,
  }) async {
    final title = state.title.trim();
    final link = state.link?.trim();

    final errors = <String, String>{};
    if (title.isEmpty) errors['title'] = 'Please enter a title';
    if (link == null || link.isEmpty) errors['link'] = 'Please enter a URL';

    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: errors,
        errorMessage: errors.values.first,
        isSubmitting: false,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      fieldErrors: const {},
    );

    final now = DateTime.now();
    final cleanLink = link?.isEmpty == true ? null : link;
    final cleanAnnotation = state.annotation?.trim().isEmpty == true
        ? null
        : state.annotation?.trim();
    final cleanTags = state.tags?.trim().isEmpty == true ? null : state.tags?.trim();
    final cleanDescription = state.description?.trim().isEmpty == true
        ? null
        : state.description?.trim();

    if (existingItemId != null) {
      final repo = ref.read(itemsRepositoryProvider);
      final existingEither = await repo.getItem(existingItemId);
      await existingEither.fold(
        (failure) async {
          state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        },
        (existing) async {
          if (existing == null) {
            state = state.copyWith(
              isSubmitting: false,
              errorMessage: 'Original item not found',
            );
            return;
          }

          final updated = Item(
            id: existing.id,
            title: title,
            description: cleanDescription,
            link: cleanLink,
            annotation: cleanAnnotation,
            tags: cleanTags,
            // LV URL flow ignores Curate-era custom fields (no longer present).
            imagePath: state.imagePath,
            imageUrl: state.imageUrl,
            faviconUrl: state.faviconUrl,
            siteName: state.siteName,
            canonicalUrl: state.canonicalUrl,
            contentType: state.contentType,
            publishedAt: state.publishedAt,
            status: state.status,
            position: existing.position,
            createdAt: existing.createdAt,
            updatedAt: now,
            collectionId: collectionId,
            ownerId: existing.ownerId,
            isPinned: existing.isPinned,
            clickCount: existing.clickCount,
            lastAccessedAt: existing.lastAccessedAt,
            isDeleted: existing.isDeleted,
            deletedAt: existing.deletedAt,
          );

          final updateResult = await ref
              .read(updateItemUseCaseProvider)
              .call(updated);

          updateResult.fold(
            (failure) => state.copyWith(
              isSubmitting: false,
              errorMessage: failure.message,
            ),
            (_) {
              ref
                  .read(itemsNotifierProvider(collectionId).notifier)
                  .updateItemInState(updated);
              state = state.copyWith(isSubmitting: false, isSuccess: true);
            },
          );
        },
      );
      return;
    }

    final quota = await TierQuotaGuard.ensureCanCreateItem(
      isPremium: ref.read(isPremiumProvider),
      user: ref.read(currentUserProvider),
      itemsRepo: ref.read(itemsRepositoryProvider),
    );
    final blocked = quota.fold((f) => f.message, (_) => null);
    if (blocked != null) {
      state = state.copyWith(isSubmitting: false, errorMessage: blocked);
      return;
    }

    final newItem = Item(
      id: const Uuid().v4(),
      title: title,
      description: cleanDescription,
      link: cleanLink,
      annotation: cleanAnnotation,
      tags: cleanTags,
      imagePath: state.imagePath,
      imageUrl: state.imageUrl,
      faviconUrl: state.faviconUrl,
      siteName: state.siteName,
      canonicalUrl: state.canonicalUrl,
      contentType: state.contentType,
      publishedAt: state.publishedAt,
      status: state.status,
      position: 0,
      createdAt: now,
      updatedAt: now,
      collectionId: collectionId,
      // Defaults for new items
      isPinned: false,
      clickCount: 0,
      lastAccessedAt: null,
      isDeleted: false,
      deletedAt: null,
    );

    final createResult = await ref
        .read(createItemUseCaseProvider)
        .call(newItem);

    createResult.fold(
      (failure) => state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (_) {
        ref
            .read(itemsNotifierProvider(collectionId).notifier)
            .addItemToState(newItem);
        state = state.copyWith(isSubmitting: false, isSuccess: true);
      },
    );
  }
}

final itemFormNotifierProvider =
    NotifierProvider.autoDispose<ItemFormNotifier, ItemFormState>(
  ItemFormNotifier.new,
);

/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/entities/item.dart';
import '../items_providers.dart';
import '../../../../../core/services/url_parsing_service.dart';
import 'item_form_state.dart';

/// Manages all form state for CreateEditItemScreen.
/// The screen owns ZERO TextEditingControllers — this notifier is the
/// single source of truth for all field values.
class ItemFormNotifier extends AutoDisposeNotifier<ItemFormState> {
  // Debounce without Timer to avoid lifecycle override pitfalls:
  // track the most recent request id and only apply the latest response.
  int _linkExtractionRequestId = 0;

  @override
  ItemFormState build() {
    ref.onDispose(() {
      _linkExtractionRequestId++;
    });
    return const ItemFormState();
  }

  /// Loads an existing item into the form (edit mode).
  /// After this call, [SmartFormField] widgets detect the change via
  /// [didUpdateWidget] and update their internal controllers automatically.
  Future<void> initialize(String? itemId) async {
    if (!state.isInit) return;

    if (itemId == null) {
      state = state.copyWith(isInit: false);
      return;
    }

    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.getItem(itemId);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isInit: false);
      },
      (item) {
        if (item != null) {
          // Determine which "More fields" to expand based on existing data
          final expandedFields = <String>{};
          if (item.link != null && item.link!.isNotEmpty) {
            expandedFields.add('link');
          }
          if (item.location != null && item.location!.isNotEmpty) {
            expandedFields.add('location');
          }
          if (item.tags != null && item.tags!.isNotEmpty) {
            expandedFields.add('tags');
          }

          final customFieldsMap = <String, CustomField>{};
          for (final cf in item.customFields) {
            customFieldsMap[cf.id] = cf;
          }

          state = state.copyWith(
            title: item.title,
            description: item.description,
            link: item.link,
            location: item.location,
            tags: item.tags,
            imagePath: item.imagePath,
            imageUrl: item.imageUrl,
            status: item.status,
            expandedFields: expandedFields,
            customFields: customFieldsMap,
            isInit: false,
          );
        } else {
          state = state.copyWith(isInit: false);
        }
      },
    );
  }

  // ── Field updaters (called directly from SmartFormField.onChanged) ─────────

  void updateTitle(String title) {
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('title');
    state = state.copyWith(
        title: title, fieldErrors: newErrors, errorMessage: null);
  }

  void updateDescription(String description) {
    state = state.copyWith(
        description: description, clearDescription: description.isEmpty);
  }

  void updateLink(String link) {
    state = state.copyWith(link: link, clearLink: link.isEmpty);

    final trimmed = link.trim();
    if (trimmed.isEmpty) return;
    if (!trimmed.contains('.')) {
      // Avoid firing preview extraction for obviously incomplete inputs.
      return;
    }

    final requestId = ++_linkExtractionRequestId;
    Future<void>.delayed(const Duration(milliseconds: 700), () async {
      final preview = await UrlParsingService.extractPreview(trimmed);
      if (requestId != _linkExtractionRequestId) return; // superseded/disposed
      if (preview == null) return;

      state = state.copyWith(
        title: state.title.trim().isEmpty
            ? (preview.title ?? state.title)
            : state.title,
        description: (state.description == null ||
                state.description!.trim().isEmpty)
            ? preview.description
            : state.description,
        websiteName: preview.websiteName,
        faviconUrl: preview.faviconUrl,
        imageUrl: state.imageUrl ?? preview.thumbnailUrl,
        clearImagePath: preview.thumbnailUrl != null,
      );
    });
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location, clearLocation: location.isEmpty);
  }

  void updateTags(String tags) {
    state = state.copyWith(tags: tags, clearTags: tags.isEmpty);
  }

  void updateImagePath(String? imagePath) {
    state =
        state.copyWith(
          imagePath: imagePath,
          clearImagePath: imagePath == null,
          // If the user picks a local image, override the parsed preview.
          clearImageUrl: imagePath != null,
        );
  }

  void updateImageUrl(String? imageUrl) {
    state = state.copyWith(
      imageUrl: imageUrl,
      clearImageUrl: imageUrl == null,
      // If we set a parsed URL thumbnail, clear any local file selection.
      clearImagePath: imageUrl != null,
    );
  }

  void updateStatus(ItemStatus status) {
    state = state.copyWith(status: status);
  }

  // ── Custom Fields ──────────────────────────────────────────────────────────

  void addCustomField(String name, CustomFieldType type) {
    final id = const Uuid().v4();
    final newField = CustomField(id: id, name: name, type: type);
    final newFields = Map<String, CustomField>.from(state.customFields)
      ..[id] = newField;
    state = state.copyWith(customFields: newFields);
  }

  void removeCustomField(String id) {
    final newFields = Map<String, CustomField>.from(state.customFields)
      ..remove(id);
    state = state.copyWith(customFields: newFields);
  }

  void updateCustomFieldValue(String id, dynamic value) {
    final field = state.customFields[id];
    if (field != null) {
      final updatedField = CustomField(
        id: field.id,
        name: field.name,
        type: field.type,
        value: value,
      );
      final newFields = Map<String, CustomField>.from(state.customFields)
        ..[id] = updatedField;
      state = state.copyWith(customFields: newFields);
    }
  }

  // ── Progressive disclosure: expand/collapse More Fields chips ─────────────

  void toggleExpandedField(String field) {
    final newFields = Set<String>.from(state.expandedFields);
    if (newFields.contains(field)) {
      newFields.remove(field);
      // Clear the field value when collapsing
      switch (field) {
        case 'link':
          state = state.copyWith(
              link: null, clearLink: true, expandedFields: newFields);
          return;
        case 'location':
          state = state.copyWith(
              location: null, clearLocation: true, expandedFields: newFields);
          return;
        case 'tags':
          state = state.copyWith(
              tags: null, clearTags: true, expandedFields: newFields);
          return;
      }
    } else {
      newFields.add(field);
    }
    state = state.copyWith(expandedFields: newFields);
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> submit(
      {required String collectionId, String? existingItemId}) async {
    final title = state.title.trim();
    final link = state.link?.trim();
    final Map<String, String> errors = {};

    if (title.isEmpty) {
      errors['title'] = 'Please enter a title';
    }

    if (link == null || link.isEmpty) {
      errors['link'] = 'Please enter a URL';
    }

    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: errors,
        errorMessage: errors.values.first,
        isSubmitting: false,
      );
      return;
    }

    state =
        state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: {});

    final now = DateTime.now();
    final cleanLink =
        link?.isEmpty == true ? null : link;
    final cleanLocation =
        state.location?.trim().isEmpty == true ? null : state.location?.trim();
    final cleanTags =
        state.tags?.trim().isEmpty == true ? null : state.tags?.trim();
    final cleanDescription = state.description?.trim().isEmpty == true
        ? null
        : state.description?.trim();

    if (existingItemId != null) {
      // Edit mode
      final repo = ref.read(itemsRepositoryProvider);
      final result = await repo.getItem(existingItemId);

      await result.fold((l) async {
        state = state.copyWith(isSubmitting: false, errorMessage: l.message);
      }, (existing) async {
        if (existing != null) {
          final updated = Item(
            id: existing.id,
            title: title,
            description: cleanDescription,
            link: cleanLink,
            location: cleanLocation,
            tags: cleanTags,
            // LV URL flow ignores Curate-era persisted custom fields.
            customFields: const [],
            imagePath: state.imagePath,
          imageUrl: state.imageUrl,
            status: state.status,
            position: existing.position,
            createdAt: existing.createdAt,
            updatedAt: now,
            collectionId: collectionId,
          );

          final updateResult =
              await ref.read(updateItemUseCaseProvider).call(updated);
          updateResult.fold(
              (failure) => state = state.copyWith(
                  isSubmitting: false, errorMessage: failure.message), (_) {
            ref
                .read(itemsNotifierProvider(collectionId).notifier)
                .updateItemInState(updated);
            state = state.copyWith(isSubmitting: false, isSuccess: true);
          });
        } else {
          state = state.copyWith(
              isSubmitting: false, errorMessage: 'Original item not found');
        }
      });
    } else {
      final quota = await TierQuotaGuard.ensureCanCreateItem(
        isPremium: ref.read(isPremiumProvider),
        user: ref.read(currentUserProvider),
        itemsRepo: ref.read(itemsRepositoryProvider),
      );
      final blocked = quota.fold((f) => f.message, (_) => null);
      if (blocked != null) {
        state = state.copyWith(isSubmitting: false, errorMessage: blocked);
        return;
      }

      // Create mode
      final newItem = Item(
        id: const Uuid().v4(),
        title: title,
        description: cleanDescription,
        link: cleanLink,
        location: cleanLocation,
        tags: cleanTags,
        // LV URL flow ignores Curate-era persisted custom fields.
        customFields: const [],
        imagePath: state.imagePath,
        imageUrl: state.imageUrl,
        status: state.status,
        position: 0,
        createdAt: now,
        updatedAt: now,
        collectionId: collectionId,
      );

      final createResult =
          await ref.read(createItemUseCaseProvider).call(newItem);
      createResult.fold(
          (failure) => state = state.copyWith(
              isSubmitting: false, errorMessage: failure.message), (_) {
        ref
            .read(itemsNotifierProvider(collectionId).notifier)
            .addItemToState(newItem);
        state = state.copyWith(isSubmitting: false, isSuccess: true);
      });
    }
  }
}

final itemFormNotifierProvider =
    NotifierProvider.autoDispose<ItemFormNotifier, ItemFormState>(
  ItemFormNotifier.new,
);
*/