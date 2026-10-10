<p align="center">
  <img src="https://raw.githubusercontent.com/abolfazlkhanmohammdi/flutter_blocx/main/assets/pub/logo.png" width="180" alt="flutter_blocx logo" />
</p>

<h1 align="center">flutter_blocx</h1>

<p align="center">
  <strong>Zero-Boilerplate Flutter UI Widgets for Paginated Lists, Grids, Slivers, Reactive Forms & Screen Management</strong><br />
  The official Flutter presentation layer for <a href="https://pub.dev/packages/blocx_core"><code>blocx_core</code></a>.
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_blocx"><img src="https://img.shields.io/pub/v/flutter_blocx.svg" alt="pub version" /></a>
  <a href="https://pub.dev/packages/flutter_blocx/score"><img src="https://img.shields.io/pub/points/flutter_blocx" alt="pub points" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/platform-flutter-blue" alt="Platform: Flutter" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT" /></a>
</p>

<p align="center">
  <a href="#why-flutter_blocx">Why flutter_blocx?</a> •
  <a href="#the-blocx-ecosystem-better-together">BlocX Ecosystem</a> •
  <a href="#installation">Installation</a> •
  <a href="#collection-screens-lists-grids--items">Collections & Grids</a> •
  <a href="#form-screens--reactive-controls">Forms</a> •
  <a href="#screen-management--shared-ux">Screen Manager</a> •
  <a href="https://pub.dev/packages/blocx_core">← blocx_core</a>
</p>

---

## Why `flutter_blocx`?

Most Flutter apps don't become difficult to maintain because of complex animations—they become difficult to maintain because every data-driven screen repeatedly wires the same UI plumbing:

- Attaching and disposing `ScrollController`s to trigger infinite pagination
- Coordinating loading, empty, error, pull-to-refresh, and search states
- Wiring `BlocConsumer`s for item selection, row expansion, highlighting, and deletion spinners
- Creating, hydrating, and disposing `TextEditingController` and `FocusNode` maps for every form
- Displaying validation errors, async uniqueness spinners, and duplicate-submit guards
- Listening for snackbar, full-page error, and route-pop side effects

**`flutter_blocx` eliminates that UI plumbing.** Paired with **[`blocx_core`](https://pub.dev/packages/blocx_core)**, you declare *what* your screen renders—and let the host state handle the controllers, listeners, pagination triggers, and side effects.

### Before vs. After

<table>
<tr>
<th>Manual Flutter + BLoC Screen (~300+ lines)</th>
<th>With <code>flutter_blocx</code> + <code>blocx_core</code> (~35 lines)</th>
</tr>
<tr>
<td>

```dart
class _ProductsScreenState extends State<ProductsScreen> {
  // Manual ScrollController + _onScroll threshold math
  // Manual TextEditingController for search + dispose()
  // Manual BlocProvider + nested BlocConsumers
  // Manual if (isLoading) ... else if (isEmpty) ...
  // Manual RefreshIndicator + load-more footer
  // Manual snackbar / error page / pop listeners
}
```

</td>
<td>

```dart
class _ProductsScreenState
    extends BlocxCollectionWidgetState<ProductsScreen, ProductEntity, void> {
  @override
  BlocxCollectionBloc<ProductEntity, void> get generateBloc => ProductsBloc();

  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<ProductEntity> state) =>
      searchField();

  @override
  Widget itemBuilder(BuildContext context, ProductEntity item) =>
      ProductCard(item: item);
}
```

</td>
</tr>
</table>

---

## The BlocX Ecosystem: Better Together

`flutter_blocx` is designed specifically to work hand-in-hand with **[`blocx_core`](https://pub.dev/packages/blocx_core)**. Using both packages together gives you a cohesive, end-to-end architecture where domain logic stays 100% pure Dart and Flutter widgets remain declarative and concise:

| Layer | Package | Responsibilities |
| :--- | :--- | :--- |
| **Domain & State (Pure Dart)** | **[`blocx_core`](https://pub.dev/packages/blocx_core)** ([GitHub](https://github.com/abolfazlkhanmohammdi/blocx_core)) | `BlocxBaseEntity`, `BlocxBaseUseCase`, `BlocxEventHub` live CRUD sync, `BlocxCollectionBloc` (10 mixins), `BlocxFormBloc` (5 mixins + 35+ validators), `ScreenManagerCubit` |
| **Presentation & UI (Flutter)** | **[`flutter_blocx`](https://pub.dev/packages/flutter_blocx)** *(you are here)* | `BlocxCollectionWidgetState`, `BlocxFormWidgetState`, `BlocxCollectionItem`, `InfiniteList` / `InfiniteGrid` / `AnimatedInfiniteList`, `textField` / `dropdown` / `checkbox`, `BlocxScreenManagerState`, `BlocxErrorWidget`, `BlocxSnackBar`, `ConfirmActionWidget` |

> **Always install both packages together** in your Flutter project so your BLoCs, UseCases, and Flutter screens share the same strongly typed contracts.

---

## Feature Highlights

- **📋 Collection Host & 6 Layout Engines (`list_widget.dart`)**: Switch effortlessly between `InfiniteList`, `AnimatedInfiniteList`, `SliverInfiniteList`, `AnimatedSliverInfiniteList`, `InfiniteGrid`, and `SliverInfiniteGrid` via `CollectionSettings`.
- **🃏 Smart Collection Items**: `BlocxCollectionItem` (stateless) and `BlocxStatefulCollectionItem` + `BlocxCollectionItemState` (stateful) with built-in helpers for `isSelected`, `isExpanded`, `isHighlighted`, `isBeingRemoved`, and modal delete confirmation.
- **🔍 Built-in Search & Scroll-Aware FAB**: Drop in `searchField()` for debounced search and mix in `HideOnScrollFabMixin` for a FloatingActionButton that hides on scroll-down and reappears on scroll-up.
- **📝 Reactive Form Host & Controls (`form_widget.dart`)**: `BlocxFormWidgetState` automatically manages `TextEditingController`s and `FocusNode`s, hydrates edit-mode data, and provides `textField()` (with type `converter`, RTL auto-detection, and async uniqueness spinner), `dropdown<T>()`, `checkbox()`, `BlocxFormRegisterButton`, and `BlocxFormButtonRow`.
- **🖥️ Unified Screen Management**: `BlocxScreenManagerState` automatically renders `BlocxSnackBar`s, full-screen `BlocxErrorWidget`s (with stack-trace expansion and retry callbacks), and route pops emitted by any `blocx_core` BLoC.

---

## Installation

Add both **`blocx_core`** and **`flutter_blocx`** to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  blocx_core: ^1.1.0
  flutter_blocx: ^1.1.0
```

Or run:

```sh
flutter pub add blocx_core flutter_blocx
```

### Barrel Imports

```dart
// Full package barrel (Collection widgets, Form widgets, ScreenManager, SnackBar, ErrorWidget, ConfirmAction)
import 'package:flutter_blocx/flutter_blocx.dart';

// Or import modular barrels:
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/form_widget.dart';
import 'package:flutter_blocx/blocx_collection_item_state.dart';
```

---

## Collection Screens, Lists, Grids & Items

### 1. Collection Screen Host (`BlocxCollectionWidget` & `BlocxCollectionWidgetState`)

Extend `BlocxCollectionWidget<Payload>` and `BlocxCollectionWidgetState<W, Entity, Payload>` to build any list, grid, or sliver collection screen backed by a `BlocxCollectionBloc` from [`blocx_core`](https://pub.dev/packages/blocx_core):

```dart
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

class ProductsScreen extends BlocxCollectionWidget<void> {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState
    extends BlocxCollectionWidgetState<ProductsScreen, ProductEntity, void>
    with HideOnScrollFabMixin<void> {
  // 1. Required GETTER: instantiate your BlocxCollectionBloc
  @override
  BlocxCollectionBloc<ProductEntity, void> get generateBloc => ProductsBloc();

  // 2. Wrap in a Scaffold with HideOnScrollFabMixin support
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
    // Open create product form or dispatch addToList(...)
  }

  // 3. Choose your layout engine (animatedList, list, grid, sliverList, animatedSliverList, sliverGrid)
  @override
  CollectionSettings get settings => CollectionSettings(
        type: CollectionWidgetStateType.grid,
        options: const InfiniteGridOptions(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: EdgeInsets.all(12),
        ),
      );

  // 4. Optional top widget: built-in debounced searchField()
  @override
  Widget? topWidget(BuildContext context, BlocxCollectionState<ProductEntity> state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: searchField(
        options: const BlocxSearchFieldOptions(hintText: 'Search products...'),
      ),
    );
  }

  // 5. Optional bottom widget: bulk selection action bar
  @override
  Widget? bottomWidget(BuildContext context, BlocxCollectionState<ProductEntity> state) {
    if (state.selectedCount == 0) return null;
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text('${state.selectedCount} selected'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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

  // 6. Required itemBuilder
  @override
  Widget itemBuilder(BuildContext context, ProductEntity item) {
    return ProductCard(key: ValueKey(item.identifier), item: item);
  }
}
```

### Layout Types & Matching Options (`CollectionSettings`)

| `CollectionWidgetStateType` | Matching `options` Class | Description |
| :--- | :--- | :--- |
| `CollectionWidgetStateType.animatedList` *(default)* | `AnimatedInfiniteListOptions` | Infinite list with animated insert/remove transitions |
| `CollectionWidgetStateType.list` | `InfiniteListOptions` | Standard infinite `ListView.separated` |
| `CollectionWidgetStateType.grid` | `InfiniteGridOptions(crossAxisCount: ...)` | Infinite `GridView` with pull-to-refresh |
| `CollectionWidgetStateType.sliverList` | `SliverInfiniteListOptions` | Sliver infinite list (`CustomScrollView`) |
| `CollectionWidgetStateType.animatedSliverList` | `AnimatedSliverInfiniteListOptions` | Animated sliver infinite list |
| `CollectionWidgetStateType.sliverGrid` | `SliverInfiniteGridOptions(crossAxisCount: ...)` | Sliver infinite grid (`CustomScrollView`) |

### 2. Standalone Composable Views (`BlocxCollectionView` & `BlocxFormView`)

Need to embed a collection list or a form inside a custom layout, tab view, dialog, or multi-pane desktop screen without subclassing `BlocxCollectionWidgetState` or `BlocxFormWidgetState`? Use the standalone composable views:

```dart
// Standalone collection list view
BlocxCollectionView<ProductEntity, void>(
  bloc: productsBloc,
  itemBuilder: (context, item) => ProductCard(item: item),
  emptyBuilder: (context) => const Center(child: Text('No products available')),
  errorBuilder: (context, error) => BlocxErrorWidget(
    error: error,
    onRetry: () => productsBloc.loadInitialPage(),
  ),
);

// Standalone form view
BlocxFormView<ProfileFormEntity, UserProfileEntity, ProfileFormField>(
  bloc: profileBloc,
  formBuilder: (context, state) => Column(children: [...]),
  loadingBuilder: (context) => const Center(child: CircularProgressIndicator()),
);
```

### 3. DI-Friendly BLoC Construction

`BlocxCollectionWidget` and `BlocxFormWidget` support three flexible dependency-injection patterns:
1. **Direct constructor injection**: Pass `bloc: myBloc` directly to `BlocxCollectionWidget(bloc: myBloc)` or `BlocxFormWidget(bloc: myBloc)`.
2. **Inherited Provider**: Provide the BLoC with `BlocProvider<MyBloc>.value(...)`. When `generateBloc` is not overridden in your state subclass, it automatically resolves `context.read<MyBloc>()`.
3. **Internal instantiation**: Subclass and override `get generateBloc => MyBloc()`.

*When a BLoC is injected via constructor or context, `autoDisposeBloc` / `autoCloseBloc` default to `false` so ancestor providers retain full lifecycle ownership.*

### 4. Collection Item Widgets (`BlocxCollectionItem` & `BlocxStatefulCollectionItem`)

#### Stateless Item (`BlocxCollectionItem<Entity, Payload>`)

```dart
class ProductCard extends BlocxCollectionItem<ProductEntity, void> {
  const ProductCard({super.key, required super.item});

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
        title: 'Delete ${item.name}?',
        question: 'Are you sure you want to permanently remove "${item.name}"?',
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

#### Stateful Item (`BlocxStatefulCollectionItem<Entity>` & `BlocxCollectionItemState<W, Entity, Payload>`)

When an item needs local `State` (e.g., an `AnimationController` or inline `TextEditingController`), extend `BlocxStatefulCollectionItem<T>` and `BlocxCollectionItemState<W, T, P>`. Inside `BlocxCollectionItemState`, override `Widget buildContent(T item)` and use context-free getters/methods (`isSelected`, `isExpanded`, `isBeingRemoved`, `toggleSelection()`, `toggleExpansion()`, `removeItem()`).

---

## Form Screens & Reactive Controls

### Form Screen Host (`BlocxFormWidget` & `BlocxFormWidgetState`)

Extend `BlocxFormWidget<Payload>` and `BlocxFormWidgetState<W, FormEntity, Payload, FieldEnum>` to connect a `BlocxFormBloc` from [`blocx_core`](https://pub.dev/packages/blocx_core) to Flutter form controls with automatic controller/focus management:

```dart
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';

class ProfileFormScreen extends BlocxFormWidget<UserProfileEntity> {
  const ProfileFormScreen({super.key, super.payload});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends BlocxFormWidgetState<
    ProfileFormScreen,
    ProfileFormEntity,
    UserProfileEntity,
    ProfileFormField> {
  // 1. Required GETTER: instantiate your BlocxFormBloc
  @override
  BlocxFormBloc<ProfileFormEntity, UserProfileEntity, ProfileFormField>
      get generateBloc => ProfileFormBloc();

  // 2. Field keys managed by the form
  @override
  List<ProfileFormField> get keys => ProfileFormField.values;

  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: Text(isUpdate ? 'Edit Profile' : 'Create Profile')),
      body: body,
    );
  }

  // 3. Hydrate text controllers in edit mode or on live stream sync
  @override
  void applyInitialDataToForm(ProfileFormEntity formData) {
    getTextEditingController(ProfileFormField.username).text = formData.username;
    getTextEditingController(ProfileFormField.email).text = formData.email;
    getTextEditingController(ProfileFormField.age).text =
        formData.age > 0 ? formData.age.toString() : '';
  }

  // 4. React after successful submission
  @override
  void onFormSubmitted(
    BlocxFormStateFormSubmitted<ProfileFormEntity, ProfileFormField> state,
  ) {
    Navigator.of(context).maybePop(state.submittedData);
  }

  // 5. Build form UI with built-in reactive controls
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
            prefix: const Icon(Icons.person_outline),
          ),
          textField(
            ProfileFormField.email,
            type: TextFieldType.outlined,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
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
            options: const BlocXDropdownOptions(labelText: 'Role'),
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
          BlocxFormButtonRow<ProfileFormEntity, UserProfileEntity, ProfileFormField>(
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

### Built-in Form Controls

| Host Helper / Widget | Key Features |
| :--- | :--- |
| `textField(...)` / `BlocxFormTextField` | `TextFieldType.filled` / `outlined` / `underlined`, `converter` for numeric/custom types, automatic RTL/LTR text direction, clear button, and automatic suffix spinner during async `BlocxUniqueFieldValidatorMixin` checks |
| `dropdown<T>(...)` / `BlocxFormDropdown` | Pre-wired `DropdownButtonFormField<T>` with automatic validation error display |
| `checkbox(...)` / `BlocxFormCheckbox` | Renders a `CheckboxListTile` when `label`/`subtitle` is provided, or a compact `Checkbox` otherwise |
| `submitButton(...)` / `BlocxFormRegisterButton` | Reacts to `isSubmitting`, `isCheckingUniqueField`, and `isLoadingRequiredFields` with an inline progress indicator |
| `formButtonRow(...)` / `BlocxFormButtonRow` | Primary `BlocxFormRegisterButton` paired with a secondary cancel/back button (`Navigator.maybePop()`) |

#### Form Validation Precedence

`flutter_blocx` supports two complementary validation mechanisms:

1. **BlocX Reactive Validation (Recommended):** Configured on the bloc via `BlocxFormValidator` rules, async uniqueness checks (`BlocxUniqueFieldValidatorMixin`), and step validation. Errors are reactively streamed into `bloc.state.errors` and rendered via `InputDecoration.errorText`.
2. **Flutter `validator:` Hook:** An optional standard `FormFieldValidator<String>` passed to `textField(..., validator: ...)`.

**Precedence Rules:**
- When Flutter's `FormState.validate()` runs, any non-null error string returned by Flutter's `validator` hook takes visual precedence in `FormFieldState`.
- When the Flutter validator returns `null` (passes), any active bloc-level error for that field in `bloc.state.errors` remains rendered on screen.
- **Guideline:** Place domain validation rules and asynchronous checks in your `BlocxFormBloc` using pure-Dart `BlocxFieldValidator` classes. Use Flutter's `validator:` hook for local UI formatting or when interoperating with third-party form wrappers.

---

## Screen Management & Shared UX

### 1. `BlocxScreenManagerState<T>`

Both `BlocxCollectionWidgetState` and `BlocxFormWidgetState` extend `BlocxScreenManagerState`. You can also extend `BlocxScreenManagerState<MyScreen>` directly on any custom screen to get automatic handling for:
- **Snackbars** (`ScreenManagerCubitStateDisplaySnackbar` $\rightarrow$ `BlocxSnackBar.show`)
- **Full-Page Errors** (`ScreenManagerCubitStateDisplayErrorPage` $\rightarrow$ `errorWidget(context, state)`)
- **Route Popping** (`ScreenManagerCubitStatePop` $\rightarrow$ `Navigator.maybePop()`)

### 2. `BlocxErrorWidget`

Render Material 3 full-page error cards with collapsible stack traces, copy-to-clipboard, report, and retry actions:

```dart
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

### 3. `BlocxSnackBar`

Show themed floating snackbars (`BlocxSnackbarType.info`, `warning`, `error`):

```dart
BlocxSnackBar.show(
  context,
  title: 'Saved',
  message: 'Your changes have been saved.',
  type: BlocxSnackbarType.info,
);
```

### 4. `ConfirmActionWidget`

Display a modal confirmation bottom sheet with optional type-to-confirm protection (`requireTyping: true`):

```dart
final confirmed = await ConfirmActionWidget.show(
  context,
  isScrollControlled: true,
  options: ConfirmActionOptions(
    title: 'Delete Account?',
    question: 'This action is permanent. Type DELETE to confirm.',
    confirmText: 'Delete Forever',
    requireTyping: true,
    deleteWord: 'DELETE',
  ),
);
```

### 5. Localization (`BlocXLocalizations`)

All built-in labels (`loadingText`, `emptyListText`, `tryAgain`, `cancel`, `delete`, and validator messages) come from `BlocXLocalizations` in [`blocx_core`](https://pub.dev/packages/blocx_core). Override any string globally before `runApp`:

```dart
void main() {
  BlocXLocalizations.localizations = MyAppLocalizations();
  runApp(const MyApp());
}
```

---

## Power Your Screens with `blocx_core`

`flutter_blocx` widgets are powered by **[`blocx_core`](https://pub.dev/packages/blocx_core)** ([GitHub](https://github.com/abolfazlkhanmohammdi/blocx_core)). Visit the `blocx_core` documentation to learn how to build:

- **`BlocxCollectionBloc`** with infinite scroll, search, filter, selection, deletion, and live `BlocxEventHub` synchronization
- **`BlocxFormBloc`** with 35+ built-in validators, async uniqueness checks, data prefetching, multi-step wizards, and live form synchronization
- **`BlocxBaseUseCase` & `BlocxEventHub`** for clean domain architecture and automatic cross-BLoC CRUD event broadcasting

👉 **[Explore `blocx_core` on pub.dev](https://pub.dev/packages/blocx_core)**

---

## Included AI Coding Skill

This repository includes an AI agent skill at [`skills/flutter-blocx/SKILL.md`](skills/flutter-blocx/SKILL.md) (compatible with Claude Code, Antigravity, and Cursor) containing full widget rules, type-signature tables, blueprints, and progressive-disclosure reference guides for `flutter_blocx`.

---

## Contributing & License

Contributions, issues, and feature requests are welcome at the [issue tracker](https://github.com/abolfazlkhanmohammdi/flutter_blocx/issues).

Released under the **MIT License**.
