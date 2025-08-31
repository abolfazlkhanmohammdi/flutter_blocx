import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

class FakeRepository {
  int _index = 1;
  Faker faker = Faker();
  String get uuid => Uuid().v4();
  int get id {
    _index++;
    return _index;
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
