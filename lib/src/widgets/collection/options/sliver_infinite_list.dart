import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class SliverInfiniteListOptions extends CollectionOptions {
  final bool reverse;
  final EdgeInsets? padding;
  final int loadMoreTriggerItemDistance;

  final ScrollPhysics? scrollPhysics;

  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final SemanticIndexCallback? semanticIndexCallback;
  final int semanticIndexOffset;

  const SliverInfiniteListOptions({
    this.reverse = false,
    this.padding,
    this.loadMoreTriggerItemDistance = 2,
    this.scrollPhysics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback,
    this.semanticIndexOffset = 0,
  });

  factory SliverInfiniteListOptions.defaultOptions() => const SliverInfiniteListOptions();

  SliverInfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    int? bottomLoadingTriggerItemDistance,
    ScrollPhysics? scrollPhysics,
    bool? addAutomaticKeepAlives,
    bool? addRepaintBoundaries,
    bool? addSemanticIndexes,
    SemanticIndexCallback? semanticIndexCallback,
    int? semanticIndexOffset,
  }) {
    return SliverInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      loadMoreTriggerItemDistance: bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      addAutomaticKeepAlives: addAutomaticKeepAlives ?? this.addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries ?? this.addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes ?? this.addSemanticIndexes,
      semanticIndexCallback: semanticIndexCallback ?? this.semanticIndexCallback,
      semanticIndexOffset: semanticIndexOffset ?? this.semanticIndexOffset,
    );
  }
}
