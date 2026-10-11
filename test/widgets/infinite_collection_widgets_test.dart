import 'package:blocx_core/collection_bloc.dart' show BlocxInfiniteListBloc;
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../helpers/fake_collection_bloc.dart';

void main() {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  final items = List.generate(
    3,
    (i) => TestItemEntity(id: '$i', title: 'Item $i'),
  );

  group(
    'U-C.2: AutoScrollTag wrapping on trigger item across all 6 collection widgets',
    () {
      testWidgets(
        'InfiniteList wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: InfiniteList<TestItemEntity>(
                    options: const InfiniteListOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    isRefreshable: false,
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );

      testWidgets(
        'SliverInfiniteList wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: SliverInfiniteList<TestItemEntity>(
                    options: const SliverInfiniteListOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loading: const SizedBox(),
                    empty: const SizedBox(),
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );

      testWidgets(
        'InfiniteGrid wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: InfiniteGrid<TestItemEntity>(
                    options: const InfiniteGridOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                      crossAxisCount: 2,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );

      testWidgets(
        'SliverInfiniteGrid wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: SliverInfiniteGrid<TestItemEntity>(
                    options: const SliverInfiniteGridOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                      crossAxisCount: 2,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );

      testWidgets(
        'AnimatedInfiniteList wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: AnimatedInfiniteList<TestItemEntity>(
                    options: const AnimatedInfiniteListOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    isRefreshable: false,
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );

      testWidgets(
        'AnimatedSliverInfiniteList wraps trigger item with AutoScrollTag and scrolls',
        (tester) async {
          final controller = AutoScrollController();
          final infiniteBloc = BlocxInfiniteListBloc();
          const triggerDistance = 1;
          final triggerIndex = items.length - triggerDistance; // 2

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: AnimatedSliverInfiniteList<TestItemEntity>(
                    options: const AnimatedSliverInfiniteListOptions(
                      loadMoreTriggerItemDistance: triggerDistance,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loading: const SizedBox(),
                    empty: const SizedBox(),
                    scrollController: controller,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(controller.tagMap.containsKey(triggerIndex), isTrue);
          final scrollFuture = controller.scrollToIndex(triggerIndex);
          await tester.pumpAndSettle();
          await scrollFuture;
        },
      );
    },
  );

  group(
    'U-C.3: No stale state in visibility callbacks across all 6 collection widgets',
    () {
      final info = VisibilityInfo(
        key: const Key('test'),
        size: const Size(200, 50),
        visibleBounds: const Rect.fromLTWH(0, 0, 200, 50),
      );

      testWidgets(
        'InfiniteList: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: InfiniteList<TestItemEntity>(
                    options: const InfiniteListOptions(
                      loadMoreTriggerItemDistance: 1,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    isRefreshable: false,
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester.state<InfiniteListWidgetState<TestItemEntity>>(
            find.byType(InfiniteList<TestItemEntity>),
          );

          // Change state after build: isLoadingMore = true
          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, state.bloc.state);
          expect(loadCount, equals(0));

          // Reset loading, change state after build: hasReachedEnd = true
          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, state.bloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );

      testWidgets(
        'SliverInfiniteList: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: SliverInfiniteList<TestItemEntity>(
                    options: const SliverInfiniteListOptions(
                      loadMoreTriggerItemDistance: 1,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loading: const SizedBox(),
                    empty: const SizedBox(),
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester
              .state<SliverBlocxInfiniteListState<TestItemEntity>>(
                find.byType(SliverInfiniteList<TestItemEntity>),
              );

          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(loadCount, equals(0));

          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );

      testWidgets(
        'InfiniteGrid: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: InfiniteGrid<TestItemEntity>(
                    options: const InfiniteGridOptions(
                      loadMoreTriggerItemDistance: 1,
                      crossAxisCount: 2,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester.state<InfiniteGridState<TestItemEntity>>(
            find.byType(InfiniteGrid<TestItemEntity>),
          );

          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(loadCount, equals(0));

          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );

      testWidgets(
        'SliverInfiniteGrid: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: SliverInfiniteGrid<TestItemEntity>(
                    options: const SliverInfiniteGridOptions(
                      loadMoreTriggerItemDistance: 1,
                      crossAxisCount: 2,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester.state<SliverInfiniteGridState<TestItemEntity>>(
            find.byType(SliverInfiniteGrid<TestItemEntity>),
          );

          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(loadCount, equals(0));

          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );

      testWidgets(
        'AnimatedInfiniteList: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: AnimatedInfiniteList<TestItemEntity>(
                    options: const AnimatedInfiniteListOptions(
                      loadMoreTriggerItemDistance: 1,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    isRefreshable: false,
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester
              .state<AnimatedBlocxInfiniteListState<TestItemEntity>>(
                find.byType(AnimatedInfiniteList<TestItemEntity>),
              );

          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(loadCount, equals(0));

          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );

      testWidgets(
        'AnimatedSliverInfiniteList: loadBottomData is not called when isLoadingMore or hasReachedEnd set after build',
        (tester) async {
          var loadCount = 0;
          final infiniteBloc = BlocxInfiniteListBloc();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 400,
                  child: AnimatedSliverInfiniteList<TestItemEntity>(
                    options: const AnimatedSliverInfiniteListOptions(
                      loadMoreTriggerItemDistance: 1,
                    ),
                    items: items,
                    itemBuilder: (context, item) =>
                        SizedBox(height: 50, child: Text(item.title)),
                    bloc: infiniteBloc,
                    loading: const SizedBox(),
                    empty: const SizedBox(),
                    loadBottomData: () => loadCount++,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          loadCount = 0;

          final state = tester
              .state<AnimatedSliverBlocxInfiniteListState<TestItemEntity>>(
                find.byType(AnimatedSliverInfiniteList<TestItemEntity>),
              );

          infiniteBloc.setLoadingBottomStatus(true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(loadCount, equals(0));

          infiniteBloc.setLoadingBottomStatus(false, true);
          await tester.pump();
          state.onVisibilityChanged(info, infiniteBloc.state);
          expect(
            loadCount,
            equals(0),
            reason: 'loadBottomData called when hasReachedEnd is true',
          );
        },
      );
    },
  );
}
