import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter_example/src/list/users/data/models/user.dart';
import 'package:blocx_flutter_example/src/list/users/data/user_repository.dart';

class UseCaseSearchUsers extends SearchUseCase<User, dynamic> {
  UserRepository repository = UserRepository();
  UseCaseSearchUsers({required super.searchQuery});

  @override
  Future<UseCaseResult<Page<User>>> perform() async {
    var result = await repository.searchUsers(searchQuery.searchText);
    return successResult(result);
  }
}
