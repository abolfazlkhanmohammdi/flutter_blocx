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

  FakeCollectionBloc({this.initialItems = const []}) : super();

  @override
  BlocxPaginatedUseCaseTask<BlocxPaginatedInput, TestItemEntity>?
      get paginationTask => BlocxPaginatedUseCaseTask(
            useCase: _FakePaginatedUseCase(initialItems),
            inputBuilder: (offset, limit) =>
                BlocxPaginatedInput(offset: offset, limit: limit),
          );
}

class _FakePaginatedUseCase
    extends BlocxPaginatedUseCase<BlocxPaginatedInput, TestItemEntity> {
  final List<TestItemEntity> items;

  _FakePaginatedUseCase(this.items);

  @override
  Future<BlocxUseCaseResult<BlocxPage<TestItemEntity>>> perform(
      BlocxPaginatedInput input) async {
    final start = input.offset.clamp(0, items.length);
    final end = (start + input.limit).clamp(0, items.length);
    return success(BlocxPage(
      items: items.sublist(start, end),
      offset: start,
      limit: input.limit,
    ));
  }
}
