import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/monetization/tier_quota_guard.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../domain/entities/item.dart';
import '../items_providers.dart';
import 'item_form_state.dart';

/// Manages all form state for CreateEditItemScreen.
/// The screen owns ZERO TextEditingControllers — this notifier is the
/// single source of truth for all field values.
class ItemFormNotifier extends AutoDisposeNotifier<ItemFormState> {
  @override
  ItemFormState build() {
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
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location, clearLocation: location.isEmpty);
  }

  void updateTags(String tags) {
    state = state.copyWith(tags: tags, clearTags: tags.isEmpty);
  }

  void updateImagePath(String? imagePath) {
    state =
        state.copyWith(imagePath: imagePath, clearImagePath: imagePath == null);
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
    final Map<String, String> errors = {};

    if (title.isEmpty) {
      errors['title'] = 'Please enter a title';
    }

    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return;
    }

    state =
        state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: {});

    final now = DateTime.now();
    final cleanLink =
        state.link?.trim().isEmpty == true ? null : state.link?.trim();
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
            customFields: state.customFields.values.toList(),
            imagePath: state.imagePath,
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
        customFields: state.customFields.values.toList(),
        imagePath: state.imagePath,
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
