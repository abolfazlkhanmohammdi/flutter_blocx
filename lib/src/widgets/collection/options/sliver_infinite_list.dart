import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class SliverInfiniteListOptions extends ListOptions {
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final SemanticIndexCallback? semanticIndexCallback;
  final int semanticIndexOffset;

  const SliverInfiniteListOptions({
    super.scrollBehavior,
    super.reverse,
    super.shrinkWrap,
    super.padding,
    super.loadMoreTriggerItemDistance,
    super.scrollPhysics,
    super.scrollDirection,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  SliverInfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? addAutomaticKeepAlives,
    bool? addRepaintBoundaries,
    bool? addSemanticIndexes,
    SemanticIndexCallback? semanticIndexCallback,
    int? semanticIndexOffset,
  }) {
    return SliverInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
              this.loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      addAutomaticKeepAlives:
          addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
      semanticIndexCallback:
          semanticIndexCallback ?? this.semanticIndexCallback,
      semanticIndexOffset: semanticIndexOffset ?? this.semanticIndexOffset,
    );
  }
}
