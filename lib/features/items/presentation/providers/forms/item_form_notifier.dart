import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/entities/item.dart';
import '../items_providers.dart';
import '../../../../../core/services/url_parsing_service.dart';
import 'item_form_state.dart';

/// Manages all state for [CreateEditItemScreen].
///
/// Controllerless MVVM: this notifier is the single source of truth for fields.
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

    final result = await ref.read(getItemUseCaseProvider).call(itemId);

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
      if (requestId != _linkExtractionRequestId) return;
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
      clearImageUrl: imagePath != null,
    );
  }

  void updateImageUrl(String? imageUrl) {
    state = state.copyWith(
      imageUrl: imageUrl,
      clearImageUrl: imageUrl == null,
      clearImagePath: imageUrl != null,
    );
  }

  void updateSiteName(String siteName) {
    final t = siteName.trim();
    state = state.copyWith(
      siteName: t.isEmpty ? null : t,
      clearSiteName: t.isEmpty,
    );
  }

  void updateCanonicalUrl(String url) {
    final t = url.trim();
    state = state.copyWith(
      canonicalUrl: t.isEmpty ? null : t,
      clearCanonicalUrl: t.isEmpty,
    );
  }

  void updateContentType(String contentType) {
    final t = contentType.trim();
    state = state.copyWith(
      contentType: t.isEmpty ? null : t,
      clearContentType: t.isEmpty,
    );
  }

  void updatePublishedAt(DateTime? publishedAt) {
    state = state.copyWith(
      publishedAt: publishedAt,
      clearPublishedAt: publishedAt == null,
    );
  }

  void updateStatus(ItemStatus status) {
    state = state.copyWith(status: status);
  }

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
    final cleanTags =
        state.tags?.trim().isEmpty == true ? null : state.tags?.trim();
    final cleanDescription = state.description?.trim().isEmpty == true
        ? null
        : state.description?.trim();
    final cleanSiteName = state.siteName?.trim().isEmpty == true
        ? null
        : state.siteName?.trim();
    final cleanCanonical = state.canonicalUrl?.trim().isEmpty == true
        ? null
        : state.canonicalUrl?.trim();
    final cleanContentType = state.contentType?.trim().isEmpty == true
        ? null
        : state.contentType?.trim();

    if (existingItemId != null) {
      final existingEither = await ref.read(getItemUseCaseProvider).call(existingItemId);
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
            imagePath: state.imagePath,
            imageUrl: state.imageUrl,
            faviconUrl: state.faviconUrl,
            siteName: cleanSiteName,
            canonicalUrl: cleanCanonical,
            contentType: cleanContentType,
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

          final updateResult =
              await ref.read(updateItemUseCaseProvider).call(updated);

          updateResult.fold(
            (failure) {
              state = state.copyWith(
                isSubmitting: false,
                errorMessage: failure.message,
              );
            },
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
      siteName: cleanSiteName,
      canonicalUrl: cleanCanonical,
      contentType: cleanContentType,
      publishedAt: state.publishedAt,
      status: state.status,
      position: 0,
      createdAt: now,
      updatedAt: now,
      collectionId: collectionId,
      isPinned: false,
      clickCount: 0,
      lastAccessedAt: null,
      isDeleted: false,
      deletedAt: null,
    );

    final createResult =
        await ref.read(createItemUseCaseProvider).call(newItem);

    createResult.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
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
