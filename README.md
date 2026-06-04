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

Most Flutter apps do not become hard to maintain because the UI is visually complex. They become hard to maintain because every data-driven screen quietly rebuilds the same infrastructure:

- load the first page
- show loading, empty, and error states
- listen for scroll-end pagination
- refresh safely
- search with debounce
- track selected, highlighted, expanded, and deleting items
- wire text controllers and focus nodes
- hydrate edit forms
- show validation errors
- block duplicate submits
- show async uniqueness checks
- route errors into snackbars or full-page states

`flutter_blocx` turns that repeated infrastructure into reusable Flutter screen primitives.

It is the presentation layer for [`blocx_core`](https://pub.dev/packages/blocx_core). `blocx_core` owns the application-state patterns: use cases, results, form blocs, collection blocs, pagination, validation, and screen side effects. `flutter_blocx` makes those patterns practical in Flutter by giving you ready-to-use widgets and state classes for lists, grids, forms, search fields, submit buttons, confirmation flows, and screen-level error handling.

Instead of writing scroll listeners, controller maps, loading flags, submit guards, and `BlocConsumer` wiring in every feature, you describe what the screen is:

```dart
BlocxCollectionWidgetState<UsersScreen, User, void>
BlocxFormWidgetState<EditUserScreen, UserForm, User, UserField>
```

Then you override the parts that are actually unique to your feature:

```dart
generateBloc
itemBuilder
formWidget
keys
settings
topWidget
onFormSubmitted
```

Use `flutter_blocx` when you want:

- consistent list and form architecture across your app
- less repetitive Flutter/BLoC glue code
- pagination, refresh, search, selection, and form submit behavior handled once
- clean separation between use cases, blocs, and widgets
- predictable screen side effects through `ScreenManagerCubit`
- reusable UI primitives that still let you override the final design

The package is built for apps with many repeated CRUD and workflow screens: admin panels, dashboards, finance apps, internal tools, back-office systems, and server-driven mobile apps.

The goal is simple: **write feature code, not infrastructure code.**

### What it provides

#### Collection screens

Build lists and grids backed by `BlocxCollectionBloc` with support for:

- infinite scrolling
- pull-to-refresh
- searching
- item selection
- item highlighting
- item expansion
- animated insert/remove operations
- sliver and grid layouts
- programmatic scrolling
- owned and externally provided scroll controllers

Instead of manually coordinating scroll controllers, pagination triggers, loading indicators, empty states, and item-state events, `BlocxCollectionWidgetState` gives you a consistent collection-screen host.

#### Form screens

Create forms powered by `BlocxFormBloc` with built-in:

- `TextEditingController` management
- `FocusNode` management
- validation error display
- async uniqueness checks
- submit state handling
- dropdowns and checkboxes
- initial data hydration
- form update tracking
- safe submit-time validation UX

`BlocxFormWidgetState` synchronizes Flutter form controls with your form entity and bloc state, eliminating repetitive form wiring code.

#### Screen management

All screen host states integrate with `ScreenManagerCubit`, providing a unified way to:

- show snackbars
- display full-screen errors
- handle retry flows
- trigger navigation pops
- surface error-code-based messages

This keeps UI side effects separate from business logic while remaining easy to consume from Flutter widgets.

#### Shared UX components

The package also includes reusable widgets for common application patterns:

- search fields
- confirmation dialogs
- error pages
- submit button states
- floating-action-button visibility management
- localization support

### Designed to work with blocx_core

`flutter_blocx` is not a replacement for `blocx_core`; it is its Flutter presentation layer.

Together they provide a complete architecture where:

- use cases handle business operations
- blocs manage application state
- mixins compose reusable behaviour
- widgets render and interact with that state

The result is a consistent, scalable approach for building CRUD applications, dashboards, admin panels, business tools, and any Flutter app that relies heavily on lists, forms, and server-driven data.

---

## Table of Contents

- [Installation](#installation)
- [Setup](#setup)
- [Lists & Collections](#lists--collections)
  - [BlocxCollectionWidget & BlocxCollectionWidgetState](#blocxcollectionwidget--blocxcollectionwidgetstate)
  - [Collection host handles](#collection-host-handles)
  - [Collection host actions](#collection-host-actions)
  - [Collection widgets that plug into the host](#collection-widgets-that-plug-into-the-host)
  - [BlocxCollectionItem](#blocxcollectionitem)
  - [BlocxStatefulCollectionItem & BlocxCollectionItemState](#blocxstatefulcollectionitem--blocxcollectionitemstate)
  - [BlocxSearchField](#blocxsearchfield)
  - [Prebuilt Scrolling Widgets](#prebuilt-scrolling-widgets)
  - [HideOnScrollFabMixin](#hideonscrollfabmixin)
- [Forms](#forms)
  - [BlocxFormWidget & BlocxFormWidgetState](#blocxformwidget--blocxformwidgetstate)
  - [Form host handles](#form-host-handles)
  - [Form host actions](#form-host-actions)
  - [Form widgets that plug into the host](#form-widgets-that-plug-into-the-host)
  - [BlocXFormTextField](#blocxformtextfield)
  - [BlocXFormDropdown](#blocxformdropdown)
  - [BlocxFormCheckbox](#blocxformcheckbox)
  - [BlocxFormRegisterButton](#blocxformregisterbutton)
  - [BlocxFormButtonRow](#blocxformbuttonrow)
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
  flutter_blocx: ^0.8.4
```

Or install via the command line:

```sh
flutter pub add flutter_blocx
```

Import the library:

```dart
// Everything: screen utilities, collection widgets, form widgets, shared widgets.
import 'package:flutter_blocx/flutter_blocx.dart';

// Collection / list widgets and state.
import 'package:flutter_blocx/list_widget.dart';

// Form widgets and state.
import 'package:flutter_blocx/form_widget.dart';

// Stateful collection item base, if needed separately.
import 'package:flutter_blocx/blocx_collection_item_state.dart';
```

---

## Setup

`flutter_blocx` uses `BlocXLocalizations` from `blocx_core` for framework copy such as loading text, empty-list text, validator messages, error labels, and button labels.

A default English localization is available, so the package works without setup. For production apps, localization, or custom wording, register your own implementation before `runApp`:

```dart
import 'package:blocx_core/blocx_core.dart';

void main() {
  BlocXLocalizations.localizations = AppLocalizations();
  runApp(const MyApp());
}

class AppLocalizations extends BlocXLocalizations {
  @override
  String get tryAgain => 'Try again';

  // ....

  @override
  String fileSizeMustBeSmallerThan(String format) {
    return 'File size must be smaller than $format';
  }
}
```

---

## Lists & Collections

The collection API is built around a host widget/state pair:

```dart
BlocxCollectionWidget<P>
BlocxCollectionWidgetState<W, T, P>
```

Use these two classes first. They create the screen-level structure that all collection widgets plug into.

`BlocxCollectionWidget<P>` is the outer `StatefulWidget`. It carries an optional `payload` into the screen. Use that payload for route arguments, filters, parent IDs, or any value needed to load the initial collection.

`BlocxCollectionWidgetState<W, T, P>` is the collection host. It owns the collection bloc, creates or attaches the scroll controller, dispatches the initial load event, renders loading/empty/list states, and connects screen side effects through `ScreenManagerCubit`.

After this host state exists, you can wire in collection widgets such as:

- `BlocxCollectionItem`
- `BlocxStatefulCollectionItem`
- `BlocxSearchField`
- `InfiniteList`
- `AnimatedInfiniteList`
- `InfiniteGrid`
- sliver list/grid variants

### Mental model

```txt
BlocxCollectionWidget
  owns route/payload

BlocxCollectionWidgetState
  owns bloc lifecycle
  owns scroll controller lifecycle
  renders loading / empty / collection states
  exposes helper methods

Collection widgets
  read the collection bloc from context
  dispatch item/search/selection/delete events
```

### `BlocxCollectionWidget` & `BlocxCollectionWidgetState`

These two classes are your entry point for any list or grid screen.

```dart
class UsersScreen extends BlocxCollectionWidget<void> {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState
    extends BlocxCollectionWidgetState<UsersScreen, User, void> {
  @override
  BlocxCollectionBloc<User, void> get generateBloc {
    return UsersBloc();
  }

  @override
  Widget itemBuilder(BuildContext context, User item) {
    return UserCard(item: item);
  }
}
```

#### How bloc initialisation works

You do **not** pass the bloc as a constructor parameter. Instead, override the `generateBloc` getter. The state calls it once in `initState`, stores the result privately, and disposes it automatically when the widget is removed from the tree when `autoDisposeBloc` is `true`.

Internally, `initState` also:

- creates the correct `ScrollController`
- uses an `AutoScrollController` when the bloc supports `BlocxCollectionScrollableMixin`
- uses a plain `ScrollController` otherwise
- attaches `_onScroll` only when needed
- dispatches `BlocxCollectionEventLoadInitialPage` with `widget.payload` when `loadOnInit` is `true`

If you override `scrollControllerProvider`, the state uses your external controller and does not dispose it.

#### What the state renders

The state wraps everything in a `BlocConsumer` tied to the bloc. On every rebuild it calls `collectionWrapperBuilder`, which stacks:

1. `topWidget`, if overridden
2. spacing
3. loading, empty, or the actual collection body
4. spacing
5. `bottomWidget`, if overridden

The core body is one of:

- `loadingWidget` while `isLoading || isSearching`
- `emptyWidget` when the list is empty after loading
- `collectionWidget` otherwise

The default wrapper is a `Column(crossAxisAlignment: CrossAxisAlignment.stretch)`. The core body is wrapped in `Expanded` unless `settings.options.shrinkWrap` is `true`.

### Collection host handles

Inside a `BlocxCollectionWidgetState`, you get these useful handles:

| Member | Type | Description |
|---|---|---|
| `generateBloc` | `BlocxCollectionBloc<T, P>` | Required. Instantiate and return your bloc here. |
| `bloc` | `BlocxCollectionBloc<T, P>` | Read-only access to the created bloc instance. |
| `payload` | `P?` | The widget payload passed into `BlocxCollectionWidget`. |
| `scrollController` | `ScrollController?` | The active scroll controller. |
| `scrollControllerProvider` | `ScrollController?` | Override to provide your own scroll controller. External controllers are not disposed by the state. |
| `isLoading` | `bool` | `true` when the current state is `BlocxCollectionStateLoading`. |
| `isSearching` | `bool` | `true` when search is active. |
| `settings` | `CollectionSettings` | Controls list/grid/sliver/animated rendering. |
| `loadOnInit` | `bool` | Whether to load the initial page automatically. Default: `true`. |
| `autoDisposeBloc` | `bool` | Whether to close the bloc in `dispose`. Default: `true`. |
| `topWidget(context, state)` | `Widget?` | Optional UI above the collection, such as search or filters. |
| `bottomWidget(context, state)` | `Widget?` | Optional UI below the collection. |
| `sliverTopWidget(context, state)` | `Widget?` | Optional sliver before sliver collections. |
| `sliverBottomWidget(context, state)` | `Widget?` | Optional sliver after sliver collections. |
| `topBottomAndListSpacing` | `double` | Gap between optional top/bottom widgets and the collection. |
| `searchingText` | `String` | Text shown while a search is running. |

### Collection host actions

`BlocxCollectionWidgetState` exposes helper methods so screens do not need to manually dispatch events:

| Method | Description |
|---|---|
| `refreshData()` | Dispatches `BlocxCollectionEventRefreshData`. |
| `loadNextPage()` | Dispatches `BlocxCollectionEventLoadNextPage`. |
| `search(text)` | Dispatches `BlocxCollectionEventSearch`. |
| `scrollToItem(item, highlightItem: true)` | Scrolls to an item when the bloc supports scrolling. |
| `addToList(item, index: 0)` | Dispatches `BlocxCollectionEventAddItem`. |
| `deleteMultipleItems(items)` | Dispatches `BlocxCollectionEventRemoveMultipleItems`. |
| `deselectMultipleItems(items)` | Dispatches `BlocxCollectionEventDeselectMultipleItems`. |

### Override points

| Method / getter | Description |
|---|---|
| `generateBloc` | Required. Return a new bloc instance. |
| `itemBuilder(context, item)` | Required. Render one collection item. |
| `settings` | Choose the widget type and options. Default: `animatedList` with `AnimatedInfiniteListOptions()`. |
| `topWidget(context, state)` | Widget above the collection. |
| `bottomWidget(context, state)` | Widget below the collection. |
| `sliverTopWidget(context, state)` | Sliver before sliver collections. |
| `sliverBottomWidget(context, state)` | Sliver after sliver collections. |
| `loadingWidget(context, state)` | Override loading UI. |
| `emptyWidget(context, state)` | Override empty UI. |
| `separatorBuilder(context, index)` | Build separators between items. |
| `loadMoreWidgetBuilder(context, isLoadingMore)` | Custom load-more indicator. |
| `refreshWidgetBuilder(context, height)` | Custom pull-to-refresh indicator. |
| `deleteAnimation` | Animation builder used when items are removed from an animated list. |
| `insertAnimation` | Animation builder used when items are inserted. |
| `blocListener(context, state)` | Hook into listen-only collection states. |
| `onSelectionChanged(context, data)` | Called when selection changes. |
| `wrapInScaffold` | Return `true` to use `scaffoldWidget`. |
| `scaffoldWidget(context, body)` | Build a scaffold when `wrapInScaffold` is true. |
| `decorateScaffold(scaffold)` | Wrap the scaffold, for example with `PopScope`. |

### Collection widgets that plug into the host

Once your screen extends `BlocxCollectionWidgetState`, the widgets below can be wired into it.

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
      selected: isSelected(context),
      onTap: () => toggleSelection(context),
      onLongPress: () => removeItem(context),
    );
  }
}
```

Reactive state flags:

| Flag | Description |
|---|---|
| `isSelected(context)` | Item id is in `state.selectedItemIds`. |
| `isHighlighted(context)` | Item id is in `state.highlightedItemIds`. |
| `isBeingRemoved(context)` | Item id is in `state.beingRemovedItemIds`. |
| `isBeingSelected(context)` | Item id is in `state.beingSelectedItemIds`. |
| `isExpanded(context)` | Item id is in `state.expandedItemIds`. |

Action helpers:

| Method | Required mixin |
|---|---|
| `selectItem(context)` | `BlocxCollectionSelectableMixin` |
| `deselectItem(context)` | `BlocxCollectionSelectableMixin` |
| `toggleSelection(context)` | `BlocxCollectionSelectableMixin` |
| `highlightItem(context)` | `BlocxCollectionHighlightableMixin` |
| `clearHighlightedItem(context)` | `BlocxCollectionHighlightableMixin` |
| `toggleExpansion(context)` | `BlocxCollectionExpandableMixin` |
| `removeItem(context)` | `BlocxCollectionDeletableMixin` |
| `updateItem(context, item)` | none |
| `insertItem(context, item, index: 0)` | none |
| `toggleAllItemsSelection(context)` | `BlocxCollectionSelectableMixin` |
| `toggleMultipleItemsSelection(context, items, areSelected)` | `BlocxCollectionSelectableMixin` |

Deletion confirmation is enabled by default. Calling `removeItem` shows `ConfirmActionWidget` as a modal bottom sheet before dispatching the delete event. Override `confirmDeleteOptions` to configure the sheet, or set `confirmBeforeDelete` to `false` to skip it.

```dart
@override
bool get confirmBeforeDelete => false;

@override
ConfirmActionOptions get confirmDeleteOptions {
  return ConfirmActionOptions(
    title: 'Remove ${item.displayName}',
    question: 'This cannot be undone.',
    imageUrl: item.avatarUrl,
  );
}
```

### `BlocxStatefulCollectionItem` & `BlocxCollectionItemState`

When a list item needs its own local state, such as an animation controller, a focus node, or local expansion state, use `BlocxStatefulCollectionItem<T>` paired with `BlocxCollectionItemState<W, T, P>`.

The key difference from the stateless version is that state flags and action helpers are getters and methods with no `BuildContext` argument. `context` is already available through `State`.

```dart
class ExpandableUserCard extends BlocxStatefulCollectionItem<User> {
  const ExpandableUserCard({super.key, required super.item});

  @override
  State<ExpandableUserCard> createState() => _ExpandableUserCardState();
}

class _ExpandableUserCardState
    extends BlocxCollectionItemState<ExpandableUserCard, User, void> {
  @override
  Widget buildContent(User item) {
    return ListTile(
      title: Text(item.displayName),
      selected: isSelected,
      onTap: toggleSelection,
      trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
    );
  }
}
```

### `BlocxSearchField`

`BlocxSearchField<T, P>` is a pre-wired search input that resolves the parent `BlocxCollectionBloc<T, P>` from the widget tree and connects to its `BlocxCollectionSearchableMixin`. It dispatches `BlocxCollectionEventSearch` on every keystroke and `BlocxCollectionEventClearSearch` when the field is cleared.

`BlocxSearchField` requires an explicit `TextEditingController`. You own its lifecycle.

```dart
class _UsersScreenState
    extends BlocxCollectionWidgetState<UsersScreen, User, void> {
  final _searchController = TextEditingController();

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<User> state) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: BlocxSearchField<User, void>(
        controller: _searchController,
        options: const BlocxSearchFieldOptions(
          hintText: 'Search users…',
        ),
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

`BlocxSearchFieldOptions` key fields:

| Field | Default | Description |
|---|---|---|
| `hintText` | `'Search...'` | Placeholder text. |
| `prefixIcon` | `Icon(Icons.search)` | Leading icon. |
| `showClearButton` | `true` | Show clear button when field has text. |
| `decoration` | computed | Full `InputDecoration` override. |
| `autofocus` | `false` | Request focus on first build. |
| `maxLines` | `1` | Maximum line count. |

### Prebuilt Scrolling Widgets

For cases where you do not need the full `BlocxCollectionWidgetState` abstraction, `flutter_blocx` provides standalone scrollable widgets you can embed anywhere. Each requires an `itemBuilder`, the matching options class, a `BlocxInfiniteListBloc` reference, and a `ScrollController`.

List variants:

- `InfiniteList<T>`
- `SliverInfiniteList<T>`
- `AnimatedInfiniteList<T>`
- `AnimatedSliverInfiniteList<T>`

Grid variants:

- `InfiniteGrid<T>`
- `SliverInfiniteGrid<T>`

```dart
InfiniteList<Product>(
  items: state.list,
  itemBuilder: (context, item) => ProductCard(item: item),
  bloc: productsBloc.infiniteListBloc,
  scrollController: scrollController,
  loadBottomData: loadNextPage,
  refreshOnSwipe: refreshData,
  options: InfiniteListOptions(
    padding: const EdgeInsets.all(8),
  ),
)
```

### Choosing the collection layout

Override `settings`:

```dart
@override
CollectionSettings get settings {
  return CollectionSettings(
    type: CollectionWidgetStateType.animatedList,
    options: AnimatedInfiniteListOptions(),
  );
}
```

| `CollectionWidgetStateType` | Required options class | Renders as |
|---|---|---|
| `animatedList` | `AnimatedInfiniteListOptions` | Animated `ListView`. |
| `list` | `InfiniteListOptions` | Standard infinite `ListView`. |
| `sliverList` | `SliverInfiniteListOptions` | Sliver list. |
| `animatedSliverList` | `AnimatedSliverInfiniteListOptions` | Animated sliver list. |
| `grid` | `InfiniteGridOptions` | Infinite `GridView`. |
| `sliverGrid` | `SliverInfiniteGridOptions` | Sliver grid. |

The options class must match the type. A mismatch throws an `ArgumentError` at runtime.

Common option fields:

| Field | Default | Description |
|---|---|---|
| `shrinkWrap` | `false` | Shrink-wrap the scroll view. |
| `reverse` | `false` | Reverse scroll direction. |
| `scrollDirection` | `Axis.vertical` | Scroll axis. |
| `scrollPhysics` | `null` | Custom scroll physics. |
| `scrollBehavior` | `null` | Custom scroll behaviour. |
| `loadMoreTriggerItemDistance` | `2` | Items from the end that trigger next-page loading. |

### `HideOnScrollFabMixin`

Mix `HideOnScrollFabMixin<T>` into any `State` to automatically show and hide a `FloatingActionButton` based on scroll direction. Feed scroll events from a `NotificationListener<UserScrollNotification>` and use `getFloatingActionButton(context)` to get the animated FAB.

```dart
class _MyScreenState extends BlocxCollectionWidgetState<MyScreen, Product, void>
    with HideOnScrollFabMixin<Product> {
  @override
  void onFabPressed(Product? data) {
    // Handle tap.
  }

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

The form API is built around a host widget/state pair:

```dart
BlocxFormWidget<P>
BlocxFormWidgetState<W, F, P, E>
```

Use these two classes first. They create the screen-level structure that all form widgets plug into.

`BlocxFormWidget<P>` is the outer `StatefulWidget`. It carries an optional `payload` into the form. Use that payload for edit/update forms.

`BlocxFormWidgetState<W, F, P, E>` is the form host. It owns the form bloc, manages text controllers and focus nodes, hydrates initial data, dispatches submit and update events, listens for form-side effects, and connects screen side effects through `ScreenManagerCubit`.

After this host state exists, you can wire in form widgets such as:

- `BlocXFormTextField`
- `BlocXFormDropdown`
- `BlocxFormCheckbox`
- `BlocxFormRegisterButton`
- `BlocxFormButtonRow`

### Mental model

```txt
BlocxFormWidget
  owns route/payload

BlocxFormWidgetState
  owns bloc lifecycle
  owns TextEditingController lifecycle
  owns FocusNode lifecycle
  hydrates edit data
  exposes helper methods

Form widgets
  read the form bloc from context
  dispatch field update / submit events
```

### `BlocxFormWidget` & `BlocxFormWidgetState`

These two classes are your entry point for any form screen.

```dart
class SignUpScreen extends BlocxFormWidget<void> {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState
    extends BlocxFormWidgetState<SignUpScreen, SignUpForm, void, SignUpField> {
  @override
  BlocxFormBloc<SignUpForm, void, SignUpField> generateBloc() {
    return SignUpBloc();
  }

  @override
  List<SignUpField> get keys {
    return SignUpField.values;
  }

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<SignUpForm, SignUpField> state,
  ) {
    return Column(
      children: [
        textField(SignUpField.email),
        textField(SignUpField.password),
        BlocxFormRegisterButton<SignUpForm, void, SignUpField>(
          state: state,
          buttonText: 'Create account',
          submitText: 'Creating…',
          onPressed: submit,
        ),
      ],
    );
  }
}
```

#### How bloc initialisation works

Override `generateBloc()`; it is called once in `initState`. The state then dispatches `BlocxFormEventInit(payload: widget.payload)` automatically.

If the bloc uses `BlocxFormInfoFetcherMixin`, the form bloc can fetch required remote data after initialization.

The state manages all `TextEditingController`s and `FocusNode`s through internal maps. They are created on demand and disposed automatically in `dispose`. Do not manually create controllers for fields built with `textField()` unless you are bypassing the host helpers intentionally.

#### What the state listens for

The form host handles these listen-only states automatically:

| State | Behaviour |
|---|---|
| `BlocxFormStateApplyInitialDataToForm` | Hydrates text controllers from form data. |
| `BlocxFormStateFormSubmitted` | Calls `onFormSubmitted(state)`. |
| `BlocxFormStateFormUpdated` | Calls `onFormUpdated(formData)`. |

### Form host handles

Inside a `BlocxFormWidgetState`, you get these useful handles:

| Member | Type | Description |
|---|---|---|
| `bloc` | `BlocxFormBloc<F, P, E>` | The form bloc created by `generateBloc()`. |
| `state` | `BlocxFormState<F, E>` | Current typed form state snapshot. |
| `payload` | `P?` | The widget payload. |
| `isUpdate` | `bool` | `true` when `widget.payload != null`. |
| `isValid` | `bool` | Whether the current form state has no validation/fetching/unique-check blockers. |
| `formVerticalSpacing` | `double` | Vertical gap between fields. Default: `16`. |
| `autoCloseBloc` | `bool` | Whether the bloc closes on dispose. Default: `true`. |
| `autovalidateMode` | `AutovalidateMode` | Default native Flutter autovalidation mode. |
| `keys` | `List<E>` | Field keys used for text-controller hydration. |

### Form host actions

| Method | Description |
|---|---|
| `textField(key, options: ..., type: ...)` | Builds a bloc-wired text field with a managed controller. |
| `dropdown<T>(key, items: ..., options: ...)` | Builds a bloc-wired dropdown. |
| `checkbox(key: ..., isChecked: ..., options: ...)` | Builds a bloc-wired checkbox. |
| `getTextEditingController(key)` | Returns the managed controller for a field. |
| `getFocusNode(key)` | Returns the managed focus node for a field. |
| `submit()` | Dispatches `BlocxFormEventSubmit`. |
| `changeListener(data, key)` | Dispatches a field update for custom widgets. |
| `setErrorToField(key, message)` | Adds a persistent field error. |
| `setTimedErrorToField(key, message, duration: ...)` | Adds an auto-clearing field error. |
| `clearFieldError(key, message: ...)` | Clears one or all errors for a field. |
| `applyInitialDataToForm(formData)` | Hydrates controllers from form data. |
| `onFormSubmitted(state)` | Override to navigate or react after success. |
| `onFormUpdated(formData)` | Override to react to field updates. |
| `blocListener(context, state)` | Override for extra listen-only states. Call `super`. |

### Form widgets that plug into the host

Once your screen extends `BlocxFormWidgetState`, the widgets below can be wired into it.

### `BlocXFormTextField`

A `TextFormField` pre-wired to a `BlocxFormBloc` field. On every keystroke it dispatches `BlocxFormEventUpdateData`. It reads bloc state directly to display validation errors and shows a spinning `CircularProgressIndicator` in the suffix while a unique-field check is running.

Prefer the host helper:

```dart
textField(
  SignUpField.email,
  type: TextFieldType.outlined,
  options: const BlocXTextFieldOptions(
    labelText: 'Email address',
    keyboardType: TextInputType.emailAddress,
  ),
)
```

Use `getTextEditingController(key)` when you need direct access to the managed controller:

```dart
final emailController = getTextEditingController(SignUpField.email);
```

`BlocXFormTextField` supports three visual variants through `TextFieldType`:

| Value | Renders as |
|---|---|
| `filled` | Filled background with rounded border. |
| `outlined` | Material outlined border. |
| `underlined` | Underline-only field. |

`BlocXTextFieldOptions` key fields:

| Field | Default | Description |
|---|---|---|
| `decoration` | `null` | Optional base `InputDecoration`. Bloc-driven errors and suffix loading indicators are still merged into it. |
| `labelText` | `null` | Floating label. |
| `hintText` | `null` | Placeholder. |
| `obscureText` | `false` | Password masking. |
| `keyboardType` | `null` | Keyboard hint. |
| `textInputAction` | `null` | Keyboard action button. |
| `maxLength` | `null` | Character counter. |
| `enabled` | `true` | Whether the field is interactive. |
| `showClearButton` | `true` | Show clear button when the field has text. Hidden for obscure text fields. |
| `filled` | `true` | Whether the `filled` variant uses a filled background. |
| `fillColor` | `null` | Fill colour for the field background. |
| `borderRadius` | `BorderRadius.circular(12)` | Border radius for default filled and outlined decorations. |
| `inputFormatters` | `[]` | Applied before value reaches the bloc. |
| `textDirection` | auto-detected | Automatically switches between RTL and LTR while typing. |
| `suffix` | `null` | Custom suffix widget. Overridden by the unique-field spinner. |
| `contentPadding` | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` | Field padding. |

### `BlocXFormDropdown`

A `DropdownButtonFormField` pre-wired to a `BlocxFormBloc` field. It dispatches `BlocxFormEventUpdateData` on every selection change and reads bloc state to display validation errors.

Prefer `BlocxFormWidgetState.dropdown()`:

```dart
dropdown<String>(
  ProfileField.country,
  items: countries.map((country) {
    return DropdownMenuItem(
      value: country.code,
      child: Text(country.name),
    );
  }).toList(),
  options: const BlocXDropdownOptions(
    labelText: 'Country',
  ),
)
```

`BlocXDropdownOptions` key fields:

| Field | Default | Description |
|---|---|---|
| `labelText` | `null` | Floating label. |
| `hintText` | `null` | Placeholder. |
| `filled` | `true` | Use filled decoration. |
| `fillColor` | `null` | Fill colour. |
| `isExpanded` | `true` | Expand dropdown to available width. |
| `textStyle` | `null` | Text style. |
| `selectedItemBuilder` | `null` | Custom selected item builder. |
| `errorText` | `null` | Static error fallback. |

### `BlocxFormCheckbox`

A platform-adaptive checkbox pre-wired to a `BlocxFormBloc` field. It dispatches `BlocxFormEventUpdateData` on every toggle.

When `label` or `subtitle` is set in `BlocxCheckboxOptions`, it renders as a `CheckboxListTile` for a larger touch target. Otherwise, it renders as a compact checkbox.

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

### `BlocxFormRegisterButton`

A standalone submit button that reacts to `BlocxFormState`.

It automatically handles:

- idle state
- submitting state
- async unique-field checks
- required field info loading

```dart
BlocxFormRegisterButton<SignUpForm, void, SignUpField>(
  state: state,
  buttonText: 'Sign Up',
  submitText: 'Signing up…',
  onPressed: submit,
)
```

When `onPressed` is `null`, the button walks up the widget tree to find the nearest matching `BlocxFormWidgetState` and calls its `submit()` method. If no matching ancestor exists, it throws a clear `FlutterError`.

Validation errors do **not** disable the button by default. This is intentional for submit-time validation flows. Invalid submission is blocked inside `BlocxFormBloc`, not by permanently disabling the button.

Set `disableWhenInvalid: true` only when you explicitly want validation errors to disable the button.

| Parameter | Default | Description |
|---|---|---|
| `state` | — | Typed `BlocxFormState<F, E>`. |
| `buttonText` | — | Label while idle. |
| `submitText` | — | Label while submitting. |
| `type` | `filled` | Button visual style. |
| `onPressed` | `null` | Submit callback. Falls back to nearest form state. |
| `disableWhenInvalid` | `false` | Disable button when validation errors exist. |
| `spacing` | `8.0` | Space between loading indicator and label. |
| `loadingIndicatorBuilder` | `null` | Custom loading indicator. |
| `style` | `null` | Unified button style override. |
| `labelTextStyle` | `null` | Text style for button label. |

`RegisterButtonType`:

| Value | Renders as |
|---|---|
| `filled` | `FilledButton`. |
| `elevated` | `ElevatedButton`. |
| `outlined` | `OutlinedButton`. |
| `text` | `TextButton`. |
| `other` | Custom — override `buildOtherButton()` in a subclass. |

### `BlocxFormButtonRow`

A horizontal row with a primary submit button on the left and a secondary button on the right. The submit button is a `BlocxFormRegisterButton`; the secondary button defaults to `Navigator.maybePop()`.

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

By default, validation errors do **not** disable the submit button. This prevents `FormValidationMode.onSubmit` forms from getting stuck after the first failed submit. The form bloc remains the final authority: it validates on submit and blocks the use case when the form is invalid.

Set `disableRegisterWhenInvalid: true` only when your validation mode clears errors while editing, such as `FormValidationMode.onUserInteraction` or `FormValidationMode.always`.

| Parameter | Default | Description |
|---|---|---|
| `formState` | — | Typed `BlocxFormState<F, E>` passed to the register button. |
| `registerText` | — | Submit button label when idle. |
| `registerSubmittingText` | — | Submit button label while submitting. |
| `registerType` | `filled` | Visual variant of the submit button. |
| `secondButtonText` | `'Cancel'` | Secondary button label. |
| `spacing` | `12.0` | Horizontal gap between buttons. |
| `height` | `40.0` | Row height. |
| `expandEqually` | `true` | Both buttons fill equal width. |
| `disablePopWhileSubmitting` | `false` | Disable secondary button during submission. |
| `disableRegisterWhenInvalid` | `false` | Disable submit button when validation errors exist. |
| `onRegisterPressed` | `null` | Override submit action. |
| `onSecondButtonPressed` | `null` | Override secondary action. Defaults to `Navigator.maybePop()`. |

---

## Screen Management

### `BlocxScreenManagerState`

`BlocxScreenManagerState<T>` is the base `State` for any screen that is driven by a `ScreenManagerCubit`. Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend it, so all collection and form screens get these capabilities automatically.

`ScreenManagerCubit` is owned internally by `BaseBloc`; you never construct or pass one manually. The state accesses it via `bloc.screenManagerCubit`.

What it handles automatically:

| Cubit state | Action |
|---|---|
| `ScreenManagerCubitStateDisplaySnackbar` | Calls `displaySnackBar`. |
| `ScreenManagerCubitStateDisplaySnackbarByErrorCode` | Looks up message via `loc.errorCodeMessage`, then calls `displaySnackBar`. |
| `ScreenManagerCubitStateDisplayErrorPage` | Replaces screen body with `errorWidget`. |
| `ScreenManagerCubitStateDisplayErrorPageByErrorCode` | Replaces screen body with `errorWidgetByErrorCode`. |
| `ScreenManagerCubitStatePop` | Calls `Navigator.maybePop()`. |

Override points:

| Member | Description |
|---|---|
| `managerCubit` | Required. Return `bloc.screenManagerCubit`. Already implemented in collection and form states. |
| `mainWidget(context, state)` | Required. Primary screen content when no error-page state is active. |
| `wrapInScaffold` | When `true`, body is wrapped by `scaffoldWidget`. Default: `false`. |
| `scaffoldWidget(context, body)` | Must be overridden when `wrapInScaffold` is `true`. |
| `decorateScaffold(scaffold)` | Wrap the scaffold with extra widgets, such as `PopScope`. |
| `errorWidget(context, state)` | Full-page error UI for `ScreenManagerCubitStateDisplayErrorPage`. |
| `errorWidgetByErrorCode(context, state)` | Full-page error UI for `ScreenManagerCubitStateDisplayErrorPageByErrorCode`. |
| `displaySnackBar(context, message, title, type)` | Override to customise snackbar presentation. |

### `BlocxErrorWidget`

A ready-made full-page error card. Displays a title, message, short error summary, optional collapsible stack trace panel, and action buttons.

```dart
BlocxErrorWidget.fromState(
  state,
  onRetry: () {
    // Retry action.
  },
)

BlocxErrorWidget(
  error: ReadableError(
    title: 'Not Found',
    message: 'Resource could not be loaded.',
  ),
  onRetry: () {},
  onReport: () {},
  expandDetails: false,
)
```

The copy-details button uses `loc.copyDetails`. The close button uses `loc.close`. Retry and report buttons are shown only when the corresponding callbacks are non-null.

---

## Shared Utilities

### `ConfirmActionWidget`

A pre-built confirmation bottom sheet used internally by `BlocxCollectionItem` before deletion, and available for direct use anywhere.

```dart
final confirmed = await ConfirmActionWidget.show(
  context,
  options: ConfirmActionOptions(
    title: 'Delete account',
    question: 'This action is permanent and cannot be undone.',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    imageUrl: user.avatarUrl,
    requireTyping: true,
    deleteWord: 'DELETE',
  ),
);

if (confirmed == true) {
  // Proceed.
}
```

`ConfirmActionOptions` fields:

| Field | Default | Description |
|---|---|---|
| `title` | `'Delete item'` | Sheet title. |
| `question` | `'This action cannot be undone. Are you sure?'` | Body text. |
| `confirmText` | `'Delete'` | Confirm button label. |
| `cancelText` | `'Cancel'` | Cancel button label. |
| `icon` | `Icons.delete_outline` | Fallback icon when no `imageUrl`. |
| `imageUrl` | `null` | Network image replacing the icon. |
| `requireTyping` | `false` | Show a text field the user must match. |
| `deleteWord` | `'DELETE'` | Word required when `requireTyping` is `true`. |

### `BlocxStatelessWidget` & `BlocXWidgetState`

Lightweight base classes that expose common Flutter helpers as named getters.

`BlocxStatelessWidget` provides:

- `theme(context)`
- `textTheme(context)`
- `colorScheme(context)`

`BlocXWidgetState<W>` provides:

- `theme`
- `textTheme`
- `colorScheme`
- `width`
- `height`

Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend `BlocXWidgetState`, so these getters are available in every screen state class.

---

## Localization

`BlocXLocalizations` provides every framework string used by `blocx_core` and `flutter_blocx`. A default English implementation is available automatically, so setup is optional. Register a custom implementation when you need localization or app-specific copy.

Commonly visible strings include:

| Member | Used by |
|---|---|
| `loadingText` | Default collection loading UI |
| `emptyListText` | Default collection empty UI |
| `tryAgain` | Error and retry UI |
| `report` | Error reporting action |
| `close` | Close action on error widgets |
| `copyDetails` | Copy-details action on error widgets |
| `errorDetailsCopied` | Snackbar after copying details |
| `somethingWentWrong` | Generic error fallback |

Validator and form-related strings include:

| Member | Used by |
|---|---|
| `thisFieldIsRequired` | Required field validators |
| `invalidEmail` | Email validator |
| `onlyNumbersAllowed` | Numeric string validator |
| `onlyAlphanumericAllowed` | Alphanumeric validator |
| `invalidUrl` | URL validator |
| `valuesDoNotMatch` | Match validator |
| `invalidPhoneNumber` | Phone validators |
| `selectedItemsMustBeUnique` | List uniqueness validator |
| `minLengthError(...)` | String minimum length validator |
| `maxLengthError(...)` | String maximum length validator |
| `lengthRangeError(...)` | String length range validator |
| `minValueError(...)` | Numeric minimum validator |
| `maxValueError(...)` | Numeric maximum validator |
| `numberRangeError(...)` | Numeric range validator |
| `minDateError(...)` | Date minimum validator |
| `maxDateError(...)` | Date maximum validator |
| `dateRangeError(...)` | Date range validator |
| `fileSizeMustBeSmallerThan(...)` | File size validator |

Error codes to handle in `errorCodeMessage`:

| Code | When it appears |
|---|---|
| `BlocXErrorCode.checkingUniqueValue` | While an async uniqueness check is in progress. |
| `BlocXErrorCode.valueNotAvailable` | When a uniqueness check fails. |
| `BlocXErrorCode.errorGettingInitialFormData` | When `BlocxFormInfoFetcherMixin` fails to load required data. |
| `BlocXErrorCode.fieldCannotBeEmpty` | When a required field is submitted empty. |
| `BlocXErrorCode.unknown` | Fallback for unclassified errors. |

---

## Quickstart: Collection Screen

The following example wires up a complete user list with infinite scroll, refresh, search, selection, highlight, and deletion.

### 1. Entity from `blocx_core`

```dart
import 'package:blocx_core/blocx_core.dart';

class User extends BlocxBaseEntity {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  @override
  String get identifier => id;
}
```

### 2. Use cases from `blocx_core`

```dart
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';

class FetchUsersUseCase extends BlocxPaginatedUseCase<BlocxPaginatedInput, User> {
  final UserRepository repo;

  FetchUsersUseCase(this.repo);

  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(
    BlocxPaginatedInput input,
  ) async {
    final users = await repo.fetchPage(
      limit: input.limit,
      offset: input.offset,
    );

    return successResult(items: users, input: input);
  }
}

class SearchUsersUseCase extends BlocxSearchUseCase<BlocxSearchInput, User> {
  final UserRepository repo;

  SearchUsersUseCase(this.repo);

  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(
    BlocxSearchInput input,
  ) async {
    final users = await repo.search(
      query: input.searchText,
      limit: input.limit,
      offset: input.offset,
    );

    return successResult(items: users, input: input);
  }
}

class DeleteUserUseCase extends BlocxBaseUseCase<String, bool> {
  final UserRepository repo;

  DeleteUserUseCase(this.repo);

  @override
  Future<BlocxUseCaseResult<bool>> perform(String id) async {
    await repo.delete(id);
    return success(true);
  }
}
```

### 3. Collection bloc from `blocx_core`

```dart
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';

class UsersBloc extends BlocxCollectionBloc<User, void>
    with
        BlocxCollectionInfiniteMixin<User, void>,
        BlocxCollectionRefreshableMixin<User, void>,
        BlocxCollectionSearchableMixin<User, void>,
        BlocxCollectionSelectableMixin<User, void>,
        BlocxCollectionHighlightableMixin<User, void>,
        BlocxCollectionDeletableMixin<User, void> {
  final UserRepository repo;

  UsersBloc(this.repo) : super();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, User>? get paginationTask {
    return BlocxPaginatedUseCaseTask<BlocxPaginatedInput, User>(
      useCase: FetchUsersUseCase(repo),
      inputBuilder: (offset, limit) {
        return BlocxPaginatedInput(
          limit: limit,
          offset: offset,
        );
      },
    );
  }

  @override
  BlocxPaginatedUseCaseTask<BlocxSearchInput, User>? get searchUseCaseTask {
    return BlocxPaginatedUseCaseTask<BlocxSearchInput, User>(
      useCase: SearchUsersUseCase(repo),
      inputBuilder: (offset, limit) {
        return BlocxSearchInput(
          searchText: searchText,
          limit: limit,
          offset: offset,
        );
      },
    );
  }

  @override
  BlocxUseCaseTask<String, bool>? deleteItemTask(User item) {
    return BlocxUseCaseTask<String, bool>(
      useCase: DeleteUserUseCase(repo),
      inputBuilder: () => item.id,
    );
  }

  @override
  bool get isSingleSelect => false;
}
```

### 4. Collection screen from `flutter_blocx`

```dart
import 'package:blocx_core/list_bloc.dart';
import 'package:flutter/material.dart';
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
  BlocxCollectionBloc<User, void> get generateBloc {
    return UsersBloc(UserRepository());
  }

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<User> state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: BlocxSearchField<User, void>(
        controller: _searchController,
        options: const BlocxSearchFieldOptions(
          hintText: 'Search users…',
        ),
      ),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, User item) {
    return UserCard(item: item);
  }

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
  CollectionSettings get settings {
    return CollectionSettings(
      type: CollectionWidgetStateType.animatedList,
      options: AnimatedInfiniteListOptions(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

### 5. Collection item from `flutter_blocx`

```dart
class UserCard extends BlocxCollectionItem<User, void> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User item) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(item.displayName[0]),
      ),
      title: Text(item.displayName),
      subtitle: Text(item.email),
      selected: isSelected(context),
      onTap: () => toggleSelection(context),
      onLongPress: () => removeItem(context),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions {
    return ConfirmActionOptions(
      title: 'Remove ${item.displayName}',
      question: 'Are you sure?',
      imageUrl: item.avatarUrl,
    );
  }
}
```

---

## Quickstart: Form Screen

### 1. Field enum, form entity, and validator from `blocx_core`

```dart
import 'package:blocx_core/form_bloc.dart';

enum SignUpField {
  email,
  password,
  confirmPassword,
}

class SignUpForm extends BlocxBaseFormEntity<SignUpForm, SignUpField> {
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpForm({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  @override
  SignUpForm updateByKey(SignUpField key, dynamic value) {
    return switch (key) {
      SignUpField.email => copyWith(email: value as String),
      SignUpField.password => copyWith(password: value as String),
      SignUpField.confirmPassword => copyWith(confirmPassword: value as String),
    };
  }

  @override
  dynamic getValueByKey(SignUpField key) {
    return switch (key) {
      SignUpField.email => email,
      SignUpField.password => password,
      SignUpField.confirmPassword => confirmPassword,
    };
  }

  SignUpForm copyWith({
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return SignUpForm(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  String get identifier => 'sign_up_form';
}

class SignUpValidator extends BlocxFormValidator<SignUpForm, SignUpField> {
  @override
  List<SignUpField> formKeys() {
    return SignUpField.values;
  }

  @override
  List<BlocxFieldValidator<SignUpForm, SignUpField, dynamic>>
      getValidatorsByKey(SignUpForm formData, SignUpField key) {
    return switch (key) {
      SignUpField.email => [
          BlocxStringRequiredValidator<SignUpForm, SignUpField>(),
          BlocxStringEmailValidator<SignUpForm, SignUpField>(),
        ],
      SignUpField.password => [
          BlocxStringRequiredValidator<SignUpForm, SignUpField>(),
          BlocxStringMinLengthValidator<SignUpForm, SignUpField>(8),
        ],
      SignUpField.confirmPassword => [
          BlocxStringRequiredValidator<SignUpForm, SignUpField>(),
          BlocxStringMatchValidator<SignUpForm, SignUpField>(
            SignUpField.password,
          ),
        ],
    };
  }
}
```

### 2. Form bloc from `blocx_core`

```dart
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/form_bloc.dart';

class SignUpBloc extends BlocxFormBloc<SignUpForm, void, SignUpField>
    with BlocxFormValidationMixin<SignUpForm, void, SignUpField> {
  SignUpBloc() : super(const SignUpForm());

  @override
  BlocxFormValidator<SignUpForm, SignUpField> get validator {
    return SignUpValidator();
  }

  @override
  List<SignUpField> get formKeysList {
    return SignUpField.values;
  }

  @override
  FormValidationMode get formValidationMode {
    return FormValidationMode.onSubmit;
  }

  @override
  BlocxUseCaseTask<CreateAccountInput, AccountResponse> get submitUseCaseTask {
    return BlocxUseCaseTask<CreateAccountInput, AccountResponse>(
      useCase: CreateAccountUseCase(),
      inputBuilder: () {
        return CreateAccountInput(
          email: formData.email,
          password: formData.password,
        );
      },
    );
  }
}
```

### 3. Form screen from `flutter_blocx`

```dart
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/form_widget.dart';

class SignUpScreen extends BlocxFormWidget<void> {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState
        extends BlocxFormWidgetState<SignUpScreen, SignUpForm, void, SignUpField> {
  @override
  BlocxFormBloc<SignUpForm, void, SignUpField> generateBloc() {
    return SignUpBloc();
  }

  @override
  List<SignUpField> get keys {
    return SignUpField.values;
  }

  @override
  Widget formWidget(
          BuildContext context,
          BlocxFormState<SignUpForm, SignUpField> state,
          ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          textField(
            SignUpField.email,
            type: TextFieldType.outlined,
            options: const BlocXTextFieldOptions(
              labelText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          SizedBox(height: formVerticalSpacing),
          textField(
            SignUpField.password,
            type: TextFieldType.outlined,
            options: const BlocXTextFieldOptions(
              labelText: 'Password',
              obscureText: true,
            ),
          ),
          SizedBox(height: formVerticalSpacing),
          textField(
            SignUpField.confirmPassword,
            type: TextFieldType.outlined,
            options: const BlocXTextFieldOptions(
              labelText: 'Confirm password',
              obscureText: true,
            ),
          ),
          const SizedBox(height: 32),
          BlocxFormButtonRow<SignUpForm, void, SignUpField>(
            formState: state,
            registerText: 'Create account',
            registerSubmittingText: 'Creating…',
            onRegisterPressed: submit,
            secondButtonText: 'Back',
            disableRegisterWhenInvalid: false,
          ),
        ],
      ),
    );
  }

  @override
  void onFormSubmitted(
          BlocxFormStateFormSubmitted<SignUpForm, SignUpField> state,
          ) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

---

## Contributing

- Run `dart format .` or `flutter format .` before committing.
- Ensure `flutter analyze` reports no issues.
- All public APIs must include dartdoc comments.
- Add widget tests for new collection or form widgets.
- Run `flutter test` to verify the full suite passes.
- Keep pull requests focused: one feature or fix per PR.

---

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file at the repository root for details.