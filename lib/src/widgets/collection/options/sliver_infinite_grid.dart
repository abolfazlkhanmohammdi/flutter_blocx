import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class SliverInfiniteGridOptions extends GridOptions {
  /// --------- CustomScrollView inputs ----------
  final bool? primary;
  final double? cacheExtent;
  final double anchor;
  final Clip clipBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Padding applied *around* the grid sliver.
  final EdgeInsets? gridPadding;

  /// --------- Grid semantic & keep-alive ----------
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final SemanticIndexCallback? semanticIndexCallback;
  final int semanticIndexOffset;

  const SliverInfiniteGridOptions({
    super.scrollBehavior,
    super.shrinkWrap,
    super.reverse,
    super.scrollPhysics,
    super.loadMoreTriggerItemDistance,
    required super.crossAxisCount,
    super.childAspectRatio,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.scrollDirection,
    this.primary,
    this.cacheExtent,
    this.anchor = 0.0,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.gridPadding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  SliverInfiniteGridOptions copyWith({
    bool? reverse,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    int? crossAxisCount,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    Axis? scrollDirection,
    bool? primary,
    double? cacheExtent,
    double? anchor,
    Clip? clipBehavior,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    EdgeInsets? gridPadding,
    bool? addAutomaticKeepAlives,
    bool? addRepaintBoundaries,
    bool? addSemanticIndexes,
    SemanticIndexCallback? semanticIndexCallback,
    int? semanticIndexOffset,
  }) {
    return SliverInfiniteGridOptions(
      reverse: reverse ?? this.reverse,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
          this.loadMoreTriggerItemDistance,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      primary: primary ?? this.primary,
      cacheExtent: cacheExtent ?? this.cacheExtent,
      anchor: anchor ?? this.anchor,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior ?? this.keyboardDismissBehavior,
      gridPadding: gridPadding ?? this.gridPadding,
      addAutomaticKeepAlives: addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
      semanticIndexCallback: semanticIndexCallback ?? this.semanticIndexCallback,
      semanticIndexOffset: semanticIndexOffset ?? this.semanticIndexOffset,
    );
  }
}
