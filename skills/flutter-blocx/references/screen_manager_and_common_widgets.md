# Screen Manager, Error Widget, SnackBar, Local Primitives, Confirm Sheet & Testing

This reference documents `BlocxScreenManagerState`, `BlocxStatelessWidget`, `BlocXWidgetState` (`BlocxWidgetState`), `BlocxLocal`, `BlocxUiToggle`, `BlocxErrorWidget`, `BlocxSnackBar`, `ConfirmActionWidget`, `BlocXLocalizations` (`loc`), and `package:flutter_blocx/testing.dart`.

---

## 1. `BlocxScreenManagerState<T extends StatefulWidget>`

`BlocxScreenManagerState<T>` is the foundational `State` class in `flutter_blocx` (and the superclass of both `BlocxCollectionWidgetState` and `BlocxFormWidgetState`). You can also extend `BlocxScreenManagerState<T>` directly for any custom screen driven by a `BlocxBaseBloc` or `ScreenManagerCubit`.

```dart
// Custom BlocxBaseBloc for a screen:
// Note: BlocxBaseEvent() is non-const, while const BlocxBaseState({required super.shouldRebuild, required super.shouldListen})
// is const and requires shouldRebuild/shouldListen. Neither uses Equatable props!
abstract class DashboardEvent extends BlocxBaseEvent {}

class DashboardLoadEvent extends DashboardEvent {}

class DashboardState extends BlocxBaseState {
  final bool isLoading;
  const DashboardState({
    this.isLoading = false,
    super.shouldRebuild = true,
    super.shouldListen = false,
  });
}

class DashboardBloc extends BlocxBaseBloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState());
}

class DashboardScreen extends StatefulWidget {
  final DashboardBloc bloc;
  const DashboardScreen({super.key, required this.bloc});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends BlocxScreenManagerState<DashboardScreen> {
  @override
  ScreenManagerCubit get managerCubit => widget.bloc.screenManagerCubit;

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: body,
    );
  }

  @override
  Widget decorateScaffold(Widget scaffold) {
    // Optional: wrap the Scaffold (e.g. in a PopScope)
    return scaffold;
  }

  @override
  Widget mainWidget(BuildContext context, ScreenManagerCubitState state) {
    return const Center(child: Text('Dashboard Content'));
  }
}
```

### Automatic Side Effects Handled by `BlocxScreenManagerState`
1. **Snackbars**:
   - `ScreenManagerCubitStateDisplaySnackbar` $\rightarrow$ calls `displaySnackBar(context, state.message, state.title, state.snackbarType)`
   - `ScreenManagerCubitStateDisplaySnackbarByErrorCode` $\rightarrow$ translates `loc.errorCodeMessage(state.errorCode)` and calls `displaySnackBar(...)`
2. **Route Popping**:
   - `ScreenManagerCubitStatePop` $\rightarrow$ calls `Navigator.of(context).maybePop()` (triggered when a BLoC calls `pop()` or when `BlocxFormSyncStreamMixin` detects the watched entity was deleted with `popOnEntityDeleted == true`).
3. **Full-Page Error Rendering**:
   - `ScreenManagerCubitStateDisplayErrorPage` $\rightarrow$ replaces `mainWidget` with `errorWidget(context, state)` (defaults to `BlocxErrorWidget.fromState(state)`).
   - `ScreenManagerCubitStateDisplayErrorPageByErrorCode` $\rightarrow$ replaces `mainWidget` with `errorWidgetByErrorCode(context, state)`.

### Overridable Hooks on `BlocxScreenManagerState`
- `ScreenManagerCubit get managerCubit;` *(required when extending `BlocxScreenManagerState` directly; already implemented by `BlocxCollectionWidgetState` and `BlocxFormWidgetState`)*
- `Widget mainWidget(BuildContext context, ScreenManagerCubitState state);` *(required when extending directly)*
- `bool get wrapInScaffold => false;` *(when `false`, wraps `body` in `SafeArea`; when `true`, calls `decorateScaffold(scaffoldWidget(context, body))`)*
- `Widget scaffoldWidget(BuildContext context, Widget body)` *(must be overridden whenever `wrapInScaffold` is `true`)*
- `Widget decorateScaffold(Widget scaffold) => scaffold;`
- `Widget errorWidget(BuildContext context, ScreenManagerCubitStateDisplayErrorPage state)` *(override to pass `onRetry` or `onReport` to `BlocxErrorWidget.fromState(state, onRetry: ...)`)*
- `Widget errorWidgetByErrorCode(BuildContext context, ScreenManagerCubitStateDisplayErrorPageByErrorCode state)`
- `void displaySnackBar(BuildContext context, String message, String? title, BlocXSnackbarType snackbarType)`

---

## 2. `BlocxStatelessWidget` & `BlocXWidgetState<W>` (`BlocxWidgetState<W>`)

Convenience base classes that provide concise theme and screen-size helpers:

### `BlocxStatelessWidget` (methods take `BuildContext context`)
```dart
class SummaryHeader extends BlocxStatelessWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      color: colorScheme(context).surfaceContainer,
      child: Text('Summary', style: textTheme(context).titleMedium),
    );
  }
}
```
- `ThemeData theme(BuildContext context)`
- `TextTheme textTheme(BuildContext context)`
- `ColorScheme colorScheme(BuildContext context)`
- `double width(BuildContext context)`
- `double height(BuildContext context)`

### `BlocXWidgetState<W>` / `BlocxWidgetState<W>` (getters without `BuildContext`)
Every `BlocxWidgetState` (including `BlocxScreenManagerState`, `BlocxCollectionWidgetState`, and `BlocxFormWidgetState`) exposes:
- `ThemeData get theme`
- `TextTheme get textTheme`
- `ColorScheme get colorScheme`
- `double get width`
- `double get height`

---

## 3. `BlocxErrorWidget`

Displays a Material 3 error card (`colorScheme.errorContainer`) with title, message, short error summary, collapsible stack trace (`ExpansionTile`), and action buttons (`Try again`, `Copy details`, `Report`, `Close`).

```dart
// 1. Direct construction:
BlocxErrorWidget(
  error: ReadableError(
    title: 'Connection Failed',
    message: 'Unable to reach the server.',
    error: exception,
    stackTrace: stackTrace,
  ),
  onRetry: () => bloc.add(BlocxCollectionEventLoadInitialPage()),
  onReport: () => reportError(exception, stackTrace),
  expandDetails: false,
)

// 2. From ScreenManagerCubitStateDisplayErrorPage inside BlocxScreenManagerState.errorWidget:
@override
Widget errorWidget(
  BuildContext context,
  ScreenManagerCubitStateDisplayErrorPage state,
) {
  return BlocxErrorWidget.fromState(
    state,
    onRetry: refreshData,
  );
}
```

---

## 4. `BlocxSnackBar`

Displays a responsive floating Material 3 snackbar styled according to `BlocXSnackbarType` (`BlocxSnackbarType.info`, `BlocxSnackbarType.warning`, `BlocxSnackbarType.error`):

```dart
BlocxSnackBar.show(
  context,
  title: 'Saved',
  message: 'Your changes have been saved.',
  type: BlocxSnackbarType.info,
  duration: const Duration(seconds: 4),
);
```

---

## 5. `ConfirmActionWidget` & `ConfirmActionOptions`

Displays a modal bottom sheet for destructive or confirmable actions, with optional type-to-confirm protection (`requireTyping: true`, `deleteWord: 'DELETE'`) and an optional leading network image thumbnail (`imageUrl`):

```dart
final confirmed = await ConfirmActionWidget.show(
  context,
  isScrollControlled: true,
  options: ConfirmActionOptions(
    title: 'Delete Account?',
    question: 'This will permanently delete all your data.',
    confirmText: 'Delete Forever',
    cancelText: 'Cancel',
    icon: Icons.warning_amber_rounded,
    requireTyping: true,
    deleteWord: 'DELETE',
    imageUrl: null,
  ),
);

if (confirmed == true) {
  // Perform deletion
}
```
> **Note**: `ConfirmActionOptions(...)` has a non-`const` constructor; do not prefix it with `const`.

---

## 6. `loc` & `BlocXLocalizations` Setup

`flutter_blocx` reads localized strings from the top-level getter `BlocXLocalizations get loc => BlocXLocalizations.localizations;`.
- In `main()` or in widget test `setUpAll()`, you can assign a custom `BlocXLocalizations` implementation:
  ```dart
  BlocXLocalizations.localizations = MyAppLocalizations();
  ```
- Used automatically by:
  - `BlocxCollectionWidgetState`: `loc.loadingText`, `loc.emptyListText`
  - `BlocxErrorWidget`: `loc.somethingWentWrong`, `loc.tryAgain`, `loc.copyDetails`, `loc.report`, `loc.close`, `loc.details`, `loc.errorDetailsCopied`
  - `ConfirmActionWidget`: `loc.areYouSure`, `loc.areYouSureYouWantToDeleteThisItem`, `loc.cancel`, `loc.delete`
  - `BlocxFormWidgetState.formButtonRow`: `loc.cancel`
  - `BlocxScreenManagerState`: `loc.errorCodeMessage(state.errorCode)`

---

## 7. Ephemeral UI State: `BlocxLocal<T>` & `BlocxUiToggle`

Use `BlocxLocal<T>` or `BlocxUiToggle` for self-contained visual micro-interactions (disclosure accordions, preview panels, local tab indices, inline filters) so you do not need to write throwaway `StatefulWidget` classes or pollute a `BlocxFormBloc` entity with non-persisted UI state:

```dart
// 1. Generic self-disposing local value holder (ValueNotifier<T> + ValueListenableBuilder<T>)
BlocxLocal<int>(
  initialValue: 0,
  onChanged: (tab) => debugPrint('Active tab: $tab'),
  builder: (context, tab, setTab, updateTab) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Details')),
        ButtonSegment(value: 1, label: Text('Activity')),
      ],
      selected: {tab},
      onSelectionChanged: (s) => setTab(s.first),
    );
  },
)

// 2. Boolean toggle primitive built on BlocxLocal<bool>
BlocxUiToggle(
  initialValue: false,
  onChanged: (expanded) => debugPrint('Expanded: $expanded'),
  builder: (context, isExpanded, toggle, setExpanded) {
    return Column(
      children: [
        ListTile(
          title: const Text('Advanced Options'),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: toggle,
        ),
        if (isExpanded) const AdvancedOptionsPanel(),
      ],
    );
  },
)
```

### API Summary
- **`BlocxLocal<T>`**:
  - `required T initialValue`
  - `required BlocxLocalWidgetBuilder<T> builder` — `(BuildContext context, T value, ValueChanged<T> setValue, void Function(T Function(T current) updater) update)`
  - `ValueChanged<T>? onChanged` — fires only when the new value differs (`_notifier.value != next`); guards against calls after unmount and disposes the internal `ValueNotifier<T>` automatically in `dispose()`.
- **`BlocxUiToggle`**:
  - `bool initialValue = false`
  - `required BlocxUiToggleBuilder builder` — `(BuildContext context, bool isActive, VoidCallback toggle, ValueChanged<bool> setValue)`
  - `ValueChanged<bool>? onChanged`

---

## 8. Testing Helpers & Semantic Finders (`package:flutter_blocx/testing.dart`)

Import `package:flutter_blocx/testing.dart` inside tests to access both all pure-Dart fixtures/fakes from `package:blocx_core/testing.dart` (`BlocxTestEntity`, `createTestEntities`, `BlocxTestEventHub`, `FakePaginatedSource`, `FakePaginatedUseCase`, `FakeSearchUseCase`, `createFakePaginatedTask`, `BlocxCollectionStateSeeder`, `BlocxFormStateSeeder`) and `BlocxCommonFinders` on `CommonFinders` (`find`):

```dart
import 'package:flutter_blocx/testing.dart';
import 'package:flutter_test/flutter_test.dart';

testWidgets('submits credentials using semantic finders', (tester) async {
  // ... pump form or collection screen
  await tester.enterText(find.blocxField(LoginField.password), 'secret123');
  await tester.tap(find.blocxObscureToggle(LoginField.password));
  await tester.tap(find.blocxSwitch(LoginField.rememberMe));
  await tester.tap(find.blocxFilter('admin'));
  await tester.tap(find.blocxSubmitButton());
  await tester.pumpAndSettle();

  expect(find.blocxItem('item-1'), findsOneWidget);
  expect(find.blocxBadge('active'), findsOneWidget);
});
```

### Deterministic Keys & `BlocxCommonFinders` Reference

| Finder Method | Matched `ValueKey<String>` Pattern | Target Widget |
| :--- | :--- | :--- |
| `find.blocxItem(Object id)` | `'blocx_item_$id'`, `'$id'`, or `'$id+...'` (deduplicated per rendered item) | Item rows/tiles across all 6 `Infinite*` / `SliverInfinite*` engines |
| `find.blocxSearchField()` | `'blocx_search_field'` | `BlocxSearchField` |
| `find.blocxField(Enum field)` | `'blocx_field_${field.name}'` | `BlocXFormTextField`, `BlocxFormChipField`, `BlocxFormSegmentedField` |
| `find.blocxDropdown(Enum field)` | `'blocx_dropdown_${field.name}'` | `BlocXFormDropdown` |
| `find.blocxCheckbox(Enum field)` | `'blocx_checkbox_${field.name}'` | `BlocxFormCheckbox` |
| `find.blocxSwitch(Enum field)` | `'blocx_switch_${field.name}'` | `BlocxFormSwitchField` |
| `find.blocxObscureToggle(Enum field)` | `'blocx_obscure_toggle_${field.name}'` | Suffix eye button inside password `BlocXFormTextField` |
| `find.blocxFilter(Object filterValue)` | `'blocx_filter_$filterValue'` | `ChoiceChip` / `FilterChip` inside `BlocxFormChipField` (or custom filter chips) |
| `find.blocxBadge(Object status)` | `'blocx_badge_$status'` | Status badges tagged with `ValueKey('blocx_badge_$status')` |
| `find.blocxSubmitButton()` | `'blocx_submit_button'` | `BlocxFormRegisterButton` |
| `find.blocxCancelButton()` | `'blocx_cancel_button'` | Secondary cancel button in `BlocxFormButtonRow` |

*(Additionally, `BlocxFormSubmitBuilder` wraps its child in `ValueKey('blocx_submit_builder')` and `BlocxFormStepBuilder` wraps its child in `ValueKey('blocx_step_builder')`.)*

> **Widget test tip**: Set `VisibilityDetectorController.instance.updateInterval = Duration.zero;` in `setUpAll` when testing `InfiniteList` / `InfiniteGrid` widgets, and dispose blocs synchronously (`bloc.close();`) inside `testWidgets` rather than `await bloc.close()`.
