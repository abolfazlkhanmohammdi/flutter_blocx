import 'package:blocx/blocx.dart';

class User extends ListEntity<User> {
  final String image;
  final String name;
  final String username;
  final int index;

  /// [isSelected]
  /// [isBeingSelected]
  /// [isBeingRemoved]
  /// [isHighlighted] have to be added as parameters
  User({
    super.isBeingRemoved,
    super.isBeingSelected,
    super.isHighlighted,
    super.isSelected,
    required this.image,
    required this.name,
    required this.username,
    required this.index,
  });

  @override
  User copyWithListFlags({
    /// [isSelected]
    /// [isBeingSelected]
    /// [isBeingRemoved]
    /// [isHighlighted] are mandatory
    bool? isSelected,
    bool? isBeingSelected,
    bool? isBeingRemoved,
    bool? isHighlighted,

    /// domain-specific
    String? name,
    String? username,
    String? image,
    int? index,
  }) {
    return User(
      // flags from ListEntity
      isSelected: isSelected ?? this.isSelected,
      isBeingSelected: isBeingSelected ?? this.isBeingSelected,
      isBeingRemoved: isBeingRemoved ?? this.isBeingRemoved,
      isHighlighted: isHighlighted ?? this.isHighlighted,

      // your own fields
      name: name ?? this.name,
      username: username ?? this.username,
      image: image ?? this.image,
      index: index ?? this.index,
    );
  }

  @override
  String get identifier => username;
}
