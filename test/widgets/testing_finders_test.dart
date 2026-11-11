import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:blocx_core/form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../flutter_blocx_test.dart';

enum _FinderFormField { name, password, role, agree, active, segment }

class _FinderFormEntity
    extends BlocxBaseFormEntity<_FinderFormEntity, _FinderFormField> {
  final String name;
  final String password;
  final String role;
  final bool agree;
  final bool active;
  final String segment;

  const _FinderFormEntity({
    this.name = '',
    this.password = '',
    this.role = 'admin',
    this.agree = false,
    this.active = false,
    this.segment = 'a',
  });

  @override
  String get identifier => 'finder-form';

  @override
  _FinderFormEntity updateByKey(_FinderFormField key, dynamic value) =>
      switch (key) {
        _FinderFormField.name => _FinderFormEntity(
          name: value as String? ?? '',
          password: password,
          role: role,
          agree: agree,
          active: active,
          segment: segment,
        ),
        _FinderFormField.password => _FinderFormEntity(
          name: name,
          password: value as String? ?? '',
          role: role,
          agree: agree,
          active: active,
          segment: segment,
        ),
        _FinderFormField.role => _FinderFormEntity(
          name: name,
          password: password,
          role: value as String? ?? 'admin',
          agree: agree,
          active: active,
          segment: segment,
        ),
        _FinderFormField.agree => _FinderFormEntity(
          name: name,
          password: password,
          role: role,
          agree: value as bool? ?? false,
          active: active,
          segment: segment,
        ),
        _FinderFormField.active => _FinderFormEntity(
          name: name,
          password: password,
          role: role,
          agree: agree,
          active: value as bool? ?? false,
          segment: segment,
        ),
        _FinderFormField.segment => _FinderFormEntity(
          name: name,
          password: password,
          role: role,
          agree: agree,
          active: active,
          segment: value as String? ?? 'a',
        ),
      };

  @override
  dynamic getValueByKey(_FinderFormField key) => switch (key) {
    _FinderFormField.name => name,
    _FinderFormField.password => password,
    _FinderFormField.role => role,
    _FinderFormField.agree => agree,
    _FinderFormField.active => active,
    _FinderFormField.segment => segment,
  };
}

class _DummySubmitUseCase extends BlocxBaseUseCase<Object?, Object?> {
  @override
  Future<BlocxUseCaseResult<Object?>> perform(Object? input) async =>
      success(null);
}

class _FinderFormBloc
    extends BlocxFormBloc<_FinderFormEntity, void, _FinderFormField> {
  _FinderFormBloc() : super(const _FinderFormEntity());

  @override
  BlocxUseCaseTask<Object?, Object?> get submitUseCaseTask =>
      BlocxUseCaseTask<Object?, Object?>(
        useCase: _DummySubmitUseCase(),
        inputBuilder: () => null,
      );
}

class _FinderFormWidget extends BlocxFormWidget<void> {
  const _FinderFormWidget({super.bloc});

  @override
  State<_FinderFormWidget> createState() => _FinderFormWidgetState();
}

class _FinderFormWidgetState
    extends
        BlocxFormWidgetState<
          _FinderFormWidget,
          _FinderFormEntity,
          void,
          _FinderFormField
        > {
  @override
  List<_FinderFormField> get keys => [
    _FinderFormField.name,
    _FinderFormField.password,
  ];

  @override
  Widget formWidget(
    BuildContext context,
    BlocxFormState<_FinderFormEntity, _FinderFormField> state,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          textField(_FinderFormField.name, labelText: 'Name'),
          passwordField(_FinderFormField.password, labelText: 'Password'),
          dropdown<String>(
            _FinderFormField.role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'user', child: Text('User')),
            ],
          ),
          checkbox(
            key: _FinderFormField.agree,
            options: const BlocxCheckboxOptions(
              isChecked: false,
              label: 'Agree',
            ),
          ),
          switchField(_FinderFormField.active, label: 'Active'),
          chipField<String>(
            _FinderFormField.role,
            options: const [BlocxChipOption(value: 'chip_a', label: 'Chip A')],
          ),
          segmentedField<String>(
            _FinderFormField.segment,
            segments: const [
              BlocxSegmentOption(value: 'a', label: 'A'),
              BlocxSegmentOption(value: 'b', label: 'B'),
            ],
          ),
          formButtonRow('Save Row', formState: state),
        ],
      ),
    );
  }
}

class _SimpleCollectionBloc extends BlocxCollectionBloc<BlocxTestEntity, void>
    with BlocxCollectionSearchableMixin<BlocxTestEntity, void> {
  final FakePaginatedSource<BlocxTestEntity> source;

  _SimpleCollectionBloc(this.source);

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, BlocxTestEntity>
  get paginationTask => createFakePaginatedTask(
    useCase: FakePaginatedUseCase<BlocxTestEntity>(source: source),
  );
}

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    BlocXLocalizations.localizations = TestLocalizations();
  });

  group('find.blocxItem across all 6 collection widgets & versioned keys', () {
    final items = createTestEntities(3, prefix: 'Entry');

    testWidgets('deduplicates versioned and AutoScrollTag keys per item', (
      tester,
    ) async {
      final infiniteBloc = BlocxInfiniteListBloc();
      final controller = AutoScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: InfiniteList<BlocxTestEntity>(
                options: const InfiniteListOptions(
                  loadMoreTriggerItemDistance: 1,
                ),
                items: items,
                bloc: infiniteBloc,
                isRefreshable: false,
                scrollController: controller,
                itemBuilder: (context, item) => ListTile(
                  key: ValueKey('${item.identifier}+v3'),
                  title: Text(item.name),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Even though AutoScrollTag wraps KeyedSubtree('blocx_item_2') wraps ListTile('2+v3'),
      // find.blocxItem('2') matches once per rendered entity!
      expect(find.blocxItem('0'), findsOneWidget);
      expect(find.blocxItem('1'), findsOneWidget);
      expect(find.blocxItem('2'), findsOneWidget);
      expect(find.blocxItem('missing'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      infiniteBloc.close();
    });

    for (final type in CollectionWidgetStateType.values) {
      testWidgets('locates items automatically in $type', (tester) async {
        final bloc = _SimpleCollectionBloc(FakePaginatedSource(items));
        bloc.add(
          BlocxCollectionEventLoadInitialPage<BlocxTestEntity, void>(
            payload: null,
          ),
        );

        final options = switch (type) {
          CollectionWidgetStateType.list => const InfiniteListOptions(),
          CollectionWidgetStateType.animatedList =>
            const AnimatedInfiniteListOptions(),
          CollectionWidgetStateType.sliverList =>
            const SliverInfiniteListOptions(),
          CollectionWidgetStateType.animatedSliverList =>
            const AnimatedSliverInfiniteListOptions(),
          CollectionWidgetStateType.grid => const InfiniteGridOptions(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
          CollectionWidgetStateType.sliverGrid =>
            const SliverInfiniteGridOptions(
              crossAxisCount: 2,
              childAspectRatio: 3,
            ),
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: BlocxCollectionView<BlocxTestEntity, void>(
                  bloc: bloc,
                  settings: CollectionSettings(type: type, options: options),
                  // Note: user itemBuilder returns a bare Text with NO manual ValueKey.
                  itemBuilder: (context, item) => Text(item.name),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.blocxItem('0'), findsOneWidget);
        expect(find.blocxItem('1'), findsOneWidget);
        expect(find.blocxItem('2'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        bloc.close();
      });
    }
  });

  group('Semantic form, filter, badge, and search finders', () {
    testWidgets(
      'locates textField, obscure toggle, dropdown, checkbox, switch, segmented, chip filter, badge, submit/cancel, and searchField',
      (tester) async {
        final formBloc = _FinderFormBloc();
        final searchController = TextEditingController();
        final collectionBloc = _SimpleCollectionBloc(FakePaginatedSource());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  BlocxSearchField<BlocxTestEntity, void>(
                    controller: searchController,
                    bloc: collectionBloc,
                  ),
                  const Text('ACTIVE', key: ValueKey('blocx_badge_active')),
                  Expanded(child: _FinderFormWidget(bloc: formBloc)),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.blocxSearchField(), findsOneWidget);
        expect(find.blocxBadge('active'), findsOneWidget);
        expect(find.blocxField(_FinderFormField.name), findsOneWidget);
        expect(find.blocxField(_FinderFormField.password), findsOneWidget);
        expect(
          find.blocxObscureToggle(_FinderFormField.password),
          findsOneWidget,
        );
        expect(find.blocxDropdown(_FinderFormField.role), findsOneWidget);
        expect(find.blocxCheckbox(_FinderFormField.agree), findsOneWidget);
        expect(find.blocxSwitch(_FinderFormField.active), findsOneWidget);
        expect(find.blocxField(_FinderFormField.segment), findsOneWidget);
        expect(find.blocxFilter('chip_a'), findsOneWidget);
        expect(find.blocxSubmitButton(), findsOneWidget);
        expect(find.blocxCancelButton(), findsOneWidget);

        // Verify blocx_core/testing.dart seeders are re-exported cleanly from package:flutter_blocx/testing.dart.
        final formSeed = BlocxFormStateSeeder.build(
          formData: const _FinderFormEntity(name: 'Seeded'),
        );
        final listSeed = BlocxCollectionStateSeeder.build(
          list: const [BlocxTestEntity(id: '9', name: 'Nine')],
        );
        expect(formSeed.formData.name, equals('Seeded'));
        expect(listSeed.list.single.identifier, equals('9'));

        await tester.pumpWidget(const SizedBox());
        searchController.dispose();
        formBloc.close();
        collectionBloc.close();
      },
    );
  });
}
