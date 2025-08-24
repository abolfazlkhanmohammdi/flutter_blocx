import 'package:blocx/blocx.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';
import 'package:flutter_blocx_example/src/list/users/data/user_repository.dart';

class UseCaseGetUsers extends PaginationUseCase<User, dynamic> {
  UserRepository repository = UserRepository();

  UseCaseGetUsers({required super.queryInput});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await repository.getUsers(queryInput.loadCount, queryInput.offset);
    return successResult(result);
  }
}
