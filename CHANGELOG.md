# Changelog

## [0.8.3]
- Updated README.md

## [0.8.2]
- Updated CHANGELOG.md

## [0.8.1]
- Updated README.md to fix some inconsistencies

## [0.8.0]

### Added

- **`BlocxScreenManagerState.errorWidgetByErrorCode`** — new overridable hook that builds a full-page error widget for `ScreenManagerCubitStateDisplayErrorPageByErrorCode`. Converts `state.errorCode` to a human-readable message via `BlocXLocalizations.errorCodeMessage` and renders a `BlocxErrorWidget`. Override to add per-error-code UI, retry logic, or reporting callbacks.

- **`BlocxScreenManagerState.decorateScaffold`** — new overridable hook to wrap the scaffold produced by `scaffoldWidget` with additional widgets (e.g. `PopScope`, theme providers). Only called when `wrapInScaffold` is `true`.

- **`BlocXLocalizations` — new required members:**
    - `close` — label for dismiss/close actions in built-in error and snackbar widgets.
    - `copyDetails` — label for the "copy error details" action in `BlocxErrorWidget`.
    - `dateRangeError(DateTime minDate, DateTime maxDate)` — message used by the date-range validator when the selected date falls outside the allowed range.
    - `BlocXErrorCode.fieldCannotBeEmpty` — new error code; add a translation in your `errorCodeMessages` map.

- **`BlocxScreenManagerState` documentation** — comprehensive dartdoc added to all public/protected members:
    - `wrapInScaffold`, `managerCubit`, `decorateScaffold`, `errorWidget`, `errorWidgetByErrorCode`, `mainWidget`, `scaffoldWidget`.

### Changed

- **`blocx_core` dependency** bumped from `0.7.1` to `^0.8.2`, picking up all breaking mixin renames and the new `BlocxPaginatedUseCaseTask` introduced in `blocx_core` 0.8.0.

- **`BlocxScreenManagerState.showSnackBar`** — parameter list reformatted to one-per-line for readability; no API change.

- **`BlocxScreenManagerState.scaffoldWidget`** — `UnimplementedError` message split across lines for readability; message text unchanged.

- **Example `ExampleLocalizations`** — `errorGettingInitialFormData` entry condensed to a single line; new entries added (see _Added_ above).

- **Example `MyApp`** — `ThemeData` construction collapsed to a single line; no visual change.

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

_See repository history for earlier entries._