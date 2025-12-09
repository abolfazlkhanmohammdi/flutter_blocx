import 'package:blocx_core/blocx_core.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocxStatefulCollectionItem<T extends BaseEntity> extends StatefulWidget {
  final T item;
  const BlocxStatefulCollectionItem({super.key, required this.item});
}

/// Base State for list rows/cards that integrate with a [ListBloc].
///
/// Usage:
/// - Your StatefulWidget should expose an `item` of type T (or override the `item` getter).
/// - Extend this State class and implement [buildContent].
///
/// This provides the same convenience helpers as the stateless version,
/// but without needing to pass `BuildContext` into each method.
abstract class BlocxCollectionItemState<W extends BlocxStatefulCollectionItem<T>, T extends BaseEntity, P>
    extends State<W> {
  /// Provide the item this row represents.
  ///
  /// Default implementation tries to read `widget.item`. If your widget uses a
  /// different field name, override this getter in your State.
  @protected
  T get item {
    return widget.item;
  }

  @override
  Widget build(BuildContext context) {
    // Fail-fast if the bloc is missing — better than a late runtime error.
    final _ = _blocOrThrow();
    return buildContent(item);
  }

  /// Render the visual representation of this item.
  @protected
  Widget buildContent(T item);

  // ---------------------------------------------------------------------------
  // Bloc access
  // ---------------------------------------------------------------------------

  @protected
  BlocxListBloc<T, P> get bloc => BlocProvider.of<BlocxListBloc<T, P>>(context);

  BlocxListBloc<T, P> _blocOrThrow() {
    try {
      return bloc;
    } catch (_) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('BlocxCollectionItemState could not find ListBloc<$T, $P> in the widget tree.'),
        ErrorDescription(
          'Ensure you wrap your list screen (or a parent widget) with '
          'BlocProvider<ListBloc<$T, $P>>.',
        ),
      ]);
    }
  }

  // ---------------------------------------------------------------------------
  // Capability guards
  // ---------------------------------------------------------------------------

  void _requireSelectable() {
    final b = bloc;
    if (!b.isSelectable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Selection is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement SelectableBlocContract<$T>. '
          'Make sure your ListBloc mixes in the selection capability.',
        ),
      ]);
    }
  }

  void _requireHighlightable() {
    final b = bloc;
    if (!b.isHighlightable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Highlight is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to mix HighlightableListBlocMixin<$T,$P>. '
          'Make sure your ListBloc mixes in the highlight capability.',
        ),
      ]);
    }
  }

  void _requireDeletable() {
    final b = bloc;
    if (!b.isDeletable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Deletion is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement DeletableListBlocContract<$T>. '
          'Make sure your ListBloc mixes in the deletable capability.',
        ),
      ]);
    }
  }

  void _requireExpandable() {
    final b = bloc;
    if (!b.isExpandable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Expansion is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement ExpandableListBlocContract<$T>. '
          'Make sure your ListBloc mixes in the expandable capability.',
        ),
      ]);
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience flags (reactive via bloc.state)
  // ---------------------------------------------------------------------------

  /// True when this item's id is present in `state.selectedItemIds`.
  bool get isSelected => bloc.state.isSelected(item);

  /// True when this item's id is present in `state.highlightedItemIds`.
  bool get isHighlighted => bloc.state.isHighlighted(item);

  /// True when this item's id is present in `state.beingRemovedItemIds`.
  bool get isBeingRemoved => bloc.state.isBeingRemoved(item);

  /// True when this item's id is present in `state.beingSelectedItemIds`.
  bool get isBeingSelected => bloc.state.isBeingSelected(item);

  /// True when this item's id is present in `state.expandedItemIds`.
  bool get isExpanded => bloc.state.isExpanded(item);

  // ---------------------------------------------------------------------------
  // Dispatch helpers (validated)
  // ---------------------------------------------------------------------------

  @protected
  void removeItem() {
    _requireDeletable();
    if (confirmBeforeDelete) {
      confirmThenDelete();
    } else {
      bloc.add(BlocxListEventRemoveItem<T>(item: item));
    }
  }

  @protected
  void selectItem() {
    _requireSelectable();
    bloc.add(BlocxListEventSelectItem<T>(item: item));
  }

  @protected
  void deselectItem() {
    _requireSelectable();
    bloc.add(BlocxListEventDeselectItem<T>(item: item));
  }

  @protected
  void toggleSelection() {
    _requireSelectable();
    isSelected ? deselectItem() : selectItem();
  }

  @protected
  void highlightItem() {
    _requireHighlightable();
    bloc.add(BlocxListEventHighlightItem<T>(item: item));
  }

  @protected
  void clearHighlightedItem() {
    _requireHighlightable();
    bloc.add(BlocxListEventClearHighlightedItem<T>(item: item));
  }

  @protected
  void toggleExpansion() {
    _requireExpandable();
    bloc.add(BlocxListEventToggleItemExpansion(item: item));
  }

  bool get confirmBeforeDelete => true;
  String? get itemName => null;

  Future<void> confirmThenDelete() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => ConfirmActionWidget(options: confirmDeleteOptions),
    );
    if (result != true) return;
    bloc.add(BlocxListEventRemoveItem(item: item));
  }

  void updateItem(T newItem) {
    bloc.add(BlocxListEventUpdateItem(item: newItem));
  }

  void insertItem(T newItem, {int index = 0}) {
    bloc.add(BlocxListEventAddItem(item: newItem, index: index));
  }

  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions();
}
