// lib/models/note_tag.dart
import 'dart:convert';
import 'package:blocx_core/blocx_core.dart';

/// Tag for grouping/colouring notes.
class NoteTag extends BaseEntity {
  final String id; // unique stable id (e.g., UUID, db id)
  final String name; // display name: "Work", "Ideas", ...
  final int? colorArgb; // optional ARGB int, e.g., 0xFFFFA000
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteTag({
    required this.id,
    required this.name,
    this.colorArgb,
    required this.createdAt,
    required this.updatedAt,
  });

  /// `identifier` powers your list/grid keys & equality checks.
  @override
  String get identifier => id;

  NoteTag copyWith({
    String? id,
    String? name,
    int? colorArgb,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteTag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorArgb': colorArgb,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory NoteTag.fromMap(Map<String, dynamic> map) => NoteTag(
    id: (map['id'] as String?) ?? '',
    name: (map['name'] as String?) ?? '',
    colorArgb: map['colorArgb'] as int?,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory NoteTag.fromJson(String source) => NoteTag.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NoteTag(id:$id, name:$name)';

  @override
  bool operator ==(Object other) => other is NoteTag && other.id == id;
  @override
  int get hashCode => id.hashCode;

  // Handy comparators for sorting
  static int byName(NoteTag a, NoteTag b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
  static int byUpdatedDesc(NoteTag a, NoteTag b) => b.updatedAt.compareTo(a.updatedAt);
}
