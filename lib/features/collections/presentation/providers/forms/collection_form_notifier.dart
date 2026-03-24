import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_categories.dart';
import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/collection_parent_validation.dart';
import '../../../domain/entities/collection.dart';
import '../../providers/collections_providers.dart';
import 'collection_form_state.dart';

class CollectionFormNotifier extends AutoDisposeNotifier<CollectionFormState> {
  @override
  CollectionFormState build() {
    return const CollectionFormState();
  }

  Future<void> initialize(String? collectionId) async {
    if (!state.isInit) return;

    if (collectionId == null) {
      state = state.copyWith(isInit: false);
      return;
    }

    // Attempt to load existing collection
    final repo = ref.read(collectionsRepositoryProvider);
    final result = await repo.getCollectionById(collectionId);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isInit: false);
      },
      (collection) {
        if (collection != null) {
          state = state.copyWith(
            title: collection.title,
            category: collection.category,
            iconName: collection.iconName,
            colorHex: collection.colorHex,
            parentId: collection.parentId,
            isPinned: collection.isPinned,
            isArchived: collection.isArchived,
            isShared: collection.isShared,
            isInit: false,
          );
        } else {
          state = state.copyWith(isInit: false);
        }
      },
    );
  }

  void updateTitle(String title) {
    // Clear title error when user starts typing
    final newErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('title');
    state = state.copyWith(
        title: title, fieldErrors: newErrors, errorMessage: null);
  }

  void updateCategory(String category) {
    state = state.copyWith(
      category: category,
      iconName: AppCategories.getIconForCategory(category),
    );
  }

  void updateColor(String colorHex) {
    state = state.copyWith(colorHex: colorHex);
  }

  void updateIconName(String iconName) {
    state = state.copyWith(iconName: iconName);
  }

  void updateParentId(String? parentId) {
    state = state.copyWith(parentId: parentId);
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

  Future<void> submit({String? existingCollectionId}) async {
    final title = state.title.trim();
    final Map<String, String> errors = {};

    // 1. Validate Fields
    if (title.isEmpty) {
      errors['title'] = 'Please enter a title';
    } else if (title.length > 50) {
      errors['title'] = 'Title cannot exceed 50 characters';
    }

    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return;
    }

    // 2. Submit Data
    state =
        state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: {});

    final allResult =
        await ref.read(collectionsRepositoryProvider).getAllCollections();
    final parentErr = allResult.fold(
      (f) => f.message,
      (all) => validateCollectionParentAssignment(
        editingCollectionId: existingCollectionId,
        proposedParentId: state.parentId,
        allCollections: all,
      ),
    );
    if (parentErr != null) {
      state = state.copyWith(isSubmitting: false, errorMessage: parentErr);
      return;
    }

    if (existingCollectionId != null) {
      // Editing existing logic
      final repo = ref.read(collectionsRepositoryProvider);
      final result = await repo.getCollectionById(existingCollectionId);

      await result.fold((l) async {
        state = state.copyWith(isSubmitting: false, errorMessage: l.message);
      }, (existing) async {
        if (existing != null) {
          final updated = Collection(
            id: existing.id,
            title: title,
            category: state.category,
            colorHex: state.colorHex,
            iconName: state.iconName,
            parentId: state.parentId,
            position: existing.position,
            isPinned: state.isPinned,
            isArchived: state.isArchived,
            isDeleted: existing.isDeleted,
            childCount: existing.childCount,
            isShared: state.isShared,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
            itemCount: existing.itemCount,
          );

          final updateResult =
              await ref.read(updateCollectionUseCaseProvider).call(updated);
          updateResult.fold(
              (failure) => state = state.copyWith(
                  isSubmitting: false, errorMessage: failure.message),
              (_) =>
                  state = state.copyWith(isSubmitting: false, isSuccess: true));
        } else {
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
        state = state.copyWith(isSubmitting: false, errorMessage: blocked);
        return;
      }

      // Creating new logic
      final newCollection = Collection(
        title: title,
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
      );

      final createResult =
          await ref.read(createCollectionUseCaseProvider).call(newCollection);
      createResult.fold(
          (failure) => state = state.copyWith(
              isSubmitting: false, errorMessage: failure.message),
          (_) => state = state.copyWith(isSubmitting: false, isSuccess: true));
    }
  }
}

final collectionFormNotifierProvider =
    NotifierProvider.autoDispose<CollectionFormNotifier, CollectionFormState>(
  CollectionFormNotifier.new,
);
