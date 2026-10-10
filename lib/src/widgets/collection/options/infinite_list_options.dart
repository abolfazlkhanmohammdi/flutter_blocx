import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class InfiniteListOptions extends ListOptions {
  const InfiniteListOptions({
    super.scrollBehavior,
    super.reverse,
    super.padding,
    super.loadMoreTriggerItemDistance,
    super.scrollPhysics,
    super.shrinkWrap,
    super.scrollDirection,
  });

  InfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
  }) {
    return InfiniteListOptions(
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
          this.loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
