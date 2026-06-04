# Changelog

## [0.8.4]

### Fixed

* **`BlocxFormRegisterButton`**

  * Changed `state` from raw `BlocxFormState` to typed `BlocxFormState<F, E>`.
  * Prevented submit buttons from becoming permanently disabled after validation errors in `FormValidationMode.onSubmit`.
  * Added `disableWhenInvalid`, defaulting to `false`.
  * Added loading/disabled handling for:

    * form submission
    * unique-field validation
    * required field info fetching
  * Added a clear error when no matching `BlocxFormWidgetState` ancestor is found.

* **`BlocxFormButtonRow`**

  * Changed `formState` from raw `BlocxFormState` to typed `BlocxFormState<F, E>`.
  * Passed `disableRegisterWhenInvalid` through to `BlocxFormRegisterButton`.
  * Added configurable `height`.
  * Improved secondary button naming and documentation.

* **`BlocXFormTextField`**

  * Fixed `TextFieldType` handling for filled, outlined, and underlined variants.
  * Respected custom `InputDecoration` while still merging bloc-driven errors and suffix loading indicators.
  * Applied `borderRadius` to default filled and outlined decorations.
  * Prevented clear buttons from showing for obscure text fields.
  * Updated automatic text direction when typing RTL/LTR content.
  * Improved external/internal controller ownership handling.

* **`BlocxFormWidgetState`**

  * Typed `BlocProvider.value` and `BlocConsumer` usage.
  * Typed form-state listener checks.
  * Typed helper methods and form state getter.
  * Fixed controller and focus-node disposal order.
  * Closed owned blocs before calling `super.dispose()`.
  * Converted initial form values to strings safely when hydrating text controllers.

* **`BlocxCollectionWidgetState`**

  * Added owned/external scroll controller tracking.
  * Avoided disposing externally provided scroll controllers.
  * Removed `AutoScrollController` listeners before disposal.
  * Closed owned collection blocs before calling `super.dispose()`.
  * Guarded scroll-to-item logic so it only runs with `AutoScrollController`.
  * Typed collection helper event dispatches.

### Changed

* Improved dartdocs across updated form and collection widget APIs.
* Improved lifecycle safety for form and collection widget states.
* Improved submit UX by making the bloc responsible for blocking invalid submits instead of disabling the button by default.

## [0.8.3]

* Updated README.md

## [0.8.2]

* Updated CHANGELOG.md

## [0.8.1]

* Updated README.md to fix some inconsistencies

## [0.8.0]

### Added

* **`BlocxScreenManagerState.errorWidgetByErrorCode`** — new overridable hook that builds a full-page error widget for `ScreenManagerCubitStateDisplayErrorPageByErrorCode`. Converts `state.errorCode` to a human-readable message via `BlocXLocalizations.errorCodeMessage` and renders a `BlocxErrorWidget`. Override to add per-error-code UI, retry logic, or reporting callbacks.

* **`BlocxScreenManagerState.decorateScaffold`** — new overridable hook to wrap the scaffold produced by `scaffoldWidget` with additional widgets (e.g. `PopScope`, theme providers). Only called when `wrapInScaffold` is `true`.

* **`BlocXLocalizations` — new required members:**

  * `close` — label for dismiss/close actions in built-in error and snackbar widgets.
  * `copyDetails` — label for the "copy error details" action in `BlocxErrorWidget`.
  * `dateRangeError(DateTime minDate, DateTime maxDate)` — message used by the date-range validator when the selected date falls outside the allowed range.
  * `BlocXErrorCode.fieldCannotBeEmpty` — new error code; add a translation in your `errorCodeMessages` map.

* **`BlocxScreenManagerState` documentation** — comprehensive dartdoc added to all public/protected members:

  * `wrapInScaffold`, `managerCubit`, `decorateScaffold`, `errorWidget`, `errorWidgetByErrorCode`, `mainWidget`, `scaffoldWidget`.

### Changed

* **`blocx_core` dependency** bumped from `0.7.1` to `^0.8.2`, picking up all breaking mixin renames and the new `BlocxPaginatedUseCaseTask` introduced in `blocx_core` 0.8.0.

* **`BlocxScreenManagerState.showSnackBar`** — parameter list reformatted to one-per-line for readability; no API change.

* **`BlocxScreenManagerState.scaffoldWidget`** — `UnimplementedError` message split across lines for readability; message text unchanged.

* **Example `ExampleLocalizations`** — `errorGettingInitialFormData` entry condensed to a single line; new entries added (see *Added* above).

* **Example `MyApp`** — `ThemeData` construction collapsed to a single line; no visual change.

### Migration Guide

#### Update your pubspec constraint

```yaml
dependencies:
  flutter_blocx: ^0.8.0
```

#### Implement new `BlocXLocalizations` members

Add the three new members to your `BlocXLocalizations` subclass:

```dart
@override
String get close => 'Close';

@override
String get copyDetails => 'Copy details';

@override
String dateRangeError(DateTime minDate, DateTime maxDate) =>
    'Date must be between $minDate and $maxDate.';
```

Add the new error code to your `errorCodeMessages` map:

```dart
BlocXErrorCode.fieldCannotBeEmpty: 'This field cannot be empty',
```

#### Adopt blocx_core 0.8.x mixin renames

`blocx_core ^0.8.2` renamed all collection mixins and form mixins. Update your `with` clauses — see the [`blocx_core` 0.8.0 migration guide](https://pub.dev/packages/blocx_core/changelog) for the full rename table.

---

## [0.7.1] - prior release

*See repository history for earlier entries.*
