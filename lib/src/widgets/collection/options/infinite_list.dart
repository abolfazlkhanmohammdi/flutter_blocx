import 'package:blocx_flutter/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class InfiniteListOptions extends CollectionOptions {
  final bool reverse;
  final EdgeInsets? padding;
  final int loadMoreTriggerItemDistance;
  final AlwaysScrollableScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const InfiniteListOptions({
    this.reverse = false,
    this.padding,
    this.loadMoreTriggerItemDistance = 2,
    this.scrollPhysics,
    this.shrinkWrap = false,
  });

  factory InfiniteListOptions.defaultOptions() => const InfiniteListOptions();

  InfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    int? bottomLoadingTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
  }) {
    return InfiniteListOptions(
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      loadMoreTriggerItemDistance: bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
