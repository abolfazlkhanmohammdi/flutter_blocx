import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class InfiniteGridOptions extends CollectionOptions {
  /// If [gridDelegateBuilder] is not provided, these are used to build a
  /// `SliverGridDelegateWithFixedCrossAxisCount`.
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  final bool reverse;
  final EdgeInsets? padding;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  /// Number of items from the end at which to trigger load-more.
  final int loadMoreTriggerItemDistance;

  const InfiniteGridOptions({
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.reverse = false,
    this.padding,
    this.scrollPhysics,
    this.shrinkWrap = false,
    this.loadMoreTriggerItemDistance = 2,
  });

  factory InfiniteGridOptions.defaultOptions() => const InfiniteGridOptions();

  InfiniteGridOptions copyWith({
    int? crossAxisCount,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    bool? reverse,
    EdgeInsets? padding,
    ScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
    int? loadMoreTriggerItemDistance,
  }) {
    return InfiniteGridOptions(
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      loadMoreTriggerItemDistance: loadMoreTriggerItemDistance ?? this.loadMoreTriggerItemDistance,
    );
  }
}
