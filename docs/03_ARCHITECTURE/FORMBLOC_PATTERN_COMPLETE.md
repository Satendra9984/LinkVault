# Gift Module - FormBloc Pattern Refactor ✅

## 🎯 **Pattern: Follows BookingFormBloc Architecture**

The Gift module now follows the same pattern as `BookingFormBloc`:

- **Form State Management + API Calls in ONE BLoC**
- No separate BLoC for API operations
- Clean, simple, maintainable

---

## 📊 **Final Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                 ReceivedGiftDetailsView                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴─────────────┬────────────────────┐
        │                        │                    │
        ▼                        ▼                    ▼
┌──────────────────┐  ┌─────────────────────┐  ┌──────────────────┐
│ GiftDetailsBloc  │  │ GiftClaimFormBloc   │  │ ProviderDetails  │
│   (READ ONLY)    │  │  (FORM + API)       │  │   Bloc (READ)    │
└──────────────────┘  └─────────────────────┘  └──────────────────┘
        │                        │                     │
        │                        │                     │
        ▼                        ▼                     ▼
   Fetch Gift         Form State + Submit        Provider Availability
   Details            Claim/Reschedule           for Date/Time Picker
```

---

## ✅ **2 BLoCs (Simple & Clean)**

### **1. GiftDetailsBloc** (READ ONLY)

**Responsibility:** Fetch and display gift details

**Events:**

- `LoadGiftDetails`
- `RefreshGiftDetails`

**States:**

- `GiftDetailsInitial`
- `GiftDetailsLoading`
- `GiftDetailsLoaded`
- `GiftDetailsError`

**Constructor:**

```dart
GiftDetailsBloc({
  required GetGiftDetailsUseCase getGiftDetailsUseCase,
})
```

---

### **2. GiftClaimFormBloc** (FORM STATE + API CALLS)

**Responsibility:** Manage form AND submit to API (like BookingFormBloc)

**Events:**

- `InitializeGiftClaimForm`
- `UpdateGiftDate`
- `UpdateGiftTime`
- `UpdateGiftAddress`
- `UpdateGiftNotes`
- **`SubmitGiftClaimForm`** ← Validates + Calls API

**States:**

- `GiftClaimFormInitial`
- `GiftClaimFormReady`
- `GiftClaimFormInvalid`
- **`GiftClaimFormSubmitting`** ← Like BookingFormSubmitting
- **`GiftClaimFormSuccess`** ← Like BookingFormSuccess
- **`GiftClaimFormError`** ← Like BookingFormError

**Constructor:**

```dart
GiftClaimFormBloc({
  required ClaimGiftUseCase claimGiftUseCase,
  required RescheduleGiftUseCase rescheduleGiftUseCase,
})
```

---

## 🔄 **Data Flow**

### **1. User Fills Form**

```
User fills date/time/address
    ↓
GiftClaimFormWidget dispatches events
    ↓
GiftClaimFormBloc updates formData
    ↓
UI rebuilds with new formData
```

### **2. User Submits**

```
User clicks "Accept"
    ↓
SubmitGiftClaimForm event dispatched
    ↓
GiftClaimFormBloc validates formData
    ↓
If valid: emit GiftClaimFormSubmitting
    ↓
Call claimGiftUseCase / rescheduleGiftUseCase
    ↓
If success: emit GiftClaimFormSuccess
If error: emit GiftClaimFormError
    ↓
ReceivedGiftDetailsView listens
    ↓
Show Toast + Refresh list + Pop screen
```

---

## 📝 **ReceivedGiftDetailsView Listeners**

### **Before (3 Listeners - Complex):**

```dart
❌ GiftDetailsBloc listener
❌ GiftClaimBloc listener  
❌ GiftClaimFormBloc listener
```

### **After (2 Listeners - Simple):**

```dart
✅ GiftDetailsBloc listener → Initialize form
✅ GiftClaimFormBloc listener → Handle success/error
```

---

## 🔥 **Implementation**

### **GiftClaimFormBloc.dart**

```dart
class GiftClaimFormBloc extends Bloc<GiftClaimFormEvent, GiftClaimFormState> {
  final ClaimGiftUseCase claimGiftUseCase;
  final RescheduleGiftUseCase rescheduleGiftUseCase;

  GiftClaimFormBloc({
    required this.claimGiftUseCase,
    required this.rescheduleGiftUseCase,
  }) : super(const GiftClaimFormInitial()) {
    on<SubmitGiftClaimForm>(_onSubmitGiftClaimForm);
    // ... other handlers
  }

  /// Submit form - Validate AND call API (like BookingFormBloc)
  Future<void> _onSubmitGiftClaimForm(
    SubmitGiftClaimForm event,
    Emitter<GiftClaimFormState> emit,
  ) async {
    // Step 1: Validate
    final validationErrors = state.formData.validate(
      requiresAddress: event.requiresAddress,
    );

    if (validationErrors.isNotEmpty) {
      emit(GiftClaimFormInvalid(...));
      return;
    }

    // Step 2: Emit submitting state
    emit(GiftClaimFormSubmitting(...));

    // Step 3: Call API
    if (state.isReschedule) {
      final result = await rescheduleGiftUseCase(...);
      result.fold(
        (failure) => emit(GiftClaimFormError(...)),
        (gift) => emit(GiftClaimFormSuccess(...)),
      );
    } else {
      final result = await claimGiftUseCase(...);
      result.fold(
        (failure) => emit(GiftClaimFormError(...)),
        (gift) => emit(GiftClaimFormSuccess(...)),
      );
    }
  }
}
```

### **ReceivedGiftDetailsView.dart**

```dart
MultiBlocListener(
  listeners: [
    // GiftDetailsBloc - Initialize form
    BlocListener<GiftDetailsBloc, GiftDetailsState>(
      listener: (context, state) {
        if (state is GiftDetailsLoaded) {
          context.read<GiftClaimFormBloc>().add(
            InitializeGiftClaimForm(gift: state.gift, ...),
          );
        }
      },
    ),
    
    // GiftClaimFormBloc - Handle submit success/error
    BlocListener<GiftClaimFormBloc, GiftClaimFormState>(
      listener: (context, formState) {
        if (formState is GiftClaimFormSuccess) {
          Toast.success(message: '...');
          context.read<GiftsListBloc>().add(const RefreshGifts());
          context.pop();
        }
        else if (formState is GiftClaimFormError) {
          Toast.error(error: formState.message);
        }
      },
    ),
  ],
  child: ...,
)
```

### **Action Buttons**

```dart
AppButton(
  label: 'Accept',
  isLoading: formState is GiftClaimFormSubmitting,  // ← Check form state
  onPressed: () {
    context.read<GiftClaimFormBloc>().add(
      SubmitGiftClaimForm(
        giftId: gift.id,
        requiresAddress: requiresAddress,
      ),
    );
  },
)
```

---

## ✅ **Benefits**

### **1. Follows Existing Pattern**

- ✅ Matches `BookingFormBloc` architecture
- ✅ Consistent with codebase conventions
- ✅ Easy for team to understand

### **2. Simpler Architecture**

- ✅ 2 BLoCs instead of 3
- ✅ Form + API in one place
- ✅ Less inter-BLoC communication

### **3. Better Maintainability**

- ✅ All form logic in one file
- ✅ Clear separation: GiftDetails (READ) vs GiftClaimForm (WRITE)
- ✅ Easy to test and debug

### **4. Reduced Complexity**

- ✅ Fewer listeners in view
- ✅ No intermediate BLoC layer
- ✅ Direct form → API flow

---

## 🗑️ **Removed**

### **GiftClaimBloc (DELETED)**

```
❌ lib/feature/gifts/presentation/bloc/gift_claim_bloc/
   ├── gift_claim_bloc.dart
   ├── gift_claim_event.dart
   └── gift_claim_state.dart
```

**Why?** Not needed when FormBloc handles both form state AND API calls.

---

## 📋 **Comparison**

### **Before (Over-engineered):**

```
GiftDetailsBloc     → Fetch gift
GiftClaimFormBloc   → Form state
GiftClaimBloc       → API calls  ❌ UNNECESSARY!

View listens to 3 BLoCs ❌
```

### **After (Clean & Simple):**

```
GiftDetailsBloc      → Fetch gift
GiftClaimFormBloc    → Form state + API calls ✅

View listens to 2 BLoCs ✅
```

---

## 🎓 **Key Takeaway**

**FormBloc Pattern:**
> A form BLoC should handle BOTH form state management AND form submission.
> Don't create a separate BLoC just for API calls if it's tightly coupled to the form.

**Follows BookingFormBloc:**

- `BookingFormBloc` handles form state AND booking submission
- `GiftClaimFormBloc` handles form state AND claim/reschedule submission
- Same pattern, consistent architecture ✅

---

**Last Updated:** October 16, 2025  
**Status:** ✅ Complete & Tested  
**Pattern:** FormBloc (Form State + API Calls in ONE BLoC)
