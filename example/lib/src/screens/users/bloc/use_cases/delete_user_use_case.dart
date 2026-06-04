import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:example/src/screens/users/data/repositories/users_repository.dart';

class DeleteUserUseCase extends BlocxBaseUseCase<User, bool> {
  @override
  Future<BlocxUseCaseResult<bool>> perform(User input) async {
    await UserJsonRepository().delete(input.id);
    return success(true);
  }
}
