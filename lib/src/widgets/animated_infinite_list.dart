import 'package:blocx/blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedInfiniteList<Entity extends BaseEntity> extends StatefulWidget {
  final AnimatedInfiniteListOptions options;
  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;
  final InfiniteListBloc bloc;
  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;
  final List<Entity> items;
  const AnimatedInfiniteList({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    this.separatorBuilder,
    this.deleteAnimation,
    this.insertAnimation,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
  });

  @override
  AnimatedInfiniteListState createState() => AnimatedInfiniteListState<Entity>();
}

class AnimatedInfiniteListState<Entity extends BaseEntity> extends State<AnimatedInfiniteList<Entity>> {
  InfiniteListBloc get bloc => widget.bloc;
  AnimatedInfiniteListOptions get options => widget.options;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<InfiniteListBloc, InfiniteListState>(
        listener: blocListener,
        bloc: widget.bloc,
        buildWhen: (_, c) => c.shouldRebuild,
        builder: (BuildContext context, InfiniteListState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              swipeRefreshWidget(context, state),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: onScroll,
                  child: Listener(
                    onPointerDown: (d) =>
                        bloc.add(InfiniteListEventVerticalDragStarted(globalY: d.position.dy)),
                    onPointerUp: maySwipe ? (d) => bloc.add(InfiniteListEventVerticalDragEnded()) : null,
                    onPointerMove: maySwipe
                        ? (d) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: d.position.dy))
                        : null,
                    onPointerCancel: maySwipe
                        ? (_) => bloc.add(InfiniteListEventVerticalDragUpdated(globalY: null))
                        : null,
                    child: ImplicitlyAnimatedList<Entity>(
                      initialAnimation: options.animateAtStart,
                      physics: options.scrollPhysics,
                      itemData: widget.items,
                      shrinkWrap: options.shrinkWrap,
                      padding: options.padding,
                      insertAnimation: widget.insertAnimation ?? _defaultAnimation,
                      deleteAnimation: widget.deleteAnimation ?? _defaultAnimation,
                      itemBuilder: (c, i) => _itemBuilder(c, i, state),
                      itemEquality: (BaseEntity f, BaseEntity s) => f.identifier == s.identifier,
                    ),
                  ),
                ),
              ),
              loadBottomWidget(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _defaultAnimation(BuildContext context, Widget child, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: _driveDefaultAnimation(animation),
      child: FadeTransition(opacity: _driveDefaultAnimation(animation), child: child),
    );
  }

  Animation<double> _driveDefaultAnimation(Animation<double> parent) {
    return CurvedAnimation(
      parent: parent,
      curve: Curves.easeInOutQuad,
    ).drive(Tween<double>(begin: 0, end: 1));
  }

  bool get maySwipe {
    final cond1 = bloc.state.isAtTop;
    final cond2 = bloc.state.isScrollingUp;
    final cond3 = !bloc.state.isRefreshing;
    final cond4 = widget.refreshOnSwipe != null;
    final result = cond1 && cond2 && cond3 && cond4;
    return result;
  }

  Widget _itemBuilder(BuildContext context, Entity data, InfiniteListState state) {
    int index = widget.items.indexOf(data);
    bool isBottomLoadingTrigger =
        index == (widget.items.length - options.bottomLoadingTriggerItemDistance) && !state.hasReachedEnd;
    bool isTopLoadingTrigger = options.topLoadingTriggerItemDistance == index;
    var itemWidget = widget.itemBuilder(context, data);
    if (isTopLoadingTrigger || isBottomLoadingTrigger && !state.hasReachedEnd) {
      var keyEnum = isTopLoadingTrigger
          ? EnumInfiniteListKey.topLoadingTrigger
          : EnumInfiniteListKey.bottomLoadingTrigger;
      return VisibilityDetector(
        key: Key(keyEnum.name),
        onVisibilityChanged: (c) => onVisibilityChanged(keyEnum, c, state),
        child: itemWidget,
      );
    }
    return itemWidget;
  }

  void onVisibilityChanged(EnumInfiniteListKey key, VisibilityInfo c, InfiniteListState state) {
    if (c.visibleFraction < 0.5) return;
    switch (key) {
      case EnumInfiniteListKey.topLoadingTrigger:
        manageTopLoading();
      case EnumInfiniteListKey.bottomLoadingTrigger:
        manageBottomLoading(state);
    }
  }

  void manageTopLoading() {
    if (bloc.state.isLoadingTop || widget.loadTopData == null || !bloc.state.isScrollingUp) return;
    bloc.setLoadingTopStatus(true);
    widget.loadTopData!();
  }

  void manageBottomLoading(InfiniteListState state) {
    if (state.isLoadingBottom || widget.loadBottomData == null || state.isScrollingUp) return;
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!();
  }

  bool onScroll(UserScrollNotification notification) {
    bool isIdle = notification.direction == ScrollDirection.idle;
    bool isScrollingUp = !isIdle && notification.direction == ScrollDirection.forward;
    bool isAtTop = notification.metrics.pixels < 40;
    bool isAtBottom = notification.metrics.pixels == notification.metrics.maxScrollExtent;
    bloc.add(
      InfiniteListEventOnScroll(
        isAtTop: isAtTop,
        isScrollingUp: isScrollingUp,
        isAtBottom: isAtBottom,
        isIdle: isIdle,
      ),
    );
    return false;
  }

  Widget loadBottomWidget(BuildContext context, InfiniteListState state) {
    var colorsScheme = Theme.of(context).colorScheme;
    var primaryColor = Theme.of(context).colorScheme.primary;
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: state.isLoadingBottom
          ? Container(
              padding: EdgeInsets.all(16),
              color: primaryColor,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: colorsScheme.onPrimary),
                ),
              ),
            )
          : SizedBox(),
    );
  }

  Widget swipeRefreshWidget(BuildContext context, InfiniteListState state) {
    var primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: primaryColor,
      height: state.swipeRefreshHeight,
      child: Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  void blocListener(BuildContext context, InfiniteListState state) {
    if (state is InfiniteListStateRefresh) {
      widget.refreshOnSwipe!();
    }
  }
}

enum EnumInfiniteListKey { topLoadingTrigger, bottomLoadingTrigger }

class AnimatedInfiniteListOptions {
  final bool reverse;
  final bool animateAtStart;
  final EdgeInsets? padding;
  final Duration? animationDuration;
  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;
  final int topLoadingTriggerItemDistance;
  final int bottomLoadingTriggerItemDistance;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const AnimatedInfiniteListOptions({
    this.reverse = false,
    this.animateAtStart = true,
    this.padding,
    this.animationDuration,
    this.deleteAnimation,
    this.insertAnimation,
    this.topLoadingTriggerItemDistance = 2,
    this.bottomLoadingTriggerItemDistance = 2,
    this.scrollPhysics,
    this.shrinkWrap = false,
  });

  /// default options
  factory AnimatedInfiniteListOptions.defaultOptions() => const AnimatedInfiniteListOptions();

  /// copyWith to selectively override fields
  AnimatedInfiniteListOptions copyWith({
    bool? reverse,
    bool? animateAtStart,
    EdgeInsets? padding,
    Duration? animationDuration,
    AnimatedChildBuilder? deleteAnimation,
    AnimatedChildBuilder? insertAnimation,
    bool Function(Object first, Object second)? itemEquality,
    int? topLoadingTriggerItemDistance,
    int? bottomLoadingTriggerItemDistance,
    ScrollPhysics? scrollPhysics,
    bool? shrinkWrap,
  }) {
    return AnimatedInfiniteListOptions(
      reverse: reverse ?? this.reverse,
      animateAtStart: animateAtStart ?? this.animateAtStart,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      deleteAnimation: deleteAnimation ?? this.deleteAnimation,
      insertAnimation: insertAnimation ?? this.insertAnimation,
      topLoadingTriggerItemDistance: topLoadingTriggerItemDistance ?? this.topLoadingTriggerItemDistance,
      bottomLoadingTriggerItemDistance:
          bottomLoadingTriggerItemDistance ?? this.bottomLoadingTriggerItemDistance,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }
}
