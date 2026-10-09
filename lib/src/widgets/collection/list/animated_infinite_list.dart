import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart'
    show
        BlocxInfiniteListBloc,
        BlocxInfiniteListEventOnScroll,
        BlocxInfiniteListEventVerticalDragEnded,
        BlocxInfiniteListEventVerticalDragStarted,
        BlocxInfiniteListEventVerticalDragUpdated,
        BlocxInfiniteListState,
        BlocxInfiniteListStateRefresh;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blocx/src/widgets/collection/options/animated_infinite_list.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedInfiniteList<Entity extends BlocxBaseEntity>
    extends StatefulWidget {
  final AnimatedInfiniteListOptions options;

  final List<Entity> items;
  final BlocxInfiniteListBloc bloc;

  final Widget Function(BuildContext context, Entity item) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  final AnimatedChildBuilder? deleteAnimation;
  final AnimatedChildBuilder? insertAnimation;

  final void Function()? loadBottomData;
  final void Function()? loadTopData;
  final void Function()? refreshOnSwipe;

  final ScrollController? scrollController;
  final Widget? Function(BuildContext context, bool isLoadingMore)?
      loadMoreWidgetBuilder;
  final Widget? Function(
    BuildContext context,
    double swipeRefreshHeight,
  )? refreshWidgetBuilder;

  final bool isRefreshable;

  const AnimatedInfiniteList({
    super.key,
    required this.options,
    required this.items,
    required this.itemBuilder,
    required this.bloc,
    required this.isRefreshable,
    this.separatorBuilder,
    this.deleteAnimation,
    this.insertAnimation,
    this.refreshOnSwipe,
    this.loadBottomData,
    this.loadTopData,
    this.scrollController,
    this.loadMoreWidgetBuilder,
    this.refreshWidgetBuilder,
  });

  @override
  AnimatedBlocxInfiniteListState<Entity> createState() =>
      AnimatedBlocxInfiniteListState<Entity>();
}

class AnimatedBlocxInfiniteListState<Entity extends BlocxBaseEntity>
    extends State<AnimatedInfiniteList<Entity>> {
  static const double _edgeTolerance = 1.0;

  late final String uuid;
  late final ScrollController scrollController;

  bool _isTrackingRefreshDrag = false;
  double? _refreshDragStartY;

  BlocxInfiniteListBloc get bloc => widget.bloc;

  AnimatedInfiniteListOptions get options => widget.options;

  @override
  void initState() {
    super.initState();

    uuid = 'AnimatedInfiniteList-${identityHashCode(this)}';
    scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocxInfiniteListBloc>.value(
      value: widget.bloc,
      child: BlocConsumer<BlocxInfiniteListBloc, BlocxInfiniteListState>(
        bloc: widget.bloc,
        listener: blocListener,
        buildWhen: (_, current) => current.shouldRebuild,
        builder: (context, state) {
          var core = _animatedList(context, state);
          core = maybeSetupRefresh(child: core);
          core = putInExpandedIfNotShrunk(
            context,
            state,
            core,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              options.reverse
                  ? loadMoreWidget(context, state)
                  : swipeRefreshWidget(context, state),
              core,
              options.reverse
                  ? swipeRefreshWidget(context, state)
                  : loadMoreWidget(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget putInExpandedIfNotShrunk(
    BuildContext context,
    BlocxInfiniteListState state,
    Widget child,
  ) {
    if (options.shrinkWrap) {
      return child;
    }

    return Expanded(child: child);
  }

  Widget maybeSetupRefresh({
    required Widget child,
  }) {
    if (!widget.isRefreshable) {
      return child;
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: onScroll,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onRefreshPointerDown,
        onPointerMove: _onRefreshPointerMove,
        onPointerUp: _onRefreshPointerUp,
        onPointerCancel: _onRefreshPointerCancel,
        child: child,
      ),
    );
  }

  void _onRefreshPointerDown(PointerDownEvent event) {
    if (!_canStartRefreshDrag) {
      _cancelLocalRefreshTracking();
      return;
    }

    _isTrackingRefreshDrag = true;
    _refreshDragStartY = event.position.dy;

    bloc.add(
      BlocxInfiniteListEventVerticalDragStarted(
        globalY: event.position.dy,
      ),
    );
  }

  void _onRefreshPointerMove(PointerMoveEvent event) {
    if (!_isTrackingRefreshDrag) {
      return;
    }

    final startY = _refreshDragStartY;

    if (startY == null) {
      _cancelLocalRefreshTracking();
      return;
    }

    final currentY = event.position.dy;

    // A normal list refreshes by pulling downward.
    // A reversed list refreshes from the opposite edge by pulling upward.
    final isMovingTowardRefreshEdge =
        options.reverse ? currentY <= startY : currentY >= startY;

    // Sending the original start coordinate collapses the indicator to zero
    // when the user moves in the wrong direction.
    final effectiveY = isMovingTowardRefreshEdge ? currentY : startY;

    bloc.add(
      BlocxInfiniteListEventVerticalDragUpdated(
        globalY: effectiveY,
      ),
    );
  }

  void _onRefreshPointerUp(PointerUpEvent event) {
    if (!_isTrackingRefreshDrag) {
      return;
    }

    _cancelLocalRefreshTracking();

    bloc.add(
      BlocxInfiniteListEventVerticalDragEnded(),
    );
  }

  void _onRefreshPointerCancel(PointerCancelEvent event) {
    if (!_isTrackingRefreshDrag) {
      return;
    }

    _cancelLocalRefreshTracking();

    // A cancelled pointer must reset the pull indicator without triggering
    // refresh.
    bloc.hideRefreshWidget();
  }

  void _cancelLocalRefreshTracking() {
    _isTrackingRefreshDrag = false;
    _refreshDragStartY = null;
  }

  bool get _canStartRefreshDrag {
    return widget.isRefreshable &&
        widget.refreshOnSwipe != null &&
        !bloc.state.isRefreshing &&
        _atRefreshEdge;
  }

  bool get _atTopByController {
    if (!scrollController.hasClients) {
      return false;
    }

    final position = scrollController.position;

    return position.pixels <= position.minScrollExtent + _edgeTolerance;
  }

  bool get _atBottomByController {
    if (!scrollController.hasClients) {
      return false;
    }

    final position = scrollController.position;

    return position.pixels >= position.maxScrollExtent - _edgeTolerance;
  }

  bool get _atRefreshEdge {
    if (scrollController.hasClients) {
      return options.reverse ? _atBottomByController : _atTopByController;
    }

    return options.reverse ? bloc.state.isAtBottom : bloc.state.isAtTop;
  }

  void onVisibilityChanged(
    VisibilityInfo visibility,
    BlocxInfiniteListState state,
  ) {
    if (visibility.visibleFraction < 0.5 ||
        state.isLoadingMore ||
        widget.loadBottomData == null ||
        state.isScrollingUp) {
      return;
    }

    bloc.setLoadingBottomStatus(true);
    widget.loadBottomData!();
  }

  bool onScroll(UserScrollNotification notification) {
    final isIdle = notification.direction == ScrollDirection.idle;
    final isAtTop = notification.metrics.extentBefore <= _edgeTolerance;
    final isAtBottom = notification.metrics.extentAfter <= _edgeTolerance;

    final bool isScrollingUp;

    if (options.reverse) {
      isScrollingUp =
          !isIdle && notification.direction == ScrollDirection.reverse;
    } else {
      isScrollingUp =
          !isIdle && notification.direction == ScrollDirection.forward;
    }

    bloc.add(
      BlocxInfiniteListEventOnScroll(
        isAtTop: isAtTop,
        isScrollingUp: isScrollingUp,
        isAtBottom: isAtBottom,
        isIdle: isIdle,
      ),
    );

    return false;
  }

  Widget loadMoreWidget(
    BuildContext context,
    BlocxInfiniteListState state,
  ) {
    final external = widget.loadMoreWidgetBuilder?.call(
      context,
      state.isLoadingMore,
    );

    if (external != null) {
      return external;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: state.isLoadingMore
          ? ColoredBox(
              color: colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget swipeRefreshWidget(
    BuildContext context,
    BlocxInfiniteListState state,
  ) {
    if (!widget.isRefreshable || state.swipeRefreshHeight <= 0) {
      return const SizedBox.shrink();
    }

    final external = widget.refreshWidgetBuilder?.call(
      context,
      state.swipeRefreshHeight,
    );

    if (external != null) {
      return external;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: SizedBox(
        height: state.swipeRefreshHeight,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  void blocListener(
    BuildContext context,
    BlocxInfiniteListState state,
  ) {
    if (state is! BlocxInfiniteListStateRefresh) {
      return;
    }

    widget.refreshOnSwipe?.call();
  }

  Widget wrapInAutoScrollTag(
    Widget itemWidget,
    Entity data,
    int index,
  ) {
    return AutoScrollTag(
      key: ValueKey(data.identifier),
      controller: scrollController as AutoScrollController,
      index: index,
      child: itemWidget,
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    Entity data,
    BlocxInfiniteListState state,
  ) {
    final index = widget.items.indexOf(data);

    final isBottomLoadingTrigger =
        index == widget.items.length - options.loadMoreTriggerItemDistance &&
            !state.hasReachedEnd;

    Widget itemWidget = widget.itemBuilder(
      context,
      data,
    );

    if (isBottomLoadingTrigger) {
      return VisibilityDetector(
        key: Key('$uuid-LoadMore'),
        onVisibilityChanged: (visibility) {
          onVisibilityChanged(
            visibility,
            state,
          );
        },
        child: itemWidget,
      );
    }

    if (scrollController is AutoScrollController) {
      itemWidget = wrapInAutoScrollTag(
        itemWidget,
        data,
        index,
      );
    }

    return itemWidget;
  }

  Widget _animatedList(
    BuildContext context,
    BlocxInfiniteListState state,
  ) {
    return ImplicitlyAnimatedList<Entity>(
      controller: scrollController,
      initialAnimation: options.animateAtStart,
      physics: options.scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
      itemData: widget.items,
      shrinkWrap: options.shrinkWrap,
      padding: options.padding,
      reverse: options.reverse,
      insertAnimation: widget.insertAnimation ?? _defaultAnimation,
      deleteAnimation: widget.deleteAnimation ?? _defaultAnimation,
      itemBuilder: (context, item) {
        return _itemBuilder(
          context,
          item,
          state,
        );
      },
      itemEquality: (
        BlocxBaseEntity first,
        BlocxBaseEntity second,
      ) {
        return first.identifier == second.identifier;
      },
    );
  }

  Widget _defaultAnimation(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    final drivenAnimation = _driveDefaultAnimation(animation);

    return SizeTransition(
      sizeFactor: drivenAnimation,
      child: FadeTransition(
        opacity: drivenAnimation,
        child: child,
      ),
    );
  }

  Animation<double> _driveDefaultAnimation(
    Animation<double> parent,
  ) {
    return CurvedAnimation(
      parent: parent,
      curve: Curves.easeInOutQuad,
    ).drive(
      Tween<double>(
        begin: 0,
        end: 1,
      ),
    );
  }
}
