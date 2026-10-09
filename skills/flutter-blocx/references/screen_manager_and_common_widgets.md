# Screen Manager, Error Widget, SnackBar, Confirm Sheet & Base Widgets

This reference documents `BlocxScreenManagerState`, `BlocxStatelessWidget`, `BlocXWidgetState` (`BlocxWidgetState`), `BlocxErrorWidget`, `BlocxSnackBar`, `ConfirmActionWidget`, and `BlocXLocalizations` (`loc`).

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
