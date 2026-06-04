import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class GetUsersUseCase extends BlocxPaginatedUseCase<BlocxPaginationInput, User> {
  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(BlocxPaginationInput input) async {
    var result = await UserJsonRepository().getPaginated(offset: input.offset, limit: input.limit);
    if (!result.ok) {
      throw Exception("error fetching users");
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(items: converted, input: input);
  }
}
