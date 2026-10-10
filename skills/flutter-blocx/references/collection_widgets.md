# Collection Screens, Lists, Grids & Items (`package:flutter_blocx/list_widget.dart`)

This reference documents every collection widget, state class, option type, search field, FAB mixin, and item card in `flutter_blocx`.

---

## 1. `BlocxCollectionWidget<Payload>` & `BlocxCollectionWidgetState<W, Entity, Payload>`

### Widget Definition
```dart
abstract class BlocxCollectionWidget<Payload> extends StatefulWidget {
  final Payload? payload;
  const BlocxCollectionWidget({super.key, this.payload});
}
```
- Use `void` or `dynamic` for `Payload` when no initial payload is passed to the screen.
- Pass `super.payload` in your subclass constructor when `Payload` is used:
  ```dart
  class OrdersScreen extends BlocxCollectionWidget<String> {
    const OrdersScreen({super.key, super.payload});

    @override
    State<OrdersScreen> createState() => _OrdersScreenState();
  }
  ```

### State Definition
```dart
abstract class BlocxCollectionWidgetState<
    W extends BlocxCollectionWidget<Payload>,
    Entity extends BlocxBaseEntity,
    Payload> extends BlocxScreenManagerState<W>
```

#### Required Overrides (2)
1. **`BlocxCollectionBloc<Entity, Payload> get generateBloc;`**
   - **Important**: Must be a **getter** (`get generateBloc => ...`), not a method.
   - Called once in `initState()`.
2. **`Widget itemBuilder(BuildContext context, Entity item);`**
   - Renders a single `Entity` item in the list or grid.

#### Built-in Properties & Lifecycle Flags
- `BlocxCollectionBloc<Entity, Payload> get bloc` — the active collection BLoC instance.
- `Payload? get payload => widget.payload;` — the initial payload passed to the widget.
- `late final TextEditingController searchController;` — created in `initState()` and disposed automatically in `dispose()`.
- `ScrollController? scrollController;` — automatically initialized to `AutoScrollController()` if `bloc.isScrollable` is `true`, or `ScrollController()` otherwise.
- `ScrollController? get scrollControllerProvider => null;` — override to supply an external `ScrollController` (when provided, `BlocxCollectionWidgetState` will not dispose it).
- `bool get loadOnInit => true;` — when `true` (default), `initState()` automatically dispatches `BlocxCollectionEventLoadInitialPage<Entity, Payload>(payload: widget.payload)`.
- `bool get autoDisposeBloc => true;` — when `true` (default), `dispose()` closes `bloc`.
- `bool get isLoading => bloc.state is BlocxCollectionStateLoading;`
- `bool get isSearching => bloc.state.isSearching;`
- `String get searchingText => 'Searching data, please wait';`

#### Layout & UI Customization Overrides
- `Widget? topWidget(BuildContext context, BlocxCollectionState<Entity> state) => null;`
  - Displayed above the list/grid inside the outer `Column`. Ideal for `searchField(...)`, filter chips, or summary banners.
- `Widget? bottomWidget(BuildContext context, BlocxCollectionState<Entity> state) => null;`
  - Displayed below the list/grid inside the outer `Column`. Ideal for bulk selection toolbars or action footers.
- `double get topBottomAndListSpacing => 8.0;`
  - Vertical spacing inserted between `topWidget`, the collection widget, and `bottomWidget`.
- `Widget? sliverTopWidget(BuildContext context, BlocxCollectionState<Entity> state) => null;`
  - Sliver widget (e.g. `SliverAppBar` or `SliverToBoxAdapter`) placed at the top of `sliverList` or `animatedSliverList`.
- `Widget? sliverBottomWidget(BuildContext context, BlocxCollectionState<Entity> state) => null;`
  - Sliver widget placed at the bottom of `sliverList` or `animatedSliverList`.
- `Widget loadingWidget(BuildContext context, BlocxCollectionState<Entity> state)`
  - Rendered when `isLoading || isSearching` is true. Defaults to a centered `CircularProgressIndicator` + `state.isSearching ? searchingText : loc.loadingText`.
- `Widget emptyWidget(BuildContext context, BlocxCollectionState<Entity> state)`
  - Rendered when `!isLoading && state.list.isEmpty`. Defaults to an icon + `loc.emptyListText`.
- `Widget collectionErrorWidget(BuildContext context, BlocxCollectionStateError<Entity> state)`
  - Rendered when initial page load fails (`state is BlocxCollectionStateError<Entity>`). Defaults to a centered `BlocxErrorWidget` with a retry callback triggering `refreshData()`. Override to present a custom error and retry screen.
- `Widget separatorBuilder(BuildContext context, int index) => const SizedBox.shrink();`
  - Separator between items in `list`, `animatedList`, `sliverList`, and `animatedSliverList`.
- `Widget? loadMoreWidgetBuilder(BuildContext context, bool isLoadingMore) => null;`
  - Custom bottom pagination indicator (return `null` to use default indicator).
- `Widget? refreshWidgetBuilder(BuildContext context, double swipeRefreshHeight) => null;`
  - Custom pull-to-refresh indicator (return `null` to use default indicator).
- `AnimatedChildBuilder? get insertAnimation => null;`
- `AnimatedChildBuilder? get deleteAnimation => null;`
  - Custom item insert/delete transition builders (`Widget Function(BuildContext context, Widget child, Animation<double> animation)`) for `animatedList`.

#### Built-in Action & Helper Methods
- `BlocxSearchField<Entity, Payload> searchField({BlocxSearchFieldOptions? options})`
  - Builds a `BlocxSearchField` wired to `searchController` and `bloc`.
- `void search(String text)`
  - Dispatches `BlocxCollectionEventSearch<Entity>(searchText: text)`.
- `void setFilter<Filter>(Filter filter)`
  - Dispatches `BlocxCollectionEventFilter<Entity, Filter>(filter: filter)`.
- `void refreshData()`
  - Dispatches `BlocxCollectionEventRefreshData<Entity>()`.
- `void loadNextPage()`
  - Dispatches `BlocxCollectionEventLoadNextPage<Entity>()`.
- `void addToList(Entity item, {int index = 0})`
  - Dispatches `BlocxCollectionEventAddItem<Entity>(item: item, index: index)`.
- `void deleteMultipleItems(List<Entity> items)`
  - Dispatches `BlocxCollectionEventRemoveMultipleItems<Entity>(items: items)`.
- `void deselectMultipleItems(List<Entity> items)`
  - Dispatches `BlocxCollectionEventDeselectMultipleItems<Entity>(items: items)`.
- `void scrollToItem(Entity item, {bool highlightItem = false})`
  - Requires `bloc` to mix in `BlocxCollectionScrollableMixin<Entity, Payload>`. Dispatches `BlocxCollectionEventScrollToItem<Entity>(item: item, highlightItem: highlightItem)`, scrolls `AutoScrollController` to the item's index, and dispatches `BlocxCollectionEventHighlightScrolledToItems()` when scrolling finishes.
- `void onSelectionChanged(BuildContext context, SelectionChangedData<Entity> selectionData) {}`
  - Called automatically when `BlocxCollectionStateSelectionChanged<Entity>` is emitted.
- `void blocListener(BuildContext context, BlocxCollectionState<Entity> state)`
  - Override to react to listen-only collection states (call `super.blocListener(context, state)` to keep `onSelectionChanged` working).

---

## 2. `CollectionSettings`, `CollectionWidgetStateType` & `CollectionOptions`

Override `CollectionSettings get settings` in `BlocxCollectionWidgetState` to configure how the collection renders:

```dart
@override
CollectionSettings get settings => CollectionSettings(
  type: CollectionWidgetStateType.grid,
  options: const InfiniteGridOptions(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    padding: EdgeInsets.all(16),
  ),
);
```

> **Important**: `CollectionSettings(...)` has a non-`const` constructor. Each `CollectionWidgetStateType` requires its exact corresponding `CollectionOptions` subclass:

| `CollectionWidgetStateType` | Required `options` Class | Key Constructor Parameters |
| :--- | :--- | :--- |
| `CollectionWidgetStateType.list` | `InfiniteListOptions` | `padding`, `reverse = false`, `shrinkWrap = false`, `scrollDirection = Axis.vertical`, `scrollPhysics`, `scrollBehavior`, `loadMoreTriggerItemDistance = 2` |
| `CollectionWidgetStateType.animatedList` *(default)* | `AnimatedInfiniteListOptions` | All `ListOptions` params + `animateAtStart = false`, `animationDuration` |
| `CollectionWidgetStateType.sliverList` | `SliverInfiniteListOptions` | All `ListOptions` params + `addAutomaticKeepAlives = true`, `addRepaintBoundaries = true`, `addSemanticIndexes = true`, `semanticIndexCallback`, `semanticIndexOffset = 0` |
| `CollectionWidgetStateType.animatedSliverList` | `AnimatedSliverInfiniteListOptions` | All `ListOptions` params + `initialAnimation = true`, `insertDuration = const Duration(milliseconds: 300)`, `deleteDuration = const Duration(milliseconds: 300)`, `insertAnimation`, `deleteAnimation` |
| `CollectionWidgetStateType.grid` | `InfiniteGridOptions` | **`required int crossAxisCount`**, `childAspectRatio = 1.0`, `mainAxisSpacing = 0.0`, `crossAxisSpacing = 0.0`, `padding`, `reverse = false`, `shrinkWrap = false`, `scrollDirection = Axis.vertical`, `scrollPhysics`, `loadMoreTriggerItemDistance = 2` |
| `CollectionWidgetStateType.sliverGrid` | `SliverInfiniteGridOptions` | **`required int crossAxisCount`**, `childAspectRatio = 1.0`, `mainAxisSpacing = 0.0`, `crossAxisSpacing = 0.0`, `gridPadding`, `primary`, `cacheExtent`, `anchor = 0.0`, `clipBehavior = Clip.hardEdge`, `keyboardDismissBehavior`, `addAutomaticKeepAlives = true`, `addRepaintBoundaries = true`, `addSemanticIndexes = true` |

All 6 option classes also provide a `.copyWith(...)` method.

> **Pagination Triggering & Scroll Fallback**:
> In addition to item-visibility detection via `loadMoreTriggerItemDistance` (default: 2 items from end), `InfiniteList` and `SliverInfiniteList` monitor scroll notifications with a 150px threshold from the bottom edge (`notification.metrics.extentAfter < 150`). This provides a seamless fallback for rapid scrolling, variable item heights, or small datasets, while debouncing duplicate triggers during active gestures.

---

## 3. `BlocxSearchField<Entity, Payload>` & `BlocxSearchFieldOptions`

Prefer calling `searchField(options: ...)` inside `BlocxCollectionWidgetState`, or construct `BlocxSearchField<Entity, Payload>` directly:

```dart
BlocxSearchField<ProductEntity, void>(
  controller: searchController,
  bloc: bloc,
  options: const BlocxSearchFieldOptions(
    hintText: 'Search products...',
    hintStyle: null,
    prefixIcon: Icon(Icons.search),
    showClearButton: true,
    autofocus: false,
    obscureText: false,
    maxLines: 1,
    minLines: null,
    keyboardType: TextInputType.text,
    textCapitalization: TextCapitalization.none,
    textInputAction: TextInputAction.search,
    textAlign: TextAlign.start,
    style: null,
    decoration: null,
  ),
)
```
- Typing (`onChanged` / `onSubmitted`) dispatches `BlocxCollectionEventSearch<Entity>(searchText: text)`.
- Tapping the clear button clears `controller` and dispatches `BlocxCollectionEventClearSearch<Entity>()`.

---

## 4. `HideOnScrollFabMixin<T>`

Mix `HideOnScrollFabMixin<T>` into a `BlocxCollectionWidgetState` (or any `State`) to render a FloatingActionButton that smoothly slides and fades out when scrolling down, and reappears when scrolling up:

```dart
class _NotesScreenState
    extends BlocxCollectionWidgetState<NotesScreen, NoteEntity, void>
    with HideOnScrollFabMixin<void> {
  @override
  bool get wrapInScaffold => true;

  @override
  Widget scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: NotificationListener<UserScrollNotification>(
        onNotification: onScrollNotification,
        child: body,
      ),
      floatingActionButton: getFloatingActionButton(
        context,
        displayFab: true,
      ),
    );
  }

  @override
  void onFabPressed(void data) {
    // Handle FAB tap
  }
  // ...
}
```
- **Members provided by `HideOnScrollFabMixin<T>`**:
  - `bool onScrollNotification(UserScrollNotification notification)` — pass to `NotificationListener<UserScrollNotification>.onNotification`.
  - `Widget getFloatingActionButton(BuildContext context, {T? data, bool displayFab = true})` — pass to `Scaffold.floatingActionButton`.
  - `void onFabPressed(T? data)` — abstract callback invoked when the FAB is tapped.

---

## 5. `BlocxCollectionItem<T, P>` (Stateless Item Widget)

`BlocxCollectionItem<T extends BlocxBaseEntity, P>` is the base class for stateless row/card widgets inside a collection. It requires an ancestor `BlocProvider<BlocxCollectionBloc<T, P>>` (automatically provided by `BlocxCollectionWidgetState`).

```dart
class OrderCard extends BlocxCollectionItem<OrderEntity, void> {
  const OrderCard({super.key, required super.item});

  @override
  bool get confirmBeforeDelete => true; // default is true

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
        title: 'Delete Order #${item.id}?',
        question: 'This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Keep',
      );

  @override
  Widget buildContent(BuildContext context, OrderEntity item) {
    return Card(
      color: isHighlighted(context)
          ? colorScheme(context).tertiaryContainer
          : isSelected(context)
              ? colorScheme(context).primaryContainer
              : null,
      child: Column(
        children: [
          ListTile(
            onTap: () => toggleExpansion(context),
            onLongPress: () => toggleSelection(context),
            title: Text(item.title),
            trailing: isBeingRemoved(context)
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => removeItem(context),
                  ),
          ),
          if (isExpanded(context))
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(item.details),
            ),
        ],
      ),
    );
  }
}
```

### Reactive State Getters on `BlocxCollectionItem<T, P>` (require `BuildContext context`)
- `BlocxCollectionBloc<T, P> bloc(BuildContext context)`
- `int index(BuildContext context)` — returns the item index via `state.indexOfId(item.identifier)` (resolved by identifier rather than reference equality). `InfiniteList` and `SliverInfiniteList` build delegates pass the item index directly, avoiding $O(n^2)$ searches during list construction.
- `bool isSelected(BuildContext context)`
- `bool isHighlighted(BuildContext context)`
- `bool isBeingRemoved(BuildContext context)`
- `bool isBeingSelected(BuildContext context)`
- `bool isExpanded(BuildContext context)`
- `bool areAllSelected(BuildContext context)`

### Validated Dispatch Helpers on `BlocxCollectionItem<T, P>` (require `BuildContext context`)
- `void removeItem(BuildContext context)` — checks `bloc.isDeletable`. If `confirmBeforeDelete` is `true` (default), opens `ConfirmActionWidget` bottom sheet with `confirmDeleteOptions` before calling `onDeleteConfirmed(context)`. Set `bool get confirmBeforeDelete => false;` for immediate deletion.
- `Future<void> confirmThenDelete(BuildContext context, {ConfirmActionOptions? confirmDeleteOptions})`
- `void onDeleteConfirmed(BuildContext context)`
- `void selectItem(BuildContext context)` / `void deselectItem(BuildContext context)` / `void toggleSelection(BuildContext context)` — checks `bloc.isSelectable`.
- `void toggleAllItemsSelection(BuildContext context)` / `void toggleMultipleItemsSelection(BuildContext context, List<T> selectionTargetItems, bool areAlreadySelected)`
- `void highlightItem(BuildContext context)` / `void clearHighlightedItem(BuildContext context)` — checks `bloc.isHighlightable`.
- `void toggleExpansion(BuildContext context)` — checks `bloc.isExpandable`.
- `void updateItem(BuildContext context, T item)` — dispatches `BlocxCollectionEventUpdateItem(item: item)`.
- `void insertItem(BuildContext context, T item, {int index = 0})` — dispatches `BlocxCollectionEventAddItem(item: item, index: index)`.

---

## 6. `BlocxStatefulCollectionItem<T>` & `BlocxCollectionItemState<W, T, P>` (Stateful Item Widget)

Import `package:flutter_blocx/blocx_collection_item_state.dart` (or `package:flutter_blocx/flutter_blocx.dart`) when a collection item needs local `State` (e.g. `AnimationController`, hover state, local `TextEditingController`).

```dart
class EditableOrderCard extends BlocxStatefulCollectionItem<OrderEntity> {
  const EditableOrderCard({super.key, required super.item});

  @override
  State<EditableOrderCard> createState() => _EditableOrderCardState();
}

class _EditableOrderCardState
    extends BlocxCollectionItemState<EditableOrderCard, OrderEntity, void> {
  @override
  bool get confirmBeforeDelete => false;

  @override
  Widget buildContent(OrderEntity item) {
    // Note: buildContent(T item) and all helpers on BlocxCollectionItemState
    // do NOT take BuildContext as a parameter!
    return ListTile(
      selected: isSelected,
      title: Text(item.title),
      onTap: toggleSelection,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: isBeingRemoved ? null : removeItem,
      ),
    );
  }
}
```

### Key Difference from `BlocxCollectionItem`: No `BuildContext` Parameter & Extends `BlocXWidgetState<W>`!
In `BlocxCollectionItemState<W, T, P>`:
- Override `Widget buildContent(T item);` (**1** parameter: `T item`, no `BuildContext`).
- Reactive flags are **getters**: `isSelected`, `isHighlighted`, `isBeingRemoved`, `isBeingSelected`, `isExpanded`, `bloc`, `item`.
- Dispatch helpers take **no `BuildContext`**: `removeItem()`, `selectItem()`, `deselectItem()`, `toggleSelection()`, `highlightItem()`, `clearHighlightedItem()`, `toggleExpansion()`, `updateItem(newItem)`, `insertItem(newItem, index: 0)`.
- Because `BlocxCollectionItemState<W, T, P>` extends `BlocXWidgetState<W>`, it also exposes `theme`, `textTheme`, `colorScheme`, `width`, and `height` getters directly without passing `BuildContext`.
