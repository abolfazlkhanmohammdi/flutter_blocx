import 'package:blocx_flutter/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class SliverInfiniteGridOptions extends CollectionOptions {
  /// --------- CustomScrollView inputs ----------
  final bool reverse;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;
  final bool? primary;
  final double? cacheExtent;
  final double anchor;
  final Clip clipBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Padding applied *around* the grid sliver.
  final EdgeInsets? gridPadding;

  /// --------- SliverGrid (default delegate) inputs ----------
  /// Used only when [gridDelegateBuilder] is null.
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// Number of items from the end at which to trigger load-more.
  final int loadMoreTriggerItemDistance;

  /// SliverChildBuilderDelegate flags / semantics
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final SemanticIndexCallback? semanticIndexCallback;
  final int semanticIndexOffset;

  const SliverInfiniteGridOptions({
    // CustomScrollView
    this.reverse = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
    this.primary,
    this.cacheExtent,
    this.anchor = 0.0,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.gridPadding,

    // Default SliverGrid delegate
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,

    // Load-more trigger
    this.loadMoreTriggerItemDistance = 2,

    // Child delegate flags
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  factory SliverInfiniteGridOptions.defaultOptions() => const SliverInfiniteGridOptions();

  SliverInfiniteGridOptions copyWith({
    // CustomScrollView
    bool? reverse,
    ScrollPhysics? scrollPhysics,
    Axis? scrollDirection,
    bool? primary,
    double? cacheExtent,
    double? anchor,
    Clip? clipBehavior,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    EdgeInsets? gridPadding,

    // SliverGrid default delegate
    int? crossAxisCount,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,

    // Load-more
    int? loadMoreTriggerItemDistance,

    // Delegate flags / semantics
    bool? addAutomaticKeepAlives,
    bool? addRepaintBoundaries,
    bool? addSemanticIndexes,
    SemanticIndexCallback? semanticIndexCallback,
    int? semanticIndexOffset,
  }) {
    return SliverInfiniteGridOptions(
      reverse: reverse ?? this.reverse,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      primary: primary ?? this.primary,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      anchor: anchor ?? this.anchor,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior ?? this.keyboardDismissBehavior,
      gridPadding: gridPadding ?? this.gridPadding,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      loadMoreTriggerItemDistance: loadMoreTriggerItemDistance ?? this.loadMoreTriggerItemDistance,
      addAutomaticKeepAlives: addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
      semanticIndexCallback: semanticIndexCallback ?? this.semanticIndexCallback,
      semanticIndexOffset: semanticIndexOffset ?? this.semanticIndexOffset,
    );
  }
}
