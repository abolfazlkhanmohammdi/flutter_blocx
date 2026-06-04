import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class AnimatedInfiniteListOptions extends ListOptions {
  final bool animateAtStart;
  final Duration?
      animationDuration; // reserved, not directly used by ImplicitlyAnimatedList

  const AnimatedInfiniteListOptions({
    super.scrollBehavior,
    super.reverse,
    this.animateAtStart = false,
    super.padding,
    this.animationDuration,
    super.loadMoreTriggerItemDistance,
    super.scrollPhysics,
    super.shrinkWrap,
    super.scrollDirection,
  });

  AnimatedInfiniteListOptions copyWith({
    bool? reverse,
    bool? animateAtStart,
    EdgeInsets? padding,
    Duration? animationDuration,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
  }) {
    return AnimatedInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      animateAtStart: animateAtStart ?? this.animateAtStart,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
              this.loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
