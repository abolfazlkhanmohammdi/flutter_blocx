import 'package:flutter_blocx_example/src/core/fake_repository.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class UserRepository extends FakeRepository {
  int index = 0;
  final List<User> allUsers = [];

  Future<List<User>> getUsers(int loadCount, int offset) async {
    await randomWaitFuture;
    var users = List.generate(loadCount, (index) => generateUser());
    return users;
  }

  User generateUser() {
    index++;
    var user = User(image: image, name: name, username: uniqueUserName, index: index);
    allUsers.add(user);
    return user;
  }
}
