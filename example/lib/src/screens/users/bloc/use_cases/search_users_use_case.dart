import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_core/list_bloc.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class SearchUsersUseCase extends BlocxSearchUseCase<SearchUsersInput, User> {
  @override
  Future<BlocxUseCaseResult<BlocxPage<User>>> perform(SearchUsersInput input) async {
    var result = await UserJsonRepository().searchUsers(input.searchText, input.offset, input.limit);
    if (!result.ok) {
      throw Exception('Failed to search users');
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(items: converted, input: input);
  }
}

class SearchUsersInput extends BlocxSearchInput {
  SearchUsersInput({required super.searchText, required super.limit, required super.offset});
}
