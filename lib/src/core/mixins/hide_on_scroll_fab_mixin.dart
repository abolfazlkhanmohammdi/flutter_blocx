import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin HideOnScrollFabMixin<T> {
  final Duration _duration = Duration(milliseconds: 500);

  StreamController<bool> scrollDirectionController = StreamController.broadcast();
  bool onScrollNotification(UserScrollNotification notification) {
    ScrollDirection direction = notification.direction;
    if (direction == ScrollDirection.idle) return true;
    bool newState = direction != ScrollDirection.reverse;
    scrollDirectionController.add(newState);
    return false;
  }

  Widget getFloatingActionButton(BuildContext context, {T? data, bool displayFab = true}) {
    return StreamBuilder(
      stream: scrollDirectionController.stream,
      builder: (context, snapshot) => _builder(context, snapshot, data, displayFab),
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<bool> snapshot, T? data, bool displayFab) {
    bool isScrollingUp = snapshot.hasData ? snapshot.data! : true;
    if (!displayFab) {
      return SizedBox(width: 0, height: 0);
    }
    var dir = Directionality.of(context);
    bool isRtl = dir == TextDirection.rtl;
    return AnimatedSlide(
      duration: _duration,
      offset: isScrollingUp ? Offset.zero : Offset(isRtl ? -2 : 2, 0),
      child: AnimatedOpacity(
        opacity: isScrollingUp ? 1 : 0,
        duration: _duration,
        child: displayFab
            ? FloatingActionButton(
                onPressed: () => onFabPressed(data),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(120)),
                child: Icon(Icons.add),
              )
            : SizedBox(width: 0, height: 0),
      ),
    );
  }

  void onFabPressed(T? data);
}
