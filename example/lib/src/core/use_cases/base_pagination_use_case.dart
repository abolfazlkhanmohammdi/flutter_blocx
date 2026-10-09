import 'dart:async';

import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';

abstract class BasePaginationUseCase<
  Input extends BlocxPaginatedInput,
  Output extends BlocxBaseEntity
>
    extends BlocxPaginatedUseCase<Input, Output> {
  @override
  UseCaseResult<BlocxPage<Output>> successResult({
    required List<Output> items,
    required BlocxPaginatedInput input,
  }) {
    return UseCaseResult.success(
      BlocxPage(items: items, offset: input.offset, limit: input.limit),
    );
  }

  @override
  FutureOr<BlocxUseCaseResult<BlocxPage<Output>>> failureResult(
    Object error,
    StackTrace stackTrace,
  ) {
    return UseCaseResult<BlocxPage<Output>>.failure(
      error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<UseCaseResult<BlocxPage<Output>>> perform(Input input);
}
