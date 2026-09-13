import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/collection_bloc.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class GetUsersUseCase extends BlocxPaginatedUseCase<BlocxPaginatedInput, User> {
  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(
    BlocxPaginatedInput input,
  ) async {
    var result = await UserJsonRepository().getPaginated(
      offset: input.offset,
      limit: input.limit,
    );
    if (!result.ok) {
      throw Exception("error fetching users");
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(items: converted, input: input);
  }
}
