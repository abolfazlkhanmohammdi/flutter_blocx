import 'package:flutter_blocx/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';

class AnimatedSliverInfiniteListOptions extends ListOptions {
  final bool initialAnimation;
  final Duration insertDuration;
  final Duration deleteDuration;
  final AnimatedChildBuilder? insertAnimation;
  final AnimatedChildBuilder? deleteAnimation;

  const AnimatedSliverInfiniteListOptions({
    super.scrollBehavior,
    super.shrinkWrap,
    super.reverse,
    super.padding,
    super.scrollPhysics,
    super.loadMoreTriggerItemDistance,
    super.scrollDirection,
    this.initialAnimation = true,
    this.insertDuration = const Duration(milliseconds: 300),
    this.deleteDuration = const Duration(milliseconds: 300),
    this.insertAnimation,
    this.deleteAnimation,
  });

  AnimatedSliverInfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    AlwaysScrollableScrollPhysics? scrollPhysics,
    int? bottomLoadingTriggerItemDistance, // legacy alias
    int? loadMoreTriggerItemDistance,
    bool? initialAnimation,
    Duration? insertDuration,
    Duration? deleteDuration,
    AnimatedChildBuilder? insertAnimation,
    AnimatedChildBuilder? deleteAnimation,
  }) {
    return AnimatedSliverInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      padding: padding ?? this.padding,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      loadMoreTriggerItemDistance:
          (bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance) ??
              this.loadMoreTriggerItemDistance,
      initialAnimation: initialAnimation ?? this.initialAnimation,
      insertDuration: insertDuration ?? this.insertDuration,
      deleteDuration: deleteDuration ?? this.deleteDuration,
      insertAnimation: insertAnimation ?? this.insertAnimation,
      deleteAnimation: deleteAnimation ?? this.deleteAnimation,
    );
  }
}
