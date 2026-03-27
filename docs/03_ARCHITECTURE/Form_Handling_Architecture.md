# Forms Architecture & MVVM Guide

**Version:** 1.0  
**Date:** February 26, 2026

> Clarification: references to "form bloc" in older discussions are conceptual.
> LinkVault's implementation standard is Riverpod notifier-based forms.

## Core Principle: Forms are State Machines

In MVVM, a form should not hold its state or connection logic within the `StatefulWidget` or `TextEditingController` directly. The Screen (View) is merely a dumb reflection of the `FormState` (ViewModel).

### The Three Components of a Form

1. **The Form State Class** (`collection_form_state.dart`):
   - An immutable data class covering all form inputs, field-level validation errors (`Map<String, String> fieldErrors`), and global submission status (`isSubmitting`, `isSuccess`, `errorMessage`).
2. **The Form Notifier (ViewModel)** (`collection_form_notifier.dart`):
   - A `Notifier` (or `AutoDisposeNotifier`) that holds the State. It validates inputs as they change (_clearing specific field errors from the map_), and calls Domain UseCases upon submission.
3. **The View (Screen)** (`create_edit_collection_screen.dart`):
   - A `ConsumerWidget` that listens to the Notifier. It binds `TextEditingController`s to the Notifier's state (typically in `initState` setting controllers, and using `onChanged` to update the Notifier). It handles side-effects (like navigation on success) via `ref.listen`.

---

## Example Implementation (Collection Form)

### 1. Form State

```dart
class CollectionFormState extends Equatable {
  final String title;
  final String category;
  final String colorHex;
  final bool isShared;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage; // Global network/server errors
  final Map<String, String> fieldErrors; // Field-level validation errors
  // ... copyWith and props ...
}
```

### 2. Form Notifier

```dart
class CollectionFormNotifier extends AutoDisposeNotifier<CollectionFormState> {
  @override
  CollectionFormState build() {
    return const CollectionFormState();
  }

  void updateTitle(String title) {
    // Clear field-level error when typig
    final newErrors = Map<String, String>.from(state.fieldErrors)..remove('title');
    state = state.copyWith(title: title, fieldErrors: newErrors);
  }

  // ... update other fields ...

  Future<void> submit({String? existingCollectionId}) async {
    final Map<String, String> errors = {};

    // 1. Validate Fields
    if (state.title.trim().isEmpty) errors['title'] = 'Title cannot be empty';

    if (errors.isNotEmpty) {
        state = state.copyWith(fieldErrors: errors);
        return;
    }

    // 2. Submit Data
    state = state.copyWith(isSubmitting: true, errorMessage: null, fieldErrors: {});

    // Call UseCase
    final result = await ref.read(createCollectionUseCaseProvider).call(...);

    result.fold(
      (l) => state = state.copyWith(isSubmitting: false, errorMessage: l.message),
      (r) => state = state.copyWith(isSubmitting: false, isSuccess: true),
    );
  }
}

final collectionFormNotifierProvider = NotifierProvider.autoDispose<
    CollectionFormNotifier, CollectionFormState>(
  CollectionFormNotifier.new,
);
```

### 3. View (Screen)

```dart
class CreateEditCollectionScreen extends ConsumerStatefulWidget { ... }

class _CreateEditCollectionScreenState extends ConsumerState<CreateEditCollectionScreen> {
  // Controllers read from state initially, then report changes back

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collectionFormNotifierProvider);
    final notifier = ref.read(collectionFormNotifierProvider.notifier);

    // Handle side effects (navigation, snackbars for strictly global/server errors)
    ref.listen(collectionFormNotifierProvider, (prev, next) {
      if (next.isSuccess) context.pop();
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    // Build UI reacting strictly to `state`
    return TextFormField(
      onChanged: notifier.updateTitle,
      decoration: InputDecoration(
        errorText: state.fieldErrors['title'], // Binds precisely to the field map
      ),
    );
  }
}
```
