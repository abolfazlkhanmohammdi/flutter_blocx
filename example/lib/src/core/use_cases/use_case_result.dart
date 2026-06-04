import 'package:blocx_core/blocx_core.dart';

class UseCaseResult<T> extends BlocxUseCaseResult<T> {
  final T? _data;
  final Object? _error;
  final StackTrace? _stackTrace;

  UseCaseResult({T? data, Object? error, StackTrace? stackTrace})
    : _data = data,
      _error = error,
      _stackTrace = stackTrace;

  @override
  T? get data => _data;

  @override
  get error => _error;

  @override
  StackTrace? get stackTrace => _stackTrace;

  factory UseCaseResult.failure(Object error, {StackTrace? stackTrace}) {
    return UseCaseResult<T>(error: error, stackTrace: stackTrace);
  }

  factory UseCaseResult.success(T data) {
    return UseCaseResult<T>(data: data);
  }
}
