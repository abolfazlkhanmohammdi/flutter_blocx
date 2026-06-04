import 'dart:async';

import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';

abstract class BaseSearchUseCase<Input extends BlocxSearchInput, Output extends BlocxBaseEntity>
    extends BlocxSearchUseCase<Input, Output> {
  @override
  FutureOr<BlocxUseCaseResult<BlocxPage<Output>>> failureResult(Object error, StackTrace stackTrace) {
    return UseCaseResult.failure(error, stackTrace: stackTrace);
  }

  @override
  Future<UseCaseResult<BlocxPage<Output>>> perform(Input input);

  @override
  UseCaseResult<BlocxPage<Output>> successResult({
    required List<Output> items,
    required BlocxPaginationInput input,
  }) {
    return UseCaseResult(
      data: BlocxPage(items: items, offset: input.offset, loadCount: input.limit),
    );
  }
}
