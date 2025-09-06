import 'package:blocx_flutter/src/widgets/collection/collection_options.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';

class AnimatedSliverInfiniteListOptions extends CollectionOptions {
  final bool reverse;
  final EdgeInsets? padding;
  final ScrollPhysics? scrollPhysics;
  final int loadMoreTriggerItemDistance;

  final bool initialAnimation;
  final Duration insertDuration;
  final Duration deleteDuration;
  final AnimatedChildBuilder? insertAnimation;
  final AnimatedChildBuilder? deleteAnimation;

  const AnimatedSliverInfiniteListOptions({
    this.reverse = false,
    this.padding,
    this.scrollPhysics,
    this.loadMoreTriggerItemDistance = 2,
    this.initialAnimation = true,
    this.insertDuration = const Duration(milliseconds: 300),
    this.deleteDuration = const Duration(milliseconds: 300),
    this.insertAnimation,
    this.deleteAnimation,
  }) : super.defaults();

  factory AnimatedSliverInfiniteListOptions.defaultOptions() => const AnimatedSliverInfiniteListOptions();

  AnimatedSliverInfiniteListOptions copyWith({
    bool? reverse,
    EdgeInsets? padding,
    ScrollPhysics? scrollPhysics,
    int? bottomLoadingTriggerItemDistance,
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
      loadMoreTriggerItemDistance: bottomLoadingTriggerItemDistance ?? loadMoreTriggerItemDistance,
      initialAnimation: initialAnimation ?? this.initialAnimation,
      insertDuration: insertDuration ?? this.insertDuration,
      deleteDuration: deleteDuration ?? this.deleteDuration,
      insertAnimation: insertAnimation ?? this.insertAnimation,
      deleteAnimation: deleteAnimation ?? this.deleteAnimation,
    );
  }
}
