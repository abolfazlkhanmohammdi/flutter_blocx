import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class InfiniteGridOptions extends GridOptions {
  final EdgeInsets? padding;

  const InfiniteGridOptions({
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
    this.padding,
  });

  InfiniteGridOptions copyWith({
    bool? reverse,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    int? crossAxisCount,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    EdgeInsets? padding,
    bool? shrinkWrap,
  }) {
    return InfiniteGridOptions(
      reverse: reverse ?? this.reverse,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
          this.loadMoreTriggerItemDistance,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      childAspectRatio: childAspectRatio ?? this.childAspectRatio,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      padding: padding ?? this.padding,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
