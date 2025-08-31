// lib/models/user_entity.dart
import 'dart:convert';
import 'package:blocx_core/blocx_core.dart';

/// Minimal user profile usable across data layers.
class User extends BaseEntity {
  final int id; // unique stable id
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String get identifier => id.toString();

  User copyWith({
    int? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'avatarUrl': avatarUrl,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: (map['id'] as int?) ?? -1,
    displayName: (map['displayName'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    avatarUrl: map['avatarUrl'] as String?,
    isActive: (map['isActive'] as bool?) ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory User.fromJson(String source) => User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserEntity(id:$id, name:$displayName)';

  @override
  bool operator ==(Object other) => other is User && other.id == id;
  @override
  int get hashCode => id.hashCode;

  // Handy comparators (e.g., for lists)
  static int byName(User a, User b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  static int byUpdatedDesc(User a, User b) => b.updatedAt.compareTo(a.updatedAt);
}
