import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class UseCaseSearchUsers extends SearchUseCase<User> {
  UseCaseSearchUsers({required super.searchText, required super.loadCount, required super.offset});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await UserJsonRepository().searchUsers(searchText, offset, loadCount);
    if (!result.ok) {
      throw StateError('Failed to search users');
    }
    var converted = result.data.map((e) => User.fromMap(e)).toList();
    return successResult(converted);
  }
}
