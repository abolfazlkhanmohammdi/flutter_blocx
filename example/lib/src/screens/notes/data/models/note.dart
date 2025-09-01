import 'dart:convert';

import 'package:blocx_core/blocx_core.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/users/data/models/user.dart';

class Note extends BaseEntity {
  final String uuid;
  final int tagId;
  final String title;
  final String? content;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  User? user;
  NoteTag? noteTag;
  Note({
    required this.uuid,
    required this.tagId,
    required this.title,
    this.user,
    this.noteTag,
    this.content,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? uuid,
    int? tagId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      uuid: uuid ?? this.uuid,
      tagId: tagId ?? this.tagId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'tagId': tagId,
    'title': title,
    'content': content,
    'isPinned': isPinned,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
    uuid: (map['uuid'] as String?) ?? "",
    tagId: (map['tagId'] as num?)?.toInt() ?? -1,
    title: map['title'] as String? ?? '',
    content: map['content'] as String?,
    isPinned: map['isPinned'] as bool? ?? false,
    isArchived: map['isArchived'] as bool? ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String toJson() => jsonEncode(toMap());
  factory Note.fromJson(String source) => Note.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Note(uuid:$uuid, tagId:$tagId, title:"$title")';

  @override
  bool operator ==(Object other) => other is Note && other.uuid == uuid;

  @override
  int get hashCode => uuid.hashCode;

  static int byUpdatedDesc(Note a, Note b) => b.updatedAt.compareTo(a.updatedAt);
  static int byTitle(Note a, Note b) => a.title.toLowerCase().compareTo(b.title.toLowerCase());

  @override
  String get identifier => uuid.toString();
}
