import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_categories.dart';
import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/collection_display_defaults.dart';
import '../../../domain/collection_parent_validation.dart';
import '../../../domain/entities/collection.dart';
import '../../providers/collections_providers.dart';
import 'collection_form_state.dart';

class CollectionFormNotifier extends AutoDisposeNotifier<CollectionFormState> {
  @override
  CollectionFormState build() {
    return const CollectionFormState();
  }

  /// [parentIdForNew] / [parentTitleHint] apply when creating (no [collectionId]).
  Future<void> initialize(
    String? collectionId, {
    String? parentIdForNew,
    String? parentTitleHint,
  }) async {
    if (!state.isInit) return;

    if (collectionId == null) {
      AppLogger.d(
          '[collections] form initialize new list parent=$parentIdForNew');
      state = state.copyWith(
        isInit: false,
        parentId: parentIdForNew,
        parentTitleHint: parentTitleHint,
      );
      return;
    }

    AppLogger.d('[collections] form initialize load id=$collectionId');
    final result = await ref.read(getCollectionByIdUseCaseProvider).call(collectionId);

    await result.fold(
      (failure) async {
        AppLogger.w('[collections] form initialize failed: ${failure.message}');
        state = state.copyWith(errorMessage: failure.message, isInit: false);
      },
      (collection) async {
        if (collection != null) {
          AppLogger.d(
              '[collections] form initialize loaded title="${collection.title}"');
          String? parentHint;
          final pid = collection.parentId?.trim();
          if (pid != null && pid.isNotEmpty) {
            final allRes = await ref.read(getAllCollectionsUseCaseProvider).call();
            parentHint = allRes.fold((_) => null, (list) {
              for (final c in list) {
                if (c.id == pid) return c.title;
              }
              return null;
            });
          }
          state = state.copyWith(
            title: collection.title,
            description: collection.description ?? '',
            category: collection.category,
            iconName: collection.iconName,
            colorHex: collection.colorHex,
            parentId: collection.parentId,
            parentTitleHint: parentHint,
            isPinned: collection.isPinned,
            isArchived: collection.isArchived,
            isShared: collection.isShared,
            itemsLayout: CollectionLayoutMode.normalize(collection.itemsLayout),
            childCollectionsLayout:
                CollectionLayoutMode.normalize(collection.childCollectionsLayout),
            itemsSortDefault: CollectionItemsSortDefault.normalize(
                collection.itemsSortDefault),
            openLinksIn:
                CollectionOpenLinksIn.normalize(collection.openLinksIn),
            showLinkPreviews: collection.showLinkPreviews,
            isInit: false,
            usesCustomCategory:
                !AppCategories.isPreset(collection.category),
          );
        } else {
          AppLogger.w(
              '[collections] form initialize collection missing id=$collectionId');
          state = state.copyWith(isInit: false);
        }
      },
    );
  }

  void updateTitle(String title) {
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('title');
    state = state.copyWith(
        title: title, fieldErrors: newErrors, errorMessage: null);
  }

  void updateDescription(String description) {
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('description');
    state = state.copyWith(
        description: description, fieldErrors: newErrors, errorMessage: null);
  }

  void updateCategory(String category) {
    state = state.copyWith(
      category: category,
      iconName: AppCategories.getIconForCategory(category),
      usesCustomCategory: false,
    );
  }

  void applyCustomCategory(String name, String emoji) {
    final n = name.trim();
    if (n.isEmpty) return;
    final e = emoji.trim().isEmpty ? '📁' : emoji.trim();
    state = state.copyWith(
      category: n,
      iconName: e,
      usesCustomCategory: true,
    );
  }

  void updateColor(String colorHex) {
    state = state.copyWith(colorHex: colorHex);
  }

  void updateIconName(String iconName) {
    state = state.copyWith(iconName: iconName);
  }

  void updateParentId(String? parentId, {String? titleHint}) {
    state = state.copyWith(
      parentId: parentId,
      parentTitleHint: titleHint,
    );
  }

  void updatePinned(bool isPinned) {
    state = state.copyWith(isPinned: isPinned);
  }

  void updateArchived(bool isArchived) {
    state = state.copyWith(isArchived: isArchived);
  }

  void updateShared(bool isShared) {
    state = state.copyWith(isShared: isShared);
  }

  void updateItemsLayout(String layout) {
    state = state.copyWith(
        itemsLayout: CollectionLayoutMode.normalize(layout));
  }

  void updateChildCollectionsLayout(String layout) {
    state = state.copyWith(
        childCollectionsLayout: CollectionLayoutMode.normalize(layout));
  }

  void updateItemsSortDefault(String? sort) {
    if (sort == null) return;
    state = state.copyWith(
        itemsSortDefault: CollectionItemsSortDefault.normalize(sort));
  }

  void updateOpenLinksIn(String mode) {
    state = state.copyWith(
        openLinksIn: CollectionOpenLinksIn.normalize(mode));
  }

  void updateShowLinkPreviews(bool value) {
    state = state.copyWith(showLinkPreviews: value);
  }

  Future<void> submit({String? existingCollectionId}) async {
    final title = state.title.trim();
    final Map<String, String> errors = {};

    AppLogger.d(
        '[collections] form submit start editId=$existingCollectionId title="$title" parent=${state.parentId}');

    if (title.isEmpty) {
      errors['title'] = 'Please enter a title';
    } else if (title.length > 50) {
      errors['title'] = 'Title cannot exceed 50 characters';
    }

    final desc = state.description.trim();
    if (desc.length > 500) {
      errors['description'] = 'Description cannot exceed 500 characters';
    }

    final cat = state.category.trim();
    if (cat.isEmpty) {
      errors['category'] = 'Please choose or enter a category';
    } else if (cat.length > 60) {
      errors['category'] = 'Category cannot exceed 60 characters';
    }
    if (state.iconName.trim().isEmpty) {
      errors['category'] = 'Please pick an emoji for this category';
    } else if (state.iconName.trim().length > 16) {
      errors['category'] = 'Emoji cannot exceed 16 characters';
    }

    if (errors.isNotEmpty) {
      AppLogger.d('[collections] form submit validation errors: $errors');
      state = state.copyWith(fieldErrors: errors);
      return;
    }

    state =
        state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: {});

    final allResult = await ref.read(getAllCollectionsUseCaseProvider).call();
    final parentErr = allResult.fold(
      (f) => f.message,
      (all) => validateCollectionParentAssignment(
        editingCollectionId: existingCollectionId,
        proposedParentId: state.parentId,
        allCollections: all,
      ),
    );
    if (parentErr != null) {
      AppLogger.w('[collections] form submit parent invalid: $parentErr');
      state = state.copyWith(isSubmitting: false, errorMessage: parentErr);
      return;
    }

    final descriptionValue = desc.isEmpty ? null : desc;
    final itemsLayout = CollectionLayoutMode.normalize(state.itemsLayout);
    final childLayout =
        CollectionLayoutMode.normalize(state.childCollectionsLayout);
    final itemsSort =
        CollectionItemsSortDefault.normalize(state.itemsSortDefault);
    final openIn = CollectionOpenLinksIn.normalize(state.openLinksIn);

    if (existingCollectionId != null) {
      final result =
          await ref.read(getCollectionByIdUseCaseProvider).call(existingCollectionId);

      await result.fold((l) async {
        AppLogger.e('[collections] form submit get existing failed: ${l.message}');
        state = state.copyWith(isSubmitting: false, errorMessage: l.message);
      }, (existing) async {
        if (existing != null) {
          final updated = Collection(
            id: existing.id,
            title: title,
            description: descriptionValue,
            category: state.category,
            colorHex: state.colorHex,
            iconName: state.iconName,
            iconJson: existing.iconJson,
            parentId: state.parentId,
            position: existing.position,
            isPinned: state.isPinned,
            isArchived: state.isArchived,
            isDeleted: existing.isDeleted,
            childCount: existing.childCount,
            isShared: state.isShared,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
            lastAccessedAt: existing.lastAccessedAt,
            itemsLayout: itemsLayout,
            childCollectionsLayout: childLayout,
            itemsSortDefault: itemsSort,
            openLinksIn: openIn,
            showLinkPreviews: state.showLinkPreviews,
            itemCount: existing.itemCount,
          );

          final updateResult =
              await ref.read(updateCollectionUseCaseProvider).call(updated);
          updateResult.fold(
              (failure) {
                AppLogger.e(
                    '[collections] form submit update failed: ${failure.message}');
                state = state.copyWith(
                    isSubmitting: false, errorMessage: failure.message);
              },
              (_) {
                AppLogger.d(
                    '[collections] form submit update ok id=$existingCollectionId');
                state = state.copyWith(isSubmitting: false, isSuccess: true);
              });
        } else {
          AppLogger.w('[collections] form submit edit: original not found');
          state = state.copyWith(
              isSubmitting: false,
              errorMessage: 'Original collection not found');
        }
      });
    } else {
      final quota = await TierQuotaGuard.ensureCanCreateCollection(
        isPremium: ref.read(isPremiumProvider),
        user: ref.read(currentUserProvider),
        collectionsRepo: ref.read(collectionsRepositoryProvider),
      );
      final blocked = quota.fold((f) => f.message, (_) => null);
      if (blocked != null) {
        AppLogger.w('[collections] form submit create quota blocked: $blocked');
        state = state.copyWith(isSubmitting: false, errorMessage: blocked);
        return;
      }

      final newCollection = Collection(
        title: title,
        description: descriptionValue,
        category: state.category,
        colorHex: state.colorHex,
        iconName: state.iconName.isNotEmpty
            ? state.iconName
            : AppCategories.getIconForCategory(state.category),
        parentId: state.parentId,
        position: 0,
        isPinned: state.isPinned,
        isArchived: state.isArchived,
        isShared: state.isShared,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        itemsLayout: itemsLayout,
        childCollectionsLayout: childLayout,
        itemsSortDefault: itemsSort,
        openLinksIn: openIn,
        showLinkPreviews: state.showLinkPreviews,
      );

      final createResult =
          await ref.read(createCollectionUseCaseProvider).call(newCollection);
      createResult.fold(
          (failure) {
            AppLogger.e(
                '[collections] form submit create failed: ${failure.message}');
            state = state.copyWith(
                isSubmitting: false, errorMessage: failure.message);
          },
          (_) {
            AppLogger.d('[collections] form submit create ok');
            state = state.copyWith(isSubmitting: false, isSuccess: true);
          });
    }
  }
}

final collectionFormNotifierProvider =
    NotifierProvider.autoDispose<CollectionFormNotifier, CollectionFormState>(
  CollectionFormNotifier.new,
);
