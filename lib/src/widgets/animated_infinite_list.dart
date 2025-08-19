import 'package:blocx/blocx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedInfiniteList<Entity extends ListEntity<Entity>> extends StatefulWidget {
  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool reverse;
  final bool animateAtStart;
  final EdgeInsets? padding;
  final List<Entity> items;
  final Duration? animationDuration;
  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;
  final bool Function(Entity first, Entity second)? itemEquality;
  final int topLoadingTriggerItemDistance;
  final int bottomLoadingTriggerItemDistance;
  final InfiniteListBloc bloc;
  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;
  const AnimatedInfiniteList({
    super.key,
    required this.itemBuilder,
    required this.items,
    required this.bloc,
    this.scrollPhysics,
    this.reverse = false,
    this.separatorBuilder,
    this.padding,
    this.itemEquality,
    this.deleteAnimation,
    this.animationDuration,
    this.insertAnimation,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.shrinkWrap = false,
    this.topLoadingTriggerItemDistance = 3,
    this.bottomLoadingTriggerItemDistance = 5,
    this.animateAtStart = true,
  });

  @override
  AnimatedInfiniteListState createState() => AnimatedInfiniteListState<Entity>();
}

class AnimatedInfiniteListState<Entity extends ListEntity<Entity>>
    extends State<AnimatedInfiniteList<Entity>> {
  InfiniteListBloc get bloc => widget.bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<InfiniteListBloc, InfiniteListBlocState>(
        listener: blocListener,
        bloc: widget.bloc,
        buildWhen: (_, c) => c.shouldRebuild,
        builder: (BuildContext context, InfiniteListBlocState state) {
          debugPrint("height is: ${state.swipeRefreshHeight}");
          return Column(
            children: [
              swipeRefreshWidget(context, state),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: onScroll,
                  child: Listener(
                    onPointerDown: maySwipe
                        ? (d) => bloc.add(InfiniteListBlocEventVerticalDragStarted(globalY: d.position.dy))
                        : null,
                    onPointerUp: maySwipe ? (d) => bloc.add(InfiniteListBlocEventVerticalDragEnded()) : null,
                    onPointerMove: maySwipe
                        ? (d) => bloc.add(InfiniteListBlocEventVerticalDragUpdated(globalY: d.position.dy))
                        : null,
                    onPointerCancel: maySwipe
                        ? (_) => bloc.add(InfiniteListBlocEventVerticalDragUpdated(globalY: null))
                        : null,
                    child: ImplicitlyAnimatedList<Entity>(
                      initialAnimation: widget.animateAtStart,
                      physics: widget.scrollPhysics,
                      itemData: widget.items,
                      shrinkWrap: widget.shrinkWrap,
                      padding: widget.padding,
                      insertAnimation: widget.insertAnimation ?? _defaultAnimation,
                      deleteAnimation: widget.deleteAnimation ?? _defaultAnimation,
                      itemBuilder: (c, i) => _itemBuilder(c, i, state),
                      itemEquality:
                          widget.itemEquality ?? (ListEntity f, ListEntity s) => f.identifier == s.identifier,
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

  bool get maySwipe =>
      (bloc.state.isAtTop &&
      bloc.state.isScrollingUp &&
      !bloc.state.isRefreshing &&
      widget.refreshOnSwipe != null);

  Widget _itemBuilder(BuildContext context, Entity data, InfiniteListBlocState state) {
    int index = widget.items.indexOf(data);
    bool isBottomLoadingTrigger =
        index == (widget.items.length - widget.bottomLoadingTriggerItemDistance) && !state.hasReachedEnd;
    bool isTopLoadingTrigger = widget.topLoadingTriggerItemDistance == index;
    var itemWidget = widget.itemBuilder(context, data);
    if (isTopLoadingTrigger || isBottomLoadingTrigger) {
      var keyEnum = isTopLoadingTrigger
          ? EnumInfiniteListKey.topLoadingTrigger
          : EnumInfiniteListKey.bottomLoadingTrigger;
      return Card(
        color: Colors.red,
        child: VisibilityDetector(
          key: Key(keyEnum.name),
          onVisibilityChanged: (c) => onVisibilityChanged(keyEnum, c, state),
          child: itemWidget,
        ),
      );
    }
    return itemWidget;
  }

  void onVisibilityChanged(EnumInfiniteListKey key, VisibilityInfo c, InfiniteListBlocState state) {
    if (c.visibleFraction < 1) return;
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

  void manageBottomLoading(InfiniteListBlocState state) {
    if (state.isLoadingBottom || widget.loadBottomData == null || state.isScrollingUp) return;
    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!();
  }

  bool onScroll(UserScrollNotification notification) {
    bool isIdle = notification.direction == ScrollDirection.idle;
    var pixels = notification.metrics.pixels;
    bool isScrollingUp = !isIdle && notification.direction == ScrollDirection.forward;
    bool isAtTop = notification.metrics.pixels == 0;
    bool isAtBottom = notification.metrics.pixels == notification.metrics.maxScrollExtent;
    bloc.add(
      InfiniteListBlocEventOnScroll(
        isAtTop: isAtTop,
        isScrollingUp: isScrollingUp,
        isAtBottom: isAtBottom,
        isIdle: isIdle,
      ),
    );
    return false;
  }

  Widget loadBottomWidget(BuildContext context, InfiniteListBlocState state) {
    var primaryColor = Theme.of(context).colorScheme.primary;
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: state.isLoadingBottom
          ? Container(
              color: primaryColor,
              child: Center(
                child: Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            )
          : SizedBox(),
    );
  }

  Widget swipeRefreshWidget(BuildContext context, InfiniteListBlocState state) {
    var primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: primaryColor,
      height: state.swipeRefreshHeight,
      child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  void blocListener(BuildContext context, InfiniteListBlocState state) {
    if (state is InfiniteListBlocStateRefresh) {
      widget.refreshOnSwipe!();
    }
  }
}

enum EnumInfiniteListKey { topLoadingTrigger, bottomLoadingTrigger }
