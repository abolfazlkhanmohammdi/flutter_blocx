import 'package:blocx/blocx.dart';
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
abstract class BlocxListItem<T extends BaseEntity, P> extends StatelessWidget {
  final T item;

  const BlocxListItem({super.key, required this.item});

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
  ListBloc<T, P> bloc(BuildContext context) => BlocProvider.of<ListBloc<T, P>>(context);

  ListBloc<T, P> _blocOrThrow(BuildContext context) {
    try {
      return bloc(context);
    } catch (_) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('BlocxListItem could not find ListBloc<$T, $P> in the widget tree.'),
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
          'Make sure your ListBloc mixes in the selection capability and calls initSelectionMixin().',
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
          'Make sure your ListBloc mixes in the deletable capability and calls initDeletable().',
        ),
      ]);
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience flags
  // ---------------------------------------------------------------------------

  bool isSelected(BuildContext context) =>
      (bloc(context) as SelectableListBlocMixin<T, P>).isSelected(item.identifier);
  bool isHighlighted(BuildContext context) =>
      (bloc(context) as HighlightableListBlocMixin<T, P>).isHighlighted(item.identifier);
  bool isBeingRemoved(BuildContext context) =>
      (bloc(context) as DeletableListBlocMixin<T, P>).isBeingRemoved(item.identifier);
  bool isBeingSelected(BuildContext context) =>
      (bloc(context) as SelectableListBlocMixin<T, P>).isBeingSelected(item.identifier);

  // ---------------------------------------------------------------------------
  // Dispatch helpers (validated)
  // ---------------------------------------------------------------------------

  @protected
  void removeItem(BuildContext context) {
    _requireDeletable(context);
    bloc(context).add(ListEventRemoveItem<T>(item: item));
  }

  @protected
  void selectItem(BuildContext context) {
    _requireSelectable(context);
    bloc(context).add(ListEventSelectItem<T>(item: item));
  }

  @protected
  void deselectItem(BuildContext context) {
    _requireSelectable(context);
    // Use the exact event name your API defines (DeSelect vs Deselect).
    bloc(context).add(ListEventDeselectItem<T>(item: item));
  }

  @protected
  void highlightItem(BuildContext context) {
    _requireHighlightable(context);
    bloc(context).add(ListEventHighlightItem<T>(item: item));
  }

  @protected
  void clearHighlightedItem(BuildContext context) {
    _requireHighlightable(context);
    bloc(context).add(ListEventClearHighlightedItem<T>(item: item));
  }
}
