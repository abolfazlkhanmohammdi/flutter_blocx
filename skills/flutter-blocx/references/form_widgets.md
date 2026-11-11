# Form Screens & Form Control Widgets (`package:flutter_blocx/form_widget.dart`)

This reference documents `BlocxFormWidget`, `BlocxFormWidgetState`, and all pre-wired form input and button widgets in `flutter_blocx`.

---

## 1. `BlocxFormWidget<P>` & `BlocxFormWidgetState<W, F, P, E>`

### Widget Definition
```dart
abstract class BlocxFormWidget<P> extends StatefulWidget {
  final P? payload;
  const BlocxFormWidget({super.key, this.payload});
}
```
- `P` is the optional edit/hydration payload type (matching the 2nd type parameter of `BlocxFormBloc<F, P, E>`). Use `void` or `dynamic` if the form never receives a payload.

### State Definition
```dart
abstract class BlocxFormWidgetState<
    W extends BlocxFormWidget<P>,
    F extends BlocxBaseFormEntity<F, E>,
    P,
    E extends Enum> extends BlocxScreenManagerState<W>
```

#### Required Overrides (3)
1. **`BlocxFormBloc<F, P, E> get generateBloc;`**
   - **Important**: `generateBloc` is a **getter** (`get generateBloc => ...`), matching `BlocxCollectionWidgetState`.
   - Called once in `initState()`, which then immediately dispatches `bloc.add(BlocxFormEventInit(payload: widget.payload))`.
2. **`List<E> get keys;`**
   - Return the list of enum keys that use managed `TextEditingController`s (typically `E.values`, e.g., `ProfileFormField.values`).
3. **`Widget formWidget(BuildContext context, BlocxFormState<F, E> state);`**
   - Builds the form content for the current `BlocxFormState<F, E>`.

#### Built-in Properties & Lifecycle Flags
- `late final BlocxFormBloc<F, P, E> bloc;` — the form BLoC instance.
- `BlocxFormState<F, E> get state => bloc.state;` — the current form state.
- `P? get payload => widget.payload;` — the widget payload.
- `bool get isUpdate => widget.payload != null;` — override if your payload is a wrapper object (e.g. `payload?.entityToEdit != null`).
- `bool get isValid => bloc.state.isValid;` — whether `state.errors` is empty.
- `bool get autoCloseBloc => true;` — when `true` (default), `dispose()` closes `bloc` (and disposes all managed `TextEditingController`s and `FocusNode`s).
- `double get formVerticalSpacing => 16;` — standard vertical spacing between fields.
- `TextFieldType get defaultTextFieldType => TextFieldType.filled;`
- `AutovalidateMode get autovalidateMode => AutovalidateMode.onUserInteraction;`

#### Lifecycle & Listener Hooks
- **`void applyInitialDataToForm(F formData)`**
  - Automatically called by `blocListener` whenever `BlocxFormStateApplyInitialDataToForm<F, E>` is emitted (both during initial edit-payload hydration and when `BlocxFormSyncStreamMixin` syncs an external entity update!).
  - **Best Practice**: Override `applyInitialDataToForm(F formData)` and set `getTextEditingController(key).text = ...` for each text field key so controllers are guaranteed to exist even if `BlocxFormEventInit` emits before the first `build()`:
    ```dart
    @override
    void applyInitialDataToForm(ProfileFormEntity formData) {
      getTextEditingController(ProfileFormField.username).text = formData.username;
      getTextEditingController(ProfileFormField.email).text = formData.email;
      getTextEditingController(ProfileFormField.age).text =
          formData.age > 0 ? formData.age.toString() : '';
    }
    ```
  - *(Note: If you rely on the default `applyInitialDataToForm`, your `BlocxBaseFormEntity` subclass **must** override `getFormattedValueByKey(E key)` so it does not throw `UnimplementedError`!)*
  - **Cursor Preservation**: The default `applyInitialDataToForm` checks whether `controller.text` differs from the new value before mutating. When updated, it preserves the cursor selection clamped to the new string length (`TextSelection.collapsed(offset: min(controller.selection.end, text.length))`), preventing cursor jumps during active stream sync.
- **`void onFormSubmitted(BlocxFormStateFormSubmitted<F, E> state)`**
  - Called when form submission completes and emits `BlocxFormStateFormSubmitted<F, E>`. Access the UseCase result data via `state.submittedData` (e.g., `Navigator.of(context).pop(state.submittedData)`).
- **`void onFormUpdated(F formData, E updatedKey, dynamic oldValue, dynamic newValue)`**
  - Called when any field is updated via `BlocxFormStateFormUpdated<F, E>`.
- **`@mustCallSuper void blocListener(BuildContext context, BlocxFormState<F, E> state)`**
  - Override to react to additional listen-only states (such as `BlocxFormStateStepChanged<F, E>` or `BlocxFormStateRequiredInfoFetched<F, E, Data>`). Always call `super.blocListener(context, state)`.

#### Imperative Helper Methods on `BlocxFormWidgetState`
- `void submit()` — dispatches `BlocxFormEventSubmit()`.
- `void changeListener(dynamic data, E key)` — dispatches `BlocxFormEventUpdateData<E>(data: data, key: key)`.
- `void setErrorToField(E key, String message)` — dispatches `BlocxFormEventSetErrorToField<E>(message: message, key: key)`.
- `void setTimedErrorToField(E key, String message, {Duration? duration})` — dispatches `BlocxFormEventSetTimedErrorToField<E>(message: message, key: key, duration: duration)`.
- `void clearFieldError(E key, {String? message})` — dispatches `BlocxFormEventClearFieldError<E>(key: key, message: message)`.
- `TextEditingController getTextEditingController(E key)` — returns (or lazily creates) the managed controller for `key`, pre-hydrating from `bloc.formData`.
- `FocusNode getFocusNode(E key)` — returns (or lazily creates) the managed `FocusNode` for `key`.
- `void requestFocusOnError(BlocxFormState<F, E> state)` — requests focus on the first field key in `state.errors`.
- `BlocxFormSubmitBuilder<F, P, E> submitBuilder({...})` — builds a decoupled `BlocxFormSubmitBuilder` wired to `bloc`.
- `BlocxFormStepBuilder<F, P, E> stepBuilder({...})` — builds a decoupled `BlocxFormStepBuilder` wired to `bloc`.

---

## 2. `textField` & `passwordField` (`BlocXFormTextField` / `BlocxFormTextField`)

Use `textField(E key, {...})` or `passwordField(E key, {...})` inside `BlocxFormWidgetState` to build a text input connected to a managed `TextEditingController` (and assigned `ValueKey('blocx_field_${key.name}')`):

```dart
BlocXFormTextField<F, P, E> textField(
  E key, {
  BlocXTextFieldOptions? options,
  FormFieldValidator<String>? validator,
  TextFieldType? type, // TextFieldType.filled (default), .outlined, .underlined
  FocusNode? focusNode,
  String? labelText,
  String? hintText,
  String? helperText,
  Widget? prefix,
  Widget? suffix,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool? obscureText,
  bool? enableObscureToggle,
  bool? enabled,
  bool? autofocus,
  bool? showClearButton,
  int? maxLines,
  int? errorMaxLines,
  int? minLines,
  int? maxLength,
  TypeConverter? converter, // typedef TypeConverter<T> = T Function(String value);
})

// Pre-configured password helper (sets obscureText: true and enableObscureToggle: true by default):
passwordField(
  LoginField.password,
  type: TextFieldType.outlined,
  labelText: 'Password',
)
```

### Built-in Features of `BlocXFormTextField` (`BlocxFormTextField`)
1. **Automatic `BlocxFormEventUpdateData` dispatch** on every keystroke, applying `converter?.call(text) ?? text`.
2. **Automatic validation error display**: reads the first error message for `formKey` from `bloc.state.errors`.
3. **Suffix Precedence Order (`getSuffix`)**:
   1. Async unique-field spinner while `bloc.state.checkingUniqueFields.contains(formKey)` is `true`.
   2. Explicit `options.suffix` if provided.
   3. Built-in obscure visibility toggle `IconButton` (`ValueKey('blocx_obscure_toggle_${key.name}')`) when `obscureText && (enableObscureToggle || options.enableObscureToggle)`.
   4. Clear button (`Icons.clear`) when `showClearButton` is `true` (default), `!obscureText`, and the controller text is non-empty.
4. **Automatic RTL/LTR text direction detection** when `options.textDirection` is null.

### `BlocXTextFieldOptions` (`BlocxTextFieldOptions`)
All visual/behavioral parameters can also be passed via `const BlocXTextFieldOptions(...)` (or `const BlocxTextFieldOptions(...)`):
- `decoration`, `style`, `keyboardType`, `textDirection`, `textCapitalization = TextCapitalization.none`, `textInputAction`, `textAlign = TextAlign.start`, `maxLines = 1`, `minLines`, `maxLength`, `minLength`, `inputFormatters = const []`, `autofocus = false`, `enabled = true`, `obscureText = false`, `enableObscureToggle = false`, `labelText`, `labelStyle`, `hintText`, `hintStyle`, `helperText`, `helperStyle`, `errorText`, `errorStyle`, `errorMaxLines = 1`, `prefix`, `prefixText`, `prefixStyle`, `suffix`, `suffixText`, `suffixStyle`, `showClearButton = true`, `filled = true`, `fillColor`, `borderRadius`, `contentPadding`, `isDense`, `constraints`.

---

## 3. `dropdown<T>` (`BlocXFormDropdown` / `BlocxFormDropdown`)

Use `dropdown<T>(E key, {required List<DropdownMenuItem<T>> items, BlocXDropdownOptions? options})` inside `BlocxFormWidgetState`, or construct `BlocXFormDropdown<F, P, E, T>` directly when you want to pass an initial `value`:

```dart
// Via BlocxFormWidgetState helper:
dropdown<String>(
  ProfileFormField.country,
  options: const BlocXDropdownOptions(
    labelText: 'Country',
    hintText: 'Select your country',
    filled: true,
    isExpanded: true,
  ),
  items: const [
    DropdownMenuItem(value: 'US', child: Text('United States')),
    DropdownMenuItem(value: 'CA', child: Text('Canada')),
  ],
)

// Or directly when passing `value:` from state.formData:
BlocxFormDropdown<ProfileFormEntity, UserProfileEntity, ProfileFormField, String>(
  formKey: ProfileFormField.country,
  value: state.formData.country,
  options: const BlocxDropdownOptions(labelText: 'Country'),
  items: const [
    DropdownMenuItem(value: 'US', child: Text('United States')),
    DropdownMenuItem(value: 'CA', child: Text('Canada')),
  ],
)
```
- Dispatches `BlocxFormEventUpdateData(data: v, key: formKey)` on selection change.
- Automatically displays any validation error for `formKey` from `bloc.state.errors`.
- Assigns `ValueKey<String>('blocx_dropdown_${key.name}')` (`find.blocxDropdown(key)`).

---

## 4. `checkbox` (`BlocxFormCheckbox` & `BlocxCheckboxOptions`)

Use `checkbox({required E key, required bool isChecked, BlocxCheckboxOptions? options})` inside `BlocxFormWidgetState`:

```dart
checkbox(
  key: ProfileFormField.acceptTerms,
  isChecked: state.formData.acceptTerms,
  options: BlocxCheckboxOptions(
    isChecked: state.formData.acceptTerms,
    label: 'I agree to the Terms of Service',
    subtitle: 'Required to create an account',
    controlAffinity: ListTileControlAffinity.leading,
  ),
)
```
- When `options.label` or `options.subtitle` is non-empty (`options.hasText == true`), renders a `CheckboxListTile.adaptive`.
- When neither `label` nor `subtitle` is set, renders a compact `Checkbox.adaptive`.
- Toggling dispatches `BlocxFormEventUpdateData(data: value, key: formKey)`.
- Assigns `ValueKey<String>('blocx_checkbox_${key.name}')` (`find.blocxCheckbox(key)`).

---

## 5. `submitButton` (`BlocxFormRegisterButton`) & `formButtonRow` (`BlocxFormButtonRow`)

### Single Submit Button (`submitButton` / `BlocxFormRegisterButton<F, P, E>`)
```dart
submitButton(
  isUpdate ? 'Update' : 'Create',
  formState: state, // optional snapshot state (avoids reading live bloc fields)
  submitText: 'Saving...',
  type: RegisterButtonType.filled, // .filled, .elevated, .outlined, .text, .other
  options: const BlocxFormRegisterButtonOptions(
    disableWhenInvalid: false,
    spacing: 8.0,
  ),
)
```
- **Automatic busy & disabled states**:
  - `isSubmittingForm`: `state is BlocxFormStateSubmittingForm<F, E>`
  - `isCheckingUniqueFields`: `state.checkingUniqueFields.isNotEmpty`
  - `isFetchingFieldInfo`: `state.fieldsFetchingInfo.isNotEmpty`
  - `isBusy`: `isSubmittingForm || isCheckingUniqueFields || isFetchingFieldInfo` (shows a 16×16 loading spinner next to the label)
  - `isDisabled`: `isBusy || (buttonOptions.disableWhenInvalid && !state.isFormValid) || state.errors.isNotEmpty`
- When `onPressed` is omitted, tapping resolves the nearest `BlocxFormWidgetState` ancestor and calls `submit()`.
- Pass `formState: state` from `formWidget(context, state)` so the button renders directly from the current immutable state snapshot rather than reading live mutable bloc fields.

### Submit + Cancel Button Row (`formButtonRow` / `BlocxFormButtonRow<F, P, E>`)
Renders a horizontal row with a primary `BlocxFormRegisterButton` and a secondary cancel `OutlinedButton` (which defaults to `Navigator.of(context).maybePop()` and disables popping while submitting):

```dart
// Direct construction (recommended when using default submit behavior):
BlocxFormButtonRow<ProfileFormEntity, UserProfileEntity, ProfileFormField>(
  formState: state,
  registerText: isUpdate ? 'Save Changes' : 'Register',
  registerSubmittingText: 'Saving...',
  secondButtonText: 'Cancel',
  registerType: RegisterButtonType.filled,
  options: const BlocxFormButtonRowOptions(
    expandEqually: true,
    spacing: 12.0,
    height: 40.0,
    disablePopWhileSubmitting: true,
  ),
)
```
- You can also call the `formButtonRow(...)` helper on `BlocxFormWidgetState`, which also supports `formState: state`:
  ```dart
  formButtonRow(
    isUpdate ? 'Save Changes' : 'Register',
    formState: state,
    registerSubmittingText: 'Saving...',
    onRegisterPressed: submit,
  )
  ```
- Deterministic semantic keys: `BlocxFormRegisterButton` wraps its button in `const ValueKey<String>('blocx_submit_button')` (`find.blocxSubmitButton()`), and `BlocxFormButtonRow`'s secondary cancel button carries `const ValueKey<String>('blocx_cancel_button')` (`find.blocxCancelButton()`).

---

## 6. `switchField` (`BlocxFormSwitchField` & `BlocxSwitchOptions`)

Use `switchField(E key, {...})` inside `BlocxFormWidgetState` (or construct `BlocxFormSwitchField<F, P, E>` directly inside a `BlocxFormScope` / `BlocProvider`):

```dart
switchField(
  ProfileFormField.notificationsEnabled,
  label: 'Email Notifications',
  subtitle: 'Receive weekly digests',
)
```
- When `label` or `subtitle` is provided (`BlocxSwitchOptions.hasText == true`), renders `SwitchListTile.adaptive`; otherwise renders compact `Switch.adaptive`.
- When `options.value` is omitted, reads `bloc.formData.getValueByKey(key) as bool? ?? false`.
- Displays `bloc.state.errorByKey(key) ?? options.errorText` beneath the control.
- Assigns `ValueKey<String>('blocx_switch_${key.name}')` (`find.blocxSwitch(key)`) and attaches `getFocusNode(key)` via `switchField(...)`.

---

## 7. `chipField` (`BlocxFormChipField`, `BlocxChipOption`, `BlocxChipFieldOptions`)

Use `chipField<T>(E key, {required List<BlocxChipOption<T>> options, ...})` for single-select (`ChoiceChip`) or multi-select (`FilterChip`) tag/filter inputs:

```dart
// Single-select ChoiceChip group (clears to null on re-tap when allowDeselect == true):
chipField<String>(
  ProfileFormField.priority,
  labelText: 'Priority',
  options: const [
    BlocxChipOption(value: 'low', label: 'Low'),
    BlocxChipOption(value: 'high', label: 'High'),
  ],
)

// Multi-select FilterChip group (emits Set<T> when emitSetInMultiSelect == true unless existing value is a List):
chipField<String>(
  ProfileFormField.tags,
  labelText: 'Tags',
  multiSelect: true,
  options: const [
    BlocxChipOption(value: 'urgent', label: 'Urgent'),
    BlocxChipOption(value: 'billing', label: 'Billing'),
  ],
)
```
- Assigns `ValueKey<String>('blocx_field_${key.name}')` on the field (`find.blocxField(key)`) and `option.itemKey ?? ValueKey<String>('blocx_filter_${option.value}')` on each chip (`find.blocxFilter(option.value)`).
- Automatically renders `bloc.state.errorByKey(key) ?? fieldOptions.errorText` (or `helperText` when no error is active).

---

## 8. `segmentedField` (`BlocxFormSegmentedField`, `BlocxSegmentOption`, `BlocxSegmentedFieldOptions`)

Use `segmentedField<T>(E key, {required List<BlocxSegmentOption<T>> segments, ...})` for a Material 3 `SegmentedButton<T>`:

```dart
segmentedField<String>(
  ProfileFormField.visibility,
  labelText: 'Visibility',
  segments: const [
    BlocxSegmentOption(value: 'private', label: 'Private', icon: Icon(Icons.lock_outline)),
    BlocxSegmentOption(value: 'public', label: 'Public', icon: Icon(Icons.public)),
  ],
)
```
- Supports both single-select (`T?`, with `emptySelectionAllowed`) and multi-select (`Set<T>` / `List<T>`, via `multiSelect: true`).
- Assigns `ValueKey<String>('blocx_field_${key.name}')` on the `SegmentedButton<T>` (`find.blocxField(key)`) and displays `bloc.state.errorByKey(key)` or `helperText`.

---

## 9. Decoupled Scaffold Actions & Multi-Step Controls (`BlocxFormScope`, `BlocxFormSubmitBuilder`, `BlocxFormStepBuilder`)

Both `BlocxFormWidgetState` and `BlocxFormView` wrap their subtrees (including `Scaffold` app bars and bottom bars when `BlocxFormWidgetState` wraps the screen) in `BlocxFormScope<F, P, E>`, allowing detached action widgets anywhere in the scaffold to resolve `BlocxFormBloc<F, P, E>`:

### `BlocxFormSubmitBuilder<F, P, E>` / `submitBuilder(...)`
```dart
@override
Widget scaffoldWidget(BuildContext context, Widget body) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Profile'),
      actions: [
        submitBuilder(
          disableWhenInvalid: true,
          resetOnCancel: true,
          builder: (context, state, submitForm, cancelForm) => Row(
            children: [
              TextButton(onPressed: cancelForm, child: const Text('Reset')),
              FilledButton(
                onPressed: submitForm,
                child: Text(state.isSubmittingForm ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
      ],
    ),
    body: body,
  );
}
```
- `submitForm` is `null` when `state.isSubmittingForm || state.isPrefetching || state.hasPendingUniqueChecks`, or (when `disableWhenInvalid: true`) when `!state.canSubmit`.
- `cancelForm` invokes `onCancel` if supplied, dispatches `BlocxFormEventReset()` if `resetOnCancel: true`, or calls `Navigator.of(context).maybePop()` otherwise.
- Wraps its output in `const ValueKey<String>('blocx_submit_builder')`.

### `BlocxFormStepBuilder<F, P, E>` / `stepBuilder(...)`
For multi-step forms backed by `BlocxFormSteppedMixin<F, P, E>`:
```dart
stepBuilder(
  builder: (context, state, controls) => Row(
    children: [
      if (!controls.isFirstStep)
        OutlinedButton(onPressed: controls.previousStep, child: const Text('Back')),
      const Spacer(),
      FilledButton(
        onPressed: controls.isLastStep ? controls.submitForm : controls.nextStep,
        child: Text(controls.isLastStep ? 'Submit' : 'Next (${controls.currentStep + 1}/${controls.maxStep + 1})'),
      ),
    ],
  ),
)
```
- `maxStep` defaults to `(bloc as BlocxFormSteppedMixin).maxStep` when omitted, or `0` otherwise.
- `BlocxFormStepControls` exposes: `currentStep` (alias `step`), `maxStep`, `isFirstStep`, `isLastStep`, `comesFromPreviousStep`, `nextStep` (`null` on last step or busy), `previousStep` (`null` on first step or submitting), `goToStep(int index)`, and `submitForm` (`state.canSubmit ? ... : null`).
- Wraps its output in `const ValueKey<String>('blocx_step_builder')`.
