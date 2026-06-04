import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/core/use_cases/use_case_result.dart';

abstract class BaseUseCase<Input, Output> extends BlocxBaseUseCase<Input, Output> {
  @override
  Future<BlocxUseCaseResult<Output>> failureResult(Object error, StackTrace stackTrace) {
    return Future.value(UseCaseResult<Output>(error: error, stackTrace: stackTrace));
  }
}
