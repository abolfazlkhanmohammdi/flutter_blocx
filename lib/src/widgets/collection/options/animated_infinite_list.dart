import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';

class AnimatedInfiniteListOptions extends CollectionOptions{
  final bool reverse;
  final bool animateAtStart;
  final EdgeInsets? padding;
  final Duration? animationDuration; // reserved, not directly used by ImplicitlyAnimatedList
  final int loadMoreTriggerItemDistance;
  final AlwaysScrollableScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const AnimatedInfiniteListOptions({
    this.reverse = false,
    this.animateAtStart = true,
    this.padding,
    this.animationDuration,
    this.loadMoreTriggerItemDistance = 2,
    this.scrollPhysics,
    this.shrinkWrap = false,
  });

  factory AnimatedInfiniteListOptions.defaultOptions() => const AnimatedInfiniteListOptions();

  AnimatedInfiniteListOptions copyWith({
    bool? reverse,
    bool? animateAtStart,
    EdgeInsets? padding,
    Duration? animationDuration,
    int? bottomLoadingTriggerItemDistance,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
  }) {
    return AnimatedInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      animateAtStart: animateAtStart ?? this.animateAtStart,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      loadMoreTriggerItemDistance: bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
