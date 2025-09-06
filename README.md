<p align="center">
  <img src="https://raw.githubusercontent.com/abolfazlkhanmohammdi/flutter_blocx/main/assets/pub/logo.png" height="300" alt="flutter_blocx" />
</p>

## Installing

Use this package as a library in your Flutter app.

### Depend on it

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_blocx: ^0.5.7-beta
```

Or add via the command line:

**With Flutter:**

```sh
flutter pub add flutter_blocx
```

**With Dart:**

```sh
dart pub add flutter_blocx
```

### Import it

```dart
import 'package:flutter_blocx/flutter_blocx.dart';
// or import specific entry points:
// import 'package:flutter_blocx/list_widget.dart';
// import 'package:flutter_blocx/form_widget.dart';
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
class UserCard extends BlocxCollectionWidget<User,dynamic>{
    @override
    Widget buildContent(BuildContext context, User item) {
      // implement your item ui with ready data item
    }
}
```

### `BlocxSearchField<T, P>`

A text field that **wires directly to your list bloc’s search** mixin. It debounces keystrokes and emits the correct events:

- `ListEventSearch<T>(searchText: ...)`
- `ListEventClearSearch<T>()` when cleared

Customizable with controller, `hintText`, debounce, and decoration. Drop it into your app bar or header; no manual subscription required.

```dart
BlocxSearchField<User, dynamic>(
  hintText: 'Search Users…',
  // controller: myController, // optional
);
```

### Example: Users list with search, selection, and helpers

Below is a compact, end-to-end example that demonstrates how the widgets and helper methods reduce boilerplate.

```dart
import 'dart:convert';
import 'package:blocx_core/blocx_core.dart';
class User extends BaseEntity {
  final int id; // unique stable id
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String get identifier => id.toString();

  User copyWith({
    int? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'avatarUrl': avatarUrl,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: (map['id'] as int?) ?? -1,
    displayName: (map['displayName'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    avatarUrl: map['avatarUrl'] as String?,
    isActive: (map['isActive'] as bool?) ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory User.fromJson(String source) => User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserEntity(id:$id, name:$displayName)';

  @override
  bool operator ==(Object other) => other is User && other.id == id;
  @override
  int get hashCode => id.hashCode;
}


// 2) Use cases (pseudo-impl)
class GetUsersUseCase extends PaginationUseCase<User, dynamic> {
  GetUsersUseCase({required super.loadCount, required super.offset});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().getPaginated(offset: offset, limit: loadCount);
    if (!result.ok) {
      throw Exception("error fetching users");
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}


class SearchUsersUseCase extends SearchUseCase<User> {
  SearchUsersUseCase({required super.searchText, required super.loadCount, required super.offset});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().searchUsers(searchText, offset, loadCount);
    if (!result.ok) {
      throw Exception('Failed to search users');
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}

class DeleteUserUseCase extends BaseUseCase<bool> {
  final User user;

  DeleteUserUseCase({required this.user});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await UserJsonRepository().delete(user.id);
    return UseCaseResult.success(result.ok);
  }
}

// 3) Bloc (compose desired features)
import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/bloc/use_cases/delete_user_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/get_users_use_case.dart';
import 'package:example/src/screens/users/bloc/use_cases/search_users_use_case.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class UsersBloc extends ListBloc<User, dynamic>
    with
        InfiniteListBlocMixin<User, dynamic>,
        SearchableListBlocMixin<User, dynamic>,
        DeletableListBlocMixin<User, dynamic>,
        HighlightableListBlocMixin<User, dynamic>,
        SelectableListBlocMixin<User, dynamic> {
  UsersBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("error", "an error occurred!");
  }

  @override
  PaginationUseCase<User, dynamic>? get loadInitialPageUseCase =>
      GetUsersUseCase(loadCount: loadCount, offset: 0);

  @override
  PaginationUseCase<User, dynamic>? get loadNextPageUseCase =>
      GetUsersUseCase(loadCount: loadCount, offset: offset);

  @override
  BaseUseCase<bool>? deleteItemUseCase(User item) {
    return DeleteUserUseCase(user: item);
  }

  @override
  SearchUseCase<User>? searchUseCase(String searchText, {int? loadCount, int? offset}) {
    return SearchUsersUseCase(
      searchText: searchText,
      loadCount: loadCount ?? this.loadCount,
      offset: offset ?? 0,
    );
  }

  @override
  ErrorDisplayPolicy get errorDisplayPolicy => ErrorDisplayPolicy.page;

  @override
  bool get isSingleSelect => false;
}


// 4) UI — search + ready-made collection widget
class UsersScreen extends CollectionWidget<dynamic> {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends CollectionWidgetState<UsersScreen, User, dynamic> {
  TextEditingController searchController = TextEditingController();

  _UsersScreenState() : super(bloc: UsersBloc());

  @override
  Widget? topWidget(BuildContext context, ListState<User> state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocxSearchField<User, dynamic>(
        controller: searchController,
        options: BlocxSearchFieldOptions(),
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
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Users", style: theme.appBarTheme.titleTextStyle),
            Text("Select a user to see their note tags", style: textTheme.bodyMedium),
          ],
        ),
      ),
      body: body,
    );
  }

  @override
  CollectionInput get settings => CollectionInput(
    type: CollectionWidgetStateType.grid,
    options: InfiniteGridOptions.defaultOptions().copyWith(childAspectRatio: 0.75),
  );
}


// 5) Card widget(extends BlocxCollectionWidget)
class UserCard extends BlocxCollectionWidget<User, dynamic> {
  const UserCard({super.key, required super.item, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget buildContent(BuildContext context, User item) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final canDelete = bloc(context).isDeletable;
    final canHighlight = bloc(context).isHighlightable;

    return Card(
      color: isHighlighted(context)
          ? Colors.green.shade100
          : isBeingRemoved(context)
          ? Colors.red.shade100
          : isSelected(context)
          ? cs.primaryContainer
          : Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteTagsScreen(payload: item))),
        onLongPress: () => isSelected(context) ? deselectItem(context) : selectItem(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, box) {
              final side = box.biggest.shortestSide;
              final radius = (side * 0.22).clamp(20.0, 36.0).toDouble();

              return Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Hero(
                          tag: "user-${item.id}",
                          child: _Avatar(url: item.avatarUrl, name: item.displayName, radius: radius),
                        ),
                      ),
                      if (isSelected(context))
                        Positioned(
                          right: 0,
                          top: 0,
                          left: 0,
                          bottom: 0,

                          child: CircleAvatar(
                            backgroundColor: cs.secondary.withAlpha(160),
                            child: Icon(Icons.check_circle, size: 24, color: cs.primary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.displayName,
                    style: t.titleSmall,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: 0.75,
                      child: Text(
                        item.email,
                        style: t.bodySmall,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Center(child: _StatusPill(active: item.isActive)),
                  const SizedBox(height: 10),
                  if (onEdit != null)
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        highlightItem(context);
                        onEdit!.call();
                      },
                    ),
                  if (onEdit != null && canDelete) const SizedBox(width: 8),
                  if (canDelete)
                    FilledButton.icon(
                      icon: isBeingRemoved(context)
                          ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                          : const Icon(Icons.delete),
                      label: Text(
                        isBeingRemoved(context) ? "Deleting" : 'Delete',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isBeingRemoved(context) ? Colors.red : Colors.white,
                        ),
                      ),
                      style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                      onPressed: isBeingRemoved(context) ? null : () => removeItem(context),
                    ),
                  if (canHighlight)
                    FilledButton.icon(
                      icon: const Icon(Icons.highlight),
                      label: const Text('highlight'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                      ),
                      onPressed: () => highlightItem(context),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
    title: "Delete ${item.displayName}",
    question: "Are you sure you want to delete the user ${item.displayName}?",
    imageUrl: item.avatarUrl,
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, required this.radius});

  final String? url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.secondaryContainer;
    final fg = Theme.of(context).colorScheme.onSecondaryContainer;
    final hasUrl = (url ?? '').isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundColor: fg,
      backgroundImage: hasUrl ? NetworkImage(url!) : null,
      child: hasUrl ? null : Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final t = parts.first;
      return (t.isNotEmpty ? t.characters.take(2).toString() : '?').toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = active ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = active ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final label = active ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
        ],
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

A full example lives in `flutter_blocx/example`. Run:

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
