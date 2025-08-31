// lib/models/note.dart
import 'dart:convert';

import 'package:blocx_core/blocx_core.dart';

class Note extends BaseEntity {
  final int? id;

  /// Short title used in lists & search.
  final String title;

  /// Optional body text.
  final String? content;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last modification timestamp.
  final DateTime updatedAt;

  Note({this.id, required this.title, this.content, required this.createdAt, required this.updatedAt});

  /// Convenience factory for a brand-new note (unpersisted).
  factory Note.newNote({required String title, String? content, bool isPinned = false}) {
    final now = DateTime.now();
    return Note(id: null, title: title, content: content, createdAt: now, updatedAt: now);
  }

  /// Returns a copy with selected fields changed.
  Note copyWith({
    int? id,
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isNew => id == null;

  // ---------- Serialization (no 3P deps) ----------

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
    id: (map['id'] as num?)?.toInt(),
    title: map['title'] as String? ?? '',
    content: map['content'] as String?,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory Note.fromJson(String source) => Note.fromMap(jsonDecode(source) as Map<String, dynamic>);

  // ---------- Equality & debugging ----------

  @override
  String toString() => 'Note(id:$id, title:"$title"';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id != null && other.id != null && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String get identifier => id!.toString();
}
