import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter/material.dart';

/// Root base for all collection option types.
abstract class CollectionOptions {
  /// Shared across all collection widgets.
  final bool reverse;
  final AlwaysScrollableScrollPhysics? scrollPhysics;
  final int loadMoreTriggerItemDistance;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollBehavior? scrollBehavior;
  const CollectionOptions({
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.scrollPhysics,
    this.scrollBehavior,
    this.loadMoreTriggerItemDistance = 2,
  });

  /// Handy defaults for callers that want a zero-arg super().
  const CollectionOptions.defaults()
      : reverse = false,
        scrollPhysics = null,
        loadMoreTriggerItemDistance = 2,
        scrollDirection = Axis.vertical,
        scrollBehavior = null,
        shrinkWrap = false;

  /// Runtime safety: ensure the options instance matches the widget state type.
  void assertCorrectType(CollectionWidgetStateType type) {
    switch (type) {
      case CollectionWidgetStateType.list:
        assert(this is InfiniteListOptions,
            'Expected InfiniteListOptions not ${runtimeType.toString()}');
        break;

      case CollectionWidgetStateType.sliverList:
        assert(
          this is SliverInfiniteListOptions,
          'Expected SliverInfiniteListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.animatedList:
        assert(
          this is AnimatedInfiniteListOptions,
          'Expected AnimatedInfiniteListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.animatedSliverList:
        assert(
          this is AnimatedSliverInfiniteListOptions,
          'Expected AnimatedSliverInfiniteListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.grid:
        assert(this is InfiniteGridOptions,
            'Expected InfiniteGridOptions not ${runtimeType.toString()}');
        break;

      case CollectionWidgetStateType.sliverGrid:
        assert(
          this is SliverInfiniteGridOptions,
          'Expected SliverInfiniteGridOptions not ${runtimeType.toString()}',
        );
        break;
    }

    final ok = switch (type) {
      CollectionWidgetStateType.list => this is InfiniteListOptions,
      CollectionWidgetStateType.sliverList => this is SliverInfiniteListOptions,
      CollectionWidgetStateType.animatedList =>
        this is AnimatedInfiniteListOptions,
      CollectionWidgetStateType.animatedSliverList =>
        this is AnimatedSliverInfiniteListOptions,
      CollectionWidgetStateType.grid => this is InfiniteGridOptions,
      CollectionWidgetStateType.sliverGrid => this is SliverInfiniteGridOptions,
    };

    if (!ok) {
      throw ArgumentError(
          'Wrong options type for "$type". Got ${runtimeType.toString()}.');
    }
  }

  T asOrThrow<T extends CollectionOptions>() {
    if (this is! T) {
      throw ArgumentError(
          'Expected ${T.toString()}, got ${runtimeType.toString()}.');
    }
    return this as T;
  }
}

/// Base options for list-like widgets (ListView, SliverList, AnimatedList).
abstract class ListOptions extends CollectionOptions {
  final EdgeInsets? padding;

  const ListOptions({
    super.scrollBehavior,
    super.reverse,
    super.scrollPhysics,
    super.scrollDirection,
    super.loadMoreTriggerItemDistance,
    this.padding,
    super.shrinkWrap,
  });

  const ListOptions.defaults()
      : padding = null,
        super.defaults();
}

/// Base options for grid-like widgets (GridView, SliverGrid).
abstract class GridOptions extends CollectionOptions {
  /// Used to build the grid delegate (or consumed by sliver grid).
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const GridOptions({
    super.scrollBehavior,
    super.reverse,
    super.scrollPhysics,
    super.shrinkWrap,
    super.scrollDirection,
    super.loadMoreTriggerItemDistance,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });
}
