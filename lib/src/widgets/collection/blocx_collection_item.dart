import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart'
    show
        BlocxCollectionBloc,
        ListStateExtensions,
        BlocxCollectionEventRemoveItem,
        BlocxCollectionEventSelectItem,
        BlocxCollectionEventDeselectItem,
        BlocxCollectionEventHighlightItem,
        BlocxCollectionEventClearHighlightedItem,
        BlocxCollectionEventToggleItemExpansion,
        BlocxCollectionEventUpdateItem,
        BlocxCollectionEventAddItem,
        BlocxCollectionEventDeselectMultipleItems,
        BlocxCollectionEventSelectMultipleItems;
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base building block for list rows/cards that integrate with a [ListBloc].
///
/// Requirements:
/// - An ancestor must provide `ListBloc<T, P>` via `BlocProvider`.
/// - Subclasses implement [buildContent] to render the item.
///
/// Provides convenience methods to dispatch common list events (remove / select / deselect /
/// highlight / clear highlight). Each method checks that the bloc supports the required
/// capability mixin before dispatching; otherwise it throws a descriptive error.
abstract class BlocxCollectionItem<T extends BlocxBaseEntity, P>
    extends BlocxStatelessWidget {
  final T item;

  const BlocxCollectionItem({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    // Fail-fast if the bloc is missing — better than a late runtime error.
    final _ = _blocOrThrow(context);
    return buildContent(context, item);
  }

  /// Render the visual representation of this item.
  @protected
  Widget buildContent(BuildContext context, T item);

  // ---------------------------------------------------------------------------
  // Bloc access
  // ---------------------------------------------------------------------------

  @protected
  BlocxCollectionBloc<T, P> bloc(BuildContext context) =>
      BlocProvider.of<BlocxCollectionBloc<T, P>>(context);

  BlocxCollectionBloc<T, P> _blocOrThrow(BuildContext context) {
    try {
      return bloc(context);
    } catch (_) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            'BlocxListItem could not find ListBloc<$T, $P> in the widget tree.'),
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

  void _requireSelectable(BuildContext context) {
    final b = bloc(context);
    if (!b.isSelectable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Selection is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement SelectableBlocContract<$T>. '
          'Make sure your ListBloc mixes in the selection capability',
        ),
      ]);
    }
  }

  void _requireHighlightable(BuildContext context) {
    final b = bloc(context);
    if (!b.isHighlightable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Highlight is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to mix HighlightableListBlocMixin<$T,$P>. '
          'Make sure your ListBloc mixes in the highlight capability',
        ),
      ]);
    }
  }

  void _requireDeletable(BuildContext context) {
    final b = bloc(context);
    if (!b.isDeletable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Deletion is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement DeletableListBlocContract<$T>. '
          'Make sure your ListBloc mixes in the deletable capability',
        ),
      ]);
    }
  }

  void _requireExpandable(BuildContext context) {
    final b = bloc(context);
    if (!b.isExpandable) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Expansion is not enabled for ListBloc<$T, $P>.'),
        ErrorDescription(
          'This action requires the bloc to implement ExpandableListBlocContract<$T>. '
          'Make sure your ListBloc mixes in the expandable capability',
        ),
      ]);
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience flags (reactive via bloc.state)
  // ---------------------------------------------------------------------------

  /// True when this item's id is present in `state.selectedItemIds`.
  bool isSelected(BuildContext context) => bloc(context).state.isSelected(item);

  /// True when this item's id is present in `state.highlightedItemIds`.
  bool isHighlighted(BuildContext context) =>
      bloc(context).state.isHighlighted(item);

  /// True when this item's id is present in `state.beingRemovedItemIds`.
  bool isBeingRemoved(BuildContext context) =>
      bloc(context).state.isBeingRemoved(item);

  /// True when this item's id is present in `state.beingSelectedItemIds`.
  bool isBeingSelected(BuildContext context) =>
      bloc(context).state.isBeingSelected(item);

  /// True when this item's id is present in `state.expandedItemIds`.
  bool isExpanded(BuildContext context) => bloc(context).state.isExpanded(item);

  // ---------------------------------------------------------------------------
  // Dispatch helpers (validated)
  // ---------------------------------------------------------------------------

  int index(BuildContext context) => bloc(context).list.indexOf(item);

  @protected
  void removeItem(BuildContext context) {
    _requireDeletable(context);
    if (confirmBeforeDelete) {
      confirmThenDelete(context);
    } else {
      bloc(context).add(BlocxCollectionEventRemoveItem<T>(item: item));
    }
  }

  @protected
  void selectItem(BuildContext context) {
    _requireSelectable(context);
    bloc(context).add(BlocxCollectionEventSelectItem<T>(item: item));
  }

  @protected
  void deselectItem(BuildContext context) {
    _requireSelectable(context);
    // Use the exact event name your API defines (DeSelect vs Deselect).
    bloc(context).add(BlocxCollectionEventDeselectItem<T>(item: item));
  }

  @protected
  void toggleSelection(BuildContext context) {
    _requireSelectable(context);
    isSelected(context) ? deselectItem(context) : selectItem(context);
  }

  @protected
  void highlightItem(BuildContext context) {
    _requireHighlightable(context);
    bloc(context).add(BlocxCollectionEventHighlightItem<T>(item: item));
  }

  @protected
  void clearHighlightedItem(BuildContext context) {
    _requireHighlightable(context);
    bloc(context).add(BlocxCollectionEventClearHighlightedItem<T>(item: item));
  }

  @protected
  void toggleExpansion(BuildContext context) {
    _requireExpandable(context);
    bloc(context).add(BlocxCollectionEventToggleItemExpansion(item: item));
  }

  bool get confirmBeforeDelete => true;
  String? get itemName => null;

  Future<void> confirmThenDelete(BuildContext context) async {
    var result = await showModalBottomSheet(
      context: context,
      builder: (_) {
        return ConfirmActionWidget(options: confirmDeleteOptions);
      },
    );
    if (result == null || !result) return;
    onDeleteConfirmed(context);
  }

  void onDeleteConfirmed(BuildContext context) {
    bloc(context).add(BlocxCollectionEventRemoveItem(item: item));
  }

  void updateItem(BuildContext context, T item) {
    bloc(context).add(BlocxCollectionEventUpdateItem(item: item));
  }

  void insertItem(BuildContext context, T item, {int index = 0}) {
    bloc(context).add(BlocxCollectionEventAddItem(item: item, index: index));
  }

  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions();

  bool areAllSelected(BuildContext context) =>
      bloc(context).state.selectedItemIds.length == bloc(context).list.length;

  void toggleAllItemsSelection(BuildContext context) {
    var blocc = bloc(context);
    blocc.add(
      areAllSelected(context)
          ? BlocxCollectionEventDeselectMultipleItems(items: blocc.list)
          : BlocxCollectionEventSelectMultipleItems(items: blocc.list),
    );
  }

  void toggleMultipleItemsSelection(
    BuildContext context,
    List<T> selectionTargetItems,
    bool areAlreadySelected,
  ) {
    var blocc = bloc(context);
    blocc.add(
      areAlreadySelected
          ? BlocxCollectionEventDeselectMultipleItems(
              items: selectionTargetItems)
          : BlocxCollectionEventSelectMultipleItems(
              items: selectionTargetItems),
    );
  }
}
