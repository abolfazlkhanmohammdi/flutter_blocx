<p align="center">
  <img src="./blocx_flutter_logo.png" alt="blocx_flutter" width="120">
</p>

<h1 align="center">blocx_flutter</h1>
<p align="center"><em>Flutter widgets for fast lists, grids, and forms powered by <code>blocx_core</code>.</em></p>

---

## Installing

Use this package as a library in your Flutter app.

### Depend on it

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  blocx_flutter: ^0.1.0
```

Or add via the command line:

**With Flutter:**

```sh
flutter pub add blocx_flutter
```

**With Dart:**

```sh
dart pub add blocx_flutter
```

### Import it

```dart
import 'package:blocx_flutter/flutter_blocx.dart';
// or import specific entry points:
// import 'package:blocx_flutter/list_widget.dart';
// import 'package:blocx_flutter/form_widget.dart';
```

---

## Lists

Widgets and base classes to build high‑quality, infinite, searchable **collections** (lists or grids) with minimal boilerplate.

### `CollectionWidget<P>`

`CollectionWidget<P>` is the abstract base for building a **collection screen**. It accepts an optional **payload** of type `P` for passing contextual parameters (filters, route args, parent entity IDs, etc.).

```dart
import 'package:flutter/cupertino.dart';

abstract class CollectionWidget<P> extends StatefulWidget {
  final P? payload;
  const CollectionWidget({super.key, this.payload});
}
```

- **What is `P`?** A freeform **payload type**. Use it to provide extra context to your collection (e.g., `{ categoryId: 'books' }`, a simple `int`, or a richer object).
- **What is the `payload`?** The **value** of type `P` you pass when constructing your widget. It’s available in your `State` and often forwarded into your bloc/use cases.

### `CollectionWidgetState<W extends CollectionWidget<P>, T extends BaseEntity, P>`

The state base class provides batteries-included wiring to a `ListBloc<T, P>` so you don’t hand-roll pagination, search, selection, or scrolling.

**Key members (commonly available):**

- `bloc` — the `ListBloc<T, P>` managing data, paging, search, selection, refresh.
- `scrollController` — the controller used for lazy loading and programmatic scroll.
- `state` — the current `ListState<T>` (items, loading flags, selection/highlight/expand sets).
- Convenience getters: `items`, `hasReachedEnd`, `isLoadingNextPage`, `isRefreshing`, `isSearching`.

**Helper methods that make life easy:**

- `refreshData()` — reload current page (pull-to-refresh behavior).
- `loadNextPage()` — trigger **infinite scroll** load.
- `scrollToItem(T item, {duration, curve})` — animate to a known item.
- `insertItem(T item, {int? at})` / `replaceItem(T item)` / `removeItem(T item)` — safe list mutations.
- `canSelect` / `selectItem(T)` / `deselectItem(T)` / `toggleSelection(T)` — selection helpers.
- `canHighlight` / `highlightItem(T)` / `unhighlightItem(T)` — highlight helpers.
- `canExpand` / `expandItem(T)` / `collapseItem(T)` — expandable row helpers.

> These helpers wrap the correct bloc events and state updates so you avoid ad‑hoc lists of flags, indices, and timers.

**When to override methods:**

- `initState()` — set up controllers, start initial loads, listen to extra streams.
- `didUpdateWidget(oldWidget)` — react to changed `payload` or external filters.
- `dispose()` — clean up controllers/subscriptions.
- `build(BuildContext)` — compose your screen (app bar, search field, body).
- `buildItem(BuildContext, T item, int index)` *(if provided by your base)* — render a single row/tile.
- `buildCollection(BuildContext, List<T> items)` *(if provided)* — render a list/grid; by default may delegate to an infinite-list builder.

> If your base exposes both `buildItem` **and** `buildCollection`, override **`buildItem`** for simple, uniform rows; override **`buildCollection`** when you need custom layouts (grids, sections, slivers).

### `BlocxCollectionWidget<T, P>`

A **ready-to-use** collection widget. Provide an `itemBuilder` and it handles:

- initial load, infinite scroll, pull-to-refresh
- empty/error/loading states
- optional separators/headers/footers
- safe mutations (insert/replace/remove)
- selection/highlight/expand helpers (if your bloc has those mixins)

Typical usage:

```dart
BlocxCollectionWidget<Todo, void>(
  itemBuilder: (context, item, index) => ListTile(title: Text(item.title)),
  onBottomReached: (state) => state.loadNextPage(),
  onRefresh: (state) => state.refreshData(),
);
```

### `BlocxSearchField<T, P>`

A text field that **wires directly to your list bloc’s search** mixin. It debounces keystrokes and emits the correct events:

- `ListEventSearch<T>(searchText: ...)`
- `ListEventClearSearch<T>()` when cleared

Customizable with controller, `hintText`, debounce, and decoration. Drop it into your app bar or header; no manual subscription required.

```dart
BlocxSearchField<Todo, void>(
  hintText: 'Search todos…',
  // controller: myController, // optional
);
```

### Example: Todos list with search, selection, and helpers

Below is a compact, end-to-end example that demonstrates how the widgets and helper methods reduce boilerplate.

```dart
// 1) Entity
class Todo extends BaseEntity {
  @override
  final String id;
  final String title;
  const Todo({required this.id, required this.title});
}

// 2) Use cases (pseudo-impl)
class FetchTodos extends PaginationUseCase<Todo, void> {
  final TodoRepo repo;
  FetchTodos({required this.repo, required super.loadCount, required super.offset});
  @override
  Future<UseCaseResult<Page<Todo>>> perform() async =>
      successResult(await repo.fetch(limit: loadCount, offset: offset));
}
class SearchTodos extends SearchUseCase<Todo> {
  final TodoRepo repo;
  SearchTodos({required this.repo, required super.searchText, required super.loadCount, required super.offset});
  @override
  Future<UseCaseResult<Page<Todo>>> perform() async =>
      successResult(await repo.search(q: searchText, limit: loadCount, offset: offset));
}

// 3) Bloc (compose desired features)
class TodosBloc extends ListBloc<Todo, void>
    with
        ListBlocDataMixin<Todo, void>,
        InfiniteListBlocMixin<Todo, void>,
        SearchableListBlocMixin<Todo, void>,
        RefreshableListBlocMixin<Todo, void>,
        SelectableListBlocMixin<Todo, void> {
  final TodoRepo repo;
  TodosBloc({required this.repo, required ScreenManagerCubit screen}) : super(screen, InfiniteListBloc()) {
    initDataMixin(); initInfiniteList(); initSearchable(); initRefresh(); initSelectable();
    add(ListEventLoadInitialPage<Todo, void>());
  }
  @override
  PaginationUseCase<Todo, void>? get loadInitialPageUseCase => FetchTodos(repo: repo, loadCount: 20, offset: 0);
  @override
  PaginationUseCase<Todo, void>? get loadNextPageUseCase => FetchTodos(repo: repo, loadCount: 20, offset: list.length);
  @override
  PaginationUseCase<Todo, void>? get refreshPageUseCase => FetchTodos(repo: repo, loadCount: list.length, offset: 0);
  @override
  SearchUseCase<Todo>? searchUseCase(String q, {int? loadCount, int? offset}) =>
      SearchTodos(repo: repo, searchText: q, loadCount: loadCount ?? 20, offset: offset ?? 0);
}

// 4) UI — search + ready-made collection widget
class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenManagerCubit();
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScreenManagerCubit>.value(value: screen),
        BlocProvider(create: (_) => TodosBloc(repo: context.read<TodoRepo>(), screen: screen)),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocxSearchField<Todo, void>(hintText: 'Search todos…'),
            ),
          ),
        ),
        body: BlocxCollectionWidget<Todo, void>(
          itemBuilder: (context, item, index) => ListTile(
            title: Text(item.title),
            onTap: () => context.read<TodosBloc>().add(ListEventSelectItem<Todo>(item: item)),
          ),
          onBottomReached: (s) => s.loadNextPage(), // helper
          onRefresh: (s) => s.refreshData(),       // helper
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final bloc = context.read<TodosBloc>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => bloc.add(ListEventRefreshData<Todo>()),
                  label: const Text('Reload'),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  onPressed: () {
                    final first = bloc.state.list.firstOrNull;
                    if (first != null) {
                      // programmatic scroll with helper
                      // (via CollectionWidgetState.scrollToItem)
                    }
                  },
                  label: const Text('Scroll to 1st'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

**Why it’s easier:** You don’t write your own paging flags, debouncers, or scroll listeners. The bloc mixins encapsulate behavior, and the `BlocxCollectionWidget` + `BlocxSearchField` emit the right events and handle edge-cases (empty, loading, end-of-list). Helper methods like `refreshData()` and `loadNextPage()` keep UI code tiny.

---

## Forms

Widgets that pair a `FormBloc` (from `blocx_core`) with ready-made inputs.

### Quickstart

```dart
class RegisterForm extends FormWidget<void> {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends FormWidgetState<RegisterForm, Map<String, dynamic>, void, FormFieldKey> {
  _RegisterFormState() : super(bloc: RegisterFormBloc());

  @override
  Widget buildForm(BuildContext context, FormBlocState<Map<String, dynamic>, FormFieldKey> state) {
    return Column(
      children: [
        BlocXFormTextField<Map<String, dynamic>, void, FormFieldKey>(
          bloc: bloc,
          fieldKey: FormFieldKey.email,
          labelText: 'Email',
        ),
        const SizedBox(height: 12),
        BlocXFormCheckbox<Map<String, dynamic>, void, FormFieldKey>(
          bloc: bloc,
          fieldKey: FormFieldKey.terms,
          label: const Text('I accept the Terms'),
        ),
        const SizedBox(height: 16),
        FormButtonRow(
          onSubmit: () => bloc.submit(),   // helper
          onCancel: () => bloc.reset(),    // helper
        ),
      ],
    );
  }
}

enum FormFieldKey { email, terms }
```

**What you get out of the box:** validation wiring, unified submit/reset, consistent error surfacing via `ScreenManagerCubit`, and inputs that read/write form state directly.

---

## Example app

A full example lives in `blocx_flutter/example`. Run:

```sh
flutter pub get
flutter run
```

---

## Contributing

- Keep public APIs documented with dartdoc.
- Add widget tests for collection & form widgets.
- Run `flutter analyze` and `flutter test` before PRs.

---

## License

Same license as the root of this repository.
