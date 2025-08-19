import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

class FakeRepository {
  final List<String> _generatedUsernames = [];
  Faker faker = Faker();
  String get uuid => Uuid().v4();
  String get uniqueUserName {
    var username = faker.internet.userName();
    int retries = 0;
    while (_generatedUsernames.contains(username) && retries < 5) {
      username = faker.internet.userName();
      retries++;
    }
    if (_generatedUsernames.contains(username)) {
      username = uuid;
    }
    _generatedUsernames.add(username);
    return username;
  }

  Future<void> get randomWaitFuture async {
    return await Future.delayed(Duration(seconds: faker.randomGenerator.integer(3, min: 1)));
  }

  String get image => faker.image.loremPicsum(
    width: faker.randomGenerator.integer(800, min: 200),
    height: faker.randomGenerator.integer(800, min: 200),
  );
  String get name => faker.person.name();
}
