import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class GetUsersUseCase extends PaginationUseCase<User, dynamic> {
  GetUsersUseCase({required super.loadCount, required super.offset});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().getPaginated(offset: offset, limit: loadCount);
    if (!result.ok) {
      throw Exception("error fetching users");
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}
