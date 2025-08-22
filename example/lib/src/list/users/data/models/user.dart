import 'package:blocx/blocx.dart';

class User extends BaseEntity {
  final String image;
  final String name;
  final String username;
  final int index;

  /// [isSelected]
  /// [isBeingSelected]
  /// [isBeingRemoved]
  /// [isHighlighted] have to be added as parameters
  User({required this.image, required this.name, required this.username, required this.index});

  @override
  String get identifier => username;
}
