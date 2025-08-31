import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class UseCaseGetUsers extends PaginationUseCase<User, dynamic> {
  UseCaseGetUsers({required super.queryInput});
  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().getPaginated(
      offset: queryInput.offset,
      limit: queryInput.loadCount,
    );
    if (!result.ok) {
      throw StateError("error fetching users");
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}
