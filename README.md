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

## Why flutter_blocx?

`flutter_blocx` is the Flutter UI framework built specifically for `blocx_core`.

While `blocx_core` provides reusable business-logic building blocks for collections, forms, pagination, searching, selection, validation, and screen management, `flutter_blocx` turns those capabilities into production-ready Flutter widgets and screen abstractions.

The goal is simple: **build complex data-driven screens without repeatedly wiring controllers, listeners, loading states, error handling, pagination, form validation, and UI side effects.**

### What it provides

#### Collection screens

Build lists and grids backed by `BlocxCollectionBloc` with support for:

* Infinite scrolling
* Pull-to-refresh
* Searching
* Item selection
* Item highlighting
* Item expansion
* Animated insert/remove operations
* Sliver and grid layouts
* Programmatic scrolling

Instead of manually coordinating scroll controllers, pagination triggers, loading indicators, and empty states, `BlocxCollectionWidgetState` provides a consistent collection-screen architecture out of the box.

#### Form screens

Create forms powered by `BlocxFormBloc` with built-in:

* Controller management
* Validation error display
* Async uniqueness checks
* Submit state handling
* Dropdowns and checkboxes
* Initial data hydration
* Form update tracking

`BlocxFormWidgetState` automatically synchronizes Flutter form controls with your form entity and bloc state, eliminating repetitive form wiring code.

#### Screen management

All screens integrate with `ScreenManagerCubit`, providing a unified way to:

* Show snackbars
* Display full-screen errors
* Handle retry flows
* Trigger navigation pops
* Surface error-code-based messages

This keeps UI side effects separate from business logic while remaining easy to consume from Flutter widgets.

#### Shared UX components

The package also includes reusable widgets for common application patterns:

* Search fields
* Confirmation dialogs
* Error pages
* Submit button states
* Floating-action-button visibility management
* Localization support

### Designed to work with blocx_core

`flutter_blocx` is not a replacement for `blocx_core`; it is its Flutter presentation layer.

Together they provide a complete architecture where:

* Use cases handle business operations
* Blocs manage application state
* Mixins compose reusable behaviour
* Widgets render and interact with that state

The result is a consistent, scalable approach for building CRUD applications, dashboards, admin panels, business tools, and any Flutter app that relies heavily on lists, forms, and server-driven data.

---

## Table of Contents

- [Installation](#installation)
- [Setup](#setup)
- [Lists & Collections](#lists--collections)
  - [BlocxCollectionWidget & BlocxCollectionWidgetState](#blocxcollectionwidget--blocxcollectionwidgetstate)
  - [BlocxCollectionItem](#blocxcollectionitem)
  - [BlocxStatefulCollectionItem & BlocxCollectionItemState](#blocxstatefulcollectionitem--blocxcollectionitemstate)
  - [BlocxSearchField](#blocxsearchfield)
  - [Prebuilt Scrolling Widgets](#prebuilt-scrolling-widgets)
  - [HideOnScrollFabMixin](#hideonscrollfabmixin)
- [Forms](#forms)
  - [BlocxFormWidget & BlocxFormWidgetState](#blocxformwidget--blocxformwidgetstate)
  - [BlocXFormTextField](#blocxformtextfield)
  - [BlocXFormDropdown](#blocxformdropdown)
  - [BlocxFormCheckbox](#blocxformcheckbox)
  - [BlocxFormButtonRow](#blocxformbuttonrow)
  - [BlocxFormRegisterButton](#blocxformregisterbutton)
- [Screen Management](#screen-management)
  - [BlocxScreenManagerState](#blocxscreenmanagerstate)
  - [BlocxErrorWidget](#blocxerrorwidget)
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

Add both packages to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  blocx_core: ^0.8.2
  flutter_blocx: ^0.8.3
```

Or install via the command line:

```sh
flutter pub add flutter_blocx
```

Import the library:

```dart
// Everything (screen utilities, shared widgets):
import 'package:flutter_blocx/flutter_blocx.dart';

// Collection / list widgets and state:
import 'package:flutter_blocx/list_widget.dart';

// Form widgets and state:
import 'package:flutter_blocx/form_widget.dart';

// Stateful item base (if needed separately):
import 'package:flutter_blocx/blocx_collection_item_state.dart';
```

---

## Setup

Before calling `runApp`, register a `BlocXLocalizations` implementation. This provides all strings used internally by the framework — error messages, loading text, empty-list copy, and button labels:

```dart
import 'package:blocx_core/blocx_core.dart';

void main() {
  BlocXLocalizations.localizations = AppLocalizations();
  runApp(const MyApp());
}

class AppLocalizations extends BlocXLocalizations {
  @override
  String get close => 'Close';

  @override
  String get copyDetails => 'Copy details';

  @override
  String dateRangeError(DateTime minDate, DateTime maxDate) =>
      'Date must be between ${minDate.toLocal()} and ${maxDate.toLocal()}.';

  @override
  String errorCodeMessage(BlocXErrorCode errorCode) {
    return switch (errorCode) {
      BlocXErrorCode.checkingUniqueValue         => 'Checking availability…',
      BlocXErrorCode.valueNotAvailable           => 'This value is already taken.',
      BlocXErrorCode.errorGettingInitialFormData => 'Failed to load form data.',
      BlocXErrorCode.fieldCannotBeEmpty          => 'This field cannot be empty.',
      BlocXErrorCode.unknown                     => 'An unexpected error occurred.',
    };
  }
}
```

Skipping this step will cause missing strings at runtime.

---

## Lists & Collections

### `BlocxCollectionWidget` & `BlocxCollectionWidgetState`

These two classes are your entry point for any list or grid screen.

**`BlocxCollectionWidget<P>`** is an abstract `StatefulWidget`. `P` is an optional payload type — use it for route arguments, filter parameters, or a parent entity ID. It exposes a single `payload` field that flows down into the state and bloc.

**`BlocxCollectionWidgetState<W, T, P>`** is the corresponding abstract `State`. It is the workhorse: it owns the entire bloc lifecycle, scroll controller setup, and full collection UI rendering.

#### How bloc initialisation works

You do **not** pass the bloc as a constructor parameter. Instead, override the `generateBloc` getter. The state calls it **once in `initState`**, stores the result privately, and disposes it automatically when the widget is removed from the tree (controlled by `autoDisposeBloc`, which defaults to `true`):

```dart
class _UsersScreenState
    extends BlocxCollectionWidgetState<UsersScreen, User, void> {

  @override
  BlocxCollectionBloc<User, void> get generateBloc => UsersBloc();
}
```

Internally, `initState` also:
- Creates the correct `ScrollController` (an `AutoScrollController` when the bloc has `BlocxCollectionScrollableMixin`, a plain `ScrollController` otherwise).
- Fires `BlocxCollectionEventLoadInitialPage` with `widget.payload` when `loadOnInit` is `true` (the default).

All of this happens before `super.initState()` so your bloc already has its initial data loading in flight by the time the first `build` runs.

#### What the state renders

The state wraps everything in a `BlocConsumer` tied to the bloc. On every rebuild it calls `collectionWrapperBuilder`, which stacks:

1. `topWidget` (if overridden) + spacing
2. The core body — one of:
  - `loadingWidget` while `isLoading || isSearching`
  - `emptyWidget` when the list is empty after loading
  - `collectionWidget` (the actual list/grid) otherwise
3. `bottomWidget` (if overridden) + spacing

All of this lives inside a `Column(crossAxisAlignment: CrossAxisAlignment.stretch)`, so the core body is wrapped in `Expanded` unless `settings.options.shrinkWrap` is `true`.

#### Key members

| Member | Type | Description |
|---|---|---|
| `generateBloc` | `BlocxCollectionBloc<T, P>` | **Required.** Instantiate and return your bloc here. |
| `bloc` | `BlocxCollectionBloc<T, P>` | Read-only access to the created bloc instance. |
| `scrollController` | `ScrollController?` | The active scroll controller. `AutoScrollController` when `BlocxCollectionScrollableMixin` is present. |
| `isLoading` | `bool` | `true` when the current state is `BlocxCollectionStateLoading`. |
| `isSearching` | `bool` | `true` when a search query is active on the bloc. |
| `payload` | `P?` | `widget.payload` forwarded for convenience. |

#### Override points

| Method / getter | Description |
|---|---|
| `generateBloc` | **Required.** Return a new bloc instance. |
| `itemBuilder(context, item)` | **Required.** Render a single list or grid item. |
| `settings` | Return a `CollectionSettings` to choose the widget type and its options. Default: `animatedList` with `AnimatedInfiniteListOptions()`. |
| `topWidget(context, state)` | Widget placed above the collection (e.g. a search field or filter bar). |
| `bottomWidget(context, state)` | Widget placed below the collection. |
| `sliverTopWidget(context, state)` | Sliver widget placed above sliver-based collections. |
| `sliverBottomWidget(context, state)` | Sliver widget placed below sliver-based collections. |
| `loadingWidget(context, state)` | Override the loading UI. Default: centred spinner + text from `loc.loadingText`. |
| `emptyWidget(context, state)` | Override the empty-list UI. Default: icon + `loc.emptyListText`. |
| `separatorBuilder(context, index)` | Build separators between items. Default: `SizedBox.shrink()`. |
| `loadMoreWidgetBuilder(context, isLoading)` | Custom "load more" indicator shown at the bottom during next-page loads. |
| `refreshWidgetBuilder(context, height)` | Custom pull-to-refresh indicator. |
| `deleteAnimation` | `AnimatedChildBuilder?` used when items are removed from an animated list. |
| `insertAnimation` | `AnimatedChildBuilder?` used when items are inserted. |
| `wrapInScaffold` | Return `true` to delegate body wrapping to `scaffoldWidget`. Default: `false`. |
| `scaffoldWidget(context, body)` | Must be overridden when `wrapInScaffold` is `true`. |
| `decorateScaffold(scaffold)` | Wrap the resulting scaffold (e.g. with `PopScope`). |
| `blocListener(context, state)` | Hook into listen-only states such as `BlocxCollectionStateSelectionChanged`. |
| `onSelectionChanged(context, data)` | Convenience hook called specifically when selection changes. |
| `loadOnInit` | Whether to fire `BlocxCollectionEventLoadInitialPage` automatically. Default: `true`. |
| `autoDisposeBloc` | Whether to close the bloc in `dispose`. Default: `true`. |
| `topBottomAndListSpacing` | Gap in px between `topWidget`/`bottomWidget` and the list. Default: `8.0`. |
| `searchingText` | Text shown in `loadingWidget` while a search is running. |

#### Action helpers

| Method | Description |
|---|---|
| `refreshData()` | Dispatches `BlocxCollectionEventRefreshData` |
| `loadNextPage()` | Dispatches `BlocxCollectionEventLoadNextPage` |
| `search(text)` | Dispatches `BlocxCollectionEventSearch` |
| `scrollToItem(item, {highlightItem})` | Programmatic scroll (requires `BlocxCollectionScrollableMixin`) |
| `addToList(item, {index})` | Dispatches `BlocxCollectionEventAddItem` |
| `deleteMultipleItems(items)` | Dispatches `BlocxCollectionEventRemoveMultipleItems` |
| `deselectMultipleItems(items)` | Dispatches `BlocxCollectionEventDeselectMultipleItems` |

#### `CollectionSettings` and layout types

```dart
@override
CollectionSettings get settings => CollectionSettings(
  type: CollectionWidgetStateType.grid,
  options: InfiniteGridOptions(crossAxisCount: 2, childAspectRatio: 0.75),
);
```

| `CollectionWidgetStateType` | Required options class | Renders as |
|---|---|---|
| `animatedList` | `AnimatedInfiniteListOptions` | `ListView` with implicit item animations *(default)* |
| `list` | `InfiniteListOptions` | Standard `ListView` with infinite scroll |
| `sliverList` | `SliverInfiniteListOptions` | Sliver list (for `CustomScrollView`) |
| `animatedSliverList` | `AnimatedSliverInfiniteListOptions` | Sliver animated list |
| `grid` | `InfiniteGridOptions` | `GridView` with infinite scroll |
| `sliverGrid` | `SliverInfiniteGridOptions` | Sliver grid |

The options class must match the type — a mismatch throws an `ArgumentError` at runtime. All options classes share a common base with these fields:

| Field | Default | Description |
|---|---|---|
| `shrinkWrap` | `false` | Shrink-wrap the scroll view |
| `reverse` | `false` | Reverse scroll direction |
| `scrollDirection` | `Axis.vertical` | Scroll axis |
| `scrollPhysics` | `null` | Custom scroll physics |
| `scrollBehavior` | `null` | Custom scroll behaviour |
| `loadMoreTriggerItemDistance` | `2` | Items from the end that trigger next-page loading |

---

### `BlocxCollectionItem`

`BlocxCollectionItem<T, P>` is the stateless base widget for individual list rows and cards. It resolves the parent `BlocxCollectionBloc<T, P>` from the widget tree automatically and exposes context-aware state flags and action helpers for that specific item.

```dart
class UserCard extends BlocxCollectionItem<User, void> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User item) {
    return ListTile(
      title: Text(item.displayName),
      subtitle: Text(item.email),
      tileColor: isSelected(context) ? Colors.blue.shade50 : null,
      onTap: () => toggleSelection(context),
      onLongPress: () => removeItem(context),
    );
  }
}
```

**Reactive state flags** (re-read from the bloc on every `build`):

| Flag | Description |
|---|---|
| `isSelected(context)` | Item id is in `state.selectedItemIds` |
| `isHighlighted(context)` | Item id is in `state.highlightedItemIds` |
| `isBeingRemoved(context)` | Item id is in `state.beingRemovedItemIds` |
| `isBeingSelected(context)` | Item id is in `state.beingSelectedItemIds` |
| `isExpanded(context)` | Item id is in `state.expandedItemIds` |

**Action helpers** — each validates that the corresponding mixin is present on the bloc and throws a descriptive `FlutterError` if not:

| Method | Required mixin |
|---|---|
| `selectItem(context)` | `BlocxCollectionSelectableMixin` |
| `deselectItem(context)` | `BlocxCollectionSelectableMixin` |
| `toggleSelection(context)` | `BlocxCollectionSelectableMixin` |
| `highlightItem(context)` | `BlocxCollectionHighlightableMixin` |
| `clearHighlightedItem(context)` | `BlocxCollectionHighlightableMixin` |
| `toggleExpansion(context)` | `BlocxCollectionExpandableMixin` |
| `removeItem(context)` | `BlocxCollectionDeletableMixin` |
| `updateItem(context, item)` | *(dispatches directly)* |
| `insertItem(context, item, {index})` | *(dispatches directly)* |
| `toggleAllItemsSelection(context)` | `BlocxCollectionSelectableMixin` |
| `toggleMultipleItemsSelection(context, items, areSelected)` | `BlocxCollectionSelectableMixin` |

**Deletion confirmation** — by default `confirmBeforeDelete` is `true`. Calling `removeItem` shows `ConfirmActionWidget` as a modal bottom sheet before dispatching the delete event. Override `confirmDeleteOptions` to configure the sheet, or set `confirmBeforeDelete` to `false` to skip it:

```dart
@override
bool get confirmBeforeDelete => false; // skip confirmation

@override
ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
  title: 'Remove ${item.displayName}',
  question: 'This cannot be undone.',
  imageUrl: item.avatarUrl, // optional avatar instead of icon
);
```

---

### `BlocxStatefulCollectionItem` & `BlocxCollectionItemState`

When a list item needs its own local state (e.g. an animation controller, a focus node, or an expansion flag managed outside the bloc), use `BlocxStatefulCollectionItem<T>` paired with `BlocxCollectionItemState<W, T, P>`.

The key difference from the stateless version is that state flags and action helpers are **getters and methods with no `BuildContext` argument** — `context` is already available via `State`:

```dart
class ExpandableArticleRow extends BlocxStatefulCollectionItem<Article> {
  const ExpandableArticleRow({super.key, required super.item});

  @override
  State<ExpandableArticleRow> createState() => _ExpandableArticleRowState();
}

class _ExpandableArticleRowState
    extends BlocxCollectionItemState<ExpandableArticleRow, Article, void> {

  @override
  Widget buildContent(Article item) {
    return Column(
      children: [
        ListTile(
          title: Text(item.title),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: toggleExpansion,  // no context argument
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(item.body),
          ),
      ],
    );
  }
}
```

State flags (`isSelected`, `isHighlighted`, `isExpanded`, etc.) and action helpers (`selectItem()`, `removeItem()`, `toggleSelection()`, etc.) all work the same way as in `BlocxCollectionItem` — with the same mixin guards — but without needing to pass `context`.

---

### `BlocxSearchField`

`BlocxSearchField<T, P>` is a pre-wired search input that resolves the parent `BlocxCollectionBloc<T, P>` from the widget tree and connects to its `BlocxCollectionSearchableMixin`. It dispatches `BlocxCollectionEventSearch` on every keystroke and `BlocxCollectionEventClearSearch` when the field is cleared.

**Important:** `BlocxSearchField` requires an explicit `TextEditingController` — you own its lifecycle:

```dart
class _ScreenState extends BlocxCollectionWidgetState<User,void> {
  final _searchController = TextEditingController();

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<User> state) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: BlocxSearchField<User, void>(
        controller: _searchController,
        options: const BlocxSearchFieldOptions(hintText: 'Search users…'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

The field throws a descriptive `FlutterError` if the resolved bloc does not implement `BlocxCollectionSearchableMixin`.

**`BlocxSearchFieldOptions`** key fields:

| Field | Default | Description |
|---|---|---|
| `hintText` | `'Search...'` | Placeholder text |
| `prefixIcon` | `Icon(Icons.search)` | Leading icon |
| `showClearButton` | `true` | Show ✕ when field has text |
| `decoration` | computed | Full `InputDecoration` override |
| `autofocus` | `false` | Request focus on first build |
| `maxLines` | `1` | Maximum line count |

---

### Prebuilt Scrolling Widgets

For cases where you don't need the full `BlocxCollectionWidgetState` abstraction, `flutter_blocx` provides standalone scrollable widgets you can embed anywhere. Each requires an `itemBuilder`, the matching options class, a `BlocxInfiniteListBloc` reference (`bloc.infiniteListBloc`), and a `ScrollController`.

**List variants:** `InfiniteList<T>`, `SliverInfiniteList<T>`, `AnimatedInfiniteList<T>`, `AnimatedSliverInfiniteList<T>`

**Grid variants:** `InfiniteGrid<T>`, `SliverInfiniteGrid<T>`

```dart
InfiniteList<Product>(
  items: state.list,
  itemBuilder: (context, item) => ProductCard(item: item),
  bloc: myBloc.infiniteListBloc,
  scrollController: scrollController,
  loadBottomData: loadNextPage,
  refreshOnSwipe: refreshData,
  options: InfiniteListOptions(padding: const EdgeInsets.all(8)),
)
```

---

### `HideOnScrollFabMixin`

Mix `HideOnScrollFabMixin<T>` into any `State` to automatically show and hide a `FloatingActionButton` based on scroll direction. Feed scroll events from a `NotificationListener<UserScrollNotification>` and use `getFloatingActionButton(context)` to get the animated FAB:

```dart
class _MyScreenState extends BlocxCollectionWidgetState<MyScreen, Product, void>
    with HideOnScrollFabMixin<Product> {

  @override
  void onFabPressed(Product? data) { /* handle tap */ }

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: onScrollNotification,
        child: body,
      ),
      floatingActionButton: getFloatingActionButton(context),
    );
  }
}
```

The FAB slides and fades out when scrolling down; it returns when scrolling up. Override `onFabPressed(T? data)` to handle taps.

---

## Forms

### `BlocxFormWidget` & `BlocxFormWidgetState`

These two classes are the entry point for any form screen.

**`BlocxFormWidget<P>`** is an abstract `StatefulWidget`. `P` is the payload type — pass an existing entity for edit/update forms. Use `void` for create-only forms.

**`BlocxFormWidgetState<W, F, P, E>`** is the corresponding abstract `State`. It extends `BlocxScreenManagerState`, so all snackbar, error-page, and pop side-effects from the bloc are handled automatically.

#### Type parameters

| Parameter | Description |
|---|---|
| `W` | The `BlocxFormWidget` subclass this state belongs to |
| `F` | The immutable form entity. Must extend `BlocxBaseFormEntity<F, E>` |
| `P` | The payload type. Use `void` for create-only forms |
| `E` | The field enum — every form field maps to one value |

#### How bloc initialisation works

Override `generateBloc()` — a method (not a getter) called **once in `initState`**:

```dart
class _SignUpScreenState
    extends BlocxFormWidgetState<SignUpScreen, SignUpForm, void, SignUpField> {

  @override
  BlocxFormBloc<SignUpForm, void, SignUpField> generateBloc() => SignUpBloc();

  @override
  List<SignUpField> get keys => SignUpField.values;
  // ...
}
```

After creating the bloc, `initState` automatically dispatches `BlocxFormEventInit(payload: widget.payload)`. If `BlocxFormInfoFetcherMixin` is applied to the bloc, it will then fire `BlocxFormEventFetchRequiredInfo` to load remote data before the form renders.

The state manages all `TextEditingController`s and `FocusNode`s via internal maps — they are created on demand and disposed automatically in `dispose`. Never create controllers manually for fields you use through `textField()`.

#### What the state renders

The state wraps the bloc in a `BlocConsumer`. On every rebuild it calls `formWidget(context, state)`, which you implement to build your column of inputs and buttons.

The state listens for three listen-only states and handles them automatically:
- `BlocxFormStateApplyInitialDataToForm` → hydrates all `TextEditingController`s from `formData` by calling `applyInitialDataToForm`, which uses `getFormattedValueByKey` (falling back to `getValueByKey`) for each key in your `keys` list.
- `BlocxFormStateFormSubmitted` → calls `onFormSubmitted(state)`, which you can override to navigate or show a banner.
- `BlocxFormStateFormUpdated` → calls `onFormUpdated(formData)`, useful for character counters or enabling/disabling other UI elements.

#### Key members

| Member | Type | Description |
|---|---|---|
| `bloc` | `BlocxFormBloc<F, P, E>` | The form bloc, created by `generateBloc()` |
| `state` | `BlocxFormState<F, E>` | Current form state snapshot |
| `isValid` | `bool` | `true` when `errors`, `fieldsFetchingInfo`, and `checkingUniqueFields` are all empty |
| `isUpdate` | `bool` | `true` when `widget.payload != null` |
| `payload` | `P?` | `widget.payload` forwarded for convenience |
| `formVerticalSpacing` | `double` | Vertical gap between fields. Default: `16` |
| `autoCloseBloc` | `bool` | Close bloc on dispose. Default: `true` |

#### Override points

| Method / getter | Description |
|---|---|
| `generateBloc()` | **Required.** Instantiate and return the form bloc. |
| `formWidget(context, state)` | **Required.** Build the form UI. Return a column of inputs and buttons. |
| `keys` | **Required.** List all field enum values that use `textField()`. Used by `applyInitialDataToForm` to hydrate controllers on edit-mode init. |
| `onFormSubmitted(state)` | Called when `BlocxFormStateFormSubmitted` is emitted. Override to navigate away or trigger analytics. |
| `onFormUpdated(formData)` | Called on every `BlocxFormStateFormUpdated`. |
| `blocListener(context, state)` | Hook into additional listen-only states. Call `super.blocListener(context, state)` to retain default behaviour. |

#### Built-in field builder helpers

| Method | Returns | Description |
|---|---|---|
| `textField(key, {options, validator, type})` | `BlocXFormTextField` | Text input with a managed controller and auto error display |
| `dropdown<T>(key, {items, options})` | `BlocXFormDropdown` | Dropdown wired to the bloc |
| `checkbox({key, isChecked, options})` | `BlocxFormCheckbox` | Adaptive checkbox wired to the bloc |

#### Other helpers

| Method | Description |
|---|---|
| `submit()` | Dispatches `BlocxFormEventSubmit` |
| `changeListener(data, key)` | Dispatches `BlocxFormEventUpdateData` for custom widgets that don't use the built-in helpers |
| `setErrorToField(key, message)` | Sets a server-side validation error on a field |
| `setTimedErrorToField(key, message, {duration})` | Sets an auto-clearing error on a field |
| `clearFieldError(key, {message})` | Clears one or all errors on a field |
| `getTextEditingController(key)` | Returns (or lazily creates) the managed `TextEditingController` for a key |
| `getFocusNode(key)` | Returns (or lazily creates) the managed `FocusNode` for a key |

---

### `BlocXFormTextField`

A `TextFormField` pre-wired to a `BlocxFormBloc` field. On every keystroke it dispatches `BlocxFormEventUpdateData`. It reads bloc state directly to display validation errors and shows a spinning `CircularProgressIndicator` in the suffix while a unique-field check is running.

Prefer `BlocxFormWidgetState.textField()` — it manages the controller for you. Construct directly only when you need to embed the field outside a `BlocxFormWidgetState`.

**`BlocXTextFieldOptions`** key fields:

| Field | Default | Description |
|---|---|---|
| `labelText` | `null` | Floating label |
| `hintText` | `null` | Placeholder |
| `obscureText` | `false` | Password masking |
| `keyboardType` | `null` | Keyboard hint |
| `textInputAction` | `null` | Keyboard action button |
| `maxLength` | `null` | Character counter |
| `enabled` | `true` | Whether the field is interactive |
| `showClearButton` | `true` | Show ✕ when the field has text |
| `filled` | `true` | Filled background |
| `inputFormatters` | `[]` | Applied before value reaches the bloc |
| `textDirection` | auto-detected | Automatically switches to RTL for Arabic / Hebrew content |
| `suffix` | `null` | Custom suffix widget — overridden by the unique-field spinner |
| `contentPadding` | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` | Field padding |

**`TextFieldType`** (visual variant, passed to `textField()`):

| Value | Renders as |
|---|---|
| `filled` | Filled background *(default)* |
| `outlined` | Material outlined border |
| `underlined` | Underline only |

---

### `BlocXFormDropdown`

A `DropdownButtonFormField` pre-wired to a `BlocxFormBloc` field. Dispatches `BlocxFormEventUpdateData` on every selection change and reads bloc state to display validation errors.

Prefer `BlocxFormWidgetState.dropdown()` — it wires the bloc automatically:

```dart
dropdown<String>(
  ProfileField.country,
  items: countries.map((c) =>
    DropdownMenuItem(value: c.code, child: Text(c.name))
  ).toList(),
  options: BlocXDropdownOptions(labelText: 'Country'),
)
```

**`BlocXDropdownOptions`** key fields: `labelText`, `hintText`, `filled` (default `true`), `fillColor`, `isExpanded` (default `true`), `textStyle`, `selectedItemBuilder`, `errorText`.

---

### `BlocxFormCheckbox`

A platform-adaptive checkbox (`Checkbox.adaptive` / `CheckboxListTile.adaptive`) pre-wired to a `BlocxFormBloc` field. Dispatches `BlocxFormEventUpdateData` on every toggle.

When `label` or `subtitle` is set in `BlocxCheckboxOptions`, renders as a `CheckboxListTile` for a larger touch target. Otherwise renders a compact `Checkbox`.

Prefer `BlocxFormWidgetState.checkbox()`:

```dart
checkbox(
  key: SignUpField.terms,
  isChecked: state.formData.acceptedTerms,
  options: BlocxCheckboxOptions(
    isChecked: state.formData.acceptedTerms,
    label: 'I accept the Terms of Service',
  ),
)
```

---

### `BlocxFormButtonRow`

A horizontal row with a primary submit button on the left and a secondary cancel button on the right. The submit button is automatically disabled while the form is submitting or has validation errors.

```dart
BlocxFormButtonRow<SignUpForm, void, SignUpField>(
  formState: state,
  registerText: 'Create account',
  registerSubmittingText: 'Creating…',
  onRegisterPressed: submit,
  secondButtonText: 'Back',
  disablePopWhileSubmitting: true,
)
```

| Parameter | Default | Description |
|---|---|---|
| `registerText` | — | Submit button label when idle |
| `registerSubmittingText` | — | Submit button label while submitting |
| `registerType` | `filled` | Visual variant of the submit button |
| `secondButtonText` | `'Cancel'` | Cancel button label |
| `spacing` | `12.0` | Horizontal gap between buttons |
| `expandEqually` | `true` | Both buttons fill equal width |
| `disablePopWhileSubmitting` | `false` | Disable cancel during submission |
| `onSecondButtonPressed` | `null` | Override the cancel action. Defaults to `Navigator.maybePop()`. |

---

### `BlocxFormRegisterButton`

A standalone submit button with four built-in visual states: idle, submitting, checking unique fields, and has errors (disabled). Use it when you need a submit button without a paired cancel action.

```dart
BlocxFormRegisterButton<SignUpForm, void, SignUpField>(
  state: state,
  buttonText: 'Sign Up',
  submitText: 'Signing up…',
  onPressed: submit,
)
```

When `onPressed` is `null`, the button walks up the widget tree to find the nearest `BlocxFormWidgetState` and calls its `submit()` method.

**`RegisterButtonType`:**

| Value | Renders as |
|---|---|
| `filled` | `FilledButton` (Material 3) *(default)* |
| `elevated` | `ElevatedButton` |
| `outlined` | `OutlinedButton` |
| `text` | `TextButton` |
| `other` | Custom — override `buildOtherButton()` in a subclass |

Extend this class and override `buildOtherButton` to provide a fully custom design (glassmorphic, neumorphic, Cupertino) while retaining all built-in state management.

---

## Screen Management

### `BlocxScreenManagerState`

`BlocxScreenManagerState<T>` is the base `State` for any screen that is driven by a `ScreenManagerCubit`. Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend it, so all collection and form screens get these capabilities automatically.

`ScreenManagerCubit` is owned internally by `BaseBloc` — you never construct or pass one. The state accesses it via `bloc.screenManagerCubit` and wires it in `initState`.

**What it handles automatically:**

| Cubit state | Action |
|---|---|
| `ScreenManagerCubitStateDisplaySnackbar` | Calls `displaySnackBar` |
| `ScreenManagerCubitStateDisplaySnackbarByErrorCode` | Looks up message via `loc.errorCodeMessage`, then calls `displaySnackBar` |
| `ScreenManagerCubitStateDisplayErrorPage` | Replaces screen body with `errorWidget` |
| `ScreenManagerCubitStateDisplayErrorPageByErrorCode` | Replaces screen body with `errorWidgetByErrorCode` |
| `ScreenManagerCubitStatePop` | Calls `Navigator.maybePop()` |

**Override points:**

| Member | Description |
|---|---|
| `managerCubit` | **Required.** Return `bloc.screenManagerCubit`. Already implemented in collection and form states. |
| `mainWidget(context, state)` | **Required.** The primary screen content when no error-page state is active. |
| `wrapInScaffold` | When `true`, body is wrapped by `scaffoldWidget`. Default: `false`. |
| `scaffoldWidget(context, body)` | Must be overridden when `wrapInScaffold` is `true`. Throws `UnimplementedError` otherwise. |
| `decorateScaffold(scaffold)` | Wrap the scaffold with extra widgets (e.g. `PopScope`). Only called when `wrapInScaffold` is `true`. |
| `errorWidget(context, state)` | Full-page error UI for `ScreenManagerCubitStateDisplayErrorPage`. Default: `BlocxErrorWidget.fromState(state)`. |
| `errorWidgetByErrorCode(context, state)` | Full-page error UI for `ScreenManagerCubitStateDisplayErrorPageByErrorCode`. Default: converts the error code to a message via `loc.errorCodeMessage`, then renders `BlocxErrorWidget`. |
| `displaySnackBar(context, message, title, type)` | Override to customise snackbar presentation. Default: `BlocxSnackBar.show(...)`. |

---

### `BlocxErrorWidget`

A ready-made full-page error card. Displays a title, message, short error summary, optional collapsible stack trace panel, and action buttons.

```dart
// Convenience factory from cubit state:
BlocxErrorWidget.fromState(state, onRetry: () { /* ... */ })

// Direct construction:
BlocxErrorWidget(
  error: ReadableError(title: 'Not Found', message: 'Resource could not be loaded.'),
  onRetry: () { /* ... */ },
  onReport: () { /* ... */ },
  expandDetails: false,
)
```

The "copy details" button (labelled `loc.copyDetails`) and the "close" button (labelled `loc.close`) are always shown. The "retry" and "report" buttons are shown only when the corresponding callbacks are non-null.

---

## Shared Utilities

### `ConfirmActionWidget`

A pre-built confirmation bottom sheet used internally by `BlocxCollectionItem` before deletion, and available for direct use anywhere:

```dart
final confirmed = await ConfirmActionWidget.show(
  context,
  options: ConfirmActionOptions(
    title: 'Delete account',
    question: 'This action is permanent and cannot be undone.',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    imageUrl: user.avatarUrl,  // optional — shown instead of icon
    requireTyping: true,       // force user to type deleteWord
    deleteWord: 'DELETE',
  ),
);
if (confirmed == true) { /* proceed */ }
```

**`ConfirmActionOptions`** fields:

| Field | Default | Description |
|---|---|---|
| `title` | `'Delete item'` | Sheet title |
| `question` | `'This action cannot be undone. Are you sure?'` | Body text |
| `confirmText` | `'Delete'` | Confirm button label |
| `cancelText` | `'Cancel'` | Cancel button label |
| `icon` | `Icons.delete_outline` | Fallback icon when no `imageUrl` |
| `imageUrl` | `null` | Network image (replaces icon) |
| `requireTyping` | `false` | Show a text field the user must match |
| `deleteWord` | `'DELETE'` | Word required when `requireTyping` is `true` |

---

### `BlocxStatelessWidget` & `BlocXWidgetState`

Lightweight base classes that expose common Flutter helpers as named getters, reducing verbosity across widget code.

**`BlocxStatelessWidget`** (for `StatelessWidget`) provides: `theme(context)`, `textTheme(context)`, `colorScheme(context)`.

**`BlocXWidgetState<W>`** (for `State`) provides: `theme`, `textTheme`, `colorScheme`, `width`, `height` (via `MediaQuery.sizeOf`).

Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend `BlocXWidgetState`, so these getters are available in every screen state class without any extra setup.

---

## Localization

`BlocXLocalizations` is the abstract class providing all strings used internally. Subclass it and register your implementation once at startup (see [Setup](#setup)).

**Required members:**

| Member | Used by |
|---|---|
| `String get close` | "Close" button on `BlocxErrorWidget` |
| `String get copyDetails` | "Copy details" button on `BlocxErrorWidget` |
| `String dateRangeError(DateTime min, DateTime max)` | Date-range field validator error message |
| `String errorCodeMessage(BlocXErrorCode code)` | All error-code → message conversions throughout the framework |

**Error codes to handle in `errorCodeMessage`:**

| Code | When it appears |
|---|---|
| `BlocXErrorCode.checkingUniqueValue` | While an async uniqueness check is in progress |
| `BlocXErrorCode.valueNotAvailable` | When a uniqueness check fails |
| `BlocXErrorCode.errorGettingInitialFormData` | When `BlocxFormInfoFetcherMixin` fails to load required data |
| `BlocXErrorCode.fieldCannotBeEmpty` | When a required field is submitted empty |
| `BlocXErrorCode.unknown` | Fallback for unclassified errors |

Other strings accessed internally via `loc.*`: `loadingText`, `emptyListText`, `somethingWentWrong`, `tryAgain`, `report`, `details`, `errorDetailsCopied`.

---

## Quickstart: Collection Screen

The following example wires up a complete user list with infinite scroll, search, selection, highlight, and deletion.

### 1. Entity (from `blocx_core`)

```dart
import 'package:blocx_core/blocx_core.dart';

class User extends BlocxBaseEntity {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;

  const User({required this.id, required this.displayName, required this.email, this.avatarUrl});

  @override
  String get identifier => id;
}
```

### 2. Use cases (from `blocx_core`)

```dart
import 'package:blocx_core/list_bloc.dart';

class FetchUsersUseCase extends BlocxPaginatedUseCase<BlocxPaginationInput, User> {
  final UserRepository _repo;
  FetchUsersUseCase(this._repo);

  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(BlocxPaginationInput input) async {
    final users = await _repo.fetchPage(limit: input.limit, offset: input.offset);
    return successResult(items: users, input: input);
  }
}

class SearchUsersUseCase extends BlocxSearchUseCase<BlocxSearchInput, User> {
  final UserRepository _repo;
  SearchUsersUseCase(this._repo);

  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(BlocxSearchInput input) async {
    final users = await _repo.search(query: input.searchText, limit: input.limit, offset: input.offset);
    return successResult(items: users, input: input);
  }
}

class DeleteUserUseCase extends BlocxBaseUseCase<String, bool> {
  final UserRepository _repo;
  DeleteUserUseCase(this._repo);

  @override
  Future<BlocxUseCaseResult<bool>> perform(String id) async {
    await _repo.delete(id);
    return success(true);
  }
}
```

### 3. Bloc (from `blocx_core`)

```dart
import 'package:blocx_core/list_bloc.dart';

class UsersBloc extends BlocxCollectionBloc<User, void>
    with
        BlocxCollectionInfiniteMixin<User, void>,
        BlocxCollectionSearchableMixin<User, void>,
        BlocxCollectionSelectableMixin<User, void>,
        BlocxCollectionHighlightableMixin<User, void>,
        BlocxCollectionDeletableMixin<User, void> {

  final UserRepository _repo;

  UsersBloc(this._repo) : super();
  // Mixins are auto-initialised in BlocxCollectionBloc's constructor —
  // no manual init*() calls needed.

  @override
  BlocxPaginatedUseCaseTask get paginationTask => BlocxPaginatedUseCaseTask(
    useCase: FetchUsersUseCase(_repo),
    inputBuilder: (offset, limit) => BlocxPaginationInput(limit: limit, offset: offset),
  );

  @override
  BlocxPaginatedUseCaseTask get searchTask => BlocxPaginatedUseCaseTask(
    useCase: SearchUsersUseCase(_repo),
    inputBuilder: (offset, limit) => BlocxSearchInput(
      searchText: currentSearchText,
      limit: limit,
      offset: offset,
    ),
  );

  @override
  BlocxBaseUseCase<String, bool>? get deleteItemUseCase => DeleteUserUseCase(_repo);

  @override
  bool get isSingleSelect => false;
}
```

### 4. Screen

```dart
import 'package:flutter_blocx/list_widget.dart';

class UsersScreen extends BlocxCollectionWidget<void> {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState
    extends BlocxCollectionWidgetState<UsersScreen, User, void> {
  final _searchController = TextEditingController();

  @override
  BlocxCollectionBloc<User, void> get generateBloc => UsersBloc(UserRepository());

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<User> state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: BlocxSearchField<User, void>(
        controller: _searchController,
        options: const BlocxSearchFieldOptions(hintText: 'Search users…'),
      ),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, User item) => UserCard(item: item);

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: body,
    );
  }

  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.animatedList,
    options: AnimatedInfiniteListOptions(),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

### 5. Item widget

```dart
class UserCard extends BlocxCollectionItem<User, void> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User item) {
    return ListTile(
      leading: CircleAvatar(child: Text(item.displayName[0])),
      title: Text(item.displayName),
      subtitle: Text(item.email),
      tileColor: isSelected(context) ? Colors.blue.shade50 : null,
      onTap: () => toggleSelection(context),
      onLongPress: () => removeItem(context),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
    title: 'Remove ${item.displayName}',
    question: 'Are you sure?',
    imageUrl: item.avatarUrl,
  );
}
```

---

## Quickstart: Form Screen

### 1. Field enum, form entity & validator (from `blocx_core`)

```dart
import 'package:blocx_core/form_bloc.dart';

enum SignUpField { email, password, confirmPassword }

class SignUpForm extends BlocxBaseFormEntity<SignUpForm, SignUpField> {
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpForm({this.email = '', this.password = '', this.confirmPassword = ''});

  @override
  SignUpForm updateByKey(SignUpField key, dynamic value) => switch (key) {
    SignUpField.email           => copyWith(email: value),
    SignUpField.password        => copyWith(password: value),
    SignUpField.confirmPassword => copyWith(confirmPassword: value),
  };

  @override
  dynamic getValueByKey(SignUpField key) => switch (key) {
    SignUpField.email           => email,
    SignUpField.password        => password,
    SignUpField.confirmPassword => confirmPassword,
  };

  SignUpForm copyWith({String? email, String? password, String? confirmPassword}) =>
      SignUpForm(
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
      );

  @override
  String get identifier => 'sign_up_form';
}

class SignUpValidator extends BlocxFormValidator<SignUpForm, SignUpField> {
  @override
  List<SignUpField> formKeys() => SignUpField.values;

  @override
  List<BlocxFieldValidator> getValidatorsByKey(SignUpForm formData, SignUpField key) =>
      switch (key) {
        SignUpField.email => [
          BlocxStringRequiredValidator(),
          BlocxStringEmailValidator(),
        ],
        SignUpField.password => [
          BlocxStringRequiredValidator(),
          BlocxStringMinLengthValidator(minLength: 8),
        ],
        SignUpField.confirmPassword => [
          BlocxStringRequiredValidator(),
          BlocxStringMatchValidator(otherValue: () => formData.password),
        ],
      };
}
```

### 2. FormBloc (from `blocx_core`)

```dart
import 'package:blocx_core/form_bloc.dart';

class SignUpBloc extends BlocxFormBloc<SignUpForm, void, SignUpField>
    with BlocxFormValidationMixin<SignUpForm, void, SignUpField> {

  SignUpBloc() : super(const SignUpForm());

  @override
  BlocxFormValidator<SignUpForm, SignUpField> get validator => SignUpValidator();

  @override
  List<SignUpField> get formKeysList => SignUpField.values;

  @override
  BlocxUseCaseTask get submitUseCaseTask => BlocxUseCaseTask(
    useCase: CreateAccountUseCase(),
    inputBuilder: () => CreateAccountInput(
      email: formData.email,
      password: formData.password,
    ),
  );
}
```

### 3. Form screen

```dart
import 'package:flutter_blocx/form_widget.dart';

class SignUpScreen extends BlocxFormWidget<void> {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState
    extends BlocxFormWidgetState<SignUpScreen, SignUpForm, void, SignUpField> {

  @override
  BlocxFormBloc<SignUpForm, void, SignUpField> generateBloc() => SignUpBloc();

  @override
  List<SignUpField> get keys => SignUpField.values;

  @override
  Widget formWidget(BuildContext context, BlocxFormState<SignUpForm, SignUpField> state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          textField(
            SignUpField.email,
            options: BlocXTextFieldOptions(
              labelText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          SizedBox(height: formVerticalSpacing),
          textField(
            SignUpField.password,
            options: BlocXTextFieldOptions(labelText: 'Password', obscureText: true),
          ),
          SizedBox(height: formVerticalSpacing),
          textField(
            SignUpField.confirmPassword,
            options: BlocXTextFieldOptions(labelText: 'Confirm password', obscureText: true),
          ),
          const SizedBox(height: 32),
          BlocxFormButtonRow<SignUpForm, void, SignUpField>(
            formState: state,
            registerText: 'Create account',
            registerSubmittingText: 'Creating…',
            onRegisterPressed: submit,
            secondButtonText: 'Back',
          ),
        ],
      ),
    );
  }

  @override
  void onFormSubmitted(BlocxFormStateFormSubmitted<SignUpForm, SignUpField> state) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

---

## Contributing

- Run `flutter format .` and ensure `flutter analyze` reports no issues before committing.
- All public APIs must include dartdoc comments.
- Add widget tests for any new collection or form widget. Run `flutter test` to verify the full suite passes.
- Keep pull requests focused — one feature or fix per PR.

---

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file at the repository root for details.