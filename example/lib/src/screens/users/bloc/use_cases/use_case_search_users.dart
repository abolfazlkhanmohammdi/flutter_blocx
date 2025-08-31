import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class UseCaseSearchUsers extends SearchUseCase<User, String> {
  UseCaseSearchUsers({required super.searchQuery});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().searchUsers(
      searchQuery.searchText,
      searchQuery.offset,
      searchQuery.loadCount,
    );
    if (!result.ok) {
      throw StateError('Failed to search users');
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}
