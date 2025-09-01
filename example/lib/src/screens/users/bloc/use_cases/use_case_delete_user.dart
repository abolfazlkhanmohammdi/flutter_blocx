import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class UseCaseDeleteUser extends BaseUseCase<bool> {
  final User user;

  UseCaseDeleteUser({required this.user});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await UserJsonRepository().delete(user.id);
    return UseCaseResult.success(result.ok);
  }
}
