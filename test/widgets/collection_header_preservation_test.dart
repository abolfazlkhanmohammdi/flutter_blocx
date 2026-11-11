import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../flutter_blocx_test.dart';

class _SearchableHeaderCollectionBloc
    extends BlocxCollectionBloc<BlocxTestEntity, void>
    with
        BlocxCollectionRefreshableMixin<BlocxTestEntity, void>,
        BlocxCollectionSearchableMixin<BlocxTestEntity, void> {
  final FakePaginatedUseCase<BlocxTestEntity> pageUseCase;
  final FakeSearchUseCase<BlocxTestEntity> searchUseCase;

  _SearchableHeaderCollectionBloc({
    required this.pageUseCase,
    required this.searchUseCase,
  }) : super();

  @override
  Duration get searchDebounceDuration => Duration.zero;

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, BlocxTestEntity>
  get paginationTask => createFakePaginatedTask(useCase: pageUseCase);

  @override
  BlocxPaginatedUseCaseTask<BlocxSearchInput, BlocxTestEntity>
  get searchUseCaseTask =>
      BlocxPaginatedUseCaseTask<BlocxSearchInput, BlocxTestEntity>(
        useCase: searchUseCase,
        inputBuilder: (offset, limit) => BlocxSearchInput(
          searchText: searchText,
          offset: offset,
          limit: limit,
        ),
      );
}

class _HeaderPreservationScreen extends BlocxCollectionWidget<void> {
  final bool preserveTopOnEmpty;
  final bool preserveTopOnError;
  final bool preserveBottomOnEmpty;
  final bool preserveBottomOnError;

  const _HeaderPreservationScreen({
    super.bloc,
    this.preserveTopOnEmpty = true,
    this.preserveTopOnError = true,
    this.preserveBottomOnEmpty = true,
    this.preserveBottomOnError = true,
  });

  @override
  State<_HeaderPreservationScreen> createState() =>
      _HeaderPreservationScreenState();
}

class _HeaderPreservationScreenState
    extends
        BlocxCollectionWidgetState<
          _HeaderPreservationScreen,
          BlocxTestEntity,
          void
        > {
  @override
  bool get preserveTopWidgetOnEmpty => widget.preserveTopOnEmpty;

  @override
  bool get preserveTopWidgetOnError => widget.preserveTopOnError;

  @override
  bool get preserveBottomWidgetOnEmpty => widget.preserveBottomOnEmpty;

  @override
  bool get preserveBottomWidgetOnError => widget.preserveBottomOnError;

  @override
  CollectionSettings get settings => CollectionSettings(
    type: CollectionWidgetStateType.list,
    options: const InfiniteListOptions(),
  );

  @override
  Widget? topWidget(
    BuildContext context,
    BlocxCollectionState<BlocxTestEntity> state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [const Text('FILTER_HEADER'), searchField()],
    );
  }

  @override
  Widget? bottomWidget(
    BuildContext context,
    BlocxCollectionState<BlocxTestEntity> state,
  ) {
    return const Text('FOOTER_BAR');
  }

  @override
  Widget itemBuilder(BuildContext context, BlocxTestEntity item) {
    return ListTile(title: Text(item.name));
  }
}

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('Header & footer preservation on empty and inline error states', () {
    testWidgets(
      'BlocxCollectionWidgetState keeps topWidget, focused searchField, and bottomWidget mounted on empty and error states, and retry dispatches BlocxCollectionEventRetryLastLoad',
      (tester) async {
        final source = FakePaginatedSource<BlocxTestEntity>([
          const BlocxTestEntity(id: '1', name: 'Alpha Watch'),
          const BlocxTestEntity(id: '2', name: 'Beta Clock'),
        ]);
        final pageUseCase = FakePaginatedUseCase(source: source);
        final searchUseCase = FakeSearchUseCase<BlocxTestEntity>(
          source: source,
          matcher: (item, query) => item.name.toLowerCase().contains(query),
        );
        final bloc = _SearchableHeaderCollectionBloc(
          pageUseCase: pageUseCase,
          searchUseCase: searchUseCase,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: _HeaderPreservationScreen(bloc: bloc)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('FILTER_HEADER'), findsOneWidget);
        expect(find.text('FOOTER_BAR'), findsOneWidget);
        expect(find.text('Alpha Watch'), findsOneWidget);

        // Focus search field and enter query yielding empty results.
        await tester.tap(find.blocxSearchField());
        await tester.enterText(find.blocxSearchField(), 'nomatch');
        await tester.pumpAndSettle();

        // Empty state is shown, while header, search input text, focus, and footer stay intact.
        expect(find.text('Empty'), findsOneWidget);
        expect(find.text('FILTER_HEADER'), findsOneWidget);
        expect(find.text('FOOTER_BAR'), findsOneWidget);
        final searchEditable = tester.widget<EditableText>(
          find.descendant(
            of: find.blocxSearchField(),
            matching: find.byType(EditableText),
          ),
        );
        expect(searchEditable.controller.text, equals('nomatch'));
        expect(searchEditable.focusNode.hasFocus, isTrue);

        // Next search fails -> inline error renders while header, searchField, and footer persist.
        searchUseCase.shouldFail = true;
        await tester.enterText(find.blocxSearchField(), 'alpha');
        await tester.pumpAndSettle();

        expect(find.byType(BlocxErrorWidget), findsOneWidget);
        expect(find.text('FILTER_HEADER'), findsOneWidget);
        expect(find.text('FOOTER_BAR'), findsOneWidget);
        expect(searchEditable.controller.text, equals('alpha'));
        expect(searchUseCase.recordedInputs.last.searchText, equals('alpha'));

        // Retry with fixed backend -> BlocxCollectionEventRetryLastLoad preserves search query "alpha"!
        searchUseCase.shouldFail = false;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();

        expect(find.byType(BlocxErrorWidget), findsNothing);
        expect(find.text('Alpha Watch'), findsOneWidget);
        expect(find.text('Beta Clock'), findsNothing);
        expect(searchUseCase.recordedInputs.last.searchText, equals('alpha'));

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets(
      'BlocxCollectionWidgetState respects preserveTopWidgetOnEmpty/Error and preserveBottomWidgetOnEmpty/Error when false',
      (tester) async {
        final source = FakePaginatedSource<BlocxTestEntity>(const []);
        final pageUseCase = FakePaginatedUseCase(source: source);
        final searchUseCase = FakeSearchUseCase<BlocxTestEntity>(
          source: source,
        );
        final bloc = _SearchableHeaderCollectionBloc(
          pageUseCase: pageUseCase,
          searchUseCase: searchUseCase,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _HeaderPreservationScreen(
                bloc: bloc,
                preserveTopOnEmpty: false,
                preserveTopOnError: false,
                preserveBottomOnEmpty: false,
                preserveBottomOnError: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Empty list with preserve flags false hides top & bottom widgets.
        expect(find.text('Empty'), findsOneWidget);
        expect(find.text('FILTER_HEADER'), findsNothing);
        expect(find.text('FOOTER_BAR'), findsNothing);

        // Trigger initial load failure -> hides top & bottom widgets cleanly.
        pageUseCase.shouldFail = true;
        bloc.add(
          BlocxCollectionEventLoadInitialPage<BlocxTestEntity, void>(
            payload: null,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BlocxErrorWidget), findsOneWidget);
        expect(find.text('FILTER_HEADER'), findsNothing);
        expect(find.text('FOOTER_BAR'), findsNothing);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets(
      'BlocxCollectionView keeps topWidget and bottomWidget across loading, empty, and initialError states and supports retry',
      (tester) async {
        final source = FakePaginatedSource<BlocxTestEntity>([
          const BlocxTestEntity(id: '1', name: 'Row 1'),
        ]);
        final pageUseCase = FakePaginatedUseCase(
          source: source,
          delay: const Duration(milliseconds: 200),
          shouldFail: true,
        );
        final searchUseCase = FakeSearchUseCase<BlocxTestEntity>(
          source: source,
        );
        final bloc = _SearchableHeaderCollectionBloc(
          pageUseCase: pageUseCase,
          searchUseCase: searchUseCase,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocxCollectionView<BlocxTestEntity, void>(
                bloc: bloc,
                settings: CollectionSettings(
                  type: CollectionWidgetStateType.list,
                  options: const InfiniteListOptions(),
                ),
                topWidget: (context, state) => const Text('VIEW_TOP'),
                bottomWidget: (context, state) => const Text('VIEW_BOTTOM'),
                itemBuilder: (context, item) => Text(item.name),
              ),
            ),
          ),
        );

        // Kick off initial load -> still loading because of 200ms delay.
        bloc.add(
          BlocxCollectionEventLoadInitialPage<BlocxTestEntity, void>(
            payload: null,
          ),
        );
        await tester.pump();
        expect(find.text('VIEW_TOP'), findsOneWidget);
        expect(find.text('VIEW_BOTTOM'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Initial load fails -> inline error shown inside Expanded while VIEW_TOP & VIEW_BOTTOM persist.
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();
        expect(find.byType(BlocxErrorWidget), findsOneWidget);
        expect(find.text('VIEW_TOP'), findsOneWidget);
        expect(find.text('VIEW_BOTTOM'), findsOneWidget);

        // Tapping retry recovers and loads data.
        pageUseCase.shouldFail = false;
        await tester.tap(find.text('Try again'));
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();
        expect(find.text('Row 1'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );

    testWidgets(
      'BlocxCollectionView hides topWidget and bottomWidget on empty and error when preserve flags are false',
      (tester) async {
        final emptySource = FakePaginatedSource<BlocxTestEntity>(const []);
        final pageUseCase = FakePaginatedUseCase(source: emptySource);
        final searchUseCase = FakeSearchUseCase<BlocxTestEntity>(
          source: emptySource,
        );
        final bloc = _SearchableHeaderCollectionBloc(
          pageUseCase: pageUseCase,
          searchUseCase: searchUseCase,
        );

        bloc.add(
          BlocxCollectionEventLoadInitialPage<BlocxTestEntity, void>(
            payload: null,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocxCollectionView<BlocxTestEntity, void>(
                bloc: bloc,
                settings: CollectionSettings(
                  type: CollectionWidgetStateType.list,
                  options: const InfiniteListOptions(),
                ),
                preserveTopOnEmpty: false,
                preserveTopOnError: false,
                preserveBottomOnEmpty: false,
                preserveBottomOnError: false,
                topWidget: (context, state) => const Text('VIEW_TOP'),
                bottomWidget: (context, state) => const Text('VIEW_BOTTOM'),
                itemBuilder: (context, item) => Text(item.name),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Empty'), findsOneWidget);
        expect(find.text('VIEW_TOP'), findsNothing);
        expect(find.text('VIEW_BOTTOM'), findsNothing);

        pageUseCase.shouldFail = true;
        bloc.add(
          BlocxCollectionEventLoadInitialPage<BlocxTestEntity, void>(
            payload: null,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BlocxErrorWidget), findsOneWidget);
        expect(find.text('VIEW_TOP'), findsNothing);
        expect(find.text('VIEW_BOTTOM'), findsNothing);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      },
    );
  });
}
