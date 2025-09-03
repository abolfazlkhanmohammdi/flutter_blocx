import 'dart:convert';

import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class Note extends BaseEntity {
  final String uuid;
  final int tagId;
  final int? userId; // ← new: user id
  final String title;
  final String? content;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional hydrated refs (not required for persistence)
  final User? user; // ← new: embedded user
  final NoteTag? noteTag; // ← new: embedded tag

  Note({
    required this.uuid,
    required this.tagId,
    this.userId,
    required this.title,
    this.content,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.noteTag,
  });

  Note copyWith({
    String? uuid,
    int? tagId,
    int? userId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    NoteTag? noteTag,
  }) {
    return Note(
      uuid: uuid ?? this.uuid,
      tagId: tagId ?? this.tagId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      noteTag: noteTag ?? this.noteTag,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'tagId': tagId,
    'userId': userId ?? user?.id, // keep id even if object is present
    'title': title,
    'content': content,
    'isPinned': isPinned,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (user != null) 'user': user!.toMap(), // assumes User.toMap()
    if (noteTag != null) 'noteTag': noteTag!.toMap(), // assumes NoteTag.toMap()
  };

  factory Note.fromMap(Map<String, dynamic> map) {
    // Read ids directly; fall back to nested maps if present
    final int parsedTagId =
        (map['tagId'] as num?)?.toInt() ??
        (map['noteTag'] is Map ? (map['noteTag']['id'] as num?)?.toInt() : null) ??
        -1;

    final int? parsedUserId =
        (map['userId'] as num?)?.toInt() ??
        (map['user'] is Map ? (map['user']['id'] as num?)?.toInt() : null);

    // Hydrate nested models if provided
    final User? u = map['user'] is Map<String, dynamic>
        ? User.fromMap(map['user'] as Map<String, dynamic>)
        : null;
    final NoteTag? t = map['noteTag'] is Map<String, dynamic>
        ? NoteTag.fromMap(map['noteTag'] as Map<String, dynamic>)
        : null;

    return Note(
      uuid: (map['uuid'] as String?) ?? '',
      tagId: parsedTagId,
      userId: parsedUserId,
      title: map['title'] as String? ?? '',
      content: map['content'] as String?,
      isPinned: map['isPinned'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      user: u,
      noteTag: t,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Note.fromJson(String source) => Note.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Note(uuid:$uuid, tagId:$tagId, userId:$userId, title:"$title")';

  @override
  bool operator ==(Object other) => other is Note && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;

  static int byUpdatedDesc(Note a, Note b) => b.updatedAt.compareTo(a.updatedAt);
  static int byTitle(Note a, Note b) => a.title.toLowerCase().compareTo(b.title.toLowerCase());

  @override
  String get identifier => uuid;
}
