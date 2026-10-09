import 'package:bloc_test/bloc_test.dart';
import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';

class TestItemEntity extends BlocxBaseEntity {
  final String id;
  final String title;

  const TestItemEntity({required this.id, required this.title});

  @override
  String get identifier => id;
}

class MockCollectionBloc<E extends BlocxBaseEntity, P>
    extends MockBloc<BlocxCollectionEvent<E>, BlocxCollectionState<E>>
    implements BlocxCollectionBloc<E, P> {}

class FakeCollectionBloc extends BlocxCollectionBloc<TestItemEntity, void>
    with
        BlocxCollectionRefreshableMixin<TestItemEntity, void>,
        BlocxCollectionInfiniteMixin<TestItemEntity, void>,
        BlocxCollectionSearchableMixin<TestItemEntity, void>,
        BlocxCollectionSelectableMixin<TestItemEntity, void> {
  final List<TestItemEntity> initialItems;
  bool shouldFail;
  Object? failureError;

  FakeCollectionBloc({
    this.initialItems = const [],
    this.shouldFail = false,
    this.failureError,
  }) : super();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, TestItemEntity>?
      get paginationTask => BlocxPaginatedUseCaseTask(
            useCase: _FakePaginatedUseCase(
              initialItems,
              shouldFail: () => shouldFail,
              failureError: () => failureError,
            ),
            inputBuilder: (offset, limit) =>
                BlocxPaginatedInput(offset: offset, limit: limit),
          );
}

class _FakePaginatedUseCase
    extends BlocxPaginatedUseCase<BlocxPaginatedInput, TestItemEntity> {
  final List<TestItemEntity> items;
  final bool Function() shouldFail;
  final Object? Function() failureError;

  _FakePaginatedUseCase(
    this.items, {
    required this.shouldFail,
    required this.failureError,
  });

  @override
  Future<BlocxUseCaseResult<BlocxPage<TestItemEntity>>> perform(
      BlocxPaginatedInput input) async {
    if (shouldFail()) {
      throw failureError() ?? Exception('Server connection failed');
    }
    final start = input.offset.clamp(0, items.length);
    final end = (start + input.limit).clamp(0, items.length);
    return success(BlocxPage(
      items: items.sublist(start, end),
      offset: start,
      limit: input.limit,
    ));
  }
}
