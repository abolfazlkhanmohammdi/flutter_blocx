import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx/src/widgets/collection/options/animated_infinite_list.dart';
import 'package:flutter_blocx/src/widgets/collection/options/animated_sliver_infinite_list.dart';
import 'package:flutter_blocx/src/widgets/collection/options/infinite_grid.dart';
import 'package:flutter_blocx/src/widgets/collection/options/infinite_list.dart';
import 'package:flutter_blocx/src/widgets/collection/options/sliver_infinite_grid.dart';
import 'package:flutter_blocx/src/widgets/collection/options/sliver_infinite_list.dart';

abstract class CollectionOptions {
  const CollectionOptions();
  const CollectionOptions.defaults();

  void assertCorrectType(CollectionWidgetStateType type) {
    switch (type) {
      case CollectionWidgetStateType.list:
        assert(this is InfiniteListOptions, 'Expected InfiniteListOptions not ${runtimeType.toString()}');
        break;

      case CollectionWidgetStateType.sliverList:
        assert(
          this is SliverInfiniteListOptions,
          'Expected SliverInfiniteListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.animatedList:
        assert(
          this is AnimatedInfiniteListOptions,
          'Expected AnimatedListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.animatedSliverList:
        assert(
          this is AnimatedSliverInfiniteListOptions,
          'Expected SliverAnimatedListOptions not ${runtimeType.toString()}',
        );
        break;

      case CollectionWidgetStateType.grid:
        assert(this is InfiniteGridOptions, 'Expected InfiniteGridOptions not ${runtimeType.toString()}');
        break;

      case CollectionWidgetStateType.sliverGrid:
        assert(
          this is SliverInfiniteGridOptions,
          'Expected SliverInfiniteGridOptions not ${runtimeType.toString()}',
        );
        break;
    }
  }

  void verifyOrThrow(CollectionWidgetStateType type) {
    final ok = switch (type) {
      CollectionWidgetStateType.list => this is InfiniteListOptions,
      CollectionWidgetStateType.sliverList => this is SliverInfiniteListOptions,
      CollectionWidgetStateType.animatedList => this is AnimatedInfiniteListOptions,
      CollectionWidgetStateType.animatedSliverList => this is AnimatedSliverInfiniteListOptions,
      CollectionWidgetStateType.grid => this is InfiniteGridOptions,
      CollectionWidgetStateType.sliverGrid => this is SliverInfiniteGridOptions,
    };

    if (!ok) {
      throw ArgumentError('Wrong options type for "$type". Got ${runtimeType.toString()}.');
    }
  }

  T asOrThrow<T extends CollectionOptions>() {
    if (this is! T) {
      throw ArgumentError('Expected ${T.toString()}, got ${runtimeType.toString()}.');
    }
    return this as T;
  }
}
