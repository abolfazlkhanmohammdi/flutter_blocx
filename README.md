<p align="center">
  <img src="https://raw.githubusercontent.com/abolfazlkhanmohammdi/flutter_blocx/main/assets/pub/logo.png" width="200" alt="flutter_blocx logo" />
</p>

<h1 align="center">flutter_blocx</h1>

<p align="center">
  Production-ready Flutter widgets for lists, grids, and forms.<br/>
  The UI layer for <a href="https://pub.dev/packages/blocx_core"><code>blocx_core</code></a> — zero paging flags, zero scroll listeners, zero boilerplate.
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_blocx"><img src="https://img.shields.io/pub/v/flutter_blocx.svg" alt="pub version"/></a>
  <a href="https://pub.dev/packages/flutter_blocx"><img src="https://img.shields.io/pub/points/flutter_blocx" alt="pub points"/></a>
  <a href="https://pub.dev/packages/flutter_blocx"><img src="https://img.shields.io/badge/platform-flutter-blue" alt="platform"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green" alt="license"/></a>
</p>

---

## Overview

`flutter_blocx` is the Flutter UI companion to [`blocx_core`](https://pub.dev/packages/blocx_core). It provides a complete set of base widgets and ready-made inputs that connect directly to `blocx_core` blocs — giving you infinite scrolling, search, pull-to-refresh, selection, highlight, expand/collapse, and form handling without writing any of the wiring yourself.

The architecture is intentional: `blocx_core` owns all business logic and state; `flutter_blocx` owns all rendering and user interaction. Neither layer bleeds into the other.

> **Prerequisites.** This package assumes familiarity with `blocx_core`. If you have not read the [`blocx_core` documentation](https://pub.dev/packages/blocx_core) yet, start there before continuing.

---

## Table of Contents

- [Installation](#installation)
- [Setup](#setup)
- [Package Structure](#package-structure)
- [Lists & Collections](#lists--collections)
    - [CollectionWidget & CollectionWidgetState](#collectionwidget--collectionwidgetstate)
    - [BlocxCollectionItem](#blocxcollectionitem)
    - [BlocxStatefulCollectionItem & BlocxCollectionItemState](#blocxstatefulcollectionitem--blocxcollectionitemstate)
    - [BlocxSearchField](#blocxsearchfield)
    - [Prebuilt Scrolling Widgets](#prebuilt-scrolling-widgets)
    - [HideOnScrollFabMixin](#hideOnScrollFabMixin)
- [Forms](#forms)
    - [FormWidget & BlocxFormWidgetState](#formwidget--blocxformwidgetstate)
    - [BlocXFormTextField](#blocxformtextfield)
    - [BlocXFormDropdown](#blocxformdropdown)
    - [FormButtonRow](#formbuttonrow)
    - [FormRegisterButton](#formregisterbutton)
- [Shared Utilities](#shared-utilities)
    - [ConfirmActionWidget](#confirmactionwidget)
    - [BlocxStatelessWidget & BlocXWidgetState](#blocxstatelesswidget--blocxwidgetstate)
- [Localization](#localization)
- [Quickstart: Collection Screen](#quickstart-collection-screen)
- [Quickstart: Form Screen](#quickstart-form-screen)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

Add `flutter_blocx` and `blocx_core` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  blocx_core: ^0.7.0
  flutter_blocx: ^0.6.0
```

Or install via the command line:

```sh
flutter pub add flutter_blocx
```

---

## Setup

Before running your app, register a `BlocXLocalizations` implementation. This provides human-readable strings for built-in error codes used internally by the framework:

```dart
import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

void main() {
  BlocXLocalizations.localizations = AppLocalizations();
  runApp(const MyApp());
}

class AppLocalizations extends BlocXLocalizations {
  @override
  String errorCodeMessage(BlocXErrorCode errorCode) {
    return switch (errorCode) {
      BlocXErrorCode.checkingUniqueValue       => 'Checking availability…',
      BlocXErrorCode.valueNotAvailable         => 'This value is already taken.',
      BlocXErrorCode.errorGettingInitialFormData => 'Failed to load form data.',
      BlocXErrorCode.unknown                   => 'An unexpected error occurred.',
    };
  }
}
```

This step is required. Skipping it will result in missing error messages at runtime.

---

## Package Structure

`flutter_blocx` is organized into four focused libraries. Import only what you need:

```dart
// Everything (re-exports all libraries below):
import 'package:flutter_blocx/flutter_blocx.dart';

// Only list/collection widgets:
import 'package:flutter_blocx/list_widget.dart';

// Only form widgets:
import 'package:flutter_blocx/form_widget.dart';

// Only item-state base classes (for custom stateful item widgets):
import 'package:flutter_blocx/blocx_collection_item_state.dart';
```

| Library | Contents |
|---|---|
| `flutter_blocx` | Core base classes, `ConfirmActionWidget`, `BlocxStatelessWidget` |
| `list_widget` | Collection screens, item widgets, search field, infinite list/grid widgets |
| `form_widget` | Form screen base, text field, dropdown, button row, submit button |
| `blocx_collection_item_state` | Standalone item-state base classes for stateful item widgets |

---

## Lists & Collections

### CollectionWidget & CollectionWidgetState

`CollectionWidget<P>` is the abstract base `StatefulWidget` for building a collection screen. `P` is an optional payload type — use it to pass route arguments, filter parameters, or a parent entity ID into the screen and its bloc.

`CollectionWidgetState<W, T, P>` is the corresponding `State` base class. It wires itself to a `BlocxListBloc<T, P>` and exposes everything you need to build a fully featured list screen without managing any of the underlying event/state machinery yourself.

**Constructor:**

Pass your bloc instance via `super(bloc: myBloc)` in your state's constructor.

**Key members:**

| Member | Type | Description |
|---|---|---|
| `bloc` | `BlocxListBloc<T, P>` | The bloc managing data, paging, search, and selection |
| `scrollController` | `ScrollController` | Used internally for lazy loading and programmatic scroll |
| `state` | `BlocxListState<T>` | Current list state snapshot |
| `items` | `List<T>` | The current list of loaded items |
| `isLoadingNextPage` | `bool` | Whether the next page is being fetched |
| `hasReachedEnd` | `bool` | Whether the data source has been exhausted |
| `isRefreshing` | `bool` | Whether a pull-to-refresh is in progress |
| `isSearching` | `bool` | Whether a search query is active |

**Helper methods:**

| Method | Description |
|---|---|
| `refreshData()` | Reload the current data (pull-to-refresh semantics) |
| `loadNextPage()` | Trigger the next page load (infinite scroll) |
| `scrollToItem(T item, {duration, curve})` | Programmatically scroll to a known item |
| `insertItem(T item, {int? at})` | Insert an item into the list |
| `replaceItem(T item)` | Replace an existing item in the list (matched by id) |
| `removeItem(T item)` | Remove an item from the list |
| `canSelect` | Whether the bloc has selection capability |
| `selectItem(T item)` | Select an item |
| `deselectItem(T item)` | Deselect an item |
| `toggleSelection(T item)` | Toggle an item's selection state |
| `canHighlight` | Whether the bloc has highlight capability |
| `highlightItem(T item)` | Highlight an item |
| `unhighlightItem(T item)` | Remove the highlight from an item |
| `canExpand` | Whether the bloc has expand/collapse capability |
| `expandItem(T item)` | Expand an item |
| `collapseItem(T item)` | Collapse an item |

**Override points:**

| Method | When to override |
|---|---|
| `initState()` | Start initial loads, set up extra controllers or subscriptions |
| `didUpdateWidget(oldWidget)` | React to changed `payload` or external filter changes |
| `dispose()` | Clean up controllers and subscriptions |
| `build(BuildContext)` | Compose your screen — app bar, search field, body |
| `itemBuilder(BuildContext, T item)` | Render a single row or card |
| `topWidget(BuildContext, state)` | Optional widget placed above the list (e.g. a search field) |
| `settings` | Return a `CollectionSettings` to configure list vs grid and options |
| `wrapInScaffold` | Return `true` to have the state wrap the body in a `Scaffold` |
| `scaffoldWidget(BuildContext, Widget body)` | Customize the `Scaffold` when `wrapInScaffold` is `true` |

**`CollectionSettings` and `CollectionWidgetStateType`:**

Use the `settings` getter to declare whether the collection renders as a list or a grid, and to configure options:

```dart
@override
CollectionSettings get settings => CollectionSettings(
  type: CollectionWidgetStateType.grid,
  options: InfiniteGridOptions.defaultOptions().copyWith(
    childAspectRatio: 0.75,
  ),
);
```

| `CollectionWidgetStateType` | Renders as |
|---|---|
| `list` | Vertical `ListView` with infinite scroll |
| `grid` | `GridView` with infinite scroll |

---

### BlocxCollectionItem

`BlocxCollectionItem<T, P>` is the stateless base widget for individual list rows and cards. Extend it and override `buildContent` to render your item. The base class automatically provides context-aware helpers that reflect the current bloc state for that item — no manual state lookups required.

```dart
class ProductCard extends BlocxCollectionItem<Product, void> {
  const ProductCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, Product item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('\$${item.price}'),
      tileColor: isSelected(context) ? Colors.blue.shade50 : null,
      onTap: () => selectItem(context),
      onLongPress: () => deselectItem(context),
    );
  }
}
```

**Available helpers inside `buildContent`:**

| Helper | Type | Description |
|---|---|---|
| `isSelected(context)` | `bool` | Whether this item is currently selected |
| `isHighlighted(context)` | `bool` | Whether this item is currently highlighted |
| `isExpanded(context)` | `bool` | Whether this item is currently expanded |
| `isBeingRemoved(context)` | `bool` | Whether this item is in the process of being deleted |
| `selectItem(context)` | `void` | Select this item |
| `deselectItem(context)` | `void` | Deselect this item |
| `highlightItem(context)` | `void` | Highlight this item |
| `unhighlightItem(context)` | `void` | Remove highlight from this item |
| `expandItem(context)` | `void` | Expand this item |
| `collapseItem(context)` | `void` | Collapse this item |
| `removeItem(context)` | `void` | Remove this item via the bloc |
| `bloc(context)` | `BlocxListBloc<T, P>` | Access the parent bloc from within the item |
| `confirmDeleteOptions` | `ConfirmActionOptions?` | Override to show a confirmation dialog before deletion |

---

### BlocxStatefulCollectionItem & BlocxCollectionItemState

When a list item needs its own local state (e.g. an animation controller, a focus node, or a local toggle), use `BlocxStatefulCollectionItem<T>` paired with `BlocxCollectionItemState<W, T, P>`. These provide the same bloc-aware helpers as `BlocxCollectionItem`, but inside a `StatefulWidget` + `State` pair.

```dart
class ExpandableRow extends BlocxStatefulCollectionItem<Article> {
  const ExpandableRow({super.key, required super.item});

  @override
  State<ExpandableRow> createState() => _ExpandableRowState();
}

class _ExpandableRowState
    extends BlocxCollectionItemState<ExpandableRow, Article, void> {

  @override
  Widget buildContent(BuildContext context, Article item) {
    return Column(
      children: [
        ListTile(
          title: Text(item.title),
          trailing: Icon(isExpanded(context) ? Icons.expand_less : Icons.expand_more),
          onTap: () => isExpanded(context)
              ? collapseItem(context)
              : expandItem(context),
        ),
        if (isExpanded(context))
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(item.body),
          ),
      ],
    );
  }
}
```

---

### BlocxSearchField

`BlocxSearchField<T, P>` is a ready-made search input that connects directly to a `BlocxSearchableListBlocMixin`. It handles debouncing and emits the correct bloc events automatically — no `TextEditingController` listener, no manual event dispatch.

```dart
BlocxSearchField<Product, void>(
  hintText: 'Search products…',
  options: BlocxSearchFieldOptions(
    debounceMilliseconds: 400,
    // Additional decoration options
  ),
)
```

It emits `BlocxListEventSearch<T>` on each debounced keystroke and `BlocxListEventClearSearch<T>` when the field is cleared. The field resolves the bloc from the widget tree automatically via `BuildContext`.

**`BlocxSearchFieldOptions`** lets you customize the debounce duration, hint text style, decoration, and clear button behavior.

---

### Prebuilt Scrolling Widgets

For cases where you do not need the full `CollectionWidgetState` screen abstraction, `flutter_blocx` provides standalone scrollable widgets you can embed anywhere in your widget tree.

**List variants:**

| Widget | Description |
|---|---|
| `InfiniteList<T>` | Standard `ListView` with automatic next-page loading |
| `SliverInfiniteList<T>` | Sliver variant for use inside `CustomScrollView` |
| `AnimatedInfiniteList<T>` | Animated list with implicit item animations |
| `AnimatedSliverInfiniteList<T>` | Sliver animated variant |

**Grid variants:**

| Widget | Description |
|---|---|
| `InfiniteGrid<T>` | Standard `GridView` with automatic next-page loading |
| `SliverInfiniteGrid<T>` | Sliver variant for use inside `CustomScrollView` |

Each widget accepts an `itemBuilder` callback and an options object (`InfiniteListOptions`, `InfiniteGridOptions`, `SliverInfiniteListOptions`, `SliverInfiniteGridOptions`, or `AnimatedInfiniteListOptions`) for configuring item extent, separators, headers, footers, loading indicators, and empty/error states.

```dart
InfiniteList<Product>(
  itemBuilder: (context, item) => ProductCard(item: item),
  options: InfiniteListOptions(
    padding: EdgeInsets.all(8),
    // separatorBuilder, headerBuilder, footerBuilder, etc.
  ),
)
```

**`AnimatedInfiniteListState<T>` and `AnimatedSliverBlocxInfiniteListState<T>`** are the corresponding `State` base classes if you need to drive animation from a custom `StatefulWidget`.

---

### HideOnScrollFabMixin

Mix `HideOnScrollFabMixin<T>` into any `State` to automatically show and hide a floating action button based on scroll direction. Useful for collection screens with a FAB that should get out of the way while the user is scrolling.

```dart
class _MyScreenState extends CollectionWidgetState<MyScreen, Product, void>
    with HideOnScrollFabMixin<Product> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(context),
      floatingActionButton: buildFab(context), // provided by the mixin
    );
  }
}
```

---

## Forms

### FormWidget & BlocxFormWidgetState

`FormWidget<P>` is the abstract base `StatefulWidget` for form screens. `P` is the initialization payload type — use `void` if the form requires no external data to initialize.

`BlocxFormWidgetState<W, F, P, E>` is the corresponding `State` base class. It wires itself to a `BlocxFormBloc<F, P, E>` and handles state listening, submit/reset coordination, and error surfacing via `ScreenManagerCubit` automatically.

**Constructor:**

Pass your bloc instance via `super(bloc: myFormBloc)` in your state's constructor.

**Key members:**

| Member | Description |
|---|---|
| `bloc` | The `BlocxFormBloc<F, P, E>` managing form state |
| `formState` | The current `BlocxFormState<F, E>` snapshot |
| `isSubmitting` | Whether the form is currently submitting |
| `isLoaded` | Whether the form has been initialized and is ready |

**Override points:**

| Method | Description |
|---|---|
| `buildForm(BuildContext, BlocxFormState<F, E>)` | Required. Render the form fields and buttons |
| `onSubmitted(F form)` | Called after a successful submission |
| `initState()` | Start any pre-load data fetching |
| `dispose()` | Clean up resources |

---

### BlocXFormTextField

`BlocXFormTextField<F, P, E>` is a `TextField` that reads its value from, and writes its changes back to, the form bloc. It displays validation errors automatically when the bloc emits an error for the corresponding field key.

```dart
BlocXFormTextField<SignUpForm, void, SignUpField>(
  bloc: bloc,
  fieldKey: SignUpField.email,
  labelText: 'Email address',
  options: BlocXTextFieldOptions(
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    type: TextFieldType.email,
  ),
)
```

**`BlocXTextFieldOptions`** exposes common `TextField` configuration — keyboard type, input action, obscure text, max length, decoration overrides, and more. The default style is a filled field with rounded corners and no underline.

**`TextFieldType`** enum lets you declare the semantic type of the field (`email`, `password`, `phone`, `text`, etc.) so the widget applies appropriate defaults automatically.

---

### BlocXFormDropdown

`BlocXFormDropdown<F, P, E, T>` is a dropdown input wired to the form bloc. It reads its current value from the form state and dispatches `BlocxFormEventUpdateData` when the user selects a new item.

```dart
BlocXFormDropdown<ProfileForm, void, ProfileField, String>(
  bloc: bloc,
  fieldKey: ProfileField.country,
  items: countries.map((c) => DropdownMenuItem(value: c.code, child: Text(c.name))).toList(),
  options: BlocXDropdownOptions(
    labelText: 'Country',
  ),
)
```

---

### FormButtonRow

`FormButtonRow<F, P, E>` renders a horizontal row with a primary submit button and a secondary cancel/reset button. It observes the form bloc's state to disable the submit button while submission is in progress and to show a loading indicator.

```dart
FormButtonRow<SignUpForm, void, SignUpField>(
  onSubmit: () => bloc.add(BlocxFormEventSubmit()),
  onCancel: () => Navigator.of(context).pop(),
  submitLabel: 'Create account',
  cancelLabel: 'Back',
)
```

---

### FormRegisterButton

`FormRegisterButton<F, P, E>` is a standalone submit button with built-in loading and disabled states. Use it when you need more layout flexibility than `FormButtonRow` provides, or when you only need a submit button without a paired cancel action.

```dart
FormRegisterButton<SignUpForm, void, SignUpField>(
  state: formState,
  label: 'Create account',
  type: RegisterButtonType.filled,
  onTap: () => bloc.add(BlocxFormEventSubmit()),
)
```

**`RegisterButtonType`** controls the visual style: `filled`, `outlined`, or `text`.

---

## Shared Utilities

### ConfirmActionWidget

`ConfirmActionWidget` is a pre-built confirmation bottom sheet or dialog, used internally by `BlocxCollectionItem` when a `confirmDeleteOptions` override is provided, and available for direct use in your own widgets.

Configure it via `ConfirmActionOptions`:

```dart
ConfirmActionOptions(
  title: 'Delete account',
  question: 'This action is permanent and cannot be undone. Are you sure?',
  imageUrl: user.avatarUrl, // optional — renders an avatar in the dialog
)
```

When `confirmDeleteOptions` is overridden on a `BlocxCollectionItem`, tapping `removeItem` will automatically show this confirmation before dispatching the delete event to the bloc.

---

### BlocxStatelessWidget & BlocXWidgetState

`BlocxStatelessWidget` and `BlocXWidgetState<W>` are lightweight base classes that provide access to common Flutter conveniences — `Theme`, `TextTheme`, `ColorScheme`, `MediaQuery`, and `Navigator` — as named getters, reducing verbosity in widget code.

```dart
class MyWidget extends BlocxStatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello',
      style: textTheme(context).headlineMedium, // direct getter, no Theme.of(context)
    );
  }
}
```

---

## Localization

`BlocXLocalizations` maps internal `BlocXErrorCode` values to display strings. This affects error messages surfaced via `ScreenManagerCubit` — for example, when a unique-field validation fails or when form initialization data cannot be fetched.

Extend `BlocXLocalizations` and register your implementation before `runApp`:

```dart
BlocXLocalizations.localizations = MyAppLocalizations();
```

The four error codes to handle are:

| Code | When it appears |
|---|---|
| `BlocXErrorCode.checkingUniqueValue` | While an async uniqueness check is in progress |
| `BlocXErrorCode.valueNotAvailable` | When a uniqueness check fails |
| `BlocXErrorCode.errorGettingInitialFormData` | When `BlocxInfoFetcherFormMixin` fails to load required data |
| `BlocXErrorCode.unknown` | Fallback for unclassified errors |

---

## Quickstart: Collection Screen

The following example builds a complete user list screen with infinite scrolling, search, selection, highlight, and deletion — in under 50 lines of UI code.

### 1. Bloc (from `blocx_core`)

```dart
class UsersBloc extends BlocxListBloc<User, void>
    with
        BlocxInfiniteListBlocMixin<User, void>,
        BlocxSearchableListBlocMixin<User, void>,
        BlocxSelectableListBlocMixin<User, void>,
        BlocxHighlightableListBlocMixin<User, void>,
        BlocxDeletableListBlocMixin<User, void> {

  UsersBloc() : super(ScreenManagerCubit(), BlocxInfiniteListBloc()) {
    initInfiniteList();
    initSearchable();
    initSelectable();
    add(BlocxListEventLoadInitialPage<User, void>());
  }

  @override
  BlocxPaginationUseCase<User>? get loadInitialPageUseCase =>
      FetchUsersUseCase(loadCount: 20, offset: 0);

  @override
  BlocxPaginationUseCase<User>? get loadNextPageUseCase =>
      FetchUsersUseCase(loadCount: 20, offset: list.length);

  @override
  BlocxBaseUseCase<bool>? deleteItemUseCase(User item) =>
      DeleteUserUseCase(user: item);

  @override
  SearchUseCase<User>? searchUseCase(String q, {int? loadCount, int? offset}) =>
      SearchUsersUseCase(searchText: q, loadCount: loadCount ?? 20, offset: offset ?? 0);

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) =>
      ('Failed to load users.', null);

  @override
  bool get isSingleSelect => false;
}
```

### 2. Screen

```dart
class UsersScreen extends CollectionWidget<void> {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends CollectionWidgetState<UsersScreen, User, void> {
  _UsersScreenState() : super(bloc: UsersBloc());

  @override
  Widget? topWidget(BuildContext context, BlocxListState<User> state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: BlocxSearchField<User, void>(
        options: BlocxSearchFieldOptions(),
      ),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, User item) => UserCard(item: item);

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: body,
    );
  }

  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: InfiniteListOptions(),
  );
}
```

### 3. Item Widget

```dart
class UserCard extends BlocxCollectionItem<User, void> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User item) {
    return ListTile(
      leading: CircleAvatar(child: Text(item.displayName[0])),
      title: Text(item.displayName),
      subtitle: Text(item.email),
      tileColor: isSelected(context) ? Colors.blue.shade50
               : isHighlighted(context) ? Colors.green.shade50
               : null,
      onTap: () => selectItem(context),
      onLongPress: () => removeItem(context),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
    title: 'Remove ${item.displayName}',
    question: 'Are you sure you want to remove this user?',
  );
}
```

---

## Quickstart: Form Screen

### 1. Form Entity, Field Enum & Validator (from `blocx_core`)

```dart
enum SignUpField { email, password, confirmPassword }

class SignUpForm extends BaseFormEntity<SignUpForm, SignUpField> {
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpForm({this.email = '', this.password = '', this.confirmPassword = ''});

  @override
  SignUpForm copyWith({String? email, String? password, String? confirmPassword}) =>
      SignUpForm(
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
      );
}

class SignUpValidator extends BlocxFormValidator<SignUpForm, SignUpField> {
  @override
  Map<SignUpField, List<BlocxFieldValidator>> get validators => {
    SignUpField.email: [
      BlocxRequiredValidator(),
      BlocxRegexValidator(pattern: r'^[^@]+@[^@]+\.[^@]+$', errorMessage: 'Enter a valid email.'),
    ],
    SignUpField.password: [
      BlocxRequiredValidator(),
      BlocxMinLengthValidator(minLength: 8),
    ],
    SignUpField.confirmPassword: [
      BlocxRequiredValidator(),
      BlocxMatchFieldValidator<String>(
        otherFieldValue: (form) => form.password,
        errorMessage: 'Passwords do not match.',
      ),
    ],
  };
}
```

### 2. FormBloc (from `blocx_core`)

```dart
class SignUpBloc extends BlocxFormBloc<SignUpForm, void, SignUpField>
    with BlocxFormValidationMixin<SignUpForm, void, SignUpField> {

  SignUpBloc() : super(ScreenManagerCubit(), const SignUpForm(), SignUpValidator());

  @override
  Future<void> onSubmit(SignUpForm form) async {
    // Call your use case here.
    // Use displaySnackBar(...) or pop() on completion.
  }
}
```

### 3. Form Screen

```dart
class SignUpScreen extends FormWidget<void> {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends BlocxFormWidgetState<SignUpScreen, SignUpForm, void, SignUpField> {
  _SignUpScreenState() : super(bloc: SignUpBloc());

  @override
  Widget buildForm(BuildContext context, BlocxFormState<SignUpForm, SignUpField> state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocXFormTextField<SignUpForm, void, SignUpField>(
            bloc: bloc,
            fieldKey: SignUpField.email,
            labelText: 'Email address',
            options: BlocXTextFieldOptions(keyboardType: TextInputType.emailAddress),
          ),
          const SizedBox(height: 16),
          BlocXFormTextField<SignUpForm, void, SignUpField>(
            bloc: bloc,
            fieldKey: SignUpField.password,
            labelText: 'Password',
            options: BlocXTextFieldOptions(obscureText: true),
          ),
          const SizedBox(height: 16),
          BlocXFormTextField<SignUpForm, void, SignUpField>(
            bloc: bloc,
            fieldKey: SignUpField.confirmPassword,
            labelText: 'Confirm password',
            options: BlocXTextFieldOptions(obscureText: true),
          ),
          const SizedBox(height: 32),
          FormButtonRow<SignUpForm, void, SignUpField>(
            onSubmit: () => bloc.add(BlocxFormEventSubmit()),
            onCancel: () => Navigator.of(context).pop(),
            submitLabel: 'Create account',
            cancelLabel: 'Back',
          ),
        ],
      ),
    );
  }
}
```

---

## Contributing

Contributions are welcome. Please follow these guidelines before opening a pull request:

- **Code style:** Run `flutter format .` and ensure `flutter analyze` reports no issues.
- **Documentation:** All public APIs must include dartdoc comments.
- **Tests:** Add widget tests for any new collection or form widget. Run `flutter test` to verify the full suite passes.
- **Scope:** Keep pull requests focused — one feature or fix per PR.

---

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file at the repository root for details.