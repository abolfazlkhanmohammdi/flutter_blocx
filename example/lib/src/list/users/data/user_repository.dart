import 'package:flutter_blocx_example/src/core/fake_repository.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class UserRepository extends FakeRepository {
  int index = 0;
  static List<User> _allUsers = [];

  Future<List<User>> getUsers(int loadCount, int offset) async {
    await randomWaitFuture;
    var hasUsers = _allUsers.length >= offset + loadCount;
    var count = hasUsers ? 0 : offset + loadCount - _allUsers.length;
    var users = hasUsers
        ? _allUsers.sublist(offset, offset + loadCount)
        : List.generate(count, (index) => generateUser());
    return users;
  }

  Future<List<User>> refreshUsers(int loadCount, int offset) async {
    await randomWaitFuture;
    return _allUsers;
  }

  User generateUser() {
    index++;
    var user = User(image: image, name: name, username: uniqueUserName, index: index);
    _allUsers.add(user);
    return user;
  }

  Future<List<User>> searchUsers(String searchText) async {
    await randomWaitFuture;
    var searchResult = _allUsers.where((e) {
      var usernameMatch = e.username.toLowerCase().contains(searchText.toLowerCase());
      var nameMatch = e.name.toLowerCase().contains(searchText.toLowerCase());
      return usernameMatch || nameMatch;
    });
    return searchResult.toList();
  }
}
