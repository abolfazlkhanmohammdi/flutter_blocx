import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter_example/src/list/users/data/models/user.dart';
import 'package:blocx_flutter_example/src/list/users/data/user_repository.dart';

class UseCaseRefreshUsers extends PaginationUseCase<User, dynamic> {
  var repository = UserRepository();

  UseCaseRefreshUsers({required super.queryInput});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await repository.refreshUsers(queryInput.loadCount, queryInput.offset);
    return successResult(result);
  }
}
