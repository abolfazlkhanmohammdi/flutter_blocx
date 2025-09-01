import 'dart:convert';

import 'package:blocx_core/blocx_core.dart';

class NoteTag extends BaseEntity {
  final int id;
  final int userId;
  final String name;
  final int? colorArgb;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteTag({
    required this.id,
    required this.userId,
    required this.name,
    this.colorArgb,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String get identifier => id.toString();

  NoteTag copyWith({
    int? id,
    int? userId,
    String? name,
    int? colorArgb,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteTag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'colorArgb': colorArgb,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory NoteTag.fromMap(Map<String, dynamic> map) => NoteTag(
    id: (map['id'] as num?)?.toInt() ?? -1,
    userId: (map['userId'] as num?)?.toInt() ?? -1,
    name: map['name'] as String? ?? '',
    colorArgb: map['colorArgb'] as int?,
    isArchived: map['isArchived'] as bool? ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory NoteTag.fromJson(String source) => NoteTag.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NoteTag(id:$id, userId:$userId, name:$name, archived:$isArchived)';

  @override
  bool operator ==(Object other) => other is NoteTag && other.id == id;

  @override
  int get hashCode => id.hashCode;

  static int byName(NoteTag a, NoteTag b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
  static int byUpdatedDesc(NoteTag a, NoteTag b) => b.updatedAt.compareTo(a.updatedAt);
}
