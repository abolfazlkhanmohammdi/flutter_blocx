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
- `TextEditingController getTextEditingController(E key)` — returns (or lazily creates) the managed controller for `key`.
- `FocusNode getFocusNode(E key)` — returns (or lazily creates) the managed `FocusNode` for `key`.
- `void requestFocusOnError(BlocxFormState<F, E> state)` — requests focus on the first field key in `state.errors`.

---

## 2. `textField` (`BlocXFormTextField` / `BlocxFormTextField`)

Use the `textField(E key, {...})` helper method inside `BlocxFormWidgetState` to build a text input connected to a managed `TextEditingController`:

```dart
BlocXFormTextField<F, P, E> textField(
  E key, {
  BlocXTextFieldOptions? options,
  FormFieldValidator<String>? validator,
  TextFieldType? type, // TextFieldType.filled (default), .outlined, .underlined
  String? labelText,
  String? hintText,
  String? helperText,
  Widget? prefix,
  Widget? suffix,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool? obscureText,
  bool? enabled,
  bool? autofocus,
  bool? showClearButton,
  int? maxLines,
  int? errorMaxLines,
  int? minLines,
  int? maxLength,
  TypeConverter? converter, // typedef TypeConverter<T> = T Function(String value);
})
```

### Built-in Features of `BlocXFormTextField` (`BlocxFormTextField`)
1. **Automatic `BlocxFormEventUpdateData` dispatch** on every keystroke, applying `converter?.call(text) ?? text`.
2. **Automatic validation error display**: reads the first error message for `formKey` from `bloc.state.errors`.
3. **Automatic async unique-field spinner**: when `bloc.state.checkingUniqueFields.contains(formKey)` is true, renders a compact `CircularProgressIndicator` in the suffix slot.
4. **Automatic clear button**: when `showClearButton` is `true` (default), `!obscureText`, and the controller text is non-empty, renders an `Icons.clear` button that clears the controller and dispatches `BlocxFormEventUpdateData(data: '', key: formKey)`.
5. **Automatic RTL/LTR text direction detection** when `options.textDirection` is null.

### `BlocXTextFieldOptions` (`BlocxTextFieldOptions`)
All visual/behavioral parameters can also be passed via `const BlocXTextFieldOptions(...)` (or `const BlocxTextFieldOptions(...)`):
- `decoration`, `style`, `keyboardType`, `textDirection`, `textCapitalization = TextCapitalization.none`, `textInputAction`, `textAlign = TextAlign.start`, `maxLines = 1`, `minLines`, `maxLength`, `minLength`, `inputFormatters = const []`, `autofocus = false`, `enabled = true`, `obscureText = false`, `labelText`, `labelStyle`, `hintText`, `hintStyle`, `helperText`, `helperStyle`, `errorText`, `errorStyle`, `errorMaxLines = 1`, `prefix`, `prefixText`, `prefixStyle`, `suffix`, `suffixText`, `suffixStyle`, `showClearButton = true`, `filled = true`, `fillColor`, `borderRadius`, `contentPadding`, `isDense`, `constraints`.

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
