---
name: flutter-blocx
description: >-
  Build, refactor, and test Flutter UI screens, infinite lists, grids, slivers,
  collection item cards, reactive forms, and screen-managed views using the
  flutter_blocx package (paired with blocx_core). Use this skill whenever working
  with package:flutter_blocx, BlocxCollectionWidget, BlocxCollectionWidgetState,
  BlocxCollectionItem, BlocxStatefulCollectionItem, BlocxCollectionItemState,
  CollectionSettings, CollectionWidgetStateType, InfiniteList, AnimatedInfiniteList,
  InfiniteGrid, SliverInfiniteList, AnimatedSliverInfiniteList, SliverInfiniteGrid,
  BlocxSearchField, HideOnScrollFabMixin, BlocxFormWidget, BlocxFormWidgetState,
  BlocxFormTextField, BlocXFormTextField, BlocxFormDropdown, BlocXFormDropdown,
  BlocxFormCheckbox, BlocxFormRegisterButton, BlocxFormButtonRow,
  BlocxScreenManagerState, BlocxErrorWidget, BlocxSnackBar, ConfirmActionWidget,
  BlocxStatelessWidget, or BlocxWidgetState.
---

# `flutter_blocx` Comprehensive UI & Widget Skill

`flutter_blocx` (located in the `blocx_flutter` package directory, imported as `package:flutter_blocx/...`) is the official Flutter UI layer for `blocx_core`. It provides ready-to-use base screens, reactive form controls, infinite/animated lists and grids, collection item widgets, and automatic screen-level side-effect handling (snackbars, full-page errors, and route popping).

---

## 1. Barrel Imports & Casing Aliases

The package name in `pubspec.yaml` is **`flutter_blocx`**. Import the barrel file matching your screen type:

```dart
// 1. Full package barrel (exports everything below + ScreenManager, SnackBar, ErrorWidget, ConfirmAction, Base Widgets)
import 'package:flutter_blocx/flutter_blocx.dart';

// 2. Collection screens, list/grid widgets, collection options, BlocxCollectionItem, BlocxSearchField, HideOnScrollFabMixin
import 'package:flutter_blocx/list_widget.dart';

// 3. Form screens (BlocxFormWidget, BlocxFormWidgetState) and form controls (textField, dropdown, checkbox, submitButton, formButtonRow)
import 'package:flutter_blocx/form_widget.dart';

// 4. Stateful collection item base classes (BlocxStatefulCollectionItem, BlocxCollectionItemState)
import 'package:flutter_blocx/blocx_collection_item_state.dart';

// 5. When referencing Emitter, BlocProvider, BlocBuilder, or Cubit in a Flutter project,
//    import package:flutter_bloc/flutter_bloc.dart (NOT package:bloc/bloc.dart):
import 'package:flutter_bloc/flutter_bloc.dart';
```

### Casing Typedef Aliases
Both `Blocx...` and `BlocX...` spellings are exported for classes that historically used capital `X`:
- `BlocxWidgetState<W>` = `BlocXWidgetState<W>`
- `BlocxSnackbarType` = `BlocXSnackbarType` (from `blocx_core`)
- `BlocxFormTextField<F, P, E>` = `BlocXFormTextField<F, P, E>`
- `BlocxFormDropdown<F, P, E, T>` = `BlocXFormDropdown<F, P, E, T>`
- `BlocxTextFieldOptions` = `BlocXTextFieldOptions`
- `BlocxDropdownOptions` = `BlocXDropdownOptions`

---

## 2. Eight Critical Rules & Gotchas

### Rule 1: Exact Generic Type Signatures
Never guess or reorder generic type parameters on `flutter_blocx` classes:

| Class | Exact Type Parameters |
| :--- | :--- |
| `BlocxScreenManagerState<W>` | `<W extends StatefulWidget>` (**1** type param) |
| `BlocxCollectionWidget<Payload>` | `<Payload>` (**1** type param — use `void` or `dynamic` if no payload) |
| `BlocxCollectionWidgetState<W, Entity, Payload>` | `<W extends BlocxCollectionWidget<Payload>, Entity extends BlocxBaseEntity, Payload>` (**3** type params) |
| `BlocxCollectionItem<T, P>` | `<T extends BlocxBaseEntity, P>` (**2** type params — `T`: entity, `P`: collection bloc's `Payload` type) |
| `BlocxStatefulCollectionItem<T>` | `<T extends BlocxBaseEntity>` (**1** type param) |
| `BlocxCollectionItemState<W, T, P>` | `<W extends BlocxStatefulCollectionItem<T>, T extends BlocxBaseEntity, P>` (**3** type params) |
| `BlocxSearchField<Entity, Payload>` | `<Entity extends BlocxBaseEntity, Payload>` (**2** type params) |
| `BlocxFormWidget<P>` | `<P>` (**1** type param — use `void` or `dynamic` if no payload) |
| `BlocxFormWidgetState<W, F, P, E>` | `<W extends BlocxFormWidget<P>, F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>` (**4** type params) |
| `BlocxFormTextField<F, P, E>` | `<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>` (**3** type params) |
| `BlocxFormDropdown<F, P, E, T>` | `<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum, T>` (**4** type params — `T` is item value type) |
| `BlocxFormCheckbox<F, P, E>` | `<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>` (**3** type params) |
| `BlocxFormRegisterButton<F, P, E>` | `<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>` (**3** type params) |
| `BlocxFormButtonRow<F, P, E>` | `<F extends BlocxBaseFormEntity<F, E>, P, E extends Enum>` (**3** type params) |

### Rule 2: `generateBloc` Is a GETTER in Both Collection and Form States
In both `BlocxCollectionWidgetState` and `BlocxFormWidgetState`, `generateBloc` is a **getter** (not a `createBloc()` or `generateBloc()` method):
- In **`BlocxCollectionWidgetState`**:
  ```dart
  @override
  BlocxCollectionBloc<ProductEntity, void> get generateBloc => ProductsBloc();
  ```
- In **`BlocxFormWidgetState`**:
  ```dart
  @override
  BlocxFormBloc<ProfileFormEntity, UserProfileEntity, ProfileFormField> get generateBloc => ProfileFormBloc();
  ```

### Rule 3: `wrapInScaffold => true` Requires Overriding `scaffoldWidget(context, body)`
Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend `BlocxScreenManagerState`.
- By default, `bool get wrapInScaffold => false;` wraps the screen content in a `SafeArea` (ideal for bottom sheets, dialogs, or embedded tabs).
- When building a full screen with a `Scaffold`, you **must** override **both**:
  ```dart
  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: body, // ALWAYS place `body` inside the Scaffold!
    );
  }
  ```
  If `wrapInScaffold` is `true` and `scaffoldWidget` is not overridden, `BlocxScreenManagerState` throws an `UnimplementedError` at runtime.

### Rule 4: `CollectionSettings.type` Must Match the Exact `CollectionOptions` Subclass
In `BlocxCollectionWidgetState`, `CollectionSettings.options` is runtime-checked via `assertCorrectType(type)`. Passing the wrong options class throws an `ArgumentError`:
- `CollectionWidgetStateType.list` $\rightarrow$ `const InfiniteListOptions(...)`
- `CollectionWidgetStateType.animatedList` (default) $\rightarrow$ `const AnimatedInfiniteListOptions(...)`
- `CollectionWidgetStateType.sliverList` $\rightarrow$ `const SliverInfiniteListOptions(...)`
- `CollectionWidgetStateType.animatedSliverList` $\rightarrow$ `const AnimatedSliverInfiniteListOptions(...)`
- `CollectionWidgetStateType.grid` $\rightarrow$ `const InfiniteGridOptions(crossAxisCount: 2, ...)`
- `CollectionWidgetStateType.sliverGrid` $\rightarrow$ `const SliverInfiniteGridOptions(crossAxisCount: 2, ...)`
- *(Note: `CollectionSettings(...)` itself has a non-`const` constructor; do not write `const CollectionSettings(...)`.)*

### Rule 5: Non-String Form Fields Must Use `converter` in `textField(...)`
`BlocXFormTextField` listens to `TextFormField.onChanged(String text)` and dispatches `BlocxFormEventUpdateData`. If a field in your `BlocxBaseFormEntity.updateByKey` expects an `int`, `double`, or custom type instead of `String`, pass `converter:` to `textField(...)`:
```dart
textField(
  ProfileFormField.age,
  labelText: 'Age',
  keyboardType: TextInputType.number,
  converter: (text) => int.tryParse(text) ?? 0,
)
```

### Rule 6: Reliable Edit-Mode & Stream-Sync Text Controller Hydration
When `BlocxFormEventInit(payload: widget.payload)` runs in `BlocxFormWidgetState.initState()`, synchronous hydration emits `BlocxFormStateApplyInitialDataToForm` before the first `build()` creates controllers via `textField(...)`.
- The default `applyInitialDataToForm(F formData)` only updates controllers that already exist in `_controllersMap` using `formData.getFormattedValueByKey(key) ?? formData.getValueByKey(key)`.
- **Best Practice for Edit/Sync Forms**: Override `applyInitialDataToForm(F formData)` and assign `getTextEditingController(key).text = ...` for each text field key (which eagerly creates the controller in `_controllersMap` if it doesn't exist yet), **or** ensure `F.getFormattedValueByKey(key)` returns a `String?` (not throwing `UnimplementedError`, which is the default in `BlocxBaseFormEntity.getFormattedValueByKey`!) and pre-create controllers or override `applyInitialDataToForm`:
  ```dart
  @override
  void applyInitialDataToForm(ProfileFormEntity formData) {
    getTextEditingController(ProfileFormField.username).text = formData.username;
    getTextEditingController(ProfileFormField.email).text = formData.email;
    getTextEditingController(ProfileFormField.age).text =
        formData.age > 0 ? formData.age.toString() : '';
  }
  ```
  > **Warning**: `BlocxBaseFormEntity.getFormattedValueByKey(E key)` in `blocx_core` throws `UnimplementedError()` unless overridden in your `BlocxBaseFormEntity` subclass! Always either override `getFormattedValueByKey(E key) => getValueByKey(key)?.toString()` in your `BlocxBaseFormEntity` **or** override `applyInitialDataToForm(F formData)` in your `BlocxFormWidgetState`.

### Rule 7: Non-`const` Constructors & `BlocXWidgetState` Theme Access
- **Non-`const` constructors** (never prefix these with `const`):
  - `CollectionSettings(type: ..., options: ...)`
  - `ConfirmActionOptions(...)`
  - `ReadableError(message: ..., title: ..., error: ..., stackTrace: ...)`
  - `BlocxBaseEvent()` (meanwhile `const BlocxBaseState({required super.shouldRebuild, required super.shouldListen})` IS `const` and requires `shouldRebuild` and `shouldListen`; neither uses `Equatable` `props`)
- **`BlocXWidgetState` / `BlocxWidgetState` Theme & Size Getters**:
  - `BlocxScreenManagerState`, `BlocxCollectionWidgetState`, `BlocxFormWidgetState`, and `BlocxCollectionItemState` all extend `BlocXWidgetState<W>`, exposing `theme`, `textTheme`, `colorScheme`, `width`, and `height` getters directly without passing `BuildContext`.
- **Localization (`loc`)**: Ensure `BlocXLocalizations.localizations` is initialized at app startup (or in test `setUpAll`) if you use a custom localization subclass, because widgets read `loc` (`BlocXLocalizations.localizations`) for default labels (`loc.loadingText`, `loc.emptyListText`, `loc.cancel`, `loc.delete`, `loc.tryAgain`, etc.).

### Rule 8: Immutable State Snapshot Reading & Initial Load Error Retries
- **Collection Error Retries**: `BlocxCollectionWidgetState` automatically renders `collectionErrorWidget` (`BlocxErrorWidget` with a retry callback triggering `refreshData()`) whenever initial load fails (`BlocxCollectionStateError`). Avoid endless loading spinners or blank screens by leaving this intact or overriding `collectionErrorWidget` with custom retry UI.
- **Snapshot Reading in Form Helpers**: Always pass `formState: state` when calling `submitButton(..., formState: state)` or `formButtonRow(..., formState: state)` within `formWidget(context, state)`. This guarantees busy/disabled button states evaluate the immutable snapshot rather than reading live mutable bloc fields.
- **Identifier-Based Item Indexing**: `BlocxCollectionItem.index(context)` resolves indices via `state.indexOfId(item.identifier)` rather than reference equality, ensuring resilient lookup across state emissions. Lists also pass builder indices directly to avoid $O(n^2)$ lookup passes.

### Rule 9: Composable Standalone Views (`BlocxCollectionView` & `BlocxFormView`)
For embedded widget trees, multi-pane dashboards, or modal sheets where you don't want a full `BlocxScreenManagerState` subclass:
- Use `BlocxCollectionView<Entity, Payload>` directly with your existing collection BLoC:
  ```dart
  BlocxCollectionView<ProductEntity, void>(
    bloc: productsBloc,
    itemBuilder: (context, item) => ProductCard(product: item),
    emptyBuilder: (context) => const Text('No products available'),
    errorBuilder: (context, error) => BlocxErrorWidget(
      error: error,
      onRetry: () => productsBloc.loadInitialPage(),
    ),
  )
  ```
- Use `BlocxFormView<F, P, E>` directly with your form BLoC:
  ```dart
  BlocxFormView<ProfileFormEntity, UserProfileEntity, ProfileFormField>(
    bloc: profileBloc,
    formBuilder: (context, state) => Column(children: [...]),
    loadingBuilder: (context) => const CircularProgressIndicator(),
  )
  ```

### Rule 10: DI-Friendly Construction & Lifecycle Management
`BlocxCollectionWidget` and `BlocxFormWidget` support three ways to acquire their BLoC:
1. **Direct constructor injection**: Pass `bloc: myBloc` directly to the widget constructor.
2. **Inherited Provider**: Provide a BLoC above the widget with `BlocProvider<MyBloc>.value(...)`. When `generateBloc` is not overridden, it automatically resolves `context.read<B>()`.
3. **Internal instantiation**: Subclass and override `get generateBloc => MyBloc()`.
- **Non-destructive lifecycle**: When a BLoC is injected via constructor or resolved from context, `autoDisposeBloc` / `autoCloseBloc` default to `false`, ensuring ancestor providers retain ownership and the bloc is not prematurely closed.

---

## 3. Complete End-to-End Blueprints

### Blueprint A: Collection Screen (`BlocxCollectionWidget` + `BlocxCollectionWidgetState` + `BlocxCollectionItem` + `HideOnScrollFabMixin`)

```dart
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

class ProductsScreen extends BlocxCollectionWidget<void> {
  final ProductsCollectionBloc Function() blocFactory;

  const ProductsScreen({
    super.key,
    required this.blocFactory,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState
    extends BlocxCollectionWidgetState<ProductsScreen, ProductEntity, void>
    with HideOnScrollFabMixin<void> {
  @override
  BlocxCollectionBloc<ProductEntity, void> get generateBloc =>
      widget.blocFactory();

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: NotificationListener<UserScrollNotification>(
        onNotification: onScrollNotification,
        child: body,
      ),
      floatingActionButton: getFloatingActionButton(context),
    );
  }

  @override
  void onFabPressed(void data) {
    // Open create form or dispatch addToList(...)
  }

  @override
  CollectionSettings get settings => CollectionSettings(
        type: CollectionWidgetStateType.animatedList,
        options: const AnimatedInfiniteListOptions(
          padding: EdgeInsets.all(12),
        ),
      );

  @override
  Widget? topWidget(
    BuildContext context,
    BlocxCollectionState<ProductEntity> state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: searchField(
        options: const BlocxSearchFieldOptions(
          hintText: 'Search products...',
        ),
      ),
    );
  }

  @override
  Widget? bottomWidget(
    BuildContext context,
    BlocxCollectionState<ProductEntity> state,
  ) {
    if (state.selectedCount == 0) return null;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text('${state.selectedCount} selected')),
            IconButton(
              icon: const Icon(Icons.deselect),
              onPressed: () => deselectMultipleItems(state.selectedItems),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => deleteMultipleItems(state.selectedItems),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget itemBuilder(BuildContext context, ProductEntity item) {
    return ProductCard(
      key: ValueKey(item.identifier),
      item: item,
    );
  }
}

class ProductCard extends BlocxCollectionItem<ProductEntity, void> {
  const ProductCard({
    super.key,
    required super.item,
  });

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
        title: 'Delete ${item.name}?',
        question: 'Are you sure you want to delete "${item.name}"?',
      );

  @override
  Widget buildContent(BuildContext context, ProductEntity item) {
    final cs = colorScheme(context);
    final selected = isSelected(context);
    final removing = isBeingRemoved(context);

    return Card(
      color: selected ? cs.primaryContainer : null,
      child: ListTile(
        onTap: () => toggleSelection(context),
        leading: Checkbox(
          value: selected,
          onChanged: (_) => toggleSelection(context),
        ),
        title: Text(item.name),
        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: removing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete_outline, color: cs.error),
          onPressed: removing ? null : () => removeItem(context),
        ),
      ),
    );
  }
}
```

### Blueprint B: Form Screen (`BlocxFormWidget` + `BlocxFormWidgetState` + Form Controls)

```dart
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

class ProfileFormScreen extends BlocxFormWidget<UserProfileEntity> {
  final ProfileFormBloc Function() blocFactory;

  const ProfileFormScreen({
    super.key,
    super.payload,
    required this.blocFactory,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends BlocxFormWidgetState<
    ProfileFormScreen,
    ProfileFormEntity,
    UserProfileEntity,
    ProfileFormField> {
  @override
  BlocxFormBloc<ProfileFormEntity, UserProfileEntity, ProfileFormField>
      get generateBloc => widget.blocFactory();

  @override
  List<ProfileFormField> get keys => ProfileFormField.values;

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit Profile' : 'Create Profile'),
      ),
      body: body,
    );
  }

  @override
  void applyInitialDataToForm(ProfileFormEntity formData) {
    getTextEditingController(ProfileFormField.username).text = formData.username;
    getTextEditingController(ProfileFormField.email).text = formData.email;
    getTextEditingController(ProfileFormField.age).text =
        formData.age > 0 ? formData.age.toString() : '';
  }

  @override
  void onFormSubmitted(
    BlocxFormStateFormSubmitted<ProfileFormEntity, ProfileFormField> state,
  ) {
    Navigator.of(context).maybePop(state.submittedData);
  }

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<ProfileFormEntity, ProfileFormField> state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: formVerticalSpacing,
        children: [
          textField(
            ProfileFormField.username,
            type: TextFieldType.outlined,
            labelText: 'Username',
            hintText: 'Choose a unique username',
            prefix: const Icon(Icons.person_outline),
          ),
          textField(
            ProfileFormField.email,
            type: TextFieldType.outlined,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.email_outlined),
          ),
          textField(
            ProfileFormField.age,
            type: TextFieldType.outlined,
            labelText: 'Age',
            keyboardType: TextInputType.number,
            converter: (value) => int.tryParse(value) ?? 0,
          ),
          dropdown<String>(
            ProfileFormField.role,
            options: const BlocXDropdownOptions(
              labelText: 'Role',
              hintText: 'Select a role',
            ),
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'member', child: Text('Member')),
            ],
          ),
          checkbox(
            key: ProfileFormField.acceptTerms,
            isChecked: state.formData.acceptTerms,
            options: BlocxCheckboxOptions(
              isChecked: state.formData.acceptTerms,
              label: 'I accept the terms and conditions',
            ),
          ),
          BlocxFormButtonRow<
              ProfileFormEntity,
              UserProfileEntity,
              ProfileFormField>(
            formState: state,
            registerText: isUpdate ? 'Save Changes' : 'Create Profile',
            registerSubmittingText: 'Saving...',
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Reference Manuals (Progressive Disclosure)

Read the relevant reference file in `./references/` when implementing specific widgets or screen features:

1. **[`references/collection_widgets.md`](./references/collection_widgets.md)**
   - `BlocxCollectionWidget<Payload>` & `BlocxCollectionWidgetState<W, Entity, Payload>` full lifecycle, properties, and hooks
   - `CollectionSettings`, `CollectionWidgetStateType` (`list`, `animatedList`, `sliverList`, `animatedSliverList`, `grid`, `sliverGrid`), and all 6 `CollectionOptions` classes (`InfiniteListOptions`, `AnimatedInfiniteListOptions`, `SliverInfiniteListOptions`, `AnimatedSliverInfiniteListOptions`, `InfiniteGridOptions`, `SliverInfiniteGridOptions`)
   - `BlocxSearchField` & `BlocxSearchFieldOptions`
   - `HideOnScrollFabMixin<T>`
   - Stateless `BlocxCollectionItem<T, P>` vs Stateful `BlocxStatefulCollectionItem<T>` & `BlocxCollectionItemState<W, T, P>`
2. **[`references/form_widgets.md`](./references/form_widgets.md)**
   - `BlocxFormWidget<P>` & `BlocxFormWidgetState<W, F, P, E>` full lifecycle, controller/focus management, and hooks
   - `textField` / `BlocXFormTextField` (`BlocxFormTextField`), `BlocXTextFieldOptions` (`BlocxTextFieldOptions`), `TextFieldType`, `TypeConverter`, RTL auto-detection, unique-field spinner, and clear button behavior
   - `dropdown` / `BlocXFormDropdown` (`BlocxFormDropdown`) & `BlocXDropdownOptions` (`BlocxDropdownOptions`)
   - `checkbox` / `BlocxFormCheckbox` & `BlocxCheckboxOptions`
   - `submitButton` / `BlocxFormRegisterButton` (`BlocxFormRegisterButtonOptions`, `RegisterButtonType`) and `formButtonRow` / `BlocxFormButtonRow` (`BlocxFormButtonRowOptions`)
   - Handling edit-mode hydration, live stream sync updates, and stepped/prefetched forms in Flutter UI
3. **[`references/screen_manager_and_common_widgets.md`](./references/screen_manager_and_common_widgets.md)**
   - `BlocxScreenManagerState<T>` (`wrapInScaffold`, `scaffoldWidget`, `decorateScaffold`, `errorWidget`, `errorWidgetByErrorCode`, `displaySnackBar`)
   - `BlocxStatelessWidget` & `BlocXWidgetState<W>` (`BlocxWidgetState<W>`) theme and media-query helpers
   - `BlocxErrorWidget` & `BlocxErrorWidget.fromState`
   - `BlocxSnackBar` & `BlocxSnackBar.show`
   - `ConfirmActionWidget` & `ConfirmActionOptions` (including `requireTyping` / `deleteWord` confirmation)
   - `loc` (`BlocXLocalizations`) setup & Flutter widget testing patterns
